Here's a complete GitHub README for your Arduino project explaining the code, filtering algorithm, buffer mechanism, averaging, and manual calculations:

---

# Back Posture Monitoring System with MPU6050 and ESP32

This project uses an **MPU6050** gyroscope and accelerometer sensor along with an ESP32 to monitor back posture in real-time. It calculates the roll angle and sends posture data to the **Blynk IoT platform**, while also activating a buzzer and LED for poor posture warnings.

---

## Features

- **Posture Monitoring**: Calculates the roll angle using the MPU6050 sensor.
- **Real-Time Feedback**: Alerts the user via LED and buzzer if their posture exceeds safe thresholds.
- **Blynk Integration**: Displays posture status ("Good" or "Bad") on the Blynk IoT app.
- **Tare Functionality**: Allows resetting the roll angle to zero for recalibration.

---

## Components Used

1. **ESP32**: Microcontroller for Wi-Fi connectivity and processing.
2. **MPU6050**: 6-axis accelerometer and gyroscope.
3. **Buzzer**: For audio alerts.
4. **LED**: For visual alerts.
5. **Blynk IoT Platform**: To monitor the posture remotely.

---

## Code Breakdown

### Main Functionalities

1. **Initialization**:
   - The MPU6050 sensor is initialized and tested for connection.
   - Wi-Fi credentials and Blynk authentication are set up.

2. **Buffer and Averaging**:
   - A buffer stores the latest sensor readings (5 values by default).
   - Averaging is applied to smooth out noisy sensor data.

3. **Posture Calculation**:
   - The roll angle is computed using the arctangent of accelerometer values.
   - The angle is adjusted based on a "tare" operation to set the reference to 0.

4. **Posture Alert System**:
   - If the roll angle deviates beyond ±30°, an alert is triggered via the buzzer and LED.
   - Posture data is sent to the Blynk app for remote monitoring.

---

### Filtering and Buffering Mechanism

1. **Buffering**:
   - Buffers are used for each axis of acceleration: `axBuffer`, `ayBuffer`, `azBuffer`.
   - New readings are added to the buffer in a cyclic manner using a circular index.

   ```cpp
   void updateBuffer(float buffer[], float newValue) {
       buffer[bufferIndex] = newValue;
       bufferIndex = (bufferIndex + 1) % bufferSize;
   }
   ```

2. **Averaging**:
   - The average of the buffered values is computed to filter out noise.

   ```cpp
   float calculateAverage(float buffer[]) {
       float sum = 0;
       for (int i = 0; i < bufferSize; i++) {
           sum += buffer[i];
       }
       return sum / bufferSize;
   }
   ```

---

### Algorithm Details

1. **Roll Angle Calculation**:
   - The roll angle is calculated using the formula:

     \[
     \text{roll} = \arctan \left(\frac{A_y}{\sqrt{A_x^2 + A_z^2}}\right) \times \frac{180}{\pi}
     \]

   - `Ay`, `Ax`, and `Az` are the filtered accelerometer readings.

2. **Tare Adjustment**:
   - A tare button in the Blynk app allows resetting the roll angle to 0.
   - This compensates for sensor orientation or mounting differences.

   ```cpp
   if (param.asInt() == 1) { // Tare button pressed
       tareApplied = true;
       initialRoll = calculateRoll();
   }
   ```

---

## Circuit Diagram

- Connect the **MPU6050** to the ESP32 via I2C:
  - `VCC` → 3.3V
  - `GND` → GND
  - `SDA` → GPIO 21
  - `SCL` → GPIO 22
- Connect a buzzer to GPIO 25 and an LED to GPIO 2.

---

## Setup and Usage

1. **Hardware Setup**:
   - Connect the components as described in the circuit diagram.

2. **Code Upload**:
   - Install the required libraries:
     - `MPU6050`
     - `BlynkSimpleEsp32`
   - Upload the code using the Arduino IDE.

3. **Blynk Configuration**:
   - Use the Blynk app to set up a project.
   - Add a button on `V0` for tare functionality.
   - Add a display widget on `V1` to show posture status.

4. **Run the System**:
   - Power up the ESP32.
   - Monitor posture status in the Blynk app.

---

## Troubleshooting

- **MPU6050 Connection Failed**:
  - Ensure proper wiring and check I2C addresses.
- **No Posture Updates**:
  - Verify Wi-Fi credentials and Blynk configuration.

---

## License

This project is open-source under the MIT License. Feel free to modify and improve it.

--- 

Feel free to customize the content further! Let me know if you'd like to add anything else.
