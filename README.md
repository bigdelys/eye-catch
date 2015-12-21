# EyeCatch
Detects eye-related ICA components from their scalp topography using a large database of previously tagged scalp maps.

EyeCatch is a fully automatic algorithm for finding Eye-Related ICA components solely based on their scalpmaps. It has a performance comparable to CORRMAP while not requiring any user intervention.

[http://sccn.ucsd.edu/wiki/MPT Measure Projection Toolbox (MPT)] includes EyeCatch software (as  pr.eyeCatch class), if you have not installed MPT you can download EyeCatch stand-alone from [ftp://sccn.ucsd.edu/pub/eyecatch/eyeCatch.zip this link (194 MB)].

## Usage
Example 1:   (finding eye ICs in the EEG structure)
```
>> eyeDetector = pr.eyeCatch;     % create an object from the class. Once you made an object it can
                                  % be used for multiple detections (much faster than creating an
                                  % object each time).
```
If you are using EyeCatch without Measure Projection toolbox, use the command below instead:
```
 >> eyeDetector = eyeCatch;
```
then
```
>> [eyeIC similarity scalpmapObj] = eyeDetector.detectFromEEG(EEG); % detect eye ICs
>> eyeIC                          % display the IC numbers for eye ICs.
>> scalpmapObj.plot(eyeIC)        % plot eye ICs
```
Example 2: (application on a study)
```    
 >> eyeDetector = pr.eyeCatch;     % create an object from the class. Once you made an object it can
                                   % be used for multiple detections (much faster than creating an
                                   % object each time).
 % read data from a loaded study
 >> [isEye similarity scalpmapObj] = pr.eyeDetector.detectFromStudy(STUDY, ALLEEG); 
 >> find(isEye)                    % display the IC numbers for eye ICs (since isEye is a logical array). The order of ICs is same order as in STUDY.cluster(1).comps .
 >> scalpmapObj.plot(isEye)        % plot eye ICs
```
