# EyeCatch
A fully automatic algorithm, implemented in MATLAB, for finding Eye-Related ICA components solely based on their scalpmaps. It has a performance comparable to CORRMAP while not requiring any user intervention.

[Measure Projection Toolbox (MPT)](http://sccn.ucsd.edu/wiki/MPT) includes EyeCatch software (as pr.eyeCatch class), if you have not installed MPT you can download EyeCatch stand-alone from this repository.

## Usage

Note: if you have already installed Measure Projection software, please use `pr.eyeCatch` instead of `eyeCatch` in the examples below.
Example 1: Finding eye ICs in the EEG structure ().
```matlab
>> eyeDetector = eyeCatch;     % create an object from the class. Once you made an object it can
                                  % be used for multiple detections (much faster than creating an
                                  % object each time).
```
then
```matlab
>> [eyeIC similarity scalpmapObj] = eyeDetector.detectFromEEG(EEG); % detect eye ICs
>> eyeIC                          % display the IC numbers for eye ICs.
>> scalpmapObj.plot(eyeIC)        % plot eye ICs
```
Example 2: (application on a study)
```matlab    
 >> eyeDetector = eyeCatch;        % create an object from the class. Once you made an object it can
                                   % be used for multiple detections (much faster than creating an
                                   % object each time).
 % read data from a loaded study
 >> [isEye similarity scalpmapObj] = eyeDetector.detectFromStudy(STUDY, ALLEEG); 
 >> find(isEye)                    % display the IC numbers for eye ICs (since isEye is a logical array). The order of ICs is same order as in STUDY.cluster(1).comps .
 >> scalpmapObj.plot(isEye)        % plot eye ICs
```
