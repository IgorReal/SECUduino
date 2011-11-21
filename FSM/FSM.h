//-----------------------------------------------------------
// Finite State Machine for Arduino
// By: Igor Real
// 17/10/2011
//-----------------------------------------------------------


#ifndef FSM_H
#define FSM_H

#include <avr/pgmspace.h>


//----------------------------------------------------------------------------
// CLASS
//----------------------------------------------------------------------------
class FSMClass
{
	public:
		//Variables:
		typedef void (*FuncPtr)(void);		

		typedef struct PROGMEM 
		{
  			unsigned char state;   // state
  			FuncPtr pFunc;         // pointer to a function
		} FSM_State_t;

		typedef struct PROGMEM
		{
		  	unsigned char state;         // state
		  	unsigned char event;         // input
		  	unsigned char next_state;    // next_state
		} FSM_NextState_t;		

		//Functions:
		void begin(const FSM_NextState_t *FSM_NextState,unsigned char SizeNextState,const FSM_State_t *FSM_State,unsigned char SizeState,unsigned char State);
		void Update(void);
		void AddEvent(unsigned char Event);

	private:
		//Functions:
		unsigned char StateMachine(unsigned char input);
		unsigned char StateFcn();
		unsigned char State(void);

		//Variables:
		unsigned char mySizeNextState;
		unsigned char mySizeState;
		unsigned char myState;

		unsigned char myEvent;
		unsigned char mybNewEvent;

		const FSM_State_t *myFSM_State;
		const FSM_NextState_t *myFSM_NextState;

};
//----------------------------------------------------------------------------
// VARIABLES
//----------------------------------------------------------------------------

extern FSMClass FSM;


#endif
