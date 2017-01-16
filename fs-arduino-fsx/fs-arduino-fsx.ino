#include "math.h"
#include "Quadrature.h"
#include <LiquidCrystal.h>

void setup() {

}

void loop() {

}

char getChar() // Get a character from the serial buffer
{
  while (Serial.available() == 0); // wait for data
  return ((char)Serial.read());
}
