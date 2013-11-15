/*
 Traffic lights client
 
 This sketch connects to a software build, continuous integration (CI) server 
 (e.g. TeamCity) using an Arduino Wiznet Ethernet shield and switches a SPDT relay 
 depending on the state (HTTP response code) returned from a buildStatus page.
 
 HTTP/200 -> Build(s) successful, Green light on
 HTTP/400 or any other value -> Build(s) broken, Red light on
   
 Circuit:
 * Ethernet shield attached to pins 10, 11, 12, 13
 * VEZ Single Pole Double Through (SPDT) Relay attached to pins +5v, gnd, 8
 
 created 23 April 2011
 by Lloyd Holman
 
 http://github.com.......
 This code is in the public domain.
 
 Based on WebClient and BlinkWithoutDelay examples (by David A. Mellis) 
*/

#include <SPI.h>
#include <Ethernet.h>

byte mac[] = { 0xD90, 0xDA2, 0xDDA, 0xD00, 0xD3D, 0xDB8 };
IPAddress ip(192,168,15,223);
//IPAddress server(192,168,15,138); //mnp-81222
//IPAddress server(173,194,41,105); //google.com
char server[] = "FQbuildServerName";

EthernetClient client;
  
// used to set the digital pin driving the relay, HIGH or LOW
int pinState = LOW;          
// the digital pin driving the relay 
const int relayPin =  8;      

// an array of TeamCity projectNames to check status for.  Ideally we would query TeamCity for this list dynamically
char* projectNames[] = {"Automation"};		
const int projectNamesCount = sizeof(projectNames) / sizeof(char*);
//int GetServerStatus();
int buildStatus = 0;

void setup() {
  // set the digital pin as output:
  pinMode(relayPin, OUTPUT);      

  Serial.begin(9600);

  // start the Ethernet connection:
  if (Ethernet.begin(mac) == 0) {
    Serial.println("Failed to configure Ethernet using DHCP");
    // no point in carrying on, so do nothing forevermore:
    // try to congifure using IP address instead of DHCP:
    Ethernet.begin(mac, ip);
  }
  delay(1000);
}

void loop()
{
      int httpStatus = GetServerStatus();
      if (httpStatus != 505)
      {
         buildStatus = httpStatus; 
      }
      Serial.print("buildStatus: ");
      Serial.println(buildStatus);

      if (buildStatus == 200 && pinState == LOW) 
        pinState = HIGH;
      else if (buildStatus != 200 && pinState == HIGH)
        pinState = LOW;

      digitalWrite(relayPin, pinState);
      delay(5000);
}

//static int GetServerStatus(char* projectNameToCheck)
static int GetServerStatus()
{
    int httpStatus = 0;  //indicates a connection error with 0 
    int parseStatus = 0;
    String response;

    if (client.connect(server, 80)) {
      client.println("GET /simpleBuildStatus.html?projectId=DeploymentPipeline&guest=1 HTTP/1.0");   
      client.println("Host: FQbuildServerName");
      client.println("Connection: close");
      client.println();
    } 
    else {
      Serial.println("connection failed");
    }
    // wait for the response from the CI server.
    while (1){
      while (client.available()) {
        char c = client.read();
        if (c != ' ') //Strip out all spaces
          response += c;
      }

      if (!client.connected()) {
          break;
      }
    }

    Serial.print(response);    
    httpStatus = response.substring(8,11).toInt();
    Serial.print("httpStatus: ");
    Serial.println(httpStatus);
    
    client.flush();
    client.stop();
    return httpStatus;   
}

