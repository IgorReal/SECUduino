//-----------------------------------------------------
//ESTE ES EL ÚNICO FICHERO QUE HAY QUE MODIFICAR
//-----------------------------------------------------

#ifndef myStates_H
#define myStates_H


//Declaracion de las funciones
extern void func2(void);
extern void func4(void);


//Declaracion del nombre de ESTADOS y de EVENTOS
#define STATE1  	0x01
#define STATE2  	0x02
#define STATE3 	        0x03
#define STATE4          0x04

#define EV_S     	0x41
#define EV_E    	0x43	
#define EV_ERROR    	0x44	

// Estructuras descriptivas de mi diagrama de flujo
const FSMClass::FSM_State_t FSM_State[] PROGMEM= {
// STATE,STATE_FUNC
{STATE1,0},
{STATE2,func2},
{STATE3,0},
{STATE4,func4},
};

const FSMClass::FSM_NextState_t FSM_NextState[] PROGMEM= {
// STATE,EVENT,NEXT_STATE
{STATE1,EV_S,STATE2},
{STATE2,0,STATE3},
{STATE3,EV_E,STATE4},
{STATE4,0,STATE1},
};


//Macros para el cálculo de los tamaños de las estructuras
//NO MODIFICAR
#define nStateFcn		sizeof(FSM_State)/sizeof(FSMClass::FSM_State_t)
#define nStateMachine		sizeof(FSM_NextState)/sizeof(FSMClass::FSM_NextState_t)

#endif

