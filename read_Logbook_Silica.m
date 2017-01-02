clear
clc
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='Logbook\';

%-------------------------------

disp('Silica dryer')

fl=dir([fl_dir,'LogBook_Troca_Silica.csv']);

count=0;
if size(fl,1)==0 && count==0
    return
else
    fid = fopen([fl_dir,'LogBook_Troca_Silica.csv']);
    while ~feof(fid)

        TextLine = fgetl(fid);
        delimiters=0;
        size_text=max(size(TextLine));
        i=1;
        while i<size_text
            if strcmp(TextLine(i),',')
                delimiters=delimiters+1;
                idx_delimiter(delimiters)=i;  
            end
            i=i+1;
        end

        try
            dummy_time_st=datenum(TextLine(1:idx_delimiter(1)-1),'dd/mm/yyyy HH:MM');
            dummy_time_end=datenum(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1),'dd/mm/yyyy HH:MM');
            time_error=0;
        catch error_message
            time_error=1;
        end

        if time_error==0;
                count=count+1; 
                time_Silica_st(count)=dummy_time_st;
                time_Silica_end(count)=dummy_time_end;
        end;
    end;
    status=fclose(fid);

    save mat-files/Troca_silica.mat

    if isunix
        !chmod 777 mat-files/Troca_silica.mat
    end
end