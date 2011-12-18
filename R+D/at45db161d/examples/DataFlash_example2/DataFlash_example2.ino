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
  unsigned long t0=micros();
  DF.BufferWrite(1,0);
  byte counter;
  for (int i=1;i<540;++i)
  {
    spi_transfer(++counter); //envio datos por SPI
    /*
    Serial.print("Grabado=");
    Serial.println(i);
    */
    if (i>=(DF.pageSizeBinary-2))  break;
  
  }
  spi_transfer(99);
  spi_transfer(1);  //Fin de datos, caracter limitador 0
  DF.EndAndWait();
  
  unsigned long tf=micros()-t0;
  Serial.print("Tiempo en enviar una pagina=");
  Serial.println(tf/1000.0);
  
  t0=micros();
  //Lo grabo en la memoria
  DF.BufferToPage(1,4095,1);
  tf=micros()-t0;
  Serial.print("Tiempo en grabar del buffer a una pagina=");
  Serial.println(tf/1000.0);
  
  //Leo los datos de la pagina y los saco por serie.
  DF.PageToBuffer(4095,2);
  DF.BufferRead(2,0,1);
  for (int i=0; i<DF.pageSizeBinary;++i)
  {    
    data=spi_transfer(0xFF);
    
    Serial.print("Leido=");
    Serial.print(data);
    Serial.print(",");
    Serial.println(i);
    
    
  }
  DF.EndAndWait();

  
  for(;;)
  {}
  
}


