


#define TRIAC 9
#define SWITCH 12
#define DEBUG 13

// variaveis do estado da chave
int current_state = 1;
int last_state = 1;
int timing;
int click_interval = 500;
int click_start;

// variaveis do estado do triac
int power = 0;
int rate = 0;
int trigger = 0;
int zero;
int mintrigger = 600;
int maxtrigger = 7000;
int factor = 200;
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
  
  // inicia porta serial
  Serial.begin(9600);
}



void loop(){
  current_state = digitalRead(SWITCH);

  digitalWrite(DEBUG, power);
  
  // se a chave foi acionada nesse ciclo, marque o tempo e retorne
  if (last_state != current_state && !current_state){
    click_start = millis();
    last_state = current_state;
    return;
  }  

  // dependendo do tempo, entramos no modo on/off ou dimmer
  timing = millis() - click_start;

  // se a chave foi solta nesse ciclo, adotamos ação de acordo com o tempo
  if (last_state != current_state && current_state){
    // se pulso rápido, modo on/off
    if (timing < click_interval){
      // modo on/off, alterna estado
      power = !power;    
    }  
  }

  // se a chave está sendo segurada, adota ação de acordo com o tempo e estado
  if (last_state == current_state && ! current_state){
    if (timing >= click_interval){
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
    }
  }    


  last_state = current_state;
  
  
  // limita o ciclo aos valores minimo e maximo
  trigger = map(rate, 0, factor, maxtrigger, mintrigger);  
}
  
 
void zeroed(){
  if (power){
    // aguarda o ponto certo da onda para disparar
    delayMicroseconds(trigger);
    // dispara o pulso de 1us
    digitalWrite(TRIAC, HIGH);
    delayMicroseconds(1);
    digitalWrite(TRIAC, LOW);
    // reseta a flag do zero cross
    //zero = 0;
  }
  // sinaliza que a rede passou pelo zero
  //zero = 1;

}
  
  
  
