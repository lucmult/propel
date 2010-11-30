


#define TRIAC 9
#define SWITCH 12
#define DEBUG 13

#define CLICK_LIMIT 500
#define MINTRIGGER 600
#define MAXTRIGGER 7300


// variaveis do estado da chave
int current_state = 1;
int last_state = 1;
int timing;
int click_start;

// variaveis de tempo de interrupcao
int now = 0;
int last_zero = 0;


// variaveis do estado do triac
int factor = 255;
int power = 0;
int rate = 0;
int trigger = MAXTRIGGER;
int zero;
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
        rate = constrain(rate, 0, factor);

        if (rate == factor)
          swing = -1;
        
        if (rate == 0)
          swing = 1;
           
      } else {
        // caso contrario, liga
        power = 1;
        rate = 0;
      }
      // limita o ciclo aos valores minimo e maximo
      trigger = map(rate, 0, factor, MAXTRIGGER, MINTRIGGER);        
    }    
  }    
  
  // memoriza estado
  last_state = current_state;
  

  // delay saudável
  delay(5);
}
  
 
void zeroed(){
  //now = micros();
  //if (now - last_zero < 6000){
  //  return;
  //}
  
  if (power){
    // aguarda o ponto certo da onda para disparar
    delayMicroseconds(trigger);
    // dispara o pulso de 10us
    digitalWrite(TRIAC, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIAC, LOW);
    // reseta a flag do zero cross
  }
  //last_zero = now;
}
  
  
  
