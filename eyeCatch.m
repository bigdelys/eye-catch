classdef eyeCatch
    % Detetcs eye ICs based solely based on on their scalpmaps.
    % The input can be an EEG structure, an array of scalpmaps (channwel weights and location, e.g.
    % from EEG.chanlocs and EEG.icawinv) or an scalpmap object from MPT.
    %
    % Example 1:   (finding eye ICs in the EEG structure)
    %
    % >> eyeDetector = eyeCatch; % create an object from the class
    % >> [isEye similarity scalpmapObj] = eyeDetector.detectFromEEG(EEG); % detect eye ICs
    % >> find(isEye)   % display the IC numbers for eye ICs (since isEye is a logical array)
    % >> scalpmapObj.plot(isEye)   % plot eye ICs
    %
    % Example 2:
    %
    % >> [isEye similarity scalpmapObj] = eyeDetector.detectFromStudy(STUDY, ALLEEG); % read data from a loaded study
    % >> find(isEye)   % display the IC numbers for eye ICs (since isEye is a logical array). The
    %                  % order of ICs is same order as in STUDY.cluster(1).comps .
    % >> scalpmapObj.plot(isEye)   % plot eye ICs
    %
    % Written by Nima Bigdely-Shamlo, Swartz Center, INC, UCSD.
    % Copyright © 2012 University Of California San Diego. Distributed under BSD License.
    
    properties
        eyeScalpmapDatabase
        eyeChannelWeightNormalized % precomputed normalized eye scalpmaps channel weights on interpolated 2D scalp.
        similarityThreshold = 0.94
    end;
    
    methods
        function obj = eyeCatch(similarityThreshold, varargin)
            % obj = eyeCatch(similarityThreshold)
            if nargin > 0
                obj.similarityThreshold = similarityThreshold;
            end;
            
            load('pooledEyeScalpmap.mat'); % load pooledEyeScalpmap varaible
            load('eyeChannelWeightNormalizedPart1.mat'); % load eyeChannelWeightNormalizedPart1 variable
            load('eyeChannelWeightNormalizedPart2.mat'); % load eyeChannelWeightNormalizedPart1 variable
            eyeChannelWeightNormalized = cat(1, eyeChannelWeightNormalizedPart1, eyeChannelWeightNormalizedPart2);
            clear eyeChannelWeightNormalizedPart1 eyeChannelWeightNormalizedPart2
            
            obj.eyeScalpmapDatabase = pooledEyeScalpmap;
            obj.eyeChannelWeightNormalized = eyeChannelWeightNormalized;
            if size(obj.eyeChannelWeightNormalized,1) ~= obj.eyeScalpmapDatabase.numberOfScalpmaps
                fprintf('Precomputed weights are being recomputed.\n');
                % to do compute weights
                channelWeight = obj.eyeScalpmapDatabase.originalChannelWeight(:,:);
                channelWeight(isnan(channelWeight)) = 0;
                channelWeight = channelWeight';
                
                channelWeightNormalized = bsxfun(@minus, channelWeight,  mean(channelWeight));
                channelWeightNormalized = bsxfun(@rdivide, channelWeightNormalized,  std(channelWeightNormalized));
                eyeChannelWeightNormalized = channelWeightNormalized';
                
                eyeChannelWeightNormalizedPart1 = eyeChannelWeightNormalized(1:2000,:);
                eyeChannelWeightNormalizedPart2 = eyeChannelWeightNormalized(2001:end,:);
                
                % save the file (overwrite)
                pooledEyeScalpmap = obj.eyeScalpmapDatabase;
                fullPath = which('eyeChannelWeightNormalizedPart1.mat');
                try
                    save(fullPath, 'eyeChannelWeightNormalizedPart1');
                    fprintf('New precomputed weights saved.\n');
                    
                    fullPath = which('eyeChannelWeightNormalizedPart2.mat');
                    save(fullPath, 'eyeChannelWeightNormalizedPart2');
                catch
                    fprintf('Could not save newly precomputed weights, please check if you have write permission.\n');
                end;
                
                
                
            end;
        end;
        
        function [isEye similarity] = detectFromInterpolatedChannelWeight(obj, channelWeight, similarityThreshold, varargin)
            % [isEye similarity] = detectFromInterpolatedChannelWeight(obj, channelWeight, similarityThreshold)
            
            if nargin < 3
                similarityThreshold = obj.similarityThreshold;
            end;
            
            channelWeight(isnan(channelWeight)) = 0;
            channelWeight = channelWeight';
            
            channelWeightNormalized = bsxfun(@minus, channelWeight,  mean(channelWeight));
            channelWeightNormalized = bsxfun(@rdivide, channelWeightNormalized,  std(channelWeightNormalized));
            channelWeightNormalized = channelWeightNormalized';
            
            similarity  = max(abs(obj.eyeChannelWeightNormalized * channelWeightNormalized')) / (size(obj.eyeChannelWeightNormalized,2));
            isEye = similarity > similarityThreshold;
        end;
        
        function [isEye similarity] = detectFromScalpmapObj(obj, scalpmapObj, similarityThreshold, varargin)
            % [isEye similarity] = detectFromScalpmapObj(obj, scalpmapObj, similarityThreshold)
            
            if nargin < 3
                similarityThreshold = obj.similarityThreshold;
            end;
            
            [isEye similarity] = detectFromInterpolatedChannelWeight(obj, scalpmapObj.originalChannelWeight(:,:), similarityThreshold);
        end;
        
        function [isEye similarity scalpmapObj] = detectFromEEG(obj, EEG, similarityThreshold, varargin)
            % [isEye similarity scalpmapObj] = detectFromEEG(obj, EEG, similarityThreshold)
            
            if nargin < 3
                similarityThreshold = obj.similarityThreshold;
            end;
            
            if isempty(EEG.icachansind)
                EEG.icachansind= 1:length(EEG.chanlocs);
            end;
            
            [isEye similarity scalpmapObj] = detectFromChannelWeight(obj, EEG.icawinv, EEG.chanlocs(EEG.icachansind), similarityThreshold);
        end;
        
        function [isEye similarity scalpmapObj] = detectFromChannelWeight(obj, channelWeight, channelLocation, similarityThreshold, varargin)
            % [isEye similarity] = detectFromChannelWeight(obj, channelWeight, channelLocation, similarityThreshold)
            if nargin < 3
                similarityThreshold = obj.similarityThreshold;
            end;
            
            scalpmapObj = scalpmap; 
            scalpmapObj = scalpmapObj.addFromChannels(channelWeight, channelLocation);
            [isEye similarity] = detectFromScalpmapObj(obj, scalpmapObj, similarityThreshold);
        end;
        
        function [isEye similarity scalpmapObj] = detectFromStudy(obj, STUDY, ALLEEG, similarityThreshold, varargin)
            scalpmapObj = scalpmapOfStudy(STUDY, ALLEEG, [], 'normalizePolarity', false);
            [isEye similarity] = detectFromScalpmapObj(obj, scalpmapObj, similarityThreshold);
        end;
    end;
end