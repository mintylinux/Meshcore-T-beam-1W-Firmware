#include <Arduino.h>
#include "target.h"

TBeamBoard board;

// === Fan thermostat configuration ===
// On-die ESP32 MCU temperature thresholds (Celsius) with hysteresis.
// Override any of these via build_flags if needed.
#ifndef FAN_TEMP_ON_C
  #define FAN_TEMP_ON_C              37.0f   // turn fan on at >= 37 C
#endif
#ifndef FAN_TEMP_OFF_C
  #define FAN_TEMP_OFF_C             33.0f   // turn fan off below 33 C (4 C hysteresis)
#endif
#ifndef FAN_MIN_RUN_TIME_MS
  #define FAN_MIN_RUN_TIME_MS        5000    // minimum runtime to avoid rapid cycling
#endif
#ifndef FAN_TEMP_POLL_INTERVAL_MS
  #define FAN_TEMP_POLL_INTERVAL_MS  1000    // poll MCU temp at most once per second
#endif

static bool     fanRunning      = false;
static uint32_t fanStartTime    = 0;
static uint32_t lastTempPollMs  = 0;
static float    lastTempC       = 0.0f;

#ifdef DISPLAY_CLASS
  DISPLAY_CLASS display;
  MomentaryButton user_btn(PIN_USER_BTN, 1000, true);
#endif

static SPIClass spi;

RADIO_CLASS radio = new Module(P_LORA_NSS, P_LORA_DIO_1, P_LORA_RESET, P_LORA_BUSY, spi);

WRAPPER_CLASS radio_driver(radio, board);

ESP32RTCClock fallback_clock;
AutoDiscoverRTCClock rtc_clock(fallback_clock);

#if ENV_INCLUDE_GPS
  #include <helpers/sensors/MicroNMEALocationProvider.h>
  MicroNMEALocationProvider nmea = MicroNMEALocationProvider(Serial1);
  EnvironmentSensorManager sensors = EnvironmentSensorManager(nmea);
#else
  EnvironmentSensorManager sensors;
#endif

#ifdef P_FAN_CTRL
static float read_mcu_temp_throttled() {
  uint32_t now = millis();
  if (lastTempPollMs == 0 || (now - lastTempPollMs) >= FAN_TEMP_POLL_INTERVAL_MS) {
    lastTempC = board.getMCUTemperature();
    lastTempPollMs = now;
  }
  return lastTempC;
}
#endif

// Called from RadioLibWrapper::onSendFinished() after each TX.
// Only kicks the fan if the MCU is at/above FAN_TEMP_ON_C.
void activate_fan() {
  #ifdef P_FAN_CTRL
    float t = read_mcu_temp_throttled();
    if (t >= FAN_TEMP_ON_C) {
      digitalWrite(P_FAN_CTRL, HIGH);
      fanRunning = true;
      fanStartTime = millis();
      // #ifdef DEBUG_FAN
      // Serial.printf("[FAN] Activated (%.1f C) at %lu ms\n", t, fanStartTime);
      // #endif
    }
  #endif
}

// Thermostat driver. Called every iteration of the main loop.
// - If fan is running: turn off only after FAN_MIN_RUN_TIME_MS AND temp < FAN_TEMP_OFF_C.
// - If fan is off:     turn on once temp >= FAN_TEMP_ON_C, even without a TX.
void update_fan_control() {
  #ifdef P_FAN_CTRL
    float t = read_mcu_temp_throttled();
    uint32_t now = millis();

    if (fanRunning) {
      uint32_t elapsed = (now >= fanStartTime)
                          ? (now - fanStartTime)
                          : ((UINT32_MAX - fanStartTime) + now);
      if (elapsed >= FAN_MIN_RUN_TIME_MS && t < FAN_TEMP_OFF_C) {
        digitalWrite(P_FAN_CTRL, LOW);
        fanRunning = false;
        // #ifdef DEBUG_FAN
        // Serial.printf("[FAN] Deactivated (%.1f C) after %lu ms\n", t, elapsed);
        // #endif
      }
    } else if (t >= FAN_TEMP_ON_C) {
      digitalWrite(P_FAN_CTRL, HIGH);
      fanRunning = true;
      fanStartTime = now;
      // #ifdef DEBUG_FAN
      // Serial.printf("[FAN] Thermostat-activated (%.1f C)\n", t);
      // #endif
    }
  #endif
}

bool radio_init() {
  // Enable the radio LDO (must be HIGH to power on radio)
  pinMode(P_LORA_LDO_EN, OUTPUT);
  digitalWrite(P_LORA_LDO_EN, HIGH);
  delay(10);  // Give LDO time to stabilize
  
  // Configure LNA control pin (LOW during TX/sleep, HIGH during RX)
  pinMode(P_LORA_CTRL, OUTPUT);
  digitalWrite(P_LORA_CTRL, HIGH);  // Start in RX mode (LNA on)
  
  // Enable cooling fan control
  #ifdef P_FAN_CTRL
  pinMode(P_FAN_CTRL, OUTPUT);
  digitalWrite(P_FAN_CTRL, LOW);  // Turn off fan initially
  #endif
  
  fallback_clock.begin();
  rtc_clock.begin(Wire);  // T-Beam 1W uses single I2C bus on Wire
  
  // Reset fan thermostat state
  fanRunning      = false;
  fanStartTime    = 0;
  lastTempPollMs  = 0;
  lastTempC       = 0.0f;
  
  return radio.std_init(&spi);
}

uint32_t radio_get_rng_seed() {
  return radio.random(0x7FFFFFFF);
}

void radio_set_params(float freq, float bw, uint8_t sf, uint8_t cr) {
  radio.setFrequency(freq);
  radio.setSpreadingFactor(sf);
  radio.setBandwidth(bw);
  radio.setCodingRate(cr);
}

void radio_set_tx_power(uint8_t dbm) {
  radio.setOutputPower(dbm);
}

mesh::LocalIdentity radio_new_identity() {
  RadioNoiseListener rng(radio);
  return mesh::LocalIdentity(&rng);  // create new random identity
}
