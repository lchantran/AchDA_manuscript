function newWords=expandWords(words, options)
arguments
    words cell
    options.justNew logical=true
    options.prefix char=''
    options.postfix char=''
    options.doubleWrap logical=false
end

addOns={'a', 'A', 'b', 'B'};

newWords={}; %(1, length(words)*length(addOns));

counter=1;
for cWC=words
    if isempty(cWC{1})
        toAdd=addOns(1:2);
    else
        toAdd=addOns;
    end
    for cAC=toAdd
        if options.doubleWrap
            newWords{counter}={[options.prefix cWC{1} cAC{1} options.postfix]};
        else
            newWords{counter}=[options.prefix cWC{1} cAC{1} options.postfix];
        end
        counter=counter+1;
    end
end

if ~options.justNew
    newWords=[words newWords];
end



