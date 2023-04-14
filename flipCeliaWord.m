function [outWord, genericWord]=flipCeliaWord(word)
outWord=word;
genericWord=word;
if isempty(word)
    return
end
firstAction=upper(word(1));

for counter=1:length(word)
    newChar=outWord(counter);
    if firstAction==upper(newChar) % same side
        if newChar=='l' || newChar=='r' % no reward
            genericWord(counter)='a';
        else
            genericWord(counter)='A'; % reward
        end
    else % other wise
        if newChar=='l' || newChar=='r' % no reward
            genericWord(counter)='b';
        else
            genericWord(counter)='B'; % reward
        end
    end

    switch newChar
        case 'r'
            outWord(counter)='l';
        case 'R'
            outWord(counter)='L';
        case 'l'
            outWord(counter)='r';
        case 'L'
            outWord(counter)='R';
    end
end