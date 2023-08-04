// Printer monitor for 4 3D printers
#include <LiquidCrystal_I2C.h>
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>
#include <WiFiClientSecure.h>

#define WIFI_SSID "<SSID of your network>"
#define WIFI_PASSWORD "<WPA password of your network>"

// List of printers to monitor
// Display name (max. 5 chars), Printer address, API key (or maker password in case of Prusa Mini/MK4)
const char *Printers[]={
 "MK3.9", "http://192.168.0.10", "5B9379B9C7A041FC88334BB981B1C728", // My MK4 Upgrade printer
 "MK4","http://192.168.0.49:80","hdp4DXhT4ZDfHpN", // My first MK4 printer
 "MK4-2","http://192.168.0.50:80","wachtwoordMK42", // My second MK4 printer
 "Mini","http://192.168.0.4:80","XFMzbJ6DUnozg2y" // My Prusa Mini printer
};
#define NUMPRINTERS (sizeof(Printers) / sizeof(Printers[0])/3)

#define BUZZER   D0
#define BTN_MK39 D5
#define BTN_MK4  D6
#define BTN_MK42 D7
#define BTN_MINI D4
// LCD shows: filename of currently printing file, printer name, tool temperature and completion percentage

/* Wiring I2C LCD - See also schematic
GND	=> GND of D1 Mini
VCC	=> 5V of D1 Mini
SDA	=> D2 of D1 Mini
SCL	=> D1 of D1 Mini*/

LiquidCrystal_I2C lcd(0x27, 16,2);
ESP8266WiFiMulti D1Mini;

void Cls(const char *txt=NULL);

void setup(){
 pinMode(BTN_MK39, INPUT_PULLUP);
 pinMode(BTN_MK4, INPUT_PULLUP);
 pinMode(BTN_MK42, INPUT_PULLUP);
 pinMode(BTN_MINI, INPUT_PULLUP);
 pinMode(BUZZER,OUTPUT);
 digitalWrite(BUZZER,LOW);

 Serial.begin(115200);
 Serial.println();
 lcd.begin(5,4); // LCD wired to D1 and D2
 lcd.init();
 lcd.backlight();
 
 Cls("Starting Wifi...");
 WiFi.mode(WIFI_STA);
 D1Mini.addAP(WIFI_SSID, WIFI_PASSWORD); 
 Cls("Wifi OK!");
 digitalWrite(BUZZER,HIGH);
 delay(300);
 digitalWrite(BUZZER,LOW); 
}

bool Printing[]={false,false,false,false};
int Temp[]={-1,-1,-1,-1};
int Completed[]={0,0,0,0};
String Status[4],Files[4];

void loop(){ 
 bool HeeftGetoond=false;
 if(D1Mini.run()== WL_CONNECTED){    
  WiFiClient Wifi;
  HTTPClient http;  
  // Query all printers for their status
  for(int i=0; i<NUMPRINTERS; i++) {
   if(!ButtonPressed(i)) continue;   
   http.begin(Wifi,String(Printers[i*3+1])+String("/api/job"));
   http.addHeader("X-Api-Key", Printers[i*3+2]);        
   int httpCode = http.GET();
   if(httpCode > 0) {     
    String payload = http.getString();
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, payload);
    String CurStatus = doc["state"].as<String>();
    if(CurStatus.indexOf("Printing")>=0) {
     // This printer is currently printing
     Files[i]=doc["job"]["file"]["name"].as<String>();
     if(IsWaitingForColourChange(i)) {      
      Files[i]="* Change color *";
      Piep();                
     }
     Printing[i]=true;
     Status[i]=String("Printing");
     float Progress = doc["progress"]["completion"].as<float>();
     Serial.println(Progress);
     Cls();
     int p=round(Progress*100);     
     lcd.print(Files[i]);
     lcd.setCursor(0,1);
     lcd.printf("%-5s %3d%cC %3d%%",Printers[i*3],GetTemperatuur(i),223,p);
     HeeftGetoond=true;
     delay(5000);
    }
    else {
     // Printer is not printing
     Printing[i]=false;
     Status[i]=String("Not printing");
     Cls(Printers[i*3]);
     lcd.setCursor(0,1);
     lcd.print("Not printing"); 
     HeeftGetoond=true;
     delay(5000);    
    }
   }
   else {
    // Printer not reachable via network (probably switched off)
    Printing[i]=true;
    Status[i]="Switched off";
    Cls(Printers[i*3]);
    lcd.setCursor(0,1);
    lcd.print("Switched off");  
    HeeftGetoond=true;
    delay(5000);            
   }    
  }//next printer
 }//Connected

 if(!HeeftGetoond) {
  Cls("Alle switches");
  lcd.setCursor(0,1);
  lcd.print("are off!    ==>");
  delay(5000);
 }
}

void Piep() {
 digitalWrite(BUZZER,HIGH);
 delay(500);
 digitalWrite(BUZZER,LOW);
}

bool IsWaitingForColourChange(int PrinterIX) {
 // Deze werkt alleen voor Prusa-printers, dus niet met Octoprint
 static double PrevCompletion[NUMPRINTERS];
 String URL = String(Printers[PrinterIX*3+1])+String("/api/printer");
 WiFiClient client; 
 HTTPClient http;   
 http.begin(client,URL);
 http.addHeader("X-Api-Key", Printers[PrinterIX*4+2]);
 int code=http.GET(); 
 String payload = http.getString();
 DynamicJsonDocument doc(1024);
 deserializeJson(doc, payload);
 http.end();
 return doc["telemetry"]["material"].as<String>()=="---"; 
}

int GetTemperatuur(int ix) {
 WiFiClient Wifi;
 HTTPClient http;  
 http.begin(Wifi,String(Printers[ix*3+1])+String("/api/printer"));
 http.addHeader("X-Api-Key", Printers[ix*3+2]);        
 int httpCode = http.GET();
 if(httpCode>0) {
  String json = http.getString();
  DynamicJsonDocument doc(1024);
  deserializeJson(doc,json);
  float t = doc["temperature"]["tool0"]["actual"].as<float>();
  http.end();
  return round(t);
 }
 http.end();
 return -1;         
}

void Cls(const char *txt /*=NULL*/) {
 lcd.clear();
 lcd.setCursor(0,0);
 if(txt) lcd.print(txt);
}

bool ButtonPressed(int i) {
 int pressed;
 
 if(i==0) pressed=digitalRead(BTN_MK39)==LOW; 
 else if(i==1) pressed=digitalRead(BTN_MK4)==LOW; 
 else if(i==2) pressed=digitalRead(BTN_MK42)==LOW;
 else if(i==3) pressed=digitalRead(BTN_MINI)==LOW;
 else return false; 
 Serial.printf("Button %d, pressed? %d\r\n",i,pressed);
 return pressed!=0;
}
