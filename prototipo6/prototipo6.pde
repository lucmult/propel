

#define TRIAC 9
#define SWITCH 12
#define DEBUG 13

#define MAX_CLICK 300
#define MIN_CLICK 10

// o disparo é feito em (256 - trigger) * 64us
#define MIN_TRIGGER 139 
#define MAX_TRIGGER 255
#define FACTOR 255

// variaveis do estado da chave
int current_state = 1;
int last_state = 1;
int timing;
int click_start;

// variaveis de tempo de interrupcao
int now = 0;
int last_update = 0;
int last_switch = 0;


// variaveis do estado do triac
int power = 0; // inicia desligado
int rate = 64; // inicia com 1/4 da luz
unsigned int trigger; 
int swing = 1;



void setup(){
  // habilita pinos de chave e triac
  pinMode(DEBUG, OUTPUT);
  pinMode(TRIAC, OUTPUT);
  pinMode(SWITCH, INPUT);
  
  // habilita resistor de pull-up da chave
  digitalWrite(SWITCH, HIGH);
  digitalWrite(TRIAC, LOW);  
  
  // conecta interrupcao ao zero-cross detector
  attachInterrupt(0, zeroed, RISING);  

  // configura timer2  

  // primeiro, desabilita o timer enquanto configuramos
  TIMSK2 &= ~(1<<TOIE2); 
  
  // coloca o timer em modo de contagem simples, sem pwm
  TCCR2A &= ~((1<<WGM21) | (1<<WGM20));  
  TCCR2B &= ~(1<<WGM22); 
  
  // seleciona o clock interno
  ASSR &= ~(1<<AS2);
  
  // desabilita comparacao, deixando apenas overflow
  TIMSK2 &= ~(1<<OCIE2A);
  
  // configura o pré-escalador para 16mhz / 1024
  TCCR2B |= (1<<CS22)  | (1<<CS21) | (1<<CS20); 

  // delay será de trigger * 64us
  setTrigger();
   
  // carrega a taxa atual e inicia o timer
  TCNT2 = trigger;  

  TIMSK2 |= (1<<TOIE2);

}

   

void loop(){
  // inicializa variáveis usadas no loop
  digitalWrite(DEBUG, power);
  current_state = digitalRead(SWITCH);
  now = millis();
  
  // se houve mudança de estado da chave, verifica o tempo
  if (last_state != current_state){
    timing = now - last_switch;
    last_switch = now;
    // se tempo abaixo do mínimo, ignora
    if (timing < MIN_CLICK){
      return;
    }
  }

  // se a chave foi acionada nesse ciclo, marca o tempo, memoriza estado, 
  // inverte swing e retorna
  if (last_state != current_state && !current_state){
    click_start = now;
    last_state = current_state;
    swing = -swing;
    return;
  }  

  // dependendo do tempo, entramos no modo on/off ou dimmer
  timing = now - click_start;
  
  // se a chave foi solta nesse ciclo, adotamos ação de acordo com o tempo
  if (last_state != current_state && current_state){
    // se pulso rápido, modo on/off
    if (timing < MAX_CLICK){
      // modo on/off, alterna estado
      power = !power;
    }    
  }

  // se a chave está sendo segurada, adota ação de acordo com o tempo e estado
  if (last_state == current_state && ! current_state){
    if (timing >= MAX_CLICK){
      // se ligado, dimmeriza
      if (power){
        // modo dimmer      
        rate += swing;
        // restringe rate a valor entre 0 e 255   
        rate = constrain(rate, 0, FACTOR);
        
        if (rate == FACTOR){
          swing = -1;
        }
        
        if (rate == 0){
          swing = 1;
        }
           
      } else {
        // caso contrario, liga
        power = 1;
        rate = 0;
      }
    }    
  }    
  
  // atualiza o ciclo
  setTrigger();

  // memoriza estado
  last_state = current_state;  

  // memoriza a hora da ultima atualizacao
  delay(5);
  
}
 
 
void setTrigger(){
   trigger = map(rate, 0, FACTOR, MIN_TRIGGER, MAX_TRIGGER);
}
 

// interrupcao do zero cross detector 
void zeroed(){
  // desliga o triac na passagem pelo zero
  digitalWrite(TRIAC, LOW);
  // zera o contador
  TCNT2 = trigger;
  // reinicia o timer
  TIMSK2 |= (1<<TOIE2);
}

// interrupcao do timer
ISR(TIMER2_OVF_vect) {  
  // quando disparada, desativa o timer
  TIMSK2 &= ~(1<<TOIE2);
  // dispara o triac
  if (power){
    digitalWrite(TRIAC, HIGH);
  }
}

