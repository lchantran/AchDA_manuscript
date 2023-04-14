function dp = dPrime(X,Y, XS, YS)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin==2
    dp=(abs(mean(X)-mean(Y)))/(((var(X)+var(Y))/2)^0.5);
elseif nargin==4
    dp=(abs(X-Y))./(((XS.^2+YS.^2)/2).^0.5);    
end