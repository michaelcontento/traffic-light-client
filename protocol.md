Lamp
----

Specifies the state of one lamp and the *TIMER-MS* is the blink interval in milliseconds.

    BODY     = "lamp" SP COLOR SP MODE LF
    COLOR    = ("red" | "yellow" | "green" )
    MODE     = ("on" | "off" | "blink" SP TIMER-MS)
    TIMER-MS = DIGIT+

Example:

    lamp yellow off
    lamp red on
    lamp green blink 500

In this example the red lamp would be on, the yellow lamp off and the green one would blink in an 500ms interval.


Update timer
------------

Delay in ms for the next request to the server.
    
    BODY  = "ttl" SP DIGIT+ LF

Example:
    
    ttl 5000

In this case the client would ask the server again after 5000ms.

Text
----

The text that is displayed on the LCD-Display. 

    BODY  = "text" SP DIGIT+ SP [CHAR+] LF

Example:
    
    text 11 Hello World
