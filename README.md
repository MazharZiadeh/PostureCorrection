

# Back Posture Monitoring and Analysis System

This project aims to monitor and analyze back posture using the **MPU6050** accelerometer and gyroscope sensor connected to an ESP32 microcontroller. The system collects data, analyzes posture, and provides real-time feedback and performance metrics.

---

## Project Overview

1. **Real-Time Posture Monitoring**:
   - Uses MPU6050 to calculate roll angles, determining the user's posture.
   - Alerts users through a buzzer and LED for poor posture.
   - Sends posture data to the Blynk IoT platform.

2. **Data Collection**:
   - Data is logged via a Python script to an Excel file for further analysis.

3. **Data Analysis**:
   - A MATLAB script evaluates the collected data for good and bad posture percentages and visualizes performance metrics.

---

## Features

- **Live Posture Alerts**:
  - LED and buzzer alert for poor posture exceeding ±30°.
- **Blynk IoT Integration**:
  - Displays posture status ("Good" or "Bad") in the Blynk app.
- **Data Logging**:
  - Saves detailed sensor data, filtered values, and manually calculated angles into an Excel file.
- **Posture Analysis**:
  - MATLAB script calculates overall performance and provides graphical comparisons of raw and filtered data.

---

## Components Used

- **ESP32**: Microcontroller for processing and Wi-Fi connectivity.
- **MPU6050**: 6-axis accelerometer and gyroscope.
- **Buzzer & LED**: For user feedback.
- **Blynk IoT Platform**: Remote monitoring.
- **Python & MATLAB**: Data collection and analysis.

---

## Setup Instructions

### Hardware

1. Connect the MPU6050 to ESP32:
   - `VCC` → 3.3V
   - `GND` → GND
   - `SDA` → GPIO 21
   - `SCL` → GPIO 22
2. Connect a buzzer to GPIO 25 and an LED to GPIO 2.

---

### Software

1. **Install Libraries**:
   - Arduino IDE:
     - `MPU6050`
     - `BlynkSimpleEsp32`
   - Python:
     - `pandas`
     - `keyboard`
   - MATLAB:
     - Ensure Excel import capability (`detectImportOptions`).

2. **Configure Arduino Code**:
   - Add your Blynk credentials and Wi-Fi SSID/password.

3. **Run Python Script for Data Collection**:
   - Adjust the serial port (`COM10`) to match your ESP32 connection.
   - Press `0` to start recording and `9` to stop.

4. **Analyze Data in MATLAB**:
   - Place the Excel files in the same folder as the MATLAB script.
   - Run the script to generate performance metrics and plots.

---

## Code Explanation

### 1. Arduino Code (Real-Time Posture Monitoring)

The Arduino code calculates the roll angle based on MPU6050 readings. It implements:
- **Filtering with Circular Buffer**:
  Smooths raw accelerometer data using a 5-value buffer.

  ```cpp
  void updateBuffer(float buffer[], float newValue) {
      buffer[bufferIndex] = newValue;
      bufferIndex = (bufferIndex + 1) % bufferSize;
  }
  ```

- **Roll Angle Calculation**:
  Uses the formula:


![image](https://github.com/user-attachments/assets/e4d69529-efa1-4521-86ca-8a6d4068e539)



  ```cpp
  float filteredRoll = atan2(filteredAy, sqrt(filteredAx * filteredAx + filteredAz * filteredAz)) * 180.0 / PI;
  ```

- **Alert System**:
  Activates the LED and buzzer for poor posture (roll > ±30°).

- **Tare Functionality**:
  Resets the reference roll angle to 0 when a Blynk button is pressed.

---

### 2. Python Script (Data Collection)

This script records real-time sensor data from the ESP32 and saves it to an Excel file with two sheets:
1. **Full Data**: Contains all raw and filtered sensor values.
2. **Filtered View**: Contains key data for posture analysis.

Key features:
- **Real-Time Data Logging**:
  Captures data every 0.5 seconds.
- **Excel Export**:
  Saves data in structured sheets for analysis.

---

### 3. MATLAB Script (Data Analysis)

The MATLAB script processes the Excel files to evaluate posture performance:
- **Good vs Bad Posture**:
  Calculates percentages of time spent in good (±30°) and bad posture.

- **Performance Metrics**:
  Generates:
  - Percentage of good and bad posture.
  - Graphical plots:
    - Time vs Manual Raw Roll.
    - Time vs Manual Filtered Roll.
    - Comparison of Raw and Filtered Roll.

Example visualization:
- **Good Posture**: Roll within ±30°.
- **Bad Posture**: Roll outside this range.

---

## Results and Graphs

The MATLAB script outputs:
1. **Performance Metrics**:
   - Good Posture: e.g., 85%
   - Bad Posture: e.g., 15%
   - Performance Index: e.g., 85%

2. **Visualizations**:
   - Roll vs Time (Raw and Filtered).
   - Comparison of Raw and Filtered Roll.

---

## How It All Fits Together

1. **Real-Time Monitoring**:
   - The Arduino code monitors and alerts on poor posture.
2. **Data Logging**:
   - The Python script logs sensor readings into Excel files for offline analysis.
3. **Posture Analysis**:
   - The MATLAB script evaluates and visualizes posture trends.

---

## Troubleshooting

- **MPU6050 Connection Fails**:
  - Check wiring and I2C addresses.
- **Data Not Saved**:
  - Ensure Python has write permissions in the script directory.
- **MATLAB Errors**:
  - Ensure Excel files are in the script directory and have valid data.

---

## License

This project is open-source under the MIT License. Contributions and modifications are welcome!

---

