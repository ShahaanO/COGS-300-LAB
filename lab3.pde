// ====== COGS 300 Bot Controller (Processing) ======
// WASD sends single-char commands to Arduino over serial.
// W=forward, A=left (pivot), S=backward, D=right (pivot), Space=stop
// +/- adjusts speed (on Arduino). GUI shows current key state.

import processing.serial.*;

Serial arduino;
final int BAUD = 115200;

// Choose your serial port index after first run prints them.
// e.g., on Windows: "COM5", on macOS: something like "/dev/tty.usbmodem1101"
final int PORT_INDEX = 0; // <-- CHANGE ME after you check the console

// Track key states so we can resolve multiple keys
boolean wDown=false, aDown=false, sDown=false, dDown=false;

void setup() {
  size(500, 220);
  printArray(Serial.list());
  try {
    arduino = new Serial(this, Serial.list()[PORT_INDEX], BAUD);
    arduino.clear();
    arduino.bufferUntil('\n');
  } catch (Exception e) {
    println("Serial open failed. Set correct PORT_INDEX.");
  }
  surface.setTitle("COGS 300 Bot: WASD Controller");
  textFont(createFont("Monospaced", 16));
}

void draw() {
  background(24);
  fill(240);
  text("Controls: W/A/S/D = move, SPACE = stop, +/- = speed", 20, 30);

  // Visual key state
  drawKey("W", 220, 70, wDown);
  drawKey("A", 170, 120, aDown);
  drawKey("S", 220, 120, sDown);
  drawKey("D", 270, 120, dDown);
  drawKey("⎵", 220, 170, keyPressed && key==' ');

  // Decide which command to send based on current keys
  // Priority order: stop if no keys; else W, S, A, D (single command at a time).
  char cmd = 0;
  if      (wDown && !aDown && !dDown && !sDown) cmd = 'W';
  else if (sDown && !aDown && !dDown && !wDown) cmd = 'S';
  else if (aDown && !wDown && !sDown && !dDown) cmd = 'A';
  else if (dDown && !wDown && !sDown && !aDown) cmd = 'D';
  else if (!wDown && !aDown && !sDown && !dDown) cmd = ' '; // stop

  // Send command continuously ~10x/sec so brief drops don't leave motors running
  if (frameCount % 6 == 0 && cmd != 0) send(cmd);
}

void drawKey(String label, float x, float y, boolean on) {
  noFill();
  stroke(on ? 180 : 80);
  strokeWeight(on ? 4 : 2);
  rectMode(CENTER);
  rect(x, y, 48, 48, 8);
  fill(on ? 220 : 140);
  noStroke();
  textAlign(CENTER, CENTER);
  text(label, x, y);
}

void keyPressed() {
  switch (key) {
    case 'w': case 'W': wDown = true; break;
    case 'a': case 'A': aDown = true; break;
    case 's': case 'S': sDown = true; break;
    case 'd': case 'D': dDown = true; break;
    case ' ': send(' '); break; // immediate stop
    case '+': case '=': send('+'); break;
    case '-': case '_': send('-'); break;
  }
}

void keyReleased() {
  switch (key) {
    case 'w': case 'W': wDown = false; break;
    case 'a': case 'A': aDown = false; break;
    case 's': case 'S': sDown = false; break;
    case 'd': case 'D': dDown = false; break;
  }
}

void send(char c) {
  if (arduino != null) {
    arduino.write(c);
    // println("TX: " + c);
  }
}

// (Optional) read Arduino state prints
void serialEvent(Serial s) {
  String line = s.readStringUntil('\n');
  if (line != null) println(line.trim());
}
