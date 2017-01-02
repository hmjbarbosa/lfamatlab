function [x_trans]=Vert(x)

    [dummy,idx]=max(size(x));

    if dummy>0

        if idx==2
            x_trans=x';
        else
            x_trans=x;
        end;

    else
        x_trans=x;
    end;


end