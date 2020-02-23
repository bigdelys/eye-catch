%% Check if eyecatch runs and detects the correct eye IC
load sample_EEG.mat

eyeDetector = eyeCatch;
[eyeIC similarity scalpmapObj] = eyeDetector.detectFromEEG(EEG);
assert(isequal(find(eyeIC), 3));

for 