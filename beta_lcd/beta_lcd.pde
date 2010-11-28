/*
Primeira brincadeira com o LCD  
 */
#include <LiquidCrystal.h>

int contraste = 3;  // VO 
int rs = 4;  // RS
int rw = 5;  // R/W
int enable = 6;  // E (Enable signal)

int d4 = 8;  // db 4
int d5 = 9;  // db 5
int d6 = 10; // db 6
int d7 = 11; // db 7

int serial = A0;
char letra;
LiquidCrystal lcd(rs, rw, enable, d4, d5, d6, d7) ;
void setup() {
  // set up the LCD's number of columns and rows: 
  lcd.begin(16, 2);
  // Print a message to the LCD.
  lcd.print("1234567890123456");
  lcd.setCursor(0, 1);
  lcd.print("luciano muniz pacheco");
}

void loop() {
  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
  lcd.setCursor(0, 1);
  // print the number of seconds since reset:
  lcd.print(millis()/1000);
}

/*
void setup()  { 
  Serial.begin(19200);
  lcd.noAutoscroll();
  lcd.print("Hello World!");
  analogWrite(serial, -1);
}

void loop()  { 
  / * if (Serial.available()) {
    letra = Serial.read();
    lcd.print(letra);
  }else{
    delay(2000);
    lcd.clear();
   } * /
   lcd.print("Hello World!");
  delay(30);
  
}*/

