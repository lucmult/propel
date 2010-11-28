// Circuito básico, somente liga e desliga
// Próximo passo, conseguir mudar a intensidade da lâmpada

int last_in;
int estado;
int current;

void setup() {                
  pinMode(13, OUTPUT);    
  pinMode(9, OUTPUT);     
  pinMode(12, INPUT);     
  digitalWrite(12, HIGH);
  estado = 0;
  last_in = 0;
}

void loop() {
  current = digitalRead(12);
  
  if (last_in != current && last_in == HIGH){
    estado = !estado; 
    digitalWrite(13, estado);   
    digitalWrite(9, estado);   
  }
  

  last_in = current;
  delay(10);              // wait for a second
}
