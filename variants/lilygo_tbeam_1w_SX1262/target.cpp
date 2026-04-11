#include <Arduino.h>
#include "target.h"

TBeamBoard board;

static bool fanRunning = false;
static uint32_t fanStartTime = 0;
static const float FAN_ON_TEMP_C  = 45.0;  // Turn fan ON at this temperature
static const float FAN_OFF_TEMP_C = 41.0;  // Turn fan OFF below this (hysteresis)
static const uint32_t FAN_MIN_RUN_MS = 5000; // Minimum 5 seconds runtime once activated

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

void activate_fan() {
  #ifdef P_FAN_CTRL
    if (!fanRunning) {
      digitalWrite(P_FAN_CTRL, HIGH);
      fanRunning = true;
      fanStartTime = millis();
      Serial.printf("[FAN] ON (temp >= %.0f°C)\n", FAN_ON_TEMP_C);
    }
  #endif
}

void deactivate_fan() {
  #ifdef P_FAN_CTRL
    if (fanRunning) {
      digitalWrite(P_FAN_CTRL, LOW);
      fanRunning = false;
      Serial.printf("[FAN] OFF (temp < %.0f°C)\n", FAN_OFF_TEMP_C);
    }
  #endif
}

void update_fan_control() {
  #ifdef P_FAN_CTRL
    float temp = temperatureRead();  // ESP32 internal temp sensor
    
    if (!fanRunning && temp >= FAN_ON_TEMP_C) {
      activate_fan();
    } else if (fanRunning && temp < FAN_OFF_TEMP_C) {
      // Enforce minimum runtime before turning off
      uint32_t elapsed = millis() - fanStartTime;
      if (elapsed >= FAN_MIN_RUN_MS) {
        deactivate_fan();
      }
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
  
  // Initialize fan state
  fanRunning = false;
  fanStartTime = 0;
  
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
