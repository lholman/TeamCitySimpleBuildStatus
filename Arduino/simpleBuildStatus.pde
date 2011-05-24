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

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  0xD90, 0xDA2, 0xDDA, 0xD00, 0xD3D, 0xDB8 };
byte subnet[] = { 255, 255, 255, 0 }; 

byte ip[] = { 192,168,4,30 }; //work
//byte ip[] = { 192,168,1,110 }; //home

byte gateway[] = { 192, 168, 4, 1 }; // work
//byte gateway[] = { 192, 168, 1, 1 }; //home

//byte server[] = { 10,100,105,16 }; // sd-swk-dev022 (dev)
byte server[] = { 10,100,101,8 }; // sp-swk-tcs01 (prod)
//byte server[] = { 93,91,23,45 }; // datumgenerics TeamCitydummy site (test)

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
//Client client(server, 771); // sd-swk-dev022 (dev)
Client client(server, 80); // sp-swk-tcs01 (prod)
//Client client(server, 8080); //home

int pinState = LOW;           // used to set the digital pin driving the relay, HIGH or LOW
const int relayPin =  8;      // the digital pin driving the relay

int GetServerStatus();


void setup() {
  // set the digital pin as output:
  pinMode(relayPin, OUTPUT);      

  // start the Ethernet connection:
  Ethernet.begin(mac, ip, gateway);
  // start the serial library:
  Serial.begin(9600);
  // give the Ethernet shield a second to initialize:
  delay(1000);
}

void loop()
{
  int buildStatus = GetServerStatus();
  Serial.print("buildStatus: ");
  Serial.println(buildStatus);
  
  if (buildStatus == 200 && pinState == LOW)
    pinState = HIGH;
  else if (buildStatus != 200 && pinState == HIGH)
    pinState = LOW;
  
  digitalWrite(relayPin, pinState);
  
  delay(30000);
}

static int GetServerStatus()
{
    int httpStatus = 0;  //indicate a connection error with 0 
    int parseStatus = 0;

    Serial.println("connecting...");
    if (client.connect()) {
      Serial.println("connected");
      // Make the HTTP Get request:
      client.println("GET /simpleBuildStatus.html?projectName=DCP_R17&guest=1 HTTP/1.0");    
      client.println();
    } 
    else {
      // if you didn't get a connection to the server:
      Serial.println("connection failed");
    }
    
    // wait for the response from the CI server.
    bool gotStatus = false;
    while (1){ 
  	while (client.available()) {
  	    char c = client.read();
            Serial.print(c);

	    switch(parseStatus) {
              case 0:
  		if (c == ' ') parseStatus++; break;  // skip "HTTP/1.1 "
              case 1:
  		if (c >= '0' && c <= '9') {
  			httpStatus *= 10;
  			httpStatus += c - '0';
  		} else {
  			parseStatus++;
  		}
	    }            

  	}
	if (!client.connected()) {
	    break;
	}  
    }

    client.flush();
    client.stop();
    return httpStatus;   
}

