clc;
clear all;
close all;

% Get list of all Excel files in the current directory
fileList = dir('*.xlsx');

% Initialize arrays for combined data
allRawRoll = [];
allFilteredRoll = [];

% Loop through each Excel file
for i = 1:length(fileList)
    fileName = fileList(i).name;
    sheetName = 'FilteredData';
    
    try
        % Check if the file exists and process it
        if isfile(fileName)
            opts = detectImportOptions(fileName, 'Sheet', sheetName);
            opts = setvartype(opts, {'ReadableTime', 'ManualRawRoll', 'ManualFilteredRoll'}, 'double');
            data = readtable(fileName, opts);

            % Extract relevant columns
            time = data.ReadableTime;
            manualRawRoll = data.ManualRawRoll;
            manualFilteredRoll = data.ManualFilteredRoll;

            % Check for NaN values and remove them
            validIndices = ~isnan(time) & ~isnan(manualRawRoll) & ~isnan(manualFilteredRoll);
            time = time(validIndices);
            manualRawRoll = manualRawRoll(validIndices);
            manualFilteredRoll = manualFilteredRoll(validIndices);

            % Check if arrays are empty after cleaning
            if isempty(time) || isempty(manualRawRoll) || isempty(manualFilteredRoll)
                error('Data arrays are empty after cleaning. Please check the data integrity in %s.', fileName);
            end

            % Calculate percentage of good and bad posture
            goodRawRoll = sum(manualRawRoll >= -30 & manualRawRoll <= 30);
            badRawRoll = sum(manualRawRoll < -30 | manualRawRoll > 30);
            goodFilteredRoll = sum(manualFilteredRoll >= -30 & manualFilteredRoll <= 30);
            badFilteredRoll = sum(manualFilteredRoll < -30 | manualFilteredRoll > 30);

            totalRawRoll = length(manualRawRoll);
            totalFilteredRoll = length(manualFilteredRoll);

            percentGoodRaw = (goodRawRoll / totalRawRoll) * 100;
            percentBadRaw = (badRawRoll / totalRawRoll) * 100;
            percentGoodFiltered = (goodFilteredRoll / totalFilteredRoll) * 100;
            percentBadFiltered = (badFilteredRoll / totalFilteredRoll) * 100;

            % Calculate performance index as the percentage of "good" posture
            performanceIndexRaw = percentGoodRaw;
            performanceIndexFiltered = percentGoodFiltered;

            % Append data to combined arrays
            allRawRoll = [allRawRoll; manualRawRoll];
            allFilteredRoll = [allFilteredRoll; manualFilteredRoll];

            % Display performance metrics
            fprintf('Performance Metrics for %s:\n', fileName);
            fprintf('Raw Data: %.2f%% Good, %.2f%% Bad\n', percentGoodRaw, percentBadRaw);
            fprintf('Filtered Data: %.2f%% Good, %.2f%% Bad\n', percentGoodFiltered, percentBadFiltered);
            fprintf('Overall Performance Index (Raw): %.2f%%\n', performanceIndexRaw);
            fprintf('Overall Performance Index (Filtered): %.2f%%\n\n', performanceIndexFiltered);

            % Create a figure for this file
            figure('Name', sprintf('Plots for %s', fileName));

            % Plot 1: Time vs Manual Raw Roll
            subplot(3, 1, 1);
            plot(time, manualRawRoll, 'LineWidth', 1.5);
            hold on;
            yline(30, 'r--', 'LineWidth', 1.5, 'Label', 'Limit 30°');
            yline(-30, 'r--', 'LineWidth', 1.5, 'Label', 'Limit -30°');
            xlabel('Time (seconds)');
            ylabel('Manual Raw Roll (degrees)');
            title('Time vs Manual Raw Roll');
            ylim([-45 45]);
            grid on;

            % Plot 2: Time vs Manual Filtered Roll
            subplot(3, 1, 2);
            plot(time, manualFilteredRoll, 'LineWidth', 1.5);
            hold on;
            yline(30, 'r--', 'LineWidth', 1.5, 'Label', 'Limit 30°');
            yline(-30, 'r--', 'LineWidth', 1.5, 'Label', 'Limit -30°');
            xlabel('Time (seconds)');
            ylabel('Manual Filtered Roll (degrees)');
            title('Time vs Manual Filtered Roll');
            ylim([-45 45]);
            grid on;

            % Plot 3: Comparison of Raw Roll and Filtered Roll over Time
            subplot(3, 1, 3);
            plot(time, manualRawRoll, 'LineWidth', 1.5);
            hold on;
            plot(time, manualFilteredRoll, 'LineWidth', 1.5);
            yline(30, 'r--', 'LineWidth', 1.5, 'Label', 'Limit 30°');
            yline(-30, 'r--', 'LineWidth', 1.5, 'Label', 'Limit -30°');
            xlabel('Time (seconds)');
            ylabel('Roll (degrees)');
            title('Comparison of Manual Raw and Filtered Roll over Time');
            legend('Manual Raw Roll', 'Manual Filtered Roll');
            ylim([-45 45]);
            grid on;

        else
            error('Excel file %s not found.', fileName);
        end

    catch ME
        % Display error messages if issues occur
        fprintf('Error while processing file %s:\n', fileName);
        disp(ME.message);
    end
end

% Perform overall performance analysis on combined data
if ~isempty(allRawRoll) && ~isempty(allFilteredRoll)
    overallGoodRaw = sum(allRawRoll >= -30 & allRawRoll <= 30);
    overallBadRaw = sum(allRawRoll < -30 | allRawRoll > 30);
    overallGoodFiltered = sum(allFilteredRoll >= -30 & allFilteredRoll <= 30);
    overallBadFiltered = sum(allFilteredRoll < -30 | allFilteredRoll > 30);

    overallTotalRaw = length(allRawRoll);
    overallTotalFiltered = length(allFilteredRoll);

    overallPercentGoodRaw = (overallGoodRaw / overallTotalRaw) * 100;
    overallPercentBadRaw = (overallBadRaw / overallTotalRaw) * 100;
    overallPercentGoodFiltered = (overallGoodFiltered / overallTotalFiltered) * 100;
    overallPercentBadFiltered = (overallBadFiltered / overallTotalFiltered) * 100;

    overallPerformanceIndexRaw = overallPercentGoodRaw;
    overallPerformanceIndexFiltered = overallPercentGoodFiltered;

    % Display overall performance metrics
    fprintf('Overall Performance Metrics (Combined Data):\n');
    fprintf('Raw Data: %.2f%% Good, %.2f%% Bad\n', overallPercentGoodRaw, overallPercentBadRaw);
    fprintf('Filtered Data: %.2f%% Good, %.2f%% Bad\n', overallPercentGoodFiltered, overallPercentBadFiltered);
    fprintf('Overall Performance Index (Raw): %.2f%%\n', overallPerformanceIndexRaw);
    fprintf('Overall Performance Index (Filtered): %.2f%%\n\n', overallPerformanceIndexFiltered);
end
