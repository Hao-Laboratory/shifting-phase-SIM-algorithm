% program for SIM reconstruction using shift phase algorithm
clear; clc; close all;
addpath('functions');
%% read image file
nOrientation = 3; % numbers of pattern's orientation 
nPhase = 3; % numbers of pattern's pnase 

filePath = ['.\results\', num2str(nOrientation), '-', num2str(nPhase), '\','\simulation data\']; % raw image file path
fileName = '1_X';
fileType = 'tif';

%% parameter of the detection system
lambda = 670; % fluorescence emission wavelength (emission maximum). unit: nm
pixelSize = 15; % psize=pixel size/magnification power. unit: nm

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
PSF_edge = fspecial('gaussian',5,40);
noiseImage = edgetaper(noiseImage,PSF_edge);
    
for iOrientation = 1:nOrientation
    % normalization by means of each image of a sequence
    % noiseImage(:,:,:,iOrientation) = removeSeqStripe(noiseImage(:,:,:,iOrientation));
end 

noiseImage = imresize(noiseImage, 2, 'bicubic'); % interpolation to satisfy Nyquist¨CShannon sampling theorem
[nPixelX, nPixelY] = size(noiseImage(:,:,1,1));

%% shift phase-SIM
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

