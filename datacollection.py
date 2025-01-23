import serial
import time
import pandas as pd
import keyboard
import os

# Set up serial connection (adjust COM port and baud rate as needed)
ser = serial.Serial('COM10', 9600)  # Replace 'COM10' with your actual port

# Give time for the ESP32 to start sending data
time.sleep(2)

# Initialize an empty list to store the data
data_list = []
recording = False

# Variable to track start time
start_time = 0

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
save_path = os.path.join(script_dir, 'posture_data.xlsx')

# Define the save function for Excel data
def save_data():
    if data_list:
        print("Saving data to Excel file...")

        # Full data DataFrame
        full_df = pd.DataFrame(data_list, columns=[ 
            'ReadableTime', 'Timestamp', 'Ax', 'Ay', 'Az', 'RawRoll', 'Gx', 'Gy', 'Gz', 'RoomTemperature', 'Posture',
            'FilteredTimestamp', 'FilteredAx', 'FilteredAy', 'FilteredAz', 'FilteredRoll', 'FilteredGx', 'FilteredGy', 'FilteredGz', 'FilteredRoomTemperature', 'FilteredPosture',
            'ManualRawRoll', 'ManualFilteredRoll', 'ManualFilteredRoll2', 'ManualRawRoll2'
        ])

        # Create second DataFrame with only specific columns for a filtered view
        filtered_df = full_df[['ReadableTime', 'Posture', 'RawRoll', 'FilteredRoll', 'ManualRawRoll', 'ManualFilteredRoll']]

        # Save both DataFrames to different sheets in the same Excel file
        with pd.ExcelWriter(save_path) as writer:
            full_df.to_excel(writer, sheet_name='FullData', index=False)
            filtered_df.to_excel(writer, sheet_name='FilteredData', index=False)

        data_list.clear()  # Clear the list after saving
        print(f"Data saved successfully to {save_path}.")

# Main loop to handle recording and data saving
try:
    while True:
        if keyboard.is_pressed('0'):  # Press '0' to start recording
            recording = True
            start_time = time.time()  # Record start time
            print("Recording started.")
        elif keyboard.is_pressed('9'):  # Press '9' to stop recording
            recording = False
            save_data()
            print("Recording stopped and data saved.")

        if recording and ser.in_waiting > 0:
            data = ser.readline().decode('utf-8').strip()  # Read and decode the data
            raw_data = data.split(',')  # Split the CSV-like string into individual values

            # Calculate elapsed time from the start of recording
            readable_time = round(time.time() - start_time, 2)  # Elapsed time in seconds

            # Add readable time to the data and append to the list
            data_list.append([readable_time] + raw_data)

            # Ensure we are collecting data exactly every 0.5 seconds
            time.sleep(0.5)  # Sleep for 0.5 second between readings

            # Save the data to an Excel file every 1850 readings
            if len(data_list) >= 1850:
                save_data()

except KeyboardInterrupt:
    # Save any remaining data before exiting
    save_data()
    print("Recording stopped and data saved.")
