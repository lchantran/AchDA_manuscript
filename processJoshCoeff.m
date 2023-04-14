blockLength=41;

newTable=table;
varList=cell(21,1);
ccc=zeros(21, 41);
for bn=0:20
    startIndex=1+1+bn*blockLength; 
    vName=char(cTable.VarName1(startIndex));
    ff=strfind(vName, '_');
    vName=vName(1:(ff(1)-1));
    newTable.([vName '_ch5'])=cTable.coeff_Ch5((0:40)+startIndex);
    newTable.([vName '_ch6'])=cTable.coeff_Ch6((0:40)+startIndex);
    varList{bn+1}=vName;
    c90=xcorr(cTable.coeff_Ch5((0:40)+startIndex), cTable.coeff_Ch6((0:40)+startIndex), 20, 'normalized');
    ccc(bn+1,:)=c90;
%    plot(0.054*(-20:20), c90, 'DisplayName', vName)
    figure; hold on; legend
    title(vName)
    plot(0.054*(-20:20), cTable.coeff_Ch5((0:40)+startIndex), 'DisplayName', 'Ch5');
    plot(0.054*(-20:20), cTable.coeff_Ch6((0:40)+startIndex), 'DisplayName', 'Ch6');


end

%%
vName='photometrySideInIndex';
chan=5;

figure; hold on; legend
title(vName)
chS=['ch' num2str(chan)];
plot(0.054*(-20:20), newTable.([vName 'aa_' chS]), 'DisplayName', ['aa ' chS], 'Color', 'g');
plot(0.054*(-20:20), newTable.([vName 'Aa_' chS]), 'DisplayName', ['Aa ' chS], 'Color', 'g', 'LineWidth', 2);
plot(0.054*(-20:20), newTable.([vName 'ab_' chS]), 'DisplayName', ['ab ' chS], 'Color', 'r');
plot(0.054*(-20:20), newTable.([vName 'AB_' chS]), 'DisplayName', ['AB ' chS], 'Color', 'r', 'LineWidth', 2);
plot([0 0], [-2 2], 'k--')
