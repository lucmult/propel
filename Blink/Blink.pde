/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */

int tempo = 20;
int pino = 5;
void setup() {                
  // initialize the digital pin as an output.
  // Pin 13 has an LED connected on most Arduino boards:
  pinMode(pino, OUTPUT);     
}

void loop() {
  digitalWrite(pino, HIGH);   // set the LED on
  delay(tempo);              // wait for a second
  digitalWrite(pino, LOW);    // set the LED off
  delay(tempo);              // wait for a second
}
