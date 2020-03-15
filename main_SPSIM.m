% Program for SIM reconstruction using "shifting-phase algorithm“ (SP-SIM)
% The algorithm was proposed in the article https://doi.org/10.1364/OL.387888

clear; clc; close all;
addpath('functions');
%% read image file
nOrientation = 3; % numbers of pattern's orientation 
nPhase = 3; % numbers of pattern's pnase 

filePath = ['.\results\', num2str(nOrientation), '-', num2str(nPhase), '\','\experimental data\']; % raw image file path
fileName = '1_X';
fileType = 'tif';

%% parameter of the detection system
lambda = 515; % fluorescence emission wavelength (emission maximum). unit: nm
pixelSize = 86.7; % pixel size of raw image. unit: nm

na = 1.49;
wienerFactor = 0.05; % parameter which depends on the noise level of the image

%% saving file
saveFlag = 0;  % save the results if saveFlag equals 1;

%% get raw images 
for iOrientation = 1:nOrientation
    for iPhase = 1:nPhase
        noiseImage(:,:,iPhase,iOrientation) = ...
            double(imread([filePath, fileName, num2str((iOrientation-1)*nPhase+iPhase),'.', fileType])); 
    end
end

%% Pre-processing to correct experimental minor fluctuations of the light source or camera exposure time (optional).     
for iOrientation = 1:nOrientation
    % normalization by means of each image of a sequence
     noiseImage(:,:,:,iOrientation) = removeSeqStripe(noiseImage(:,:,:,iOrientation));
end 

PSF_edge = fspecial('gaussian',5,40);
noiseImage = edgetaper(noiseImage,PSF_edge);

noiseImage = imresize(noiseImage, 2, 'bicubic'); % interpolation to satisfy Nyquist–Shannon sampling theorem
[nPixelX, nPixelY] = size(noiseImage(:,:,1,1));

%% Pre-processing：Wiener filtering to get smaller psf (optional, for star-like sample and beads in the manuscript, the process is commented)
[ipsfde, OTFde] = generatePSF(nPixelX,nPixelY,pixelSize/2, na, lambda);

for iOrientation = 1:nOrientation
    for iPhase = 1:nPhase
      %noiseImage(:,:,iPhase,iOrientation)=wienerFilter(OTFde,squeeze(noiseImage(:,:,iPhase,iOrientation)),wienerFactor.^2);        
      %noiseImage(:,:,iPhase,iOrientation)=noiseImage(:,:,iPhase,iOrientation).*(noiseImage(:,:,iPhase,iOrientation)>0);
    end
end

%% shifting-phase SIM
% pre-defined matrix to store the results
minusSquareImage = zeros(nPixelX, nPixelY, nPhase, nOrientation);
shiftPhaseImageOri = zeros(nPixelX, nPixelY, nOrientation); % shift phase image per orientation
wideFieldImageOri= mean(noiseImage, 3); % wide field image per orientation
wideFieldImage = mean(mean(noiseImage,3),4); % wide field image 

for iOrientation = 1:nOrientation
    for iPhase = 1:nPhase
        minusSquareImage(:,:,iPhase,iOrientation) = (noiseImage(:,:,iPhase,iOrientation) - ...
            wideFieldImageOri(:,:,1,iOrientation)).^2;
    end
    shiftPhaseImageOri(:,:,iOrientation) = sqrt(mean(minusSquareImage(:,:,:,iOrientation), 3));
end
  
shiftPhaseImage = mean(shiftPhaseImageOri, 3);

% draw figures
figure;
imagesc(1:nPixelX, 1:nPixelY, wideFieldImage);
axis square; colormap('gray');
colorbar; xlabel('Position X (pixel)'); ylabel('Positon Y (pixel)');
title('WF image');

figure;
imagesc(1:nPixelX, 1:nPixelY, shiftPhaseImage);
axis square; colormap('gray');
colorbar; xlabel('Position X (pixel)'); ylabel('Positon Y (pixel)');
title('SP-SIM image');

if saveFlag
    imwrite(uint8(norm01(wideFieldImage)*255), gray(256), [filePath,'WF','.', fileType],fileType,'Resolution',300);
    imwrite(uint8(norm01(shiftPhaseImage)*255), gray(256), [filePath,'SP-SIM','.', fileType],fileType,'Resolution',300);   
end

