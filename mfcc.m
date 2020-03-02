%% mfcc function
function [cn, ystt] = mfcc(s, fs, N, p, M)
% Calculates the Mel-Frequency Ceptstral Coefficients
% Inputs:
% s - Audio vector (assuming 1-channel/mono-channel)
% fs - Sampling Frequency
% N - Number of elements in Hamming window for stft()
% p - Number of filters in the filter bank for melfb
% M - overlap length for stft()
%
% Outputs:
% cn - Mel-Frequency Ceptstral Coefficients w/ size (p*length(ystt))
% ystt - Time-domain for STFT(Short-Time Fourier Transform)

% Step 1: Take the stft of signal
[yst, ystf, ystt] = stft(s, fs, 'Window', hamming(N), 'OverlapLength', M);
% yst: mxn matrix amplitude output of stft
% ystf: mx1 frequency output corresponding to stft
% ystt: nx1 time output corresponding to stft

% plotSpec(ystt, ystf, db(abs(yst))); caxis([-40, max(db(yst(:)))]);
% xlim([min(ystt), max(ystt)]); ylim([min(ystf), max(ystf)]);
% xlabel('Time (s)'); ylabel('Frequency (Hz)');

% Step 2: Get mel frequency filter bank
m = melfb(p, N, fs); % Mel-spaced filter bank

% figure; plot(linspace(0, (fs/2), 129), m');
% title('Mel-spaced filterbank'); xlabel('Frequency (Hz)');

% Step 3: Take the positive half of the frequency (since symmetry)
% and matrix multiply the mel filter bank with stft output
ystcut = yst(128:end, :);
ystcut = ystcut .* conj(ystcut); % take square
mfcstuff = m * ystcut; % matrix multiply mel with stft

% plotSpec(ystt, 1:p, db(abs(mfcstuff))); caxis([-40, max(db(mfcstuff(:)))]);
% xlim([min(ystt), max(ystt)]); ylim([0 p-1]);

% Step 4: Take the log10 of the matrix multiply output
% and apply dct (Discrete Cosine Transform)
sk = log10(mfcstuff);
cn = dct(sk);

% Step 5: Plot the amplitude output of the dct
%plotSpec(ystt, 1:p, cn); caxis([-30 15]);
%xlim([min(ystt), max(ystt)]); ylim([1 p]);
%xlabel('Time (s)'); ylabel('mfc coefficients')
end