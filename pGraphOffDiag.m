
smoothing=3;
b = (1/smoothing)*ones(1,smoothing);
a = 1;

figure; hold on 

curvea=processed_sum.ph.SI.Hi_Rew.xc2_diags_sa_hi_sem{5,6}(9,1:419);
curveb=processed_sum.ph.SI.Hi_Rew.xc2_diags_sa_low_sem{5,6}(9,1:419);
curvemid=processed_sum.ph.SI.Hi_Rew.xc2_diags{5,6}(9,1:419);

if smoothing>1
    curvea=filter(b, a, curvea);
    curveb=filter(b, a, curveb);
    curvemid=filter(b, a, curvemid);
end

tRange=[-121 0.018];

xx=tRange(2)*((1:length(curvemid))+tRange(1));

fillBetween(...
    curvea(1:(end-floor(smoothing/2))), ...
    curveb(1:(end-floor(smoothing/2))), ...
    colorName='red', ...
    tRange=tRange-[floor(smoothing/2) 0]);

plot(xx(1:(end-floor(smoothing/2))), curvemid((1+floor(smoothing/2)):end), ...
    'Color', 'red', ...
    'LineWidth', 2);


%% no rew
curvea=processed_sum.ph.SI.Low_NoRew.xc2_diags_sa_hi_sem{5,6}(9,1:419);
curveb=processed_sum.ph.SI.Low_NoRew.xc2_diags_sa_low_sem{5,6}(9,1:419);
curvemid=processed_sum.ph.SI.Low_NoRew.xc2_diags{5,6}(9,1:419);

if smoothing>1
    curvea=filter(b, a, curvea);
    curveb=filter(b, a, curveb);
    curvemid=filter(b, a, curvemid);
end

tRange=[-121 0.018];

xx=tRange(2)*((1:length(curvemid))+tRange(1));

fillBetween(...
    curvea(1:(end-floor(smoothing/2))), ...
    curveb(1:(end-floor(smoothing/2))), ...
    colorName='black', ...
    tRange=tRange-[floor(smoothing/2) 0]);

plot(xx(1:(end-floor(smoothing/2))), curvemid((1+floor(smoothing/2)):end), ...
    'Color', 'black', ...
    'LineWidth', 2);
