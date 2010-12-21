/***************************************************
 **                CONFIGURATION                  **
 ***************************************************/

// The pins of the lamps
int pinLampRed    = 7;
int pinLampYellow = 8;
int pinLampGreen  = 9;

// The setting for the ethernet 
byte mac[]     = { 0x44, 0x1c, 0xc0, 0xad, 0x86, 0x31 };
byte ip[]      = { 192, 168, 71, 113 };
byte gateway[] = { 192, 168, 71, 254 };
byte subnet[]  = { 255, 255, 252, 0 };

// The traffic-light-server that should be used
byte server[]  = { 192, 168, 70, 105 };
#define serverPort 8804
#define serverPath "/"
#define serverReadDelay 250
#define minTTL 10000

/***************************************************
 **        DON'T TOUCH ANYTHING BELOW HERE        **
 ***************************************************/

#include <SPI.h>
#include <Ethernet.h>
#include "WString.h"

// Modes for the lamps
#define MODE_ON           "on"
#define MODE_OFF          "off"
#define MODE_BLINK        "blink"

// Length for the used String object
#define maxResponseLength 200
#define maxTextLength     25

// Variables used for the communication 
Client        client(server, serverPort);
unsigned long nextStateChange   = 0;

// Variables to track the current state 
String       text               = String(maxTextLength);
String       modeLampRed        = MODE_OFF;
String       modeLampYellow     = MODE_OFF;
String       modeLampGreen      = MODE_OFF;
unsigned int intervalLampRed    = 0;
unsigned int intervalLampYellow = 0;
unsigned int intervalLampGreen  = 0;

// Variables for the response parsing
String response = String(maxResponseLength);
String event = String(maxResponseLength);
int posNewLine = 0;
boolean ttlParsed = false;
    
void changeState()
{      
    // Request the job status page
    client.println("GET /");
    client.println();
    delay(serverReadDelay);
           
    // Read response from the server
    response = "";       
    while (client.available() > 0) {
        response += (char) client.read();
    }      
   
    ttlParsed = false;
   
    // Process every event in the response
    while (response.length() > 0) {
        posNewLine = response.indexOf("\n");      
        event      = response.substring(0, 5);     
     
        if (event.startsWith("lamp")) {
            String        body               = response.substring(5, posNewLine);   
            String*       targetLampMode     = NULL;
            unsigned int* targetLampInterval = 0;
    
            if (body.startsWith("red")) {
                targetLampMode     = &modeLampRed;
                targetLampInterval = &intervalLampRed;
            } else if (body.startsWith("yellow")) {
                targetLampMode     = &modeLampYellow;
                targetLampInterval = &intervalLampYellow;
            } else if (body.startsWith("green")) {
                targetLampMode     = &modeLampGreen;
                targetLampInterval = &intervalLampGreen;
            }
    
            if (body.endsWith(MODE_ON)) {
                *targetLampMode     = MODE_ON;
                *targetLampInterval = 0;
            } else if (body.endsWith(MODE_OFF)) {
                *targetLampMode     = MODE_OFF;
                *targetLampInterval = 0;
            }    
        } else if (event.startsWith("ttl")) {
            ttlParsed = true;
            char ttlString[10] = "";
            response.substring(4, posNewLine).toCharArray(ttlString, 25);
            nextStateChange = millis() + max(minTTL, atoi(ttlString));
        }
        
        response = response.substring(posNewLine + 1);
    }   
    
    if (!ttlParsed) { 
        nextStateChange = millis() + minTTL;
    }      
 }

void setup()
{
    pinMode(pinLampRed,    OUTPUT);
    pinMode(pinLampYellow, OUTPUT);
    pinMode(pinLampGreen,  OUTPUT);

    Ethernet.begin(mac, ip, gateway, subnet);  
}

void loop()
{         
    if (millis() >= nextStateChange) {
        if (client.connect()) {
            changeState();
            client.stop();             
        }
        
        digitalWrite(pinLampRed,    (modeLampRed    == MODE_ON) ? HIGH : LOW);
        digitalWrite(pinLampYellow, (modeLampYellow == MODE_ON) ? HIGH : LOW);
        digitalWrite(pinLampGreen,  (modeLampGreen  == MODE_ON) ? HIGH : LOW);    
    }
}


