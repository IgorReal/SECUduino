// ----------------------------------------------
// SECUDUINO
// OBD2 Example
// http://secuduino.blogspot.com/
// ---------------------------------------------- 

#include <CAN.h>

long rpm;

void setup()
{
 Serial.begin(115200);
 Serial.println("Starting...");

 CAN.begin(500);

 CAN_TxMsg.id=0x7DF;   
 CAN_TxMsg.header.rtr=0;
 CAN_TxMsg.header.length=8;
 CAN_TxMsg.data[0]=0x02;
 CAN_TxMsg.data[1]=0x01;  //MODE 
 CAN_TxMsg.data[2]=0x0C;  //PID
 CAN_TxMsg.data[3]=0x00;
 CAN_TxMsg.data[4]=0x00;
 CAN_TxMsg.data[5]=0x00;
 CAN_TxMsg.data[6]=0x00;
 CAN_TxMsg.data[7]=0x00; 

}

void loop()
{


 CAN.send(&CAN_TxMsg);

 delay(5);


 if (CAN.CheckNew())
 {
 
   if ( CAN.ReadFromDevice(&CAN_RxMsg) )
   {
     if (CAN_RxMsg.data[2]==0x0C)   //PID=0x0C (rpm)
     {
       rpm =  ((CAN_RxMsg.data[3]*256) + CAN_RxMsg.data[4])/4;
           
       Serial.print(millis());
       Serial.print(";");
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
       Serial.print(CAN_RxMsg.data[7],HEX);
       Serial.print(";");
       Serial.print("RPM=");
       Serial.println(rpm,DEC);
     }
 }
 
 }else
 {
   
 }

}





