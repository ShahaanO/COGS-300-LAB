// COGS 300 Bot — One L298N, two motors, WASD over Serial (115200)
// Left:  enA=11, in1=12, in2=13
// Right: enB=9,  in3=8,  in4=7
const uint8_t enL=11,inL1=12,inL2=13;
const uint8_t enR=9, inR1=8, inR2=7;

uint8_t speedPct=60, minPct=45, maxPct=100;
uint8_t pctToPWM(uint8_t p){ if(p>100)p=100; return (uint8_t)(p*255/100); }

void setupPins(){
  pinMode(enL,OUTPUT); pinMode(inL1,OUTPUT); pinMode(inL2,OUTPUT);
  pinMode(enR,OUTPUT); pinMode(inR1,OUTPUT); pinMode(inR2,OUTPUT);
}

void setSide(int dir,uint8_t pwm,uint8_t en,uint8_t a,uint8_t b){
  if(dir>0){ digitalWrite(a,HIGH); digitalWrite(b,LOW); }
  else if(dir<0){ digitalWrite(a,LOW); digitalWrite(b,HIGH); }
  else { digitalWrite(a,LOW); digitalWrite(b,LOW); }
  analogWrite(en,pwm);
}

void driveBoth(int ldir,int rdir,uint8_t pwm){
  setSide(ldir,pwm,enL,inL1,inL2);
  setSide(rdir,pwm,enR,inR1,inR2);
}

void stopAll(){ analogWrite(enL,0); analogWrite(enR,0); }

void printState(const char* s){
  Serial.print(F("[STATE] ")); Serial.print(s);
  Serial.print(F(" | speed=")); Serial.print(speedPct); Serial.println(F("%"));
}

void setup(){
  setupPins(); stopAll(); Serial.begin(115200); delay(200);
  Serial.println(F("W/A/S/D = move, SPACE=stop, +/- speed (one L298N)"));
}

void loop(){
  if(Serial.available()){
    char c=Serial.read(); if(c>='a'&&c<='z') c-=32;
    uint8_t pwm=pctToPWM(speedPct<minPct?minPct:speedPct);
    switch(c){
      case 'W': driveBoth(+1,+1,pwm); printState("Forward"); break;
      case 'S': driveBoth(-1,-1,pwm); printState("Backward"); break;
      case 'A': driveBoth(-1,+1,pwm); printState("Turn Left"); break;
      case 'D': driveBoth(+1,-1,pwm); printState("Turn Right"); break;
      case ' ': stopAll(); printState("Stop"); break;
      case '+': speedPct=(speedPct+5>maxPct)?maxPct:speedPct+5; printState("Speed++"); break;
      case '-': speedPct=(speedPct<minPct+5)?minPct:speedPct-5; printState("Speed--"); break;
      case '0': speedPct=0; stopAll(); printState("Speed 0"); break;
      case '5': speedPct=60; printState("Speed 60"); break;
      case '9': speedPct=100; printState("Speed 100"); break;
    }
  }
}
