clc; clear; close all;

% Load Data
speech_data = load('noisy_speech.txt');  
noise_data = load('external_noise.txt'); 
clean_data = load("clean_speech.txt");   

Fs = 44100; 


% SNR Before Filtering
signal_power = sum(clean_data.^2);
noise_power = sum((speech_data - clean_data).^2);
snr_before = 10 * log10(signal_power / noise_power);

% Filter Parameters
order = 12; 
mu = 0.00008; 
delta = 1e-5;  

notch_freqs =  1000;  
r = 0.998;


f0 = notch_freqs;
omega = 2 * pi * f0 / Fs;
b0 = 1;
b1 = -2 * cos(omega);
b2 = 1;

a0 = 1;
a1 = -2 * r * cos(omega);
a2 = r^2;

x = noise_data;
N = length(x);
y = zeros(N, 1);

for n = 3:N
    y(n) = b0 * x(n) + b1 * x(n-1) + b2 * x(n-2) ...
         - a1 * y(n-1) - a2 * y(n-2);
end

noise_notched = y; 


% NLMS Function call
[error, ~] = NLMS(speech_data, noise_notched, mu, order, delta);

filtered_output = error;

% SNR After Filtering
filtered_noise_power = mean((filtered_output - clean_data).^2);
snr_after = 10 * log10(mean(clean_data.^2) / filtered_noise_power);

sound(filtered_output,Fs);

% SNR Results
fprintf('SNR Before Filtering: %.2f dB\n', snr_before);
fprintf('SNR After Filtering: %.2f dB\n', snr_after);

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