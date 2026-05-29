% Florian Meyer, 2024

function [modes,zValues,ks] = getModesSBCEXP17(wDepth,layers,scenario,index)

% parameters specifying depth sampling of modes
freqs = scenario.freqs;
maxModes = scenario.maxModes;
templateName = scenario.templateName;


% determine number of layers (halfspace does not count)
numLayers = size(layers,1) - 1;

% read template file and remove unnecessary lines
wIndex = 7;
halfSpaceStartIndex = 38;
textEnv = readlines(['SBCEXP17Template',templateName,'.env']);
layersEndIndex = wIndex + 3*numLayers;
textEnv(layersEndIndex+1:halfSpaceStartIndex-1) = [];

% adapt number of layers
textEnv{3} = regexprep(textEnv{3}, 'numLayers', num2str(numLayers+1));

% adapt waterdepth
textEnv = adaptWaterdepth(textEnv, wDepth, wIndex);

% adapt layers
lIndex = wIndex+1;
lastLayerEnd = wDepth;
for currentLayer = 1:numLayers
    [textEnv,lastLayerEnd] = adaptLayer(textEnv, layers(currentLayer), lastLayerEnd, lIndex );
    lIndex = lIndex + 3;
end

% adapt halfspace
hIndex = lIndex + 1;
textEnv = adaptHalfspace(textEnv, layers(numLayers+1), lastLayerEnd, hIndex );

% adapt frequencies
fIndex = hIndex + 7;
textEnv = adaptFrequencies(textEnv, freqs, fIndex );


% write .env file and run Kraken
filenameOut = ['SBCEXP17Compute',num2str(index)];
writelines(textEnv,[filenameOut,'.env']); fclose('all');
runKraken( filenameOut );

% read and store modes
numFreqs = size(freqs,1);
modesCell = cell(numFreqs,1);
ks = zeros(maxModes,numFreqs);
for indexF = 1:numFreqs

    clear readModes;
    modesKraken = readModes( [filenameOut,'.mod'], freqs(indexF), 1:maxModes);

    modesCell{indexF} = modesKraken.phi;
    numModes = size(modesCell{indexF},2);
    ks(1:numModes,indexF) = modesKraken.k;

end
eval( [ '! rm ' filenameOut '.*' ] );

% reorganize modes into vector
numModesTotal = size(modesKraken.phi,2);
numPoints = size(modesKraken.phi,1);
modes = zeros(numPoints,numModesTotal,numFreqs);
for indexF = 1:numFreqs

    numModes = size(modesCell{indexF},2);
    modes(:,1:numModes,indexF) = modesCell{indexF};

end

zValues = modesKraken.z;

end


function textEnv = adaptWaterdepth(textEnv, wDepth, wIndex )

% adapt water depth
textEnv{5} = regexprep(textEnv{5}, 'wDepth', num2str(wDepth));
textEnv{wIndex} = regexprep(textEnv{wIndex}, 'wDepth', num2str(wDepth));

end


function [textEnv,layer1End] = adaptLayer(textEnv, layer, layer1Start, lIndex  )

% extract layer1 parameters
speedTop1 = layer.speedTop;
speedBottom1 = layer.speedBottom;
density1 = layer.density;
attenuation1 = layer.attenuation;
thickness1 = layer.thickness;

layer1End = layer1Start + thickness1;

% adapt layer1 parameters
textEnv{lIndex} = regexprep(textEnv{lIndex}, 'layerEnd', num2str(layer1End));
textEnv{lIndex+1} = regexprep(textEnv{lIndex+1}, 'layerStart', num2str(layer1Start));
textEnv{lIndex+1} = regexprep(textEnv{lIndex+1}, 'speedTop', num2str(speedTop1));
textEnv{lIndex+2} = regexprep(textEnv{lIndex+2}, 'speedBottom', num2str(speedBottom1));
textEnv{lIndex+1} = regexprep(textEnv{lIndex+1}, 'density', num2str(density1));
textEnv{lIndex+1} = regexprep(textEnv{lIndex+1}, 'attenuation', num2str(attenuation1));
textEnv{lIndex+2} = regexprep(textEnv{lIndex+2}, 'density', num2str(density1));
textEnv{lIndex+2} = regexprep(textEnv{lIndex+2}, 'attenuation', num2str(attenuation1));
textEnv{lIndex+2} = regexprep(textEnv{lIndex+2}, 'layerEnd', num2str(layer1End));

end


function textEnv = adaptHalfspace(textEnv, layer, halfStart, hIndex )

% extract halfspace parameters
halfSpeed = layer.speedTop;
halfDensity = layer.density;
halfAttenuation = layer.attenuation;

% adapt halfspace parameters
textEnv{hIndex} = regexprep(textEnv{hIndex}, 'hStart', num2str(halfStart));
textEnv{hIndex} = regexprep(textEnv{hIndex}, 'hSpeed', num2str(halfSpeed));
textEnv{hIndex} = regexprep(textEnv{hIndex}, 'hDensity', num2str(halfDensity));
textEnv{hIndex} = regexprep(textEnv{hIndex}, 'hAttenuation', num2str(halfAttenuation));

end


function textEnv = adaptFrequencies(textEnv, freqs, fIndex )

% adapt frequencies
numFreqs = size(freqs,1);
freqString = [];
for indexF = 1:numFreqs
    freqString = [freqString,' ',num2str(freqs(indexF))];
end

textEnv{fIndex} = regexprep(textEnv{fIndex}, 'numFreqs', num2str(numFreqs));
textEnv{fIndex+1} = regexprep(textEnv{fIndex+1}, 'freqString', freqString);

end


function runKraken( filename )

runkraken = which( 'kraken.exe' );

if ( isempty( runkraken ) )
    error( 'kraken.exe not found in your Matlab path' )
else
    eval( [ '! "' runkraken '" ' filename ] );
end

end