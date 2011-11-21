//-----------------------------------------------------
//ESTE ES EL ÚNICO FICHERO QUE HAY QUE MODIFICAR
//-----------------------------------------------------

#ifndef myStates_H
#define myStates_H


//Declaracion de las funciones
extern void func1(void);
extern void func2(void);
extern void func3(void);


//Declaracion del nombre de ESTADOS y de EVENTOS
#define STATE1  	0x01
#define STATE2  	0x02
#define STATE3 	        0x03

#define EV_S     	0x41
#define EV_NUMBER       0x42
#define EV_E    	0x43	
#define EV_ERROR    	0x44	

// Estructuras descriptivas de mi diagrama de flujo
const FSMClass::FSM_State_t FSM_State[] PROGMEM= {
// STATE,STATE_FUNC
{STATE1,func1},
{STATE2,func2},
{STATE3,func3},
};

const FSMClass::FSM_NextState_t FSM_NextState[] PROGMEM= {
// STATE,EVENT,NEXT_STATE
{STATE1,EV_S,STATE2},
{STATE2,EV_NUMBER,STATE2},
{STATE2,EV_E,STATE3},
{STATE2,EV_ERROR,STATE1},
{STATE2,EV_S,STATE1},
{STATE3,0,STATE1},
};


//Macros para el cálculo de los tamaños de las estructuras
//NO MODIFICAR
#define nStateFcn		sizeof(FSM_State)/sizeof(FSMClass::FSM_State_t)
#define nStateMachine		sizeof(FSM_NextState)/sizeof(FSMClass::FSM_NextState_t)

#endif

