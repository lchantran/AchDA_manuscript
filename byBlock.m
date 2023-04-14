function pSignal=byBlock(rSignal, blockLength, options)
arguments
    rSignal double
    blockLength double
    options.mode double=0
end

% if options.mode==0, calculate sum
% if options.mode==1, calculate avg
% if options.mode==2, calculate any
    
if nargin<3
    options.mode=0;
end

nBlocks=floor(length(rSignal)/blockLength);
rr=reshape(rSignal(1:(nBlocks*blockLength)), blockLength, nBlocks);
if options.mode==0
    pSignal=mean(rr,1);
elseif options.mode==1
    pSignal=sum(rr,1);
elseif options.mode==2
    pSignal=any(rr,1);        
else
    error('byBlock: unknown options.mode')
end
