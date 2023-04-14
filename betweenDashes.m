function y=betweenDashes(x)
    y='';
    pp=strfind(x, '_');
    if length(pp)>=2
        y=x(pp(1)+1:pp(2)-1);
    end
