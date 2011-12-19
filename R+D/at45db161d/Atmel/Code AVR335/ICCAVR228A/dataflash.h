// DataFlash.h


#pragma language=extended

//Global status register flags

#define T1_OVF  0x01
#define CLEARED 0x02

// DataFlash reset port pin (PB 0)
#define DF_RESET 0x01
         
// DataFlash ready/busy status port pin (PB 1)
#define DF_RDY_BUSY 0x02

// DataFlash boot sector write protection (PB 2)
#define DF_WRITE_PROTECT 0x04

// DataFlash chip select port pin (PB 4)
#define DF_CHIP_SELECT 0x10

// buffer 1 
#define BUFFER_1 0x00

// buffer 2
#define BUFFER_2 0x01


// defines for all opcodes

// buffer 1 write 
#define BUFFER_1_WRITE 0x84

// buffer 2 write 
#define BUFFER_2_WRITE 0x87

// buffer 1 read
#define BUFFER_1_READ 0x54

// buffer 2 read
#define BUFFER_2_READ 0x56

// buffer 1 to main memory page program with built-in erase
#define B1_TO_MM_PAGE_PROG_WITH_ERASE 0x83

// buffer 2 to main memory page program with built-in erase
#define B2_TO_MM_PAGE_PROG_WITH_ERASE 0x86

// buffer 1 to main memory page program without built-in erase
#define B1_TO_MM_PAGE_PROG_WITHOUT_ERASE 0x88

// buffer 2 to main memory page program without built-in erase
#define B2_TO_MM_PAGE_PROG_WITHOUT_ERASE 0x89

// main memory page program through buffer 1
#define MM_PAGE_PROG_THROUGH_B1 0x82
 
// main memory page program through buffer 2
#define MM_PAGE_PROG_THROUGH_B2 0x85
 
// auto page rewrite through buffer 1
#define AUTO_PAGE_REWRITE_THROUGH_B1 0x58
 
// auto page rewrite through buffer 2
#define AUTO_PAGE_REWRITE_THROUGH_B2 0x59
 
// main memory page compare to buffer 1
#define MM_PAGE_TO_B1_COMP 0x60

// main memory page compare to buffer 2
#define MM_PAGE_TO_B2_COMP 0x61
 
// main memory page to buffer 1 transfer
#define MM_PAGE_TO_B1_XFER 0x53

// main memory page to buffer 2 transfer
#define MM_PAGE_TO_B2_XFER 0x55

// DataFlash status register for reading density, compare status, 
// and ready/busy status
#define STATUS_REGISTER 0x57

// main memory page read
#define MAIN_MEMORY_PAGE_READ 0x52

// erase a 528 byte page
#define PAGE_ERASE 0x81

// erase 512 pages
#define BLOCK_ERASE 0x50

#define TRUE                0xff
#define FALSE               0x00

// delay values based on a 8Mhz CPU clock
#define QTR_MICRO_SECOND    2
#define HALF_MICROSECOND    4
#define ONE_MICROSECOND     8
#define TWO_MICROSECONDS    16
#define THREE_MICROSECONDS  24
#define FIVE_MICROSECONDS   40
#define TEN_MICROSECONDS    80
#define TWENTY_MICROSECONDS 160

 

