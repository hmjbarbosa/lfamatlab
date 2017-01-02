%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 15/Aug/2014   %                                  %
%                                      %                                 %
%This routine reads the OFR ascii file %
%and sorts the ACSM accordingly.       % 
%                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
close all

load mat-files/OFR.mat

fl_dir=dir('ACSM/2min_avg/2014*');

disp('Sort ACSM-OFR')

%-------------------------------

count=0;
for i=1:max(size(fl_dir))
    
    fl_acsm=dir(['ACSM/2min_avg/',fl_dir(i).name,'/*.itx']);
    
    if exist(['ACSM/2min_avg/AMB/',fl_dir(i).name],'dir')==0
        eval(['mkdir ACSM/2min_avg/AMB/',fl_dir(i).name])
    end;
    
    if exist(['ACSM/2min_avg/OFR/',fl_dir(i).name],'dir')==0
        eval(['mkdir ACSM/2min_avg/OFR/',fl_dir(i).name])
    end;
    
    if exist(['ACSM/2min_avg/Trans/',fl_dir(i).name],'dir')==0
        eval(['mkdir ACSM/2min_avg/Trans/',fl_dir(i).name])
    end;
    
    if min(size(fl_acsm))>0
        for j=1:max(size(fl_acsm))
            count=count+1;
            time_fl_acsm=datenum(fl_acsm(j).name(1:end-4),'yyyymmdd_HH_MM_SS');
            [a,idx_end]=min(abs(time_OFR-time_fl_acsm));
            [a,idx_st]=min(abs(time_OFR-(time_fl_acsm-2./(24*60))));

            if time_fl_acsm<datenum(2014,03,27,12,0,0) || a>1.5/(24*60)
                dest='AMB/';
                flag(count)=1;
            else

                if valve_status(idx_st)==valve_status(idx_end)
                    if valve_status(idx_st)==0
                        dest='AMB/';
                        flag(count)=1;
                    else
                        dest='OFR/';
                        flag(count)=2;
                    end

                else

                    dest='Trans/';
                    flag(count)=3;
                end;
            end;
    
            
            if exist(['ACSM/2min_avg/',dest,fl_dir(i).name,'/',fl_acsm(j).name],'file')==0;
                eval(['copyfile ACSM/2min_avg/',fl_dir(i).name,'/',fl_acsm(j).name,' ACSM//2min_avg/',dest,fl_dir(i).name,'/']);
            end;
        end;
    end;
end;

