function [seq, weights] = removeSeqStripe(seq)
% Correct fluctuations of illumination such that all images
% (and/or image sequences) have the same mean intensity value.


if isstruct(seq)
    nSubSeq = length(seq);
    weights = ones(1,nSubSeq);
    for iSubSeq = 1:nSubSeq
        seq(iSubSeq).IMseq = removeStrip(seq(iSubSeq).IMseq);
        weights(iSubSeq) =  mean(double(seq(iSubSeq).IMseq(:)));
    end
    weights = mean(weights)./weights;
    for iSubSeq = 1:nSubSeq
        seq(iSubSeq).IMseq = weights(iSubSeq) * seq(iSubSeq).IMseq;
    end
else
    [seq, weights] = removeStrip(seq);
end

% ------------------------------------
function [IMseq, weights] = removeStrip(IMseq)
% ------------------------------------
% estimate weights
numseq = size(IMseq,3);
weights = ones(1,numseq);
for iSeq = 1:numseq
    im = IMseq(:,:,iSeq);
    weights(iSeq) = mean(double(im(:)));
end
weights = mean(weights)./weights;
% remove stripes
for iSeq = 1:numseq
    IMseq(:,:,iSeq) = weights(iSeq) * IMseq(:,:,iSeq);
end
