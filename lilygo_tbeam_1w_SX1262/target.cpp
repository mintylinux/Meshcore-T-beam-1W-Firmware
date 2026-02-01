#include <Arduino.h>
#include "target.h"

TBeamBoard board;


float currentTemperature = 0.0;

 bool fanRunning = false;

static unsigned long lastTempCheck = 0;
const unsigned long tempCheckInterval = 2000;



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



void initThermalManagement() {
    pinMode(P_FAN_CTRL, OUTPUT);
    digitalWrite(P_FAN_CTRL, LOW); // Start with fan OFF
    fanRunning = false;
    
    // Configure ADC for the thermistor pin (ESP32 specific)
    analogReadResolution(12); // Set to 12-bit resolution (0-4095)
    // Note: You may not need to set the attenuation explicitly for 3.3V,
    // but if readings are off, check ADC_ATTEN_DB_11 for full 3.3V range.

    Serial.println("Thermal management system initialized.");
}

float readThermistorTemperature() {
    // 1. Read the analog value
    int adcValue = analogRead(THERMISTOR_PIN);
    
    // 2. Convert ADC value to voltage
    float voltage = (adcValue / (float)ADC_MAX) * 3.3; // Assuming a 3.3V reference
    
    // 3. Calculate thermistor resistance from voltage divider
    // Formula: R_thermistor = ( (Vcc * R_series) / V_adc ) - R_series
    float thermistorResistance = (3.3 * SERIES_RESISTOR) / voltage - SERIES_RESISTOR;
    
    // 4. Use Steinhart-Hart equation to convert resistance to temperature in Kelvin
    float steinhart = thermistorResistance / THERMISTOR_NOMINAL;   // (R/Ro)
    steinhart = log(steinhart);                                   // ln(R/Ro)
    steinhart /= B_COEFFICIENT;                                   // 1/B * ln(R/Ro)
    steinhart += 1.0 / (TEMPERATURE_NOMINAL + 273.15);            // + (1/To)
    steinhart = 1.0 / steinhart;                                  // Invert
    
    // 5. Convert from Kelvin to Celsius and return
    float temperatureC = steinhart - 273.15;
    
    // Optional: Print debug info
     //Serial.printf("ADC: %d, Volt: %.2fV, Res: %.0fΩ, Temp: %.1fC\n", 
     //              adcValue, voltage, thermistorResistance, temperatureC);
    
    return temperatureC;
}

void update_fan_control() {
#ifdef P_FAN_CTRL
    currentTemperature = readThermistorTemperature();
    
    if (!fanRunning && currentTemperature > TEMP_THRESHOLD_HIGH)
     {
        pinMode(P_FAN_CTRL, OUTPUT);
        digitalWrite(P_FAN_CTRL, HIGH);
        fanRunning = true;
        Serial.printf("Fan ON at %.1f°C\n", currentTemperature);
    } 
    else if (fanRunning && currentTemperature < TEMP_THRESHOLD_LOW) {
        pinMode(P_FAN_CTRL, OUTPUT);
        digitalWrite(P_FAN_CTRL, LOW);
        fanRunning = false;
        Serial.printf("Fan OFF at %.1f°C\n", currentTemperature);
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
  
  
  fallback_clock.begin();
  rtc_clock.begin(Wire);  // T-Beam 1W uses single I2C bus on Wire
  


 
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
