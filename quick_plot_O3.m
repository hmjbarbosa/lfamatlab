%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the O3 monitor ascii file and plots daily values %
% for a quick look. It saves a .mat with read data.                  %
%                                                                    %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all
[tmp,mydir]=fileparts(pwd);

if strcmp(mydir,'A_T2')
    station=' - T2 (Tiwa)';
else
    station=[' - ' mydir];    
end;

fl_dir='Thermo_49i_O3/raw/';

disp('O3')

%-------------------------------

if exist('mat-files/O3.mat')>0
    load mat-files/O3.mat
    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'49*']);

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
    fl=dir([fl_dir,'49*']);
    count=0;
    count_old=1;
    time_O3_avg=[];
    O3_avg=[];
    fl_old=fl;
end;



if size(fl,1)==0 && count==0

    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);
        while ~feof(fid)
            TextLine = fgetl(fid);
            spaces=0;
            size_text=max(size(TextLine));
            i=2;
             while i<size_text
                if strcmp(TextLine(i),' ')
                    if strcmp(TextLine(i-1),' ') 
                        TextLine(i)=[];
                        size_text=size_text-1;
                        i=i-1;
                   else
                        spaces=spaces+1;
                        idx_space(spaces)=i;
                   end;
                elseif strcmp(TextLine(i),'	')
                    spaces=spaces+1;
                    idx_space(spaces)=i;  
                end
                i=i+1;
            end

            if spaces==12   

                dummy_O3=str2num(TextLine(idx_space(3)+1:idx_space(4)-1));
                test_flag=strcmp(TextLine(idx_space(2)+1:idx_space(3)-1),'--------');
                dummy_day=str2num(TextLine(10:11));
                dummy_month=str2num(TextLine(7:8));
                dummy_year=str2num(TextLine(13:14))+2000;
                dummy_hour=str2num(TextLine(1:2));
                dummy_minute=str2num(TextLine(4:5));
                dummy_sec=0;

                    if max(size(dummy_O3))==1 && dummy_O3<150 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                        count=count+1; 
                        O3(count)=dummy_O3;
                        time_O3(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                        if time_O3(count)>(now+4) || time_O3(count)< datenum(2014,01,01) 
                            count=count-1;
                            O3(end)=[];
                            time_O3(end)=[];
                        end;
                    end;
            end;
        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------

    
[time_O3,idx]=unique(time_O3);
O3=O3(idx);

Readme_O3='Data from Thermo O3 Monitor i49 TS. Data filtered for reasonable time strings and limited to maximum of 150ppb of O3.';
  
label_O3='O3 mixing ratio (ppbv)';
title_O3='O3 (Thermo)';

if isunix
    fig1 = figure('visible','off');
else
    fig1=figure;
end;
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 

plot(time_O3(time_O3>datenum(2014,02,01)),O3(time_O3>datenum(2014,02,01)),'k*')
title(['O3 (Thermo)',station])
xlabel('Date')
ylabel(label_O3)
ylim([0 70])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/O3_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;
%Plot each day

days_O3=unique(floor(time_O3));

count_days=0;
clear rem_days;
if exist('days_O3_OK','var')==1
    if min(size(days_O3_OK))>0
        days_O3_OK=unique(days_O3_OK);
        for i=1:max(size(days_O3))
            if max(days_O3(i)==days_O3_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        if count_days>0
            days_O3(rem_days)=[];
        end
    end;
else
    days_O3_OK=[];
end;


if min(size(days_O3))>0
    for i=1:max(size(days_O3))

         if days_O3(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/O3_',mydir,'_',datestr(days_O3(i),29)];
        elseif days_O3(i)>datenum(2014,04,01) && days_O3(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/O3_',mydir,'_',datestr(days_O3(i),29)];
        elseif days_O3(i)>=datenum(2014,08,15) && days_O3(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/O3_',mydir,'_',datestr(days_O3(i),29)];
         end

        clear fig1;

        quick_time_O3=(time_O3-days_O3(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_O3));
        [diff_end,idx_end]=min(abs(quick_time_O3 - 24));


        if diff_st<1/24 && diff_end<1/24
            days_O3_OK=[days_O3_OK days_O3];
        end;

        %Calculate sunrise/sunset
        [rs,t,d,z,a,r]=suncycle(-3.07,60,i);

        rs=rs+8;

        if idx_end>idx_st+30


            if isunix
                fig1 = figure('visible','off');
            else
                fig1=figure;
            end;
            set(fig1,'InvertHardcopy','on');
            set(gca,'FontSize', 12, 'LineWidth', 2); 

            axis('off');
            axes1 = axes('Parent',fig1,...
            'XTickLabel',{'0','2','4','6','8','10','12','14','16','18','20','22','24'},...
            'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);


            hold on
    %            rectangle('Parent',axes1,'Position',[0,-1000,rs(1),2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
    %            rectangle('Parent',axes1,'Position',[rs(2),-1000,24,2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
            rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
            plot(quick_time_O3(idx_st:idx_end),O3(idx_st:idx_end),'k*')
            ylim(axes1,[min(O3(idx_st:idx_end)) max(O3(idx_st:idx_end))])
            xlim(axes1,[0 24])

            title(['O3 (Thermo)',station,' - ',datestr(days_O3(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_O3)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

            if isunix
                print(fig1,'-depsc',[fig_name,'.eps']);
                eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])
                eval(['delete ',fig_name,'.eps '])
            else
                eval(['export_fig ',fig_name,' -png -transparent'])
                close
            end;
        end;
    end;
end;

if isunix
    fid = fopen('0_Ascii-files/O3.csv','wt');
    fprintf(fid,'Date(UTC), O3 mixing ratio (ppbv)\n');
    for i=1:max(size(time_O3))
        fprintf(fid,'%s, %2.2f\n',datestr(time_O3(i)),O3(i));
    end;
    fclose(fid);

    !rm -f mat-files/O3.mat
end
save mat-files/O3.mat



if isunix
    !chmod 777 mat-files/O3.mat
end;