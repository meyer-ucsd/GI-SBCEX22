% Florian Meyer, 2024

function [samples,logLikelihoods,logPriors,swapIndexes] = performSwap(samples,logLikelihoods,logPriors,tempering,currentIndex)
temperatures = tempering.temperatures;
numTemperatures = size(tempering.temperatures,1);
isSwap = tempering.isSwap;

swapIndexes = nan(2,numTemperatures);
if(isSwap)

    for iSwap = 1:numTemperatures

        swapIndex1 = randi(numTemperatures);
        swapIndex2 = randi(numTemperatures);

        if(swapIndex1==swapIndex2)
            fprintf([num2str(currentIndex), ': not swapped ', '\n'])
            continue
        end

        % not really needed but makes visualization easier to interprete
        if(swapIndex1>swapIndex2)
            swapIndex1Tmp = swapIndex1;
            swapIndex1 = swapIndex2;
            swapIndex2 = swapIndex1Tmp;
        end

        swapCandidate1 = samples(:,swapIndex1);
        swapCandidate2 = samples(:,swapIndex2);
        logLikelihood1 = logLikelihoods(swapIndex1);
        logLikelihood2 = logLikelihoods(swapIndex2);
        logPrior1 = logPriors(swapIndex1);
        logPrior2 = logPriors(swapIndex2);
        temperature1 = temperatures(swapIndex1);
        temperature2 = temperatures(swapIndex2);

        [samples(:,swapIndex1),samples(:,swapIndex2),logLikelihoods(swapIndex1),logLikelihoods(swapIndex2),logPriors(swapIndex1),logPriors(swapIndex2),isSwapped,swapProbability] = swapStatesPrior(swapCandidate1,swapCandidate2,logLikelihood1,logLikelihood2,logPrior1,logPrior2,temperature1,temperature2);

        if(isSwapped)
            swapIndexes(:,iSwap) = [swapIndex1;swapIndex2];
            fprintf([num2str(currentIndex), ': swapped, first index = ', num2str(swapIndex1), ', second index = ' num2str(swapIndex2), ', log likelihood 1 = ' num2str(logLikelihood1*temperature1), ', log likelihood 2 = ' num2str(logLikelihood2*temperature2), ', swap probability = ' num2str(swapProbability), '\n'])
        else
            fprintf([num2str(currentIndex), ': not swapped, first index = ', num2str(swapIndex1), ', second index = ' num2str(swapIndex2), ', log likelihood 1 = ' num2str(logLikelihood1*temperature1), ', log likelihood 2 = ' num2str(logLikelihood2*temperature2), ', swap probability = ' num2str(swapProbability), '\n'])
        end

    end

end

end


function [sampleOut1,sampleOut2,logLikelihoodOut1,logLikelihoodOut2,logPriorOut1,logPriorOut2,isSwapped,swapProbability] = swapStatesPrior(sampleIn1,sampleIn2,logLikelihood1,logLikelihood2,logPrior1,logPrior2,temperature1,temperature2)
sampleOut1 = sampleIn1;
sampleOut2 = sampleIn2;
isSwapped = false;

logLikelihoodOut1 = logLikelihood1;
logLikelihoodOut2 = logLikelihood2;
logPriorOut1 = logPrior1;
logPriorOut2 = logPrior2;


logLikelihood2 = logLikelihood2 * temperature2;
logLikelihood1 = logLikelihood1 * temperature1;

logPrior2 = logPrior2 * temperature2;
logPrior1 = logPrior1 * temperature1;

swapProbability = min([1;exp( (-logLikelihood2+logLikelihood1-logPrior2+logPrior1) * (1/temperature2-1/temperature1))]);

if rand(1) <= swapProbability
    sampleOut1 = sampleIn2;
    sampleOut2 = sampleIn1;

    logLikelihoodOut1 = logLikelihood2 / temperature1;
    logLikelihoodOut2 = logLikelihood1 / temperature2;

    logPriorOut1 = logPrior2 / temperature1;
    logPriorOut2 = logPrior1 / temperature2;

    isSwapped = true;
end

end