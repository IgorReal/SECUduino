// -------------------------------------------------------------------------------------
// Ejemplo libreria FSM
// Si se recibe una secuencia por la UART del tipo SxxxxE, siendo xxxxx numeros
// se recoge en una variable global llamada mynumber y se imprime por pantalla
// S viene de Start y E de End.
// El numero debe ser un unsigned long
// -------------------------------------------------------------------------------------

#include <FSM.h>
#include "myStates.h"

unsigned char myEvent;
char myByteRec;
unsigned long mynumber;



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
    }else if ( (myByteRec>='0') && (myByteRec<='9') )
    {
      myEvent=EV_NUMBER;  //Evento recibido un numero   
    }else if (myByteRec=='E') 
    {
      myEvent=EV_E;       //Evento recibido E  
    }else
    {
      myEvent=EV_ERROR;   //Evento recibido caracter no valido
    }
  }
  
  FSM.AddEvent(myEvent);
  
  
}

//Funciones correspondientes a los ESTADOS
void func1(void)
{
  mynumber=0;  
}
void func2(void)
{
  if (myEvent==EV_NUMBER)
  {
    mynumber=mynumber*10+(myByteRec-0x30);
  }  
}
void func3(void)
{
  if (myEvent==EV_E)
  {
    Serial.print("RECIBIDO NUMERO=");  
    Serial.println(mynumber);
    mynumber=0;
  }
    
}


