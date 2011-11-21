//------------------------------------------------
// Fast Acquisition
// By: Igor R.
// 03/09/2011
//------------------------------------------------


#define CHRONO  0


void setup()
{
  Serial.begin(1000000);  //1 Mbps
  
  //Prescaler
  //ADPS2 - ADPS1 - ADPS0 - Division Factor
  //0        - 0       - 0        ->2
  //0        - 0       - 1        ->2
  //0        - 1       - 0        ->4
  //0        - 1       - 1        ->8
  //1        - 0       - 0        ->16
  //1        - 0       - 1        ->32
  //1        - 1       - 0        ->64
  //1        - 1       - 1        ->128
  //Configure to Prescaler=16 (11793.57 Hz a 115200)
  //Configure to Prescaler=16 (66418.71 Hz a 1000000)

  bitWrite(ADCSRA,ADPS2,1);
  bitWrite(ADCSRA,ADPS1,0);
  bitWrite(ADCSRA,ADPS0,0);
  
  //Analog Input A5
  ADMUX=(1<<ADLAR)|(0<<REFS1)|(1<<REFS0)|(0<<MUX3)|(1<<MUX2)|(0<<MUX1)|(1<<MUX0);
}


void loop()
{

  #if CHRONO==1
  
    MeasureTime();
    for (;;)
    {
    }

  #else
  
    int i;

    for (;;)
    {
      while (!(UCSR0A & (1 << UDRE0)));
      UDR0 = analogReadFast();
      i++;
      if (i==-1);
    }
    
  #endif
  
}

//Read ADC
int analogReadFast()
{
	ADCSRA|=(1<<ADSC);
	// ADSC is cleared when the conversion finishes
	while (bit_is_set(ADCSRA, ADSC));
        return ADCH;
}


//Chrono function
void MeasureTime()
{
  unsigned int i=1;
  unsigned long tStart;
  unsigned long tEnd;
  
  //--------------------------------------------
  //CHRONO
  tStart=micros();
  for (;;)
  {
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = analogReadFast();
    i++;
    if (i== 1000)  break;
  }
  tEnd=micros();  
  // END CHRONO
  //--------------------------------------------
  
  Serial.begin(115200);
  delay(100);
  Serial.println("");
  
  Serial.print("tStart=");
  Serial.println(tStart);
  
  Serial.print("tEnd=");
  Serial.println(tEnd);
  
  Serial.print("Puntos=");
  Serial.println(i);
  
  Serial.print("Frecuecy=");
  Serial.print((float)1000000000.0/((float)tEnd-(float)tStart));
  Serial.println(" Hz");
  
}


