clc; clear; close all;

% Load Data
speech_data = load('noisy_speech.txt');  
noise_data = load('external_noise.txt'); 
clean_data = load("clean_speech.txt");   

Fs = 44100; 

% SNR before filterinng
signal_power = sum(clean_data.^2);
noise_power = sum((speech_data - clean_data).^2);
snr_before = 10 * log10(signal_power / noise_power);

% Filter Parameters
order = 8;  % Filter order
mu = 0.008;  % Step size
delta = 1e-3;  % Regularization term

% NLMS Function call
[error, ~] = NLMS(speech_data, noise_data, mu, order, delta);
filtered_output = error;

% SNR After Filtering
filtered_noise_power = mean((filtered_output - clean_data).^2);
snr_after = 10 * log10(mean(clean_data.^2) / filtered_noise_power);

% Save & Play Filtered Speech
sound(filtered_output,Fs);

% SNR Results
fprintf('SNR Before Filtering: %.2f dB\n', snr_before);
fprintf('SNR After Filtering: %.2f dB\n', snr_after);


% NLMS Algorithm Implementation
function [e, y] = NLMS(d, x, mu, M, delta)
    Ns = length(d);
    buff = zeros(M,1);
    w1 = zeros(M,1);
    y = zeros(Ns,1);
    e = zeros(Ns,1);
 
    for n = 1:Ns
        buff = [buff(2:M); x(n)];
        y(n) = w1' * buff;
           
        k = mu / (delta + buff' * buff);
        e(n) = d(n) - y(n);
        update = k * e(n) * buff;
        w1 = w1 + update;
    end
end