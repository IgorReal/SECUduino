// --------------------------------------------------------
// SECUDUINO
// Example: Using CAN + SPI memory (buffer)
// By Igor R.
// --------------------------------------------------------


#include <CAN.h>
#include <at45db161d.h>

#define nMsgCAN  5

ATD45DB161D DF;
uint8_t data;
uint8_t RXcounter;
uint8_t offset;

void setup()
{
  pinMode(10,OUTPUT);
  DF.Init();
  CAN.begin(100);
  Serial.begin(115200);
}

void loop()
{

  
  if ( (CAN.CheckNew()) && (RXcounter<nMsgCAN) )
  {
    CAN.ReadFromDevice(&CAN_RxMsg);
    
    if (CAN_RxMsg.id==0x100)
    {

      ++RXcounter;
            
      //Use buffer1 starting at the beggining
      DF.BufferWrite(1,offset);
      offset+= 10;
      spi_transfer(0xFF);  //Byte start/finish 0xFF
      spi_transfer(0x08);  //Number of data
      for (int i=0;i<8;i++)
      {
        spi_transfer(CAN_RxMsg.data[i]);
      }
      DF.EndAndWait();      //Finish TX to buffer1
    }        
  }
    
  //Tx to the serial when received nMsgCAN messages
  if (RXcounter>=nMsgCAN)
  {
    DF.BufferWrite(1,offset);
    spi_transfer(0xFF);  //Start/Finish byte
    //Read buffer 1 data
    DF.BufferRead(1,0,1);
    for(int i=0;i<(nMsgCAN*10)+1;i++)
    {
      data=spi_transfer(0xFF);
      Serial.print("Dato ");
      Serial.print(i);
      Serial.print(",");
      Serial.println(data);
      
    }
    DF.EndAndWait();  
    RXcounter=0;
    offset=0;
  }
  
  
}


