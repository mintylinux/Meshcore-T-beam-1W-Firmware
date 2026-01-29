// Minimal T-Beam 1W test - just blink LED and serial output
// This will verify:
// 1. ESP32-S3 boots
// 2. Serial/USB works
// 3. GPIO works (LED)

#define LED_PIN 18  // TX LED on T-Beam 1W

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\n=================================");
  Serial.println("T-Beam 1W Basic Test");
  Serial.println("=================================");
  Serial.println("If you see this, serial works!");
  
  pinMode(LED_PIN, OUTPUT);
  Serial.println("LED pin configured on GPIO 18");
}

void loop() {
  static int count = 0;
  
  digitalWrite(LED_PIN, HIGH);
  Serial.print("LED ON - Count: ");
  Serial.println(count++);
  delay(500);
  
  digitalWrite(LED_PIN, LOW);
  Serial.println("LED OFF");
  delay(500);
}
