// -------------------------------------------------------------------
// SECUduino
// CAN CONFORT VW
// Ejemplo bajar ventanillas con el mando inalambrico de la llave
// 24/Apr/2011
// By Igor Real
// -------------------------------------------------------------------

#include <CAN.h>
long myCarOpening;
long myCarClosing;
int myfirsttime;

void setup()
{
 Serial.begin(115200);
 Serial.println("Empezamos...");
 CAN.begin(100);
 
 CAN_TxMsg.id=0x181;     
 CAN_TxMsg.header.rtr=0;
 CAN_TxMsg.header.length=3;
 CAN_TxMsg.data[0]=0x00;
 CAN_TxMsg.data[1]=0x00;  
 CAN_TxMsg.data[2]=0x00; 
 CAN_TxMsg.data[3]=0x00;
 CAN_TxMsg.data[4]=0x00;
 CAN_TxMsg.data[5]=0x00;
 CAN_TxMsg.data[6]=0x00;
 CAN_TxMsg.data[7]=0x00;
 
 myfirsttime=1;
}

void loop()
{
  
  while (CAN.CheckNew())
  {
      if ( CAN.ReadFromDevice(&CAN_RxMsg) )
      {
          if (CAN_RxMsg.id==0x291)        //Trama con la info del mando inalámbrico
          {
              //Serial.print("Byte 0=");
              //Serial.println(CAN_RxMsg.data[0],HEX);
              //OPENING
              if (CAN_RxMsg.data[0]==0x49)
              {
                myCarOpening++; 
                myCarClosing=0; 
                //Serial.print("Opening=");
                //Serial.println(myCarOpening,DEC);
              //CLOSING
              }else if (CAN_RxMsg.data[0]==0x89)
              {
                myCarClosing++;  
                myCarOpening=0;
                //Serial.print("Closing=");
                //Serial.println(myCarClosing,DEC);
              }else
              {
                myCarOpening=0;
                myCarClosing=0;
                myfirsttime=1;
                //Serial.println("myCarOpening=0");
              }
          }
          
          //Abro ventanillas, si el usuario ha estado pulsando el boton una cierta cantidad de tiempo
          if (myCarOpening>10)
          {
              if (myfirsttime)
              {
                  CAN_TxMsg.id=0x271;    //Le mando al coche como si estuviera en contacto
                  CAN_TxMsg.header.rtr=0;
                  CAN_TxMsg.header.length=1;
                  CAN_TxMsg.data[0]=0x03;
                  CAN_TxMsg.data[1]=0x00;  
                  CAN.send(&CAN_TxMsg); 
                  delay(100);
                  myfirsttime=0;
                  //Serial.println("Enviado msg contacto");
              }
   
              CAN_TxMsg.id=0x181; 
              CAN_TxMsg.header.rtr=0;
              CAN_TxMsg.header.length=3;
              CAN_TxMsg.data[0]=0x44;  // Bajar ventanilla delantera izquierda
              CAN_TxMsg.data[1]=0x44;  // Bajar ventanillas traseras
              CAN.send(&CAN_TxMsg); 
              //Serial.println("Opening Windows");
          }
          //Cierro ventanillas, si el usuario ha estado pulsando el boton una cierta cantidad de tiempo
          if (myCarClosing>10)
          {
              if (myfirsttime)
              {
                  CAN_TxMsg.id=0x271;    //Le mando al coche como si estuviera en contacto
                  CAN_TxMsg.header.rtr=0;
                  CAN_TxMsg.header.length=1;
                  CAN_TxMsg.data[0]=0x03;
                  CAN_TxMsg.data[1]=0x00;  
                  CAN.send(&CAN_TxMsg); 
                  delay(20);
                  CAN.send(&CAN_TxMsg); 
                  delay(100);
                  myfirsttime=0;
                  //Serial.println("Enviado msg contacto");
              }
              
              CAN_TxMsg.id=0x181; 
              CAN_TxMsg.header.rtr=0;
              CAN_TxMsg.header.length=3;
              CAN_TxMsg.data[0]=0x11;  // Subir ventanilla delantera izquierda
              CAN_TxMsg.data[1]=0x11;  // Subir ventanillas traseras
              CAN.send(&CAN_TxMsg); 
              //Serial.println("Closing Windows");
          }
          
           
      }
  }
}
