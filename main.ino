#define BLYNK_TEMPLATE_ID "TMPL69TtiGEcp"
#define BLYNK_TEMPLATE_NAME "BACK POSTURE"
#define BLYNK_AUTH_TOKEN "u_krIg135Ukp3xzz1o3Re3kGShFMJtSN"

#include <Wire.h>
#include <MPU6050.h>
#include <BlynkSimpleEsp32.h>

char ssid[] = "YOUR WIFI ADRESS";
char pass[] = "YOUR WIFI PASSWORD";

MPU6050 mpu;
BlynkTimer timer;

int ledPin = 2;      // Built-in LED pin on the ESP32
int buzzerPin = 25;   // Pin connected to the buzzer

const int bufferSize = 5;
float axBuffer[bufferSize] = {0}, ayBuffer[bufferSize] = {0}, azBuffer[bufferSize] = {0};
float gxBuffer[bufferSize] = {0}, gyBuffer[bufferSize] = {0}, gzBuffer[bufferSize] = {0};
int bufferIndex = 0;

bool tareApplied = false;
float initialRoll = 0.0;

void setup() {
  Serial.begin(9600);
  Wire.begin();
  mpu.initialize();

  if (!mpu.testConnection()) {
    Serial.println("MPU6050 connection failed!");
    while (1);
  }

  Serial.println("MPU6050 connection successful!");
  pinMode(ledPin, OUTPUT);
  pinMode(buzzerPin, OUTPUT);

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);
  timer.setInterval(500L, sendPostureData);
}

void loop() {
  Blynk.run();
  timer.run();
}

BLYNK_WRITE(V0) {
  if (param.asInt() == 1) { // Button press detected
    tareApplied = true;
    initialRoll = calculateRoll(); // Set the current roll as the reference point (0 degrees)
    Serial.println("Tare applied: Roll angle reset to 0.");
  }
}

void sendPostureData() {
  int16_t ax, ay, az;
  int16_t gx, gy, gz;

  mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  float Ax = ax / 16384.0;
  float Ay = az / 16384.0;  // Z-axis mapped to Y
  float Az = ay / 16384.0;  // Y-axis mapped to Z

  updateBuffer(axBuffer, Ax);
  updateBuffer(ayBuffer, Ay);
  updateBuffer(azBuffer, Az);

  float filteredAx = calculateAverage(axBuffer);
  float filteredAy = calculateAverage(ayBuffer);
  float filteredAz = calculateAverage(azBuffer);

  float filteredRoll = atan2(filteredAy, sqrt(filteredAx * filteredAx + filteredAz * filteredAz)) * 180.0 / PI;
  float adjustedFilteredRoll = tareApplied ? filteredRoll - initialRoll : filteredRoll;

  String posture = "Good";
  if (adjustedFilteredRoll > 30 || adjustedFilteredRoll < -30) {
    posture = "Bad";
    digitalWrite(ledPin, HIGH);
    digitalWrite(buzzerPin, HIGH); // Activate buzzer
  } else {
    digitalWrite(ledPin, LOW);
    digitalWrite(buzzerPin, LOW); // Deactivate buzzer
  }

  Blynk.virtualWrite(V1, posture); // Send posture status to Blynk

  Serial.print("Posture: ");
  Serial.println(posture);
}

void updateBuffer(float buffer[], float newValue) {
  buffer[bufferIndex] = newValue;
  bufferIndex = (bufferIndex + 1) % bufferSize;
}

float calculateAverage(float buffer[]) {
  float sum = 0;
  for (int i = 0; i < bufferSize; i++) {
    sum += buffer[i];
  }
  return sum / bufferSize;
}

float calculateRoll() {
  int16_t ax, ay, az;
  mpu.getAcceleration(&ax, &ay, &az);
  float Ax = ax / 16384.0;
  float Ay = az / 16384.0;
  float Az = ay / 16384.0;
  return atan2(Ay, sqrt(Ax * Ax + Az * Az)) * 180.0 / PI;
}
