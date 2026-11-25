clc;
clear;
close all;

% Load dataset
data = readtable('datasets/accelerometer.csv');

% Dataset dimensions
disp('Dataset dimensions:');
disp(size(data));

% Weight configurations
disp('Weight configurations:');
disp(unique(data.wconfid));

% Fan speed percentages
disp('Fan speed percentages:');
disp(unique(data.pctid));

% First 10 measurements
disp('First 10 measurements:');
disp(head(data,10));

Fs = 50;                 % Sampling frequency (Hz)
N = 1000;                % Number of samples

signals = [data.x(1:N), ...
    data.y(1:N), ...
    data.z(1:N)];

axisNames = {'X-axis', 'Y-axis', 'Z-axis'};

figure;

for k = 1:3

    % Remove the DC component
    signal = signals(:,k) - mean(signals(:,k));

    % Apply Hann window
    window = hann(N);
    signal = signal .* window;

    % Compute FFT
    Y = fft(signal);

    % Single-sided amplitude spectrum
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:N/2)/N;

    subplot(3,1,k);
    plot(f,P1);
    title(['Frequency Spectrum - ',axisNames{k}]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    grid on;

end
speeds = [20 40 60 80 100];
Fs = 50;
N = 1000;

figure;
hold on;

for i = 1:length(speeds)

    % Select configuration 1 at the chosen fan speed
    idx = data.wconfid == 1 & data.pctid == speeds(i);
    signal = data.y(idx);

    % Use first 1000 samples
    signal = signal(1:N);

    % Remove DC component
    signal = signal - mean(signal);

    % Apply Hann window
    signal = signal .* hann(N);

    % FFT
    Y = fft(signal);

    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:N/2)/N;

    plot(f, P1, 'DisplayName', ...
        [num2str(speeds(i)), '% speed']);

end

xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Vibration Spectrum at Different Fan Speeds');
legend('show');
grid on;
hold off;
