clear variables; close all; clc; addpath('../'); rng(1);

% SBCEXP17 12:30 J88

%% set general parameters

freqsNoise = (190:20:590)';
freqsTones = [53; 103; 203; 253; 303; 403; 503; 703; 953];
freqsTonesUpper = [303; 403; 503; 703; 953];

scenario.freqs = freqsTonesUpper;
scenario.maxModes = 50;
scenario.receiverDepths = [14.0000;17.7500;21.5000;25.2500;29.0000;32.7500;36.5000;40.2500;44.0000;47.7500;51.5000;55.2500;59.0000;62.7500;66.5000;70.2500];
scenario.likelihoodConstantSNR = 10;
scenario.modelMode = 'L2HM1N';
scenario.templateName = '88';

sourceRange = 1857.4;
sourceDepth = 44.3;   

tilt = 0;
waterDepth = 75;

speedTop1 = 1445;
density1 = 1.612;
attenuation1 = 0.04;
speedBottom1 = 1500;
thickness1 = 9;

speedTop2 = 1500;
density2 = 1.7;
attenuation2 = 0.15;
speedBottom2 = 1750;
thickness2 = 1.3;

scenario.knownState = [sourceRange;sourceDepth;tilt;waterDepth;speedTop1;density1;attenuation1;speedBottom1;thickness1;speedTop2;density2;attenuation2;speedBottom2;thickness2];      % this is the the order of parameters we use all the time
numParameters = size(scenario.knownState,1);

scenario.isKnown = false(numParameters,1);
scenario.isKnown(13) = true;

scenario.coupling = zeros(0,2);

%% load data

load('data1FirstWAcousticSnapshots')
scenario.snapshotIndex = 4;
dataMatrixes = dataMatrixHighTones(:,:,5:9,scenario.snapshotIndex);


%% perform inversion

% general parameters
numParameters = numel(scenario.isKnown);
numParametersUnkown = sum(~scenario.isKnown) - size(scenario.coupling,1);

% define prior
scenario.prior.sourceRange = [1500;2100];
scenario.prior.sourceDepth = [30;60];
scenario.prior.tilt = [-3;3];
scenario.prior.waterDepths = [73;78];

scenario.prior.topSpeed1 = [1400;1750];
scenario.prior.density1 = [1.00;2.50];
scenario.prior.attenuation1 = [0;0.5];
scenario.prior.bottomSpeed1 = [1400;1750];
scenario.prior.thickness1 = [5;15];

scenario.prior.topSpeed2 = [1400;1750];
scenario.prior.density2 = [1.00;2.50];
scenario.prior.attenuation2 = [0;0.5];
scenario.prior.bottomSpeed2 = [1400;1750];
scenario.prior.thickness2 = [.5;4];

scenario.priorMean = nan(numParameters,1);
scenario.priorStds = inf(numParameters,1);


% initialize prior and initial proposal distribution
mcmc.regularizationFactor = 1e-7;
[scenario.priorMean,priorCovariance,priorRotation,priorVariances] = getPriorCovariance(scenario,mcmc);

% initialize first sample and proposal
referenceSample = scenario.priorMean;

ranges = scenario.prior.sourceRange(1):5:scenario.prior.sourceRange(2);
depths = scenario.prior.sourceDepth(1):.5:scenario.prior.sourceDepth(2);

ambiguitySurface1 = zeros(numel(ranges),numel(depths));
for iRange = 1:numel(ranges)
    for iDepth = 1:numel(depths)
        currentSample = referenceSample;
        currentSample(1) = ranges(iRange);
        currentSample(2) = depths(iDepth);
        
        if(iRange == 1 && iDepth == 1)
            layers = createLayersSBCEXP17Model1(4,[1812;2.2;0.05],currentSample(5:9),currentSample(10:14));
            [modes,z,k] = getModesSBCEXP17(currentSample(4),layers,scenario,1);
        end

        [receiverDepthsTilted,receiverOffsets] = getReceiverDepthOffset(scenario.receiverDepths,currentSample(3));
        modelledPressure = getPressure(modes,z,k,receiverDepthsTilted,receiverOffsets,currentSample(1),currentSample(2));

        [~,correlationCoefficients] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);
        ambiguitySurface1(iRange,iDepth) = mean(correlationCoefficients);
    end
end

figure(1)
%imagesc(ranges,depths,10*log10(ambiguitySurface1'),[-40,0])
imagesc(ranges,depths,ambiguitySurface1',[0,0.3])
colorbar




load('mapEstimateJ881230')
referenceSample = mapEstimate;

layers = createLayersSBCEXP17Model1(4,[1812;2.2;0.05],referenceSample(5:9),referenceSample(10:14));
[modes,z,k] = getModesSBCEXP17(referenceSample(4),layers,scenario,1);
[receiverDepthsTilted,receiverOffsets] = getReceiverDepthOffset(scenario.receiverDepths,referenceSample(3));
modelledPressure = getPressure(modes,z,k,receiverDepthsTilted,receiverOffsets,referenceSample(1),referenceSample(2));
[~,correlationCoefficientsMAP] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);


ranges = scenario.prior.sourceRange(1):5:scenario.prior.sourceRange(2);
depths = scenario.prior.sourceDepth(1):.5:scenario.prior.sourceDepth(2);

ambiguitySurface2 = zeros(numel(ranges),numel(depths));
for iRange = 1:numel(ranges)
    for iDepth = 1:numel(depths)
        currentSample = referenceSample;
        currentSample(1) = ranges(iRange);
        currentSample(2) = depths(iDepth);

        [receiverDepthsTilted,receiverOffsets] = getReceiverDepthOffset(scenario.receiverDepths,currentSample(3));
        modelledPressure = getPressure(modes,z,k,receiverDepthsTilted,receiverOffsets,currentSample(1),currentSample(2));

        [~,correlationCoefficients] = evaluateLogLikelihood(modelledPressure,dataMatrixes,nan,scenario.likelihoodConstantSNR);
        ambiguitySurface2(iRange,iDepth) = mean(correlationCoefficients);
    end
end

figure(2)
%imagesc(ranges,depths,10*log10(ambiguitySurface2'),[-40,0])
imagesc(ranges,depths,ambiguitySurface2',[0,0.7])
colorbar

save('ambiguitySurfacesSBCEXP17','ranges','depths','ambiguitySurface1','ambiguitySurface2')