'' ===========================================================================
''
''  File: ADS_IndexedArrayDemo_010.spin 
''
''  Modification History
''
''  Author:     Andre' LaMothe 
''  Copyright (c) Andre' LaMothe / Parallax Inc.
''  See end of file for terms of use
''  Version:    1.0
''  Date:       2/20/2011
''
''  Comments: This demo illustrates using a single array to hold records where the
''  named fields are accessed by indexing fixed lengths into the array to locate
''  each record and then from that point accessing each field of the record.

''  Requires: Uses a serial connection @ 38.4 Kb for communication and printing, so any Propeller
''  platform will work. Simply change the serial tx/rx constants in the CON section
''  to reflect your hardware connections.''
'' ===========================================================================


CON
' -----------------------------------------------------------------------------
' CONSTANTS, DEFINES, MACROS, ETC.   
' -----------------------------------------------------------------------------

  ' set speed to 80 MHZ, 5.0 MHZ xtal, change this if you are using
  ' other XTAL speeds
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ' ASCII codes for ease of character and string processing
  ASCII_A      = 65
  ASCII_B      = 66
  ASCII_C      = 67
  ASCII_D      = 68
  ASCII_E      = 69
  ASCII_F      = 70
  ASCII_G      = 71
  ASCII_H      = 72
  ASCII_O      = 79  
  ASCII_P      = 80
  ASCII_Z      = 90
  ASCII_0      = 48
  ASCII_9      = 57
  ASCII_LEFT   = $C0
  ASCII_RIGHT  = $C1
  ASCII_UP     = $C2
  ASCII_DOWN   = $C3 
  ASCII_BS     = $C8 ' backspace
  ASCII_DEL    = $C9 ' delete
  ASCII_LF     = $0A ' line feed 
  ASCII_CR     = $0D ' carriage return
  ASCII_ESC    = $CB ' escape
  ASCII_HEX    = $24 ' $ for hex
  ASCII_BIN    = $25 ' % for binary
  ASCII_LB     = $5B ' [ 
  ASCII_SEMI   = $3A ' ; 
  ASCII_EQUALS = $3D ' = 
  ASCII_PERIOD = $2E ' .
  ASCII_COMMA  = $2C ' ,
  ASCII_SHARP  = $23 ' #
  ASCII_SNGL_QUOTE = $27
  ASCII_QUOTE  = $22     
  ASCII_NULL   = $00 ' null character
  ASCII_SPACE  = $20 ' space
  ASCII_TAB    = $09 ' horizontal tab
  
  NULL         = $00 ' NULL pointer

  ' serial I/O pins on Propeller board/setup you are using
  SERIAL_RX_PIN = 31
  SERIAL_TX_PIN = 30

  ' string processing constants
  MAX_NAME_LENGTH   = 33 ' max length of a person's name, 32 plus a NULL
  MAX_PERSONS       = 16 ' 16 records to play with

  BYTES_PER_PERSON  = 36 ' number of bytes each "person" record takes

  ' this technique uses "indices" into each compressed record
  
  PERSON_INDEX_NAME   = 0  ' offset of "name" field in a record
  PERSON_INDEX_AGE    = 33 ' offset of "age" field in a record
  PERSON_INDEX_HEIGHT = 34 ' offset of "height" field in a record
  PERSON_INDEX_WEIGHT = 35 ' offset of "weight" field in a record  

OBJ
  '---------------------------------------------------------------------------
  ' IMPORT SINGLE SERIAL OBJECT 
  '---------------------------------------------------------------------------
  serial     : "FullDuplexserial_drv_014.spin"       ' the full duplex serial driver    

VAR
' -----------------------------------------------------------------------------
' DECLARED VARIABLES, ARRAYS, ETC.   
' -----------------------------------------------------------------------------

' use a single array to hold the person's name, age, height and weight in a linear
' compacted format and then index into array to access each record, thus in this
' case we have a cleaner single array for storage, but the access methods become
' more complex since we have to simulate how a language would allow access to fields
' of a declared data type with names, we do this with "indices" that offset into any record
' from its base address then extract each field manually 
'
' record format:
'
' name:   33 bytes
' age:    1 byte
' height: 1 byte
' weight  1 byte
' 
' each "record" is 36 bytes long
'
byte gPerson[ MAX_PERSONS*BYTES_PER_PERSON ]    


CON
' -----------------------------------------------------------------------------
' MAIN ENTRY POINT   
' -----------------------------------------------------------------------------
PUB Start | index 

  ' intialize serial driver (only works if nothing else is on serial port)
  serial.start(SERIAL_RX_PIN, SERIAL_TX_PIN, %0000, 38_400) ' receive pin, transmit pin, baud rate     

  ' clear the terminal off
  serial.tx( 0 )
  serial.tx( ASCII_CR )
  serial.txstring( string ("Abstract Data Structures | Indexed Array Demo | (c) Parallax 2011"))
  serial.tx( ASCII_CR )

  ' step 1: manually insert records into array(s) one, per person
  ' person 0: Bob Smith, 32 yrs, 6', 187 lb
  ' person 1: Jack O. Lantern, 82 yrs, 5'7", 155 lb  
  ' person 2: Xander Cage, 33 yrs, 6'2", 220 lb  

  InsertRecord( 0, string("Bob Smith"), 32, 6*12, 187 )
  InsertRecord( 1, string("Jack O. Lantern"), 82, 5*12+7, 155 )
  InsertRecord( 2, string("Xander Cage"), 33, 6*12+2, 220 )

  ' now print the records out
  repeat index from 0 to 2
    PrintRecord( index )
       
' end PUB ---------------------------------------------------------------------


CON
' -----------------------------------------------------------------------------
' RECORD MANIPULATION METHODS   
' -----------------------------------------------------------------------------
PUB InsertRecord( pIndex, pStrNamePtr, pAge, pHeight, pWeight ) | recordOffset
{{
DESCRIPTION: Inserts the sent record into the storage array.   
PARMS:       pIndex      - index of record to use.
             pStrNamePtr - pointer to name string to insert. 
             pAge        - age of person.
             pHeight     - height in inches of person.
             pWeight     - weight in pounds of person.  
RETURNS: nothing. 
}}

  ' first compute the offset to access the record we want, a simple multiplication by
  ' the size of each record
  recordOffset := pIndex * BYTES_PER_PERSON

  ' now when we access each field of the compressed data, we use the base offset just
  ' computed along with the "field" indices defined as constants, this gives some feel
  ' of typed data structure

  ' copy name string
  bytemove ( @gPerson[ recordOffset + PERSON_INDEX_NAME], pStrNamePtr, strsize( pStrNamePtr )+1 ) 

  ' and now other field, notice the simple syntax transform a single addition along with the computed
  ' base address/offset is all that is required to access each element properly   
  gPerson[ recordOffset + PERSON_INDEX_AGE ]    := pAge  
  gPerson[ recordOffset + PERSON_INDEX_HEIGHT]  := pHeight 
  gPerson[ recordOffset + PERSON_INDEX_WEIGHT ] := pWeight   
   
' end PUB ---------------------------------------------------------------------

PUB PrintRecord( pIndex ) | feet, inches, recordOffset
{{
DESCRIPTION: Prints the requested record to terminal.  
PARMS: pIndex - index of record to pretty print to screen. 
RETURNS: nothing. 
}}

  ' first compute the offset to access the record we want, a simple multiplication by
  ' the size of each record
  recordOffset := pIndex * BYTES_PER_PERSON

  ' convert height to feet and inches from inches
  feet   := gPerson[ recordOffset + PERSON_INDEX_HEIGHT ] / 12
  inches := gPerson[ recordOffset + PERSON_INDEX_HEIGHT ] // 12 

  serial.tx( ASCII_CR )
  serial.txstring( string ("Name: "))
  serial.txstring( @gPerson[ recordOffset + PERSON_INDEX_NAME ] )
  serial.tx( ASCII_CR )
  
  serial.txstring( string ("Age: "))
  serial.dec( gPerson[ recordOffset + PERSON_INDEX_AGE ] )
  serial.txstring( string (" yrs"))
  serial.tx( ASCII_CR )
    
  serial.txstring( string ("Height: "))
  serial.dec( feet )
  serial.tx( ASCII_SNGL_QUOTE)
  serial.dec( inches )
  serial.tx( ASCII_QUOTE )
  serial.tx( ASCII_CR )
        
  serial.txstring( string ("Weight: "))
  serial.dec( gPerson[ recordOffset + PERSON_INDEX_WEIGHT ] )
  serial.txstring( string (" Lbs"))
  serial.tx( ASCII_CR )

' end PUB ---------------------------------------------------------------------


CON
' -----------------------------------------------------------------------------
' USER TEXT INPUT METHOD(s)   
' -----------------------------------------------------------------------------

CON
' -----------------------------------------------------------------------------
' SOFTWARE LICENSE SECTION   
' -----------------------------------------------------------------------------
{{
┌────────────────────────────────────────────────────────────────────────────┐
│                     TERMS OF USE: MIT License                              │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy│
│of this software and associated documentation files (the "Software"), to    │
│deal in the Software without restriction, including without limitation the  │
│rights to use, copy, modify, merge, publish, distribute, sublicense, and/or │
│sell copies of the Software, and to permit persons to whom the Software is  │
│furnished to do so, subject to the following conditions:                    │
│                                                                            │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE │
│AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS│
│IN THE SOFTWARE.                                                            │
└────────────────────────────────────────────────────────────────────────────┘
}}       