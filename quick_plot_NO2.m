%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the CAPS NO2 monitor ascii file and plots daily  %
% NO2 values for a quick look. It saves a .mat with read data.       %
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

station=mydir;    

fl_dir='NO2/raw/';

disp('NO2')

%-------------------------------

if exist('mat-files/NO2.mat')>0
    load mat-files/NO2.mat
    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'CAPS*.dat']);

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
    fl=dir([fl_dir,'CAPS*.dat']);
    count=0;
    count_old=1;
    time_NO2_avg=[];
    NO2_avg=[];
    fl_old=fl;
end;



if size(fl,1)==0 && count==0

    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);
        disp([fl_dir,fl(fl_number).name]);
        
        while ~feof(fid)
            TextLine = fgetl(fid);
            delimiters=0;
            size_text=max(size(TextLine));
            i=2;
             while i<size_text
                if strcmp(TextLine(i),',')
                    delimiters=delimiters+1;
                    idx_delimiter(delimiters)=i;  
                end
                i=i+1;
            end

            if delimiters==9 
                if max(size(TextLine(idx_delimiter(9):end)))>10

                    dummy_NO2=str2num(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1));
                    dummy_year=str2num(TextLine(idx_delimiter(9)+1:idx_delimiter(9)+4));
                    dummy_month=str2num(TextLine(idx_delimiter(9)+6:idx_delimiter(9)+7));
                    dummy_day=str2num(TextLine(idx_delimiter(9)+9:idx_delimiter(9)+10));
                    dummy_hour=str2num(TextLine(idx_delimiter(9)+12:idx_delimiter(9)+13));
                    dummy_minute=str2num(TextLine(idx_delimiter(9)+15:idx_delimiter(9)+16));
                    dummy_sec=str2num(TextLine(idx_delimiter(9)+18:idx_delimiter(9)+19));


                    if max(size(dummy_NO2))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                            count=count+1; 
                            NO2(count)=dummy_NO2;
                            time_NO2(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                            if time_NO2(count)>(now+4) || time_NO2(count)< datenum(2014,08,02) %Excludes weird dates from MAAP (e.g. future and before GoAmazon dataset.).
                                count=count-1;
                                NO2(end)=[];
                                time_NO2(end)=[];
                            end;
                    end;
                end;
            end   
        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------

    
[time_NO2,idx]=unique(time_NO2);
NO2=NO2(idx);

NO2(time_NO2==0)=[];
time_NO2(time_NO2==0)=[];

Readme_NO2='Data from Aerodyne CAPS monitor. Data filtered for reasonable time strings.';


label_NO2='NO2 mixing ratio (ppbv)';
title_NO2='NO2 (CAPS)';

while count_old < count
    S=0;
    D=0;
    i=1;
    while S<300 && D<1 && (count_old+i)<max(size(time_NO2))
        [D, S] = DateDiff(time_NO2(count_old),time_NO2(count_old+i));
        i=i+1;
    end;
    if i>3
        time_NO2_avg=[time_NO2_avg (time_NO2(count_old)+time_NO2(i+count_old))/2];
        NO2_avg=[NO2_avg mean(NO2(count_old:count_old+i))];
    end;
    count_old=count_old+i+1;
end;

if nodisplay
    fig1 = figure('visible','off');
else
    fig1=figure;
end;

set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 

plot(time_NO2,NO2,'k*')
title(['NO2 (CAPS) - ',station])
xlabel('Date')
ylabel(label_NO2)
ylim([0 40])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/NO2_' mydir '_Time_series'];

if nodisplay
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;
%Plot each day

days_NO2=unique(floor(time_NO2));

count_days=0;
if exist('days_NO2_OK','var')==1
    if min(size(days_NO2_OK))>0
        days_NO2_OK=unique(days_NO2_OK);
        for i=1:max(size(days_NO2))
            if max(days_NO2(i)==days_NO2_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_NO2(rem_days)=[];
    end;
else
    days_NO2_OK=[];
end;

if min(size(days_NO2))>0
    for i=1:max(size(days_NO2))

        fig_name=['fig/NO2_',mydir,'_',datestr(days_NO2(i),29)];

        clear fig1;

        quick_time_NO2=(time_NO2-days_NO2(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_NO2));
        [diff_end,idx_end]=min(abs(quick_time_NO2 - 24));


        if diff_st<1/24 && diff_end<1/24
            days_NO2_OK=[days_NO2_OK days_NO2];
        end;

        %Calculate sunrise/sunset
        [rs,t,d,z,a,r]=suncycle(-3.07,60,i);

        rs=rs+8;

        if idx_end>idx_st+30

            if nodisplay
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
            plot(quick_time_NO2(idx_st:idx_end),NO2(idx_st:idx_end),'k*')
            ylim(axes1,[min(NO2(idx_st:idx_end)) max(NO2(idx_st:idx_end))])
            xlim(axes1,[0 24])

            title(['NO2 (CAPS) - ',station,' - ',datestr(days_NO2(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_NO2)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

            if nodisplay
                print(fig1,'-depsc',[fig_name,'.eps']);
                eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])
                eval(['delete ',fig_name,'.eps '])
            else
                eval(['export_fig ',fig_name,' -png -transparent'])
            end;
    
        end;
    end;
end;

fid = fopen('0_Ascii-files/NO2.csv','wt');
fprintf(fid,'Date(UTC), NO2 mixing ratio (ppbv)\n');
for i=1:max(size(time_NO2_avg))
  fprintf(fid,'%s, %2.2f\n',datestr(time_NO2_avg(i)),NO2_avg(i));
end;
fclose(fid);

save mat-files/NO2.mat

