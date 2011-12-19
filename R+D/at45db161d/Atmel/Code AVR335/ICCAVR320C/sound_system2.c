/*****************************************************************************
*
* Atmel Corporation
*
* File              : sound_system2.c
* Compiler          : IAR EWAAVR 3.20C
* Revision          : $Revision: 1.4 $
* Date              : $Date: Monday, November 15, 2004 12:53:58 UTC $
*
* Support mail      : avr@atmel.com
*
* Supported devices : ATmega8535
*
* AppNote           : AVR335 Digital Sound Recorder.
*
*
****************************************************************************/


#include <inavr.h>
#include <ioavr.h>
#include "dataflash.h"

// prototypes
void setup (void);
void erasing (void);
void recording (void);     
void write_to_flash (unsigned char ad_data);
void playback (void);
void next_page_to_next_buffer (unsigned char active_buffer, unsigned int page_counter); 
void active_buffer_to_speaker (unsigned char active_buffer);
void write_SPI(unsigned char data);

// global variables  
volatile unsigned char wait = 0;


void setup(void)
{
    DDRB = 0xBD;                            // SPI Port initialisation
                                            // SCK, MISO, MOSI,  CS, LED,  WP , RDYBSY, RST
                                            // PB7, PB6,  PB5,  PB4, PB3, PB2 ,  PB1,   PB0
                                            //  O    I     O     O    O    O      I      O
                                            //  1    0     1     1    1    1      0      1
                                            
    PORTB = 0xFF;                           // all outputs high, inputs have pullups (LED is off) 
    DDRA = 0x00;                            // define port A as an input    
    PORTA = 0x00;
    DDRD = 0x10;                            // define port D as an input (D4: output)

    __enable_interrupt();                   // enable interrupts
}

void write_SPI(unsigned char data)
{
       SPDR = data;
       while (!(SPSR & 0x80));             // wait for data transfer to be completed
}

void erasing(void)
{
    unsigned int block_counter = 0;
    
    ACSR |= CLEARED;                           // set signal flag that new data has to be recorded next

    // interrupt disabled, SPI port enabled, master mode, MSB first,  SPI mode 3, Fcl/4
    SPCR = 0x5C;

    while (block_counter < 512)
    {
        PORTB &= ~DF_CHIP_SELECT;           // enable DataFlash
        
        write_SPI(BLOCK_ERASE);
        write_SPI((char)(block_counter>>3));
        write_SPI((char)(block_counter<<5));
        write_SPI(0x00);

        PORTB |= DF_CHIP_SELECT;            // disable DataFlash

        block_counter++;
        while(!(PINB & 0x02));              // wait until block is erased
    }
    SPCR = 0x00;                            //disable SPI        
}

 
void recording(void)
{   
    unsigned char count;
    // interrupt disabled, SPI port enabled, master mode, MSB first, SPI mode 3, Fcl/4
    SPCR = 0x5C;           
    ADMUX = 0x00;                           // A/D converter input pin number = 0
    ADCSRA = 0xD5;                           // single A/D conversion, fCK/32, conversion now started 
    do
    {
        do
        {
        } while(!(ADCSRA&(1<<ADIF)));         // Wait for A/D conversion to finish
        count = 6;                          
        do                                   // Customize this loop to 66 cycles !!
        {
        } while(--count);                   // wait some cycles
        ADCSRA |= 0x40;                      // start new A/D conversion 
        write_to_flash(ADC-0x1D5);          // read data, convert to 8 bit and store in flash 
    } while (!(PIND & 2));                  // loop while button for recording (button 1) is pressed

    ADCSRA = 0x00;                           // disable AD converter
    SPCR = 0x00;                            // disable SPI        
}

void write_to_flash(unsigned char flash_data)
{
    static unsigned int buffer_counter;
    static unsigned int page_counter;
    
    if((ACSR&CLEARED))                       // if flag is set that new data has to be written
    {
        buffer_counter = 0;
        page_counter = 0;                   // reset the counter if new data has to be written
        ACSR &= (~CLEARED);                       // clear the signal flag
    }

    while(!(PINB & 0x02));                  // check if flash is busy

    PORTB &= ~DF_CHIP_SELECT;               // enable DataFlash
     
    write_SPI(BUFFER_1_WRITE);
    write_SPI(0x00);                         // don't cares
    write_SPI((char)(buffer_counter>>8));    // don't cares plus first two bits of buffer address
    write_SPI((char)buffer_counter);         // buffer address (max. 2^8 = 256 pages)
    write_SPI(flash_data);                   // write data into SPI Data Register
        
    PORTB |= DF_CHIP_SELECT;                // disable DataFlash 
    
    buffer_counter++; 
        
    if (buffer_counter > 528)               // if buffer full write buffer into memory page
    {
        buffer_counter = 0;
        if (page_counter < 4096)            // if memory is not full   
        { 
            PORTB &= ~DF_CHIP_SELECT;       // enable DataFlash

            write_SPI(B1_TO_MM_PAGE_PROG_WITHOUT_ERASE);// write data from buffer1 to page 
            write_SPI((char)(page_counter>>6));
            write_SPI((char)(page_counter<<2));
            write_SPI(0x00);                    // don't cares
        
            PORTB |= DF_CHIP_SELECT;        // disable DataFlash
            page_counter++;
        }
        else
        {
            PORTB |= 0x08;                  // turn LED off
            while (!(PIND & 2));            // wait until button for recording (button 1) is released
        }
    }
}


void playback(void)
{      
    unsigned int page_counter = 0;
    unsigned char active_buffer = 1;        // active buffer = buffer1

    TCCR1A = 0x21;                          // 8 bit PWM, using COM1B
    TCNT1 = 0x00;                           // set counter1 to zero      
    TIFR = 0x04;                            // clear counter1 overflow flag 
    TIMSK = 0x04;                           // enable counter1 overflow interrupt
    TCCR1B = 0x01;                          // counter1 clock prescale = 1
    OCR1B = 0x00;                           // set output compare register B to zero
    
    // interrupt disabled, SPI port enabled, master mode, MSB first,  SPI mode 3, Fcl/4
    SPCR = 0x5C;
        
    next_page_to_next_buffer (active_buffer, page_counter);  // read page0 to buffer1 
        
    while (!(PINB & 0x02));                 // wait until page0 to buffer1 transaction is finished
    
    while ((page_counter < 4095)&(!(PIND & 4))) // while button for playback (button 2) is pressed
    {   
        page_counter++;                     // now take next page
         
        next_page_to_next_buffer (active_buffer, page_counter);         
        active_buffer_to_speaker (active_buffer);        
        
        if (active_buffer == 1)             // if buffer1 is the active buffer
        {
          active_buffer++;                    // set buffer2 as active buffer
        }
        else                                // else
        {
          active_buffer--;                    // set buffer1 as active buffer
        }      
    }
    TIMSK = 0x00;                           // disable all interrupts
    TCCR1B = 0x00;                          // stop counter1
    SPCR = 0x00;                            // disable SPI
}


void next_page_to_next_buffer (unsigned char active_buffer, unsigned int page_counter)
{
    while(!(PINB & 0x02));                  // wait until flash is not busy
    
    PORTB &= ~DF_CHIP_SELECT;               // enable DataFlash
                
    if (active_buffer == 1)                 // if buffer1 is the active buffer
    {
          write_SPI(MM_PAGE_TO_B2_XFER);      // transfer next page to buffer2
    }
    else                                    // else
    {
           write_SPI(MM_PAGE_TO_B2_XFER);          // transfer next page to buffer1
    }
    write_SPI((char)(page_counter >> 6));
    write_SPI((char)(page_counter << 2));
    write_SPI(0x00);

    PORTB |= DF_CHIP_SELECT;                // disable DataFlash and start transaction     
}
 

#pragma vector = TIMER1_OVF_vect
__interrupt void out_now(void)
{
   ACSR |= T1_OVF;                                // an interrupt has occured 
}                          


void active_buffer_to_speaker (unsigned char active_buffer)
{
    // until active buffer not empty read active buffer to speaker
    
    unsigned int buffer_counter = 528;
        
    PORTB &= ~DF_CHIP_SELECT;               // enable DataFlash     

    if (active_buffer == 1)                 // if buffer1 is the active buffer
    {
        write_SPI(BUFFER_1_READ);           // read from buffer1
    }
    else                                    // else
    {
        write_SPI(BUFFER_2_READ);               // read from buffer2
    }
    write_SPI(0x00);                          // write don't care byte
    write_SPI(0x00);                          // write don't care byte
    write_SPI(0x00);                          // start at buffer address 0
    write_SPI(0x00);                          // write don't care byte
         
    do
    {
        write_SPI(0xFF);                     // write dummy value to start register shift
        while(!(ACSR&T1_OVF));                        // wait for timer1 overflow interrupt            
        OCR1B = SPDR;                       // play data from shift register
        ACSR &= (~T1_OVF);                           // clear the signal flag               
     } while (--buffer_counter);                          
     PORTB |= DF_CHIP_SELECT;               // disable DataFlash
}


void main(void)
{   
    setup();
    
    for(;;)
    {       
        if (!(PIND & 2))                    // if button for recording (button 2) is pressed
        {
            PORTB &= 0xF7;                  // turn LED on
            recording();       
        }     
        if (!(PIND & 1))                    // if button for erasing (button 0) is pressed
        {            
            PORTB &= 0xF7;                  // turn LED on
            erasing();
            while (!(PIND & 1));            // wait until button for erasing (button 0) is released          
        }       
        if (!(PIND & 4))                    // if button for playback (button 3) is pressed
        {
            PORTB &= 0xF7;                  // turn LED on      
            playback();
            while (!(PIND & 4));            // wait until button for playback (button 3) is released             
        }
    PORTB |= 0x08;                          // turn LED off while running idle
    }
} 
