//-----------------------------------------------------
//ESTE ES EL ÚNICO FICHERO QUE HAY QUE MODIFICAR
//-----------------------------------------------------

#ifndef myStates_H
#define myStates_H


//Declaracion de las funciones
extern void func1(void);
extern void func2(void);
extern void func3(void);
extern void func4(void);
extern void func5(void);

//Declaracion del nombre de ESTADOS y de EVENTOS
#define STATE1  	0x01
#define STATE2  	0x02
#define STATE3 	        0x03
#define STATE4          0x04
#define STATE5          0x05

#define EV_Start     	0x01
#define EV_100    	0x02	
#define EV_Stop    	0x03
#define EV_Wait    	0x04


// Estructuras descriptivas de mi diagrama de flujo
const FSMClass::FSM_State_t FSM_State[] PROGMEM= {
// STATE,STATE_FUNC
{STATE1,func1},
{STATE2,func2},
{STATE3,func3},
{STATE4,func4},
{STATE5,func5},
};

const FSMClass::FSM_NextState_t FSM_NextState[] PROGMEM= {
// STATE,EVENT,NEXT_STATE
{STATE1,EV_Stop,STATE2},
{STATE2,EV_Start,STATE3},
{STATE3,0,STATE4},
{STATE4,EV_100,STATE5},
{STATE4,EV_Stop,STATE1},
{STATE5,EV_Wait,STATE1},
};


//Macros para el cálculo de los tamaños de las estructuras
//NO MODIFICAR
#define nStateFcn		sizeof(FSM_State)/sizeof(FSMClass::FSM_State_t)
#define nStateMachine		sizeof(FSM_NextState)/sizeof(FSMClass::FSM_NextState_t)

#endif

