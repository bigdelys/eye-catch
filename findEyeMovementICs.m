function isEye = findEyeMovementICs(EEG, isEye, eyeCatchSimilarity)
% isEye = findEyeMovementICs(EEG, isEye, eyeCatchSimilarity)

criticalFreq = 3; 
powerRatioThreshold = 100;
timeRatioOfPowerRatioTooHigh = 0.01;

icNumbers = find(eyeCatchSimilarity > 0.85 & ~isEye);

wname = 'cmor1-1.5';
T = 1/EEG.srate;
frequencyRange = [1 15];
numberOfFrequencies = 20;
[scales, freqs] = freq2scales(frequencyRange(1), frequencyRange(2), numberOfFrequencies, wname, T);

if isempty(EEG.icaact)
    if isempty(EEG.icachansind)
        EEG.icachansind = 1:size(EEG.data,1);
    end;
    EEG.icaact = EEG.icaweights * EEG.icasphere * EEG.data(EEG.icachansind,:);
end;

powerRatioTooHigh = false(length(icNumbers), size(EEG.data,2));

for i=1:length(icNumbers)

tfdecomposition = cwt(EEG.icaact(icNumbers(i),:)',scales, wname);

tfdecomposition = abs(tfdecomposition);
powerRatio = sum(tfdecomposition(freqs < criticalFreq,:).^2) ./ sum(tfdecomposition(freqs >= criticalFreq,:).^2);
powerRatioTooHigh(i,:) = powerRatio > powerRatioThreshold;
end;

eyeMovementICs = mean(powerRatioTooHigh,2) > timeRatioOfPowerRatioTooHigh; % more than 1% of time have a very high low-frequency activity
if any(eyeMovementICs)
    fprintf('Found %d additional eye movement ICs: %s\n', sum(eyeMovementICs), ...
        strjoin_adjoiner_first(', ', arrayfun(@num2str, find(eyeMovementICs), 'UniformOutput', false)));
end;
isEye(icNumbers(eyeMovementICs)) = true;