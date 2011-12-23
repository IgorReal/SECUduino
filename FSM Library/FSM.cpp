//-----------------------------------------------------------
// Finite State Machine for Arduino
// By: Igor Real
// 17/10/2011
//-----------------------------------------------------------

#if defined(ARDUINO) && ARDUINO >= 100
	#include "Arduino.h"
#else
	#include "WProgram.h"
#endif

#include "FSM.h"

#define DEBUGMODE	0


/******************************************************************************
 * Variables
 ******************************************************************************/
FSMClass FSM;

/******************************************************************************
 * Constructors
 ******************************************************************************/


/******************************************************************************
 * PUBLIC METHODS
 ******************************************************************************/

void FSMClass::begin(const FSM_NextState_t *FSM_NextState,unsigned char SizeNextState,const FSM_State_t *FSM_State,unsigned char SizeState,unsigned char State)
{
	mySizeNextState=SizeNextState;
	mySizeState=SizeState;
	myState=State;
	myFSM_NextState=FSM_NextState;
	myFSM_State=FSM_State;
}

unsigned char FSMClass::State(void)
{
	return myState;
}

void FSMClass::Update(void)
{
	//Pasos:
	//Hay nuevo evento? Mientras exista nuevo evento:
	// 1- Limpio booleano
	// 2- Actualizo maquina de estados
	// 3- Ejecuto función correspondiente a dicho estado
	//   [ Dicha función puede generar un nuevo evento (interno) ]

	while (mybNewEvent) 
	{
		mybNewEvent=0;	
		StateMachine(myEvent);
		StateFcn();
		#if (DEBUGMODE==1)
			Serial.print("Estado=");
			Serial.println(myState,HEX);
			Serial.print("Evento ?=");
			Serial.println(mybNewEvent,HEX);
		#endif

	}
}

void FSMClass::AddEvent(unsigned char Event)
{
	myEvent=Event;
	mybNewEvent=1;
}


/******************************************************************************
 * PRIVATE METHODS
 ******************************************************************************/
unsigned char FSMClass::StateMachine(unsigned char event)
{
	unsigned char new_state=0;
 
	for (uint8_t i=0; i<mySizeNextState;i++)
  	{

	    //Busco el estado actual
	    if (myState==pgm_read_byte(&myFSM_NextState[i].state))
	    {
	    	//Busco el input
	      	if(event==pgm_read_byte(&myFSM_NextState[i].event))
	      	{
			new_state= pgm_read_byte(&myFSM_NextState[i].next_state); 
			myState=new_state;
			break;
	      	}
	    }
	}
	return new_state;
}

unsigned char FSMClass::StateFcn()
{
	FuncPtr FPtr;
  	FPtr=0;
  
	for (uint8_t i=0; i<mySizeState;i++)
  	{
    		if (myState==pgm_read_byte(&myFSM_State[i].state))
    		{      
      			FPtr=(FuncPtr)pgm_read_word(&myFSM_State[i].pFunc);
      			break;
    		}               
  	} 

	if (FPtr!=0)
	{
  		FPtr();
		return 1;
	}else
	{
		return 0;
	}

}






