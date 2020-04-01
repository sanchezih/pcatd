/*
  Base code for ArdSimX Library.

  Download ARDsimX Library on the SimVimDesign website:
  http://svglobe.com
*/


//================================
#include <ArdSimX_Interface.h>          //  -- ArdSimX library 
//================================


//------------------------------------------
void setup()  {
  BoardNumber 3;            // -- Assign Board Number here  (0...9)
}

//------------------------------------------
void loop()   {

  ArdSimScan;               // main loop  - scan inputs and read incoming data for output

}
//===========================================

void ProgOut(byte id, float val) {

  if (id == 1) {  }
  else if (id == 2 && val > 0) {    } //example

  //.. etc., or use "case"

}
