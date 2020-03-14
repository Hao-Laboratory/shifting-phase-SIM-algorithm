function [ noiseimage ] = wienerFilter( OTF,noiseimage,noise_factor)
%low-pass filter
[~,~,num]=size(noiseimage);
abs_OTF=abs(OTF);
for ii=1:num
    ft=fftshift(fft2(noiseimage(:,:,ii)));
    filtered_ft=ft.*OTF./(abs_OTF.^2+noise_factor);
    noiseimage(:,:,ii)=ifft2(ifftshift(filtered_ft));
end

end