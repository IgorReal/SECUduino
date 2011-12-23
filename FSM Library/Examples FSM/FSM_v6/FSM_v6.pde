// -------------------------------------------------------------------------------------
// Ejemplo libreria FSM
// Si se recibe una S (Start) por la UART empieza a cronometrar
// Cuando recibe una E (End) por la UART, imprime el tiempo cronometrado hasta ese momento
// -------------------------------------------------------------------------------------

#include <FSM.h>
#include "myStates.h"

unsigned char myEvent;
char myByteRec;
unsigned long t0;



void setup()
{
  Serial.begin(9600);
  Serial.println("Empezamos...");
  
  // Inicializo  mi maquina de estados. Le paso las estructuras y sus tamaños,que definen el diagrama de flujo
  // y le paso el estado inicial.
  FSM.begin(FSM_NextState,nStateMachine,FSM_State,nStateFcn,STATE1);
}

void loop()
{
  //PASOS DE LA MAQUINA DE ESTADOS
  //  Primer paso:  LEO EVENTOS EXTERNOS
  //  Segundo paso: ACTUALIZO ESTADOS
  //  Tercer paso:  EJECUTO FUNCION CORRESPONDIENTE A DICHO ESTADO
  //  Cuaro paso:   ACTUALIZO ESTADOS DEPENDIENDO DE LOS EVENTOS INTERNOS GENERADOS
  
  ReadEvents();
  FSM.Update();
  
}


void ReadEvents(void)
{
  myEvent=0;
  if (Serial.available()>0)
  {
    myByteRec=Serial.read();

    if (myByteRec=='S')  
    {
      myEvent=EV_S;      //Evento recibido S
    }else if (myByteRec=='E') 
    {
      myEvent=EV_E;       //Evento recibido E  
    }else
    {
      myEvent=EV_ERROR;   //Evento recibido caracter no valido
    }
    //Solo genero el evento si se ha recibido algo por serie
    FSM.AddEvent(myEvent);
  }
  

  
  
}

//Funciones correspondientes a los ESTADOS
void func2(void)
{
  t0=millis();
  FSM.AddEvent(0);
}
void func4(void)
{
  Serial.print("Tiempo transcurrido=");
  Serial.println((millis()-t0)/1000.0);
  FSM.AddEvent(0);  
}


