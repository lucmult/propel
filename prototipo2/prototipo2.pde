// Brincando com a tamanho da onda da corrente A/C
// CONCLUSÃO: Sem chance, sem o Zero cross detector

void setup() {                
  pinMode(13, OUTPUT);    
  pinMode(9, OUTPUT);     
  //pinMode(12, INPUT);     
  //digitalWrite(12, HIGH);
  //estado = 0;
  //last_in = 0;
}



void loop() {
  delayMicroseconds(7275);              
  digitalWrite(9, HIGH);   
  delayMicroseconds(1000);
  digitalWrite(9, LOW);  
}
