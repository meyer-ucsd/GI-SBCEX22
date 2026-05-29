clear variables; close all; clc; %addpath('./results'); addpath('./resultsAdiabatic/')

numBins = 50;
numBurnIn = 20000;

load('results17L2H');
plotTitle = '';

numTotal = sum(samples(1,1,:)>0);
numTemperatures = size(samples,2);


% compute estimates
samples1 = permute(samples(:,1,numBurnIn:numTotal),[1,3,2]);
logLikelihoods = logLikelihoods(1,numBurnIn:numTotal)';

mmseEstimate = mean(samples1,2)
[~,maxIndex] = max(logLikelihoods);
mapEstimate = samples1(:,maxIndex)

%isvalid = squeeze(samples(11,1,:) < 9.5);

%isvalid = true(numTotal,1);
%isvalid(1:numBurnIn) = false;
%isvalid(numTotal:end) = false;

isvalid = numBurnIn:numTotal;


% extract prior information and parameter names
prior = scenario.prior;
if(isfield(prior, 'sourceRangeStd'))
    prior = rmfield(prior,'sourceRangeStd');
    prior = rmfield(prior,'sourceDepthStd');
end

parameterNames = fieldnames(prior);
priorCell = struct2cell(prior);
priorMean = mean([priorCell{:}],1)';
numParameters = size(priorMean,1);

% scenario.modelMode = 'L2M1';
% % perform sensitivity analysis (if not already performed)
% if(~exist('sensitivityY','var'))
%     [sensitivityY,sensitivityX] = getSensitivitySBCEXP17(prior,scenario,25);
% end

% % show sensitivity results
% currentFigure = figure(1);
% currentFigure.WindowState = 'maximized';
% for parameterIndex = 1:numParameters
%     subplot(5,4,parameterIndex)
%     plot(sensitivityX(:,parameterIndex),sensitivityY(:,parameterIndex))
%     hold on
%     xlabel(parameterNames{parameterIndex})
%     ylabel('correlation coefficient')
%     ylim([min(sensitivityY(:,parameterIndex)) 1])
%     xlim([prior.(parameterNames{parameterIndex})(1) prior.(parameterNames{parameterIndex})(2)])
% end

% show inversion results
for indexTemp = numTemperatures:-1:1

    % remove initial samples
    currentSamples = permute(samples(:,indexTemp,isvalid),[1,3,2]);


    currentFigure = figure(indexTemp+1);
    currentFigure.WindowState = 'maximized';
    for parameterIndex = 1:numParameters
        priorInterval = prior.(parameterNames{parameterIndex});
        resolution = (priorInterval(2) - priorInterval(1))/(numBins-1);
        valuesGrid = (priorInterval(1):resolution:priorInterval(2))';

        % if(parameterIndex == 4)
        %     currentSamples(parameterIndex,:) = currentSamples(parameterIndex,:) + 1.5;
        %     if(indexTemp == 1)
        %         mmseEstimate(parameterIndex) = mmseEstimate(parameterIndex) + 1.5;
        %     end
        % end
        % 
        % if(parameterIndex == 7)
        %     currentSamples(parameterIndex,:) = currentSamples(parameterIndex,:) + 0.2;
        %     if(indexTemp == 1)
        %         mmseEstimate(parameterIndex) = mmseEstimate(parameterIndex) + 0.2;
        %     end
        % end

        subplot(5,4,parameterIndex)
        binEdges = linspace(prior.(parameterNames{parameterIndex})(1),prior.(parameterNames{parameterIndex})(2),(prior.(parameterNames{parameterIndex})(2)-prior.(parameterNames{parameterIndex})(1))/resolution + 1);
        h = histogram(currentSamples(parameterIndex,:), 'BinEdges', binEdges, 'Normalization', 'probability');
        hold on
        xlabel(parameterNames{parameterIndex})
        ylabel('estimated probability')
        ylim([0 1.1*max(h.Values)])
        xline(mmseEstimate(parameterIndex),'r--','Linewidth',1.5)
        xline(scenario.knownState(parameterIndex),'k-.','Linewidth',1.5)
        

    end
    sgtitle(plotTitle) 
end
