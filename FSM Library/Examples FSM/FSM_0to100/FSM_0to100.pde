 // -------------------------------------------------------------------------------------
// SECUduino: Chrono 0 to 100 kph
// By Igor Real
// 22/10/2011
// -------------------------------------------------------------------------------------

#include <FSM.h>
#include <LiquidCrystal.h>
#include <CAN.h>
#include "myStates.h"

#define delayShowData  7000

//VARIABLES
unsigned char myEvent;
char myByteRec;
unsigned long my0to100;
unsigned long t0;
unsigned long t_prev;
float Speed;
char bUpdateLCD;

LiquidCrystal LCD(13,12, 11, 10, 9, 8, 7);

void setup()
{
  
  LCD.begin(20,4);
  bUpdateLCD=1;
  func1();  //Print Initial screen
  
  CAN.begin(100);
  uint16_t  Filters[6];
  uint16_t Masks[2];
  Masks[0]=0x3FF;
  Masks[1]=0x3FF;
  Filters[0]=0x351;  //Buffer0
  Filters[2]=0x351;  //Buffer1
  CAN.SetFilters(Filters,Masks);  //Only messages with ID=0x351 are allowed in both Rx buffers
  
  FSM.begin(FSM_NextState,nStateMachine,FSM_State,nStateFcn,STATE1);
}

void loop()
{
  ReadEvents();
  FSM.Update();
}


void ReadEvents(void)
{
  
  if (CAN.CheckNew() )
  {
    CAN.ReadFromDevice(&CAN_RxMsg);
    Speed=0.005*(256*CAN_RxMsg.data[2]+CAN_RxMsg.data[1]);
    //Speed=CAN_RxMsg.data[0];
    LCD.setCursor(0,1);
    LCD.print("Speed= ");
    LCD.print((int)Speed);
  }
  
  if (Speed<=0){
    FSM.AddEvent(EV_Stop);
  }else if (Speed>=100){
    FSM.AddEvent(EV_100);
  }else if ( (Speed>0) && (Speed<100) ){
    FSM.AddEvent(EV_Start);    
  }
  
}

void func1(void)
{
  if (bUpdateLCD)
  {  
    LCD.clear();
    LCD.setCursor(0,0);
    LCD.print("  *- SECUduino -*");
  
    LCD.setCursor(0,2);
    LCD.print("State 1");
    
    bUpdateLCD=0;
  }
}
void func2(void)
{
  LCD.setCursor(0,2);
  LCD.print("State 2");
  bUpdateLCD=1;
}

void func3(void)
{
  t0=millis();
  LCD.setCursor(0,2);
  LCD.print("State 3");
  FSM.AddEvent(0);
}

void func4(void)
{
  LCD.setCursor(0,2);
  LCD.print("State 4");
}

void func5(void)
{
  my0to100=millis()-t0;
  t_prev=millis();
  LCD.setCursor(0,2);
  LCD.print("State 4");
  
  LCD.setCursor(0,3);
  LCD.print((float)my0to100/(float)1000.0);
  LCD.print(" s");
  
  while(millis()-t_prev<=delayShowData);
  FSM.AddEvent(EV_Wait);  
}


