#! /usr/bin/env python

import serial
import sys 


ser = serial.Serial('/dev/ttyUSB0', 1000000);
while 1:
    try:
        n=ser.read();
        n=ord(n)*5000/255;  #Convierto en mV
        print n;
    except KeyboardInterrupt:
        ser.close();        
        sys.exit(0)



