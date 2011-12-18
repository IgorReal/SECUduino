#include <at45db161d.h>

ATD45DB161D DF;
uint8_t data;

void setup()
{
  pinMode(10,OUTPUT);
  DF.Init();
  Serial.begin(115200);
  
  
}

void loop()
{

  //Grabo en el buffer 1 10 datos, empezando desde posicion 0
  DF.BufferWrite(1,0);
  for (int i=1;i<540;++i)
  {
    spi_transfer(10); //envio datos por SPI
    /*
    Serial.print("Grabado=");
    Serial.println(i);
    */
    if (i>=(DF.pageSizeBinary-1))  break;
  
  }
  spi_transfer(1);  //Fin de datos, caracter limitador 0
  DF.EndAndWait();
  
  //Leo los datos del buffer y los saco por serie.
  DF.BufferRead(1,0,1);
  data=spi_transfer(0xFF);
  int i=0;
  while (data !=1)
  {    
    /*
    Serial.print("Leido=");
    Serial.print(data);
    Serial.print(",");
    Serial.println(++i);
    */
    data=spi_transfer(0xFF);
  }
  DF.EndAndWait();
  
  Serial.println(DF.ReadStatusRegister(),BIN);
  
  for(;;)
  {}
  
}


