

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

// flags do timer2
unsigned int tcnt2;
int toggle = 1;


void setup(){
  // habilita pinos de chave e triac
  pinMode(DEBUG, OUTPUT);
  pinMode(TRIAC, OUTPUT);
  pinMode(SWITCH, INPUT);
  
  // habilita resistor de pull-up da chave
  digitalWrite(SWITCH, HIGH);
  
  digitalWrite(DEBUG, toggle);
  
  // conecta interrupcao ao zero-cross detector
  attachInterrupt(0, zeroed, RISING);  

  // configura timer2  

  // primeiro, desabilita enquanto configuramos
  TIMSK2 &= ~(1<<TOIE2); 
  
  // configura em modo normal
  TCCR2A &= ~((1<<WGM21) | (1<<WGM20));  
  TCCR2B &= ~(1<<WGM22); 
  
  // seleciona clock interno
  ASSR &= ~(1<<AS2);
  
  // desabilita comparacao (queremos só overflow)
  TIMSK2 &= ~(1<<OCIE2A);
  
  // configura o pré-escalador para 16mhz / 128
  TCCR2B |= (1<<CS22)  | (1<<CS20); // Set bits  
  TCCR2B &= ~(1<<CS21);             // Clear bit
  
 /* We need to calculate a proper value to load the timer counter. 
  * The following loads the value 131 into the Timer 2 counter register 
  * The math behind this is: 
  * (CPU frequency) / (prescaler value) = 125000 Hz = 8us. 
  * (desired period) / 8us = 125. 
  * MAX(uint8) + 1 - 125 = 131; 
  */  

  // Save value globally for later reload in ISR */  
  tcnt2 = 1;   
   
  // Finally load end enable the timer */  
  TCNT2 = tcnt2;  
  TIMSK2 |= (1<<TOIE2);

}

   
 /* 
  * Install the Interrupt Service Routine (ISR) for Timer2 overflow. 
  * This is normally done by writing the address of the ISR in the 
  * interrupt vector table but conveniently done by using ISR()  */  
ISR(TIMER2_OVF_vect) {  
  /* Reload the timer */  
   //TCNT2 = tcnt2;  
   /* Write to a digital pin so that we can confirm our timer */  
   toggle = ~toggle;  
   digitalWrite(DEBUG, toggle);  
} 



void loop(){
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
  delay(5);  
}
 
 
void zeroed(){
 // desliga o triac na passagem pelo zero
 digitalWrite(TRIAC, LOW);
}

void trigger_triac(){
  if (power){
    digitalWrite(TRIAC, HIGH);
  }
}

  
