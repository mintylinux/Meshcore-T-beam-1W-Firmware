// Simple test to verify XIAO nRF52840 boots and outputs to serial

void setup() {
  Serial.begin(115200);
  delay(2000);  // Wait for serial to initialize
  
  Serial.println("===================================");
  Serial.println("XIAO nRF52840 Test - BOOTED!");
  Serial.println("===================================");
  Serial.println();
  Serial.println("If you see this, the XIAO is working.");
  Serial.println();
  
  // Test LED
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.println("Testing built-in LED...");
  
  pinMode(11, OUTPUT);  // TX LED
  Serial.println("Testing TX LED (pin 11)...");
}

void loop() {
  static int count = 0;
  
  Serial.print("Loop count: ");
  Serial.println(count++);
  
  // Blink built-in LED
  digitalWrite(LED_BUILTIN, HIGH);
  digitalWrite(11, LOW);  // TX LED on
  delay(500);
  
  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(11, HIGH);  // TX LED off
  delay(500);
}
