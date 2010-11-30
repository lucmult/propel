


#define TRIAC 9
#define SWITCH 12
#define DEBUG 13

#define CLICK_LIMIT 500
#define MINTRIGGER 600
/* 7500 parecia o ideal, mas 7000 não chega a desligar a lampada, 
   deixando a luz bem fraca, sabendo que não está desligada
*/
#define MAXTRIGGER 7000
#define FACTOR 255

// variaveis do estado da chave
int current_state = 1;
int last_state = 1;
int timing;
int click_start;

// variaveis de tempo de interrupcao
volatile int last_zero = 0;

int now = 0;
int last_update = 0;


// variaveis do estado do triac
int power = 0;
int rate = 0;
int count = 0;
int trigger = MAXTRIGGER;
int swing = 1;


void setup(){
  // habilita pinos de chave e triac
  pinMode(DEBUG, OUTPUT);
  pinMode(TRIAC, OUTPUT);
  pinMode(SWITCH, INPUT);
  
  // habilita resistor de pull-up da chave
  digitalWrite(SWITCH, HIGH);
  
  // conecta interrupcao ao zero-cross detector
  attachInterrupt(0, zeroed, RISING);
  
}



void loop(){
  // faz todo o trabalho
  now = micros();
  
  // atualiza o triac assincronamente
  // se está ligado, se ainda não atualizamos nessa passagem pelo zero, 
  // se agora já é depois do tempo mínimo de gatilho, dispara
  if (power && last_zero && now - last_zero >= trigger){
    digitalWrite(TRIAC, HIGH);
    last_zero = 0;
  }
  
  // atualiza a cada 5ms
  if (now - last_update < 5000){
    return;
  }
  
  current_state = digitalRead(SWITCH);

  digitalWrite(DEBUG, power);
  
  // se a chave foi acionada nesse ciclo, marca o tempo, memoriza estado, 
  // inverte swing e retorna
  if (last_state != current_state && !current_state){
    click_start = millis();
    last_state = current_state;
    swing = -swing;
    return;
  }  

  // dependendo do tempo, entramos no modo on/off ou dimmer
  timing = millis() - click_start;

  // se a chave foi solta nesse ciclo, adotamos ação de acordo com o tempo
  if (last_state != current_state && current_state){
    // se pulso rápido, modo on/off
    if (timing < CLICK_LIMIT){
      // modo on/off, alterna estado
      power = !power;
    }    
    
  }

  // se a chave está sendo segurada, adota ação de acordo com o tempo e estado
  if (last_state == current_state && ! current_state){
    if (timing >= CLICK_LIMIT){
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
      // limita o ciclo aos valores minimo e maximo
      trigger = map(rate, 0, FACTOR, MAXTRIGGER, MINTRIGGER);        
    }    
  }    
  
  // memoriza estado
  last_state = current_state;
  

  // delay saudável
  //delay(5);
  last_update = now;
  
}
 
 
void zeroed(){
 // desliga o triac na passagem pelo zero
 digitalWrite(TRIAC, LOW);
 // marca o tempo da passagem;
 last_zero = micros();
}
  
