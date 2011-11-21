// ----------------------------------------------
// SECUDUINO
// http://secuduino.blogspot.com/
// By Igor Real
// 16/05/2011
// ----------------------------------------------

#include <CAN.h>

void setup() 
{
  // set up CAN
  CAN.begin(1);
  CAN.SetMode(LOOPBACK_MODE);
  //setup SERIAL
  Serial.begin(115200);
  
  CAN_TxMsg.id=0x351;     
  CAN_TxMsg.header.rtr=0;
  CAN_TxMsg.header.length=8;
  CAN_TxMsg.data[0]=0x00;
  CAN_TxMsg.data[1]=0x00;  
  CAN_TxMsg.data[2]=0x00; 
  CAN_TxMsg.data[3]=0x00;
  CAN_TxMsg.data[4]=0x00;
  CAN_TxMsg.data[5]=0x00;
  CAN_TxMsg.data[6]=0x00;
  CAN_TxMsg.data[7]=0x00;
}

void loop() 
{

  CAN.send(&CAN_TxMsg);

  if (CAN.CheckNew())
  {
    CAN_TxMsg.data[0]++;
    CAN.ReadFromDevice(&CAN_RxMsg);
    
    if (CAN_RxMsg.id==0x351)        //SPEED
    {
       Serial.print(CAN_RxMsg.id,HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[0],HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[1],HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[2],HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[3],HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[4],HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[5],HEX);
       Serial.print(";");
       Serial.print(CAN_RxMsg.data[6],HEX);
       Serial.print(";");
       Serial.println(CAN_RxMsg.data[7],HEX);
    }
       
  }    
}

