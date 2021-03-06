''*********************************************
''*  Depth Firsth Search Algorithm            *
''*  Author: Jeffrey Allen                    *
''*  Artificial Intelligence                  *
''*  Spring 2014                              *
''*********************************************
'' 
{{{
┌───────────────────────────────────────┐
│      Depth First Search Algorithm     │
│             No Copyright              │
│       See end of file for notes       │
└───────────────────────────────────────┘
This program demonstrates the use the DFS algorithm by finding a goal state G
in a 10 by 10 coordinate grid starting from start state S 

Version History
───────────────

2014.02.14: Initial Version 1

}}

{{=======[ Introduction ]=========================================================
  
                Matrix
                --------------------------------------------------------------
                | 0-9 | 1-9 | 2-9 | 3-9 | 4-9 | 5-9 | 6-9 | 7-9 | 8-9 | 9-9 |
                --------------------------------------------------------------
                | 0-8 | 1-8 | 2-8 | 3-8 | 4-8 | 5-8 | 6-8 | 7-8 | 8-8 | 9-8 |
                --------------------------------------------------------------
                | 0-7 | 1-7 | 2-7 | 3-7 | 4-7 | 5-7 | 6-7 | 7-7 | 8-7 | 9-7 |
                --------------------------------------------------------------
                | 0-6 | 1-6 | 2-6 | 3-6 | 4-6 | 5-6 | 6-6 | 7-6 | 8-6 | 9-6 |
                --------------------------------------------------------------
                | 0-5 | 1-5 | 2-5 | 3-5 | 4-5 | 5-5 | 6-5 | 7-5 | 8-5 | 9-5 |
                --------------------------------------------------------------
                | 0-4 | 1-4 | 2-4 | 3-4 | 4-4 | 5-4 | 6-4 | 7-4 | 8-4 | 9-4 |
                --------------------------------------------------------------
                | 0-3 | 1-3 | 2-3 | 3-3 | 4-3 | 5-3 | 6-3 | 7-3 | 8-3 | 9-3 |
                --------------------------------------------------------------
                | 0-2 | 1-2 | 2-2 | 3-2 | 4-2 | 5-2 | 6-2 | 7-2 | 8-2 | 9-2 |
                --------------------------------------------------------------
                | 0-1 | 1-1 | 2-1 | 3-1 | 4-1 | 5-1 | 6-1 | 7-1 | 8-1 | 9-1 |
                --------------------------------------------------------------
                | 0-0 | 1-0 | 2-0 | 3-0 | 4-0 | 5-0 | 6-0 | 7-0 | 8-0 | 9-0 |
                --------------------------------------------------------------


}}


''=======[ Constants... ]=========================================================
CON

  _CLKMODE = XTAL1 + PLL16X
  _CLKFREQ = 5_000_000
  MAX_STATESPACE = 100 ' Number of spaces
  NUM_OF_BYTES   = 2   ' What each space holds
  LISTSIZE       = 100 'Size of list

  INDEX_X = 0
  INDEX_Y = 1
  
''=======[ Objects..... ]===========================================================
OBJ                                      

  cyborg  : "cyborg"
  listT[LISTSIZE] : "node.spin"
  listV[LISTSIZE] : "node.spin"

''=======[ Variables... ]===========================================================
VAR

'Matrix format
'
' xcoordinate: 1 byte
' ycoordinate: 1 byte
'
'
  
  byte matrix[MAX_STATESPACE * NUM_OF_BYTES]
  

''=======[ Public Functions... ]==================================================   
PUB Main

  ' Inititialize Environment: cyborg and statespace
  cyborg.start                                 ' Start up cyborg
  cyborg.button_mode(true,true)                ' Set button mode to display in LEDs and to reset
  cyborg.set_led(cyborg#POWER, cyborg#BLUE)    ' Turn on power LED
  cyborg.start_motors                          ' Start motors contoller of cyborg
  cyborg.set_speed(7)                          ' Set drawing speed to 50% (7) ... move to 100% first chance I get
  cyborg.set_line_threshold(132)

  '@ gets starting address of the grid'
  bytefill (@matrix,0,MAX_STATESPACE * NUM_OF_BYTES)
  fillMatrix

  ' Initialize State: Where cyborg starts
  cyborg.here_is(0,60)

  ' Successor function



''        2) If T is empty
          if isEmpty(listT)
             cyborg.beep 
''          else select a node n (tuple, my x and y) from T
          else
            candidateNode := pop(ListT)
            xCoordinate := 
              feet   := gPerson[ pIndex ]._height / 12        
            move_to()
          
        3) If state n is the goal
              return
           else remove n from T

        4) Find all descendants of n (N, S, E, & W) not in V and add paths to T, add n to V

          Add clockwise:

             N - can't push if y = 9

             ****Perform check of list V
             
             E - can't push where x = 9

             ****Perform check of list V
             
             S - check if y = 0

             ****Perform check of list V

             W - check if x = 0

             ****Perform check of list V

        5) Go back to #2
              

  
  ' Goal test

PUB InsertCoordinates( Index, x, y ) | matrixOffset
{{
DESCRIPTION: Inserts the coordinate into the storage array.   
PARMS:       Index      - index of record to use. 
             x           - x Coordinate
             y           - y Coordinate  
RETURNS: nothing. 
}}

  ' first compute the offset to access the record we want, a simple multiplication by
  ' the size of each record
  matrixOffset := Index * NUM_OF_BYTES

  ' now when we access each field of the compressed data, we use the base offset just
  ' computed along with the "field" indices defined as constants, this gives some feel
  ' of typed data structure 

  ' and now other field, notice the simple syntax transform a single addition along with the computed
  ' base address/offset is all that is required to access each element properly   
  matrix[ matrixOffset + INDEX_X ] := x  
  matrix[ matrixOffset + INDEX_Y] := y    


PUB fillMatrix | Xcounter, Ycounter, index, i, j

  Xcounter := 0
  Ycounter := 0
  index    := 0

  repeat i from 0 to MAX_STATESPACE-1
    if Ycounter > 9                     ' Y loop
      Ycounter := 0
    repeat j from 0 to 9                ' X loop
      InsertCoordinates(index, Xcounter, Ycounter)
      Xcounter++
      index++
    Xcounter := 0
    Ycounter++
    

PUB push( Index, xPosition, yPosition )
{{
DESCRIPTION: Inserts the sent matrix into the object storage array.   
PARMS:       Index       - index of matrix to use.
             xPosition   - x coordinate 
             yPosition   - y coordinate  
RETURNS: nothing. 
}}

  ' now we access the records as "method" calls to our object array, the syntax
  ' is a little rough, but surely better than all the indexing and contrived
  ' arrays of the previous examples, now we have a nice layer of abstraction

  ' now write the fields, syntax is a little tricky since to write to any
  ' field we have to make a call to the setter method, and then pass the value
  ' as a parameter, but a couple parens is really all we need syntactically that
  ' takes the place of ":=" if we could support operator overloading, but can't
  ' NOTE: all write methods have a trailing underscore "_" this is so we can
  ' keep the name similar to the data fields and remember to put an underscore
  ' before for getter, underscore after for setter

  matrix[ Index ].xPos_( xPosition )
  matrix[ Index ].yPos_( yPosition )

PUB isEmpty( array )

  ' Lookup gets the value from an indexed position within a list '

  temp := lookupz(array)

  if array = 0
    return true
  else
      return false

PUB retrieveIndex

'' Todo - Pop


{{ *************DEPRACATED FOR NOW***************
' fill grid with x coordinates '
PUB fillXcoordinates | counter, i

  counter := 0
  
  repeat i from 0 to LISTSIZE
    if counter > 9
      counter := 0
    if (i//2) == 0
      grid[i] := counter
      counter++
      
PUB fillYcoordinates | counter, i, j, k

  ' fill grid with x coordinates
  repeat i from 1 to 19 step 2    ' column   
    k := 0
    counter := 0
    repeat j from 1 to 19 step 2  ' row
      grid[k] := counter          
      k := i + 20
      counter++
  
  
''=======[ Private Functions... ]=================================================

{{ Private function todo list:

  Add a node to a list
  Remove a node from a list
  Check goal
  Check list V

}}

''=======[ Data... ]=================================================}}