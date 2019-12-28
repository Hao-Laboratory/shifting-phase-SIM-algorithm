function [ipsfde, OTFde] = generatePSF(xsize,ysize,psize,NA, lambda)

[Y,X]=meshgrid(1:ysize,1:xsize);

xc=floor(xsize/2+1);% the x-coordinate of the center
yc=floor(ysize/2+1);% the y-coordinate of the center
yr=Y-yc;
xr=X-xc;
R=sqrt((xr).^2+(yr).^2);% distance between the point (x,y) and center (xc,yc)

%% Generate the PSF
pixelnum=xsize;
rpixel=NA*pixelnum*psize/lambda;
cutoff=round(2*rpixel);% cutoff frequency
ctfde=ones(pixelnum,pixelnum).*(R<=rpixel);
ctfdeSignificantPix=numel(find(abs(ctfde)>eps(class(ctfde))));
ifftscalede=numel(ctfde)/ctfdeSignificantPix;
apsfde=fftshift(ifft2(ifftshift(ctfde)));
ipsfde=ifftscalede*abs(apsfde).^2;
OTFde=real(fftshift(fft2(ifftshift(ipsfde))));

% figure;imagesc(ipsfde);colormap(hot);title('psf');
% figure;imagesc(OTFde);colormap(hot);title('OTF');
