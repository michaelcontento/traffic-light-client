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
byte server[]  = { 127, 0, 0, 1 };
#define serverPort 80
#define serverPath "/"
#define serverReadDelay 100

/***************************************************
 **        DON'T TOUCH ANYTHING BELOW HERE        **
 ***************************************************/

#include <SPI.h>
#include <Ethernet.h>
#include "WString.h"

// Modes for the lamps
#define MODE_ON           "on"
#define MODE_OFF          "off"
#deinfe MODE_BLINK        "blink"

// Length for the used String object
#define maxResponseLength 1024
#define maxTextLength     255

// Variables used for the communication 
Client client(server, serverPort);
String        response           = String(maxResponseLength);
unsigned long nextStateChange    = 0;

// Variables to track the current state 
String        text               = String(maxTextLength);
char*         modeLampRed        = MODE_OFF;
char*         modeLampYellow     = MODE_OFF;
char*         modeLampGreen      = MODE_OFF;
unsigned int  intervalLampRed    = 0;
unsigned int  intervalLampYellow = 0;
unsigned int  intervalLampGreen  = 0;

void logError(char* message)
{
    Serial.writeln("ERROR: " + message);
}

void logInfo(char* message)
{
    Serial.writeln("INFO : " + message);
}

void changeState()
{
    // Request the job status page
    client.print("GET ");
    client.print(hudsonJobName);
    client.println();
    delay(serverReadDelay);
           
    // Read response from the server
    response = ""; 
    for (char c; c != -1; c = client.read()) {
        response.append(c);
    }     
   
    // Base positions - used to split the event 
    int posNewLine     = 0;
    int posFirstSpace  = 0;
    int posSecondSpace = 0;

    // Process every event in the response
    while (response.length() > 0) {
        posNewLine     = response.indexOf("\n");
        posFirstSpace  = response.indexOf(" ");
        posSecondSpace = response.indexOf(" ", posFirstSpace);

        switch (response.substr(0, 3)) {
            case "lamp":
                char*        color              = response.substr(posFirstSpace, posSecondSpace);
                String       mode               = response.substr(posSecondSpace, 5);
                char*        targetLampMode     = MODE_OFF;
                unsigned int targetLampInterval = 0;

                switch (color) {
                    case "red":
                        targetLampMode     = &modeLampRed;
                        targetLampInterval = &intervalLampRed;
                        break;

                    case "yellow":
                        targetLampMode     = &modeLampYellow;
                        targetLampInterval = &intervalLampYellow;
                        break;

                    case "green":
                        targetLampMode     = &modeLampGreen;
                        targetLampInterval = &intervalLampGreen;
                        break;

                    default:
                        logError("response: invalid color: " + color);
                }

                if (mode.startsWith(MODE_ON)) {
                    targetLampMode     = MODE_ON;
                    targetLampInterval = 0;
                } else if (mode.startsWith(MODE_OFF)) {
                    targetLampMode     = MODE_OFF;
                    targetLampInterval = 0;
                } else if (mode.startsWith(MODE_BLINK)) {
                    int posThirdSpace  = response.indexOf(" ", posSecondSpace);
                    targetLampMode     = MODE_BLINK;
                    targetLampInterval = response.substr(posThirdSpace, posNewLine);
                } else {
                    logError("response: invalid mode: " + mode.substr(0, 5).toCharArray());
                }

                response = response.substr(posNewLine);
                break;

            case "ttl ":
                int ttl         = response.substring(posFirstSpace, posNewLine);
                nextStateChange = millis() + ttl;
                response        = response.substr(posNewLine);
                logInfo("response: next state change in ~" + ttl + "ms");
                break;

            case "text":
                int textLength = response.substr(posFirstSpace, postSecondSpace);
                text           = response.substr(posSecondSpace, min(textLength, maxTextLength);
                response       = response.substr(textLength);
                break;
        
            default:
                logError("response: invalid event: " + response.substr(0, 5).toCharArray());
                response = response.substr(posNewLine);
        }
    }
}

void setup()
{
    pinMode(lampRed,    OUTPUT);
    pinMode(lampYellow, OUTPUT);
    pinMode(lampGreen,  OUTPUT);

    Ethernet.begin(mac, ip, gateway, subnet);
    Serial.begin(9600);    

    logInfo("setup done");
    // TODO: Add the interrupt handling
    // TODO: Implement the blink logic in the interrupt method
}

void loop()
{         
    if (millis() >= nextStateChange) {
        if (client.connect()) {
            changeState();
            client.stop();             
        }
    }
}

