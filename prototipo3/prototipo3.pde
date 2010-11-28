// Brincando de acertar o tamanho da corrent com o zero cross detector
// colocamos um interrupção para "ouvir" o zero cross detector
// a cada 50 50 detectados vamos trocar o estado do led do pino 13

int pin = 13;
volatile int state = LOW;
float count;
int zerou;
char c;
float amount;
int current =1;
int maxval = 7600;
int minval = 500;
int click_interval = 1000;
int click_start = 0;
int last_state = 1;
int tempo;
int ligado;
    
void setup()
{
  pinMode(pin, OUTPUT);
  pinMode(9, OUTPUT);  
  pinMode(12, INPUT);
  digitalWrite(12, HIGH);
  attachInterrupt(0, counter, RISING);
  count = maxval;
  zerou = 0;
  Serial.begin(9600);
  amount = -0.2;
  current = 0;
  ligado=0;
}

void loop(){
 
  current = digitalRead(12);  

  if ((last_state) && (!current)){
       click_start = millis();
       last_state = current;
       return;
  }

  
  tempo = millis() - click_start;
  
  if (tempo < click_interval){
    // modo on-off
    ligado = !ligado;
    
  } else {
    // modo dimmer
     
     if (!ligado){
       count = maxval;
       ligado = true;
     }
      if (!last_state) {
         count += amount;
      }
      if (count >= maxval || count <= minval) {
        amount = -amount;
      }  
    
  }
  
  
  if ((!current) && last_state) {
    Serial.println(tempo);
  }
  if (current && !last_state) {
     Serial.println(tempo);
     Serial.println(ligado);
     Serial.println(count);
     Serial.println("---");
  } 
  
  //delay(10);
  last_state = current;
}


void dimmer(){
  count = constrain(count, minval, maxval);
  
  if (zerou) {
    if (ligado) {
      delayMicroseconds(count);
      digitalWrite(9, HIGH);
      delayMicroseconds(1);
      digitalWrite(9, LOW);
          
     zerou = 0;
    } 
  }
  
}


void counter()
{
  //count++;
  
  zerou=1;
}



