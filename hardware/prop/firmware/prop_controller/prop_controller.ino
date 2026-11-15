// =============================================================================
//  Bronchoscopy Simulator — Vive scope prop controller
//  Reads the deflection lever with an AS5600 magnetic encoder and presents it
//  as a HID joystick axis, so the simulator needs no serial plumbing.
//
//  Board : Raspberry Pi Pico / RP2040-Zero (Arduino-Pico core 4.x)
//          Board manager: "Raspberry Pi Pico/RP2040" by Earle Philhower
//  Wiring:
//          AS5600 VCC -> 3V3          AS5600 SDA -> GP4
//          AS5600 GND -> GND          AS5600 SCL -> GP5
//          AS5600 DIR -> GND          (flip to 3V3 if the axis is inverted)
//  Magnet:  Ø6 x 2.5 mm diametric, centred on the lever pivot, 1.5-3 mm gap.
//
//  Behaviour:
//    * first boot (or holding the lever forward at boot) enters calibration:
//      sweep the lever to both stops within 8 seconds
//    * calibration is stored in flash; subsequent boots are silent
//    * the axis is centred, deadzoned and clamped; raw angle is printed at
//      115200 baud for diagnostics
//
//  Axis convention: -32767 = full up/back, 0 = centred, +32767 = full forward.
//  Set AXIS_RANGE if your joystick stack expects 0..1023 instead.
// =============================================================================

#include <Wire.h>
#include <EEPROM.h>
#include <Joystick.h>

#define AS5600_ADDR 0x36
#define PIN_SDA 4
#define PIN_SCL 5
#define AXIS_RANGE 32767      // arduino-pico Joystick axis scale
#define DEADZONE 0.03f
#define CALIBRATION_MS 8000
#define MAGIC 0x42A5          // bump when the stored format changes

struct Calibration {
  uint16_t magic;
  uint16_t centre;
  uint16_t half_span;
};

Calibration cal;
bool calibrating = false;
uint32_t cal_start = 0;
uint16_t raw_min = 4095, raw_max = 0;

uint16_t read_raw_angle() {
  Wire.beginTransmission(AS5600_ADDR);
  Wire.write(0x0C);                 // RAW_ANGLE high byte
  if (Wire.endTransmission(false) != 0) return 0;
  if (Wire.requestFrom(AS5600_ADDR, 2) != 2) return 0;
  uint16_t hi = Wire.read();
  uint16_t lo = Wire.read();
  return ((hi << 8) | lo) & 0x0FFF; // 12-bit
}

void load_calibration() {
  EEPROM.get(0, cal);
  if (cal.magic != MAGIC || cal.half_span < 100) {
    Serial.println(F("no calibration stored"));
    calibrating = true;
  }
}

void save_calibration() {
  EEPROM.put(0, cal);
  EEPROM.commit();
  Serial.println(F("calibration saved"));
}

void start_calibration() {
  calibrating = true;
  cal_start = millis();
  raw_min = 4095;
  raw_max = 0;
  Serial.println(F("CALIBRATION: sweep the lever to both stops (8 s)"));
}

void finish_calibration() {
  if (raw_max - raw_min < 200) {
    Serial.println(F("calibration failed: not enough travel, retrying"));
    start_calibration();
    return;
  }
  cal.magic = MAGIC;
  cal.centre = (raw_min + raw_max) / 2;
  cal.half_span = (raw_max - raw_min) / 2;
  calibrating = false;
  save_calibration();
  Serial.print(F("centre="));
  Serial.print(cal.centre);
  Serial.print(F(" half_span="));
  Serial.println(cal.half_span);
}

float lever_normalised(uint16_t raw) {
  if (cal.half_span == 0) return 0.0f;
  float v = ((float)raw - (float)cal.centre) / (float)cal.half_span;
  v = constrain(v, -1.0f, 1.0f);
  if (fabsf(v) < DEADZONE) v = 0.0f;
  return v;
}

void setup() {
  Serial.begin(115200);
  Wire.setSDA(PIN_SDA);
  Wire.setSCL(PIN_SCL);
  Wire.begin();
  Wire.setClock(400000);
  EEPROM.begin(64);
  load_calibration();

  Joystick.begin();
  Joystick.useManualSend(true);
  Serial.print(F("prop controller up; "));
  if (calibrating) start_calibration();
  else { Serial.print(F("centre=")); Serial.println(cal.centre); }
}

void loop() {
  uint16_t raw = read_raw_angle();
  float lever = lever_normalised(raw);

  if (calibrating) {
    raw_min = min(raw_min, raw);
    raw_max = max(raw_max, raw);
    if (millis() - cal_start > CALIBRATION_MS) finish_calibration();
    lever = 0.0f;
  }

  Joystick.x((int)(lever * AXIS_RANGE));
  Joystick.send_now();

  static uint32_t last = 0;
  if (millis() - last > 250) {
    last = millis();
    Serial.print(F("raw="));
    Serial.print(raw);
    Serial.print(F(" lever="));
    Serial.print(lever, 3);
    if (calibrating) {
      Serial.print(F(" calibrating min="));
      Serial.print(raw_min);
      Serial.print(F(" max="));
      Serial.print(raw_max);
    }
    Serial.println();
  }
  delay(5);   // ~200 Hz, plenty for a thumb lever
}
