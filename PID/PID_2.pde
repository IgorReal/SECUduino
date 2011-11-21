//--------------------------------------------
// MAQUETA DE CONTROL PID
// VIRTUALCAMP JUL 2011
// IGOR R.
//--------------------------------------------

#include <avr/pgmspace.h>

//CONSTANTES
#define cte_kp  500.0   //300
#define cte_ki  10.0     //5.0
#define cte_kd  3500.0
#define Margin_Int 0.9
#define target1  60.0    //60
#define target2  58.0    //58

//Variables de control de flujo
long tInit;
long tSerial;

//Input
float Target;

//Sensor
float temp;

//Output
float dutycycle;

//PID
float error;
float prev_error;
float Proportional;
float Integral;
float Derivative;
float Kp;
float Ki;
float Kd;
long LastTime;
long SampleTime;
long timeOutInt;


//Tabla guardada en memoria de programa del Arduino (FLASH)
PROGMEM  prog_uint16_t ntc[21][2]  = { 
  {861,0},
  {778,10},
  {678,20},
  {570,30},
  {463,40},
  {366,50},  
  {285,60},  
  {219,70},
  {168,80},
  {128,90},
  {99,100},
  {77,110},
  {60,120},
  {47,130},
  {38,140},
  {30,150},  
  {24,160},  
  {20,170},
  {16,180},
  {14,190},
  {11,200},
};
 
 
void setup() 
{
  //Empiezo comunicacion serie a 19200(maxima velocidad de StampPlot)
  Serial.begin(19200); 
  delay(10);
  //Configuro el StampPlot (maximo, minimo, grabar en un archivo los datos, etc).
  config_StampPlot();  
  //Configuro el pin 9 como salida (PWM)
  pinMode(9,OUTPUT);
  
  //Capturo tiempos para el control de mi programa.
  tInit=millis();
  LastTime=millis();
  
  //Valor de mis constantes del control PI
  Kp=cte_kp;
  Ki=cte_ki;
  Kd=cte_kd;
  
  //Modificar frecuencia PWM
  //Setting 	Divisor 	Frequency
  //0x01 	 	1 	 	31250
  //0x02 	 	8 	 	3906.25
  //0x03  		64 	 	488.28125
  //0x04  		256 	 	122.0703125
  //0x05 	 	1024 	 	30.517578125
  //TCCR1B = TCCR1B & 0b11111000 | <setting>;
  //Configuro el PWM a 30 kHz.
  TCCR1B=TCCR1B & 0b11111000 | 0x01;

  
}

void loop() 
{
  
  //Recojo 10 veces el dato del sensor y hago la media
  for (int i=0; i<10;i++)
  {
    temp+=calcTemp(analogRead(A5));  //Función que transforma mi lectura del ADC en grados usando una tabla guardad en memoria FLASH
  }
  temp/=10;

  // Cambio el SetPoint a target1 y target2 cada 120 segundos
  Target=target1;
  long time=(millis()-tInit)/1000;
  if ((time>60) && (time<120) )
  {
    Target=target2;  
  }else if ( time>120 )
  {
    tInit=millis();  
  }

  //----------------------------------------------------
  //CONTROL PID
  //Hago los calculos de manera periodica
  
  SampleTime=(millis()-LastTime);  
  if (SampleTime>=100)
  { 

    LastTime=millis();
    
    //Calculo de error (diferencia entre SetPoint y temperatura actual
    prev_error=(float)error;
    error=(float)temp-(float)Target;
  
    Proportional=(float)Kp*(float)error;
    
    //El control integral solo entra cuando esta lo suficientemente cerca
    //Esto es para evitar saturar el control
    if ( (abs(error)<=Margin_Int))
    {
      
      if (timeOutInt++ >10)        //Si se cumple durante X veces el SampleTime (delay de la parte integral)
      {
        Integral+=(float)Ki*(float)error;
        timeOutInt=3000;              //Para evitar desbordamiento del numero si esta durante mucho tiempo
      }
    }else
    {
      Integral=0;
      timeOutInt=0;
    }

    //Parte derivativa
    Derivative=(float)Kd*((float)error-(float)prev_error);
    //----------------------------------------------------------------
    dutycycle=(int)Proportional+ (int)Integral + (int)Derivative;

    //Limites de la salida. PWM de Arduino 0-255 (8 bits).
    if (dutycycle <0)
    {
      dutycycle=0;
    }else if (dutycycle>255)
    {
      dutycycle=255;
    }  
   
    //Actualizo salida
    analogWrite(9,(int)dutycycle);
    
    //Mando datos a Stamplot
    Serial.print(temp);
    Serial.print(13,BYTE);
    
    Serial.print("D=");
    Serial.print(dutycycle);
    Serial.print(";E=");
    Serial.print(error);
    Serial.print("; P=");
    Serial.print(Proportional);
    Serial.print("; I=");
    Serial.print(Integral);
    Serial.print("; D=");
    Serial.print(Derivative);    
    Serial.print(13,BYTE);
    
  }
  //----------------------------------------------------  
 
             
}

// Funcion de conversion lectura ADC a grados mediante una tabla guardada en memoria de programa del micro
// para no gastar memoria RAM.
float calcTemp(uint16_t myADC)
{
  
  //Recorro la tabla de valores del sensor NTC 
  for(int i=0; i<21;i++)
  {
      //No extrapola, si es menor se queda con el primer valor de la tabla
      if (myADC>=pgm_read_word(&(ntc[0][0])))
      {
        temp=pgm_read_word(&(ntc[0][1]));    
        break;
      }
      //No extrapola, si es mayor se queda con el ultimo valor de la tabla
      if (myADC<=pgm_read_word(&(ntc[20][0])))
      {
        temp=pgm_read_word(&(ntc[20][1]));  
        break;  
      }

      uint16_t actualADC=pgm_read_word(&(ntc[i][0]));
      
      if (myADC>=actualADC)
      {
        if (i>0)
        {
          uint16_t previousADC=pgm_read_word(&(ntc[i-1][0]));  
          uint16_t previousTemp=pgm_read_word(&(ntc[i-1][1]));
          uint16_t actualTemp=pgm_read_word(&(ntc[i][1]));
          
          temp=( ((float)myADC - (float)previousADC) * ((float)actualTemp - (float)previousTemp) / ((float)actualADC - (float)previousADC) )+previousTemp;

          break;
        }
      }  
  }  
  
  return (temp);
  
}


void config_StampPlot()
{

  //----------------------------------------------------------
  //CONFIGURACION STAMP PLOT LITE
  //----------------------------------------------------------
  //Titulo de la ventana (FORM)
  Serial.print("!TITL Arduino Power!");
  Serial.print(13,BYTE);
  //Titulo de usuario (STATUS)
  Serial.print("!USRS Control PID");
  Serial.print(13,BYTE);  
  //Valor maximo del eje Y
  Serial.print("!AMAX 62");
  Serial.print(13,BYTE);
  //Valor minimo del eje Y
  Serial.print("!AMIN 57");
  Serial.print(13,BYTE);
  //Valor maximo de tiempo
  Serial.print("!TMAX 500");
  Serial.print(13,BYTE);
  //Configuro el numero de puntos
  Serial.print("!PNTS 8000");
  Serial.print(13,BYTE);  
  //Ayadir Tiempo en la lista de mensajes
  Serial.print("!TSMP OFF");
  Serial.print(13,BYTE);  
  //Plot ON
  Serial.print("!PLOT ON");
  Serial.print(13,BYTE);    
  //Borra el valor Max y Min almacenado despues del RESET
  Serial.print("!CLMM");
  Serial.print(13,BYTE);  
  //Limpio la lista de mensajes
  Serial.print("!CLRM");
  Serial.print(13,BYTE);
  
  //Borro el fichero stampdat.txt
  Serial.print("!DELD");
  Serial.print(13,BYTE);
  //Borro el fichero stampmsg.txt
  Serial.print("!DELM");
  Serial.print(13,BYTE);  
  //Salvar datos Analogicos y digitales en stampdat.txt
  Serial.print("!SAVD ON");
  Serial.print(13,BYTE);  
  //Salvar Mensajes en stampmsg.txt
  Serial.print("stampmsg.txt");
  Serial.print(13,BYTE);    
  
  //RESET DEL GRAFICO PARA COMENZAR A PLOTEAR
  Serial.print("!RSET");
  Serial.print(13,BYTE);  
  //----------------------------------------------------------
  
}

