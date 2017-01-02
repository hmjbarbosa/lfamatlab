%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 15/Aug/2014   %                                  %
%                                      %                                 %
%This routine reads the OFR ascii file %
%and saves a .mat with data read.      % 
%                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all
[tmp,mydir]=fileparts(pwd);

if strcmp(mydir,'A_T2')
    station=' - T2 (Tiwa)';
else
    station=[' - ' mydir];    
end;


fl_dir='OFR/';

disp('OFR')

%-------------------------------

if exist('mat-files/OFR.mat')>0
    load mat-files/OFR.mat
    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'*JGmasterlog.txt']);

    for i=1:max(size(fl_old))
        for j=1:max(size(fl))
            if strcmp(fl(j).name,fl_old(i).name)
                if fl(j).bytes==fl_old(i).bytes
                    count_rem=count_rem+1;
                    rem_idx(count_rem)=j;
                end;
            end;
        end;
    end;
    
    fl(rem_idx)=[];
    
    fl_old=[fl_old;fl];

else
    fl=dir([fl_dir,'*JGmasterlog.txt']);
    count=0;
    count_dummy=0;
    count_old=1;
    fl_old=fl;
end;



if size(fl,1)==0 && count==0

    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))
             fid = fopen([fl_dir,fl(fl_number).name]);
        total_lines=0;
        TextLine = fgetl(fid);
        while ~feof(fid)
            total_lines=total_lines+1;
            delimiters=0;
            size_text=max(size(TextLine));
            i=2;
            while i<size_text
                if strcmp(TextLine(i),'	')
                        delimiters=delimiters+1;
                        idx_delimiter(delimiters)=i;
                end
                i=i+1;
            end

            
            if delimiters==19
                count_dummy=count_dummy+1;
                dummy_O3_OFR=str2num(TextLine(idx_delimiter(7)+1:idx_delimiter(8)-1));
                dummy_valve_status=str2num(TextLine(idx_delimiter(19)+1:end));
                dummy_lamp=str2num(TextLine(idx_delimiter(14)+1:idx_delimiter(15)-1));
                
                dummy_day=str2num(TextLine(idx_delimiter(2):idx_delimiter(3)));
                dummy_month=str2num(TextLine(idx_delimiter(1):idx_delimiter(2)));
                dummy_year=str2num(TextLine(1:idx_delimiter(1)));
                dummy_hour=str2num(TextLine(idx_delimiter(3):idx_delimiter(4)));
                dummy_minute=str2num(TextLine(idx_delimiter(4):idx_delimiter(5)));
                dummy_sec=str2num(TextLine(idx_delimiter(5):idx_delimiter(6)));


                 if max(size(dummy_O3_OFR))==1 && max(size(dummy_lamp))==1 && max(size(dummy_valve_status))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                     if dummy_sec==0
                        count=count+1;  
                        valve_status(count)=dummy_valve_status;
                        lamp(count)=dummy_lamp;
                        O3_OFR(count)=dummy_O3_OFR;
                        time_OFR(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                     end
                end;
            end   
   
    
        
            % get next line of text
            TextLine = fgetl(fid);

        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------

[time_OFR,idx_sort]=unique(time_OFR);
time_OFR=time_OFR+4./24; %Conversion to UCT
O3_OFR=O3_OFR(idx_sort);
lamp=lamp(idx_sort);
valve_status=valve_status(idx_sort);
    
if isunix 
    !rm -f mat-files/OFR.mat
end;

save mat-files/OFR.mat
save mat-files/flag_OFR.mat valve_status time_OFR

if isunix
    !chmod 777 mat-files/OFR.mat
    !chmod 777 mat-files/flag_OFR.mat
end;