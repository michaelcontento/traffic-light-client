/***************************************************
 **                CONFIGURATION                  **
 ***************************************************/

// The pins of the lamps
int lampRed    = 7;
int lampYellow = 8;
int lampGreen  = 9;

// The setting for the ethernet 
byte mac[]     = { 0x44, 0x1c, 0xc0, 0xad, 0x86, 0x31 };
byte ip[]      = { 192, 168, 71, 113 };
byte gateway[] = { 192, 168, 71, 254 };
byte subnet[]  = { 255, 255, 252, 0 };

// The traffic-light-server that should be used
byte server[]  = { 79, 110, 87, 189 };
#define serverPort 80
#define serverPath "/"

/***************************************************
 **        DON'T TOUCH ANYTHING BELOW HERE        **
 ***************************************************/

#include <SPI.h>
#include <Ethernet.h>
#include "WString.h"

unsigned long nextStateChange = 0;
String response = String(maxResponseLength);
Client client(server, serverPort);

void doCheck()
{
    // Request the job status page
    client.print("GET ");
    client.print(hudsonJobName);
    client.println();
    // TODO: Short delay?
           
    // Read response from the server
    response = ""; 
    for (char c; c != -1; c = client.read()) {
        response.append(c);
    }     
    
    // Process the response
    // TODO: Process every line of the response
}

void setup()
{
    pinMode(lampRed,    OUTPUT);
    pinMode(lampYellow, OUTPUT);
    pinMode(lampGreen,  OUTPUT);

    Ethernet.begin(mac, ip, gateway, subnet);
    Serial.begin(9600);    

    // TODO: Add the interrupt handling
    // TODO: Implement the blink logic in the interrupt method
}

void loop()
{         
    if (millis() >= nextStateChange) {
        if (client.connect()) {
            doCheck();
            client.stop();             
        }
    }
}

