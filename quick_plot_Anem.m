%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the Lufft anemometer ascii file and plots daily  % 
%wind direction values for a quick look. It saves a .mat file to be  %
%integrated in different analysis.                                   %
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

fl_dir='LUFT_V200/raw/';

disp('Anemometer')

%-------------------------------

if exist('mat-files/Anem.mat')>0
    load mat-files/Anem.mat
    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'lufft*']);

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
    fl=dir([fl_dir,'lufft*']);
    count=0;
    fl_old=fl;
end;



if size(fl,1)==0 && count==0
    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);
        total_lines=0;

        while ~feof(fid)
            TextLine = fgetl(fid);
            total_lines=total_lines+1;
            delimiters=0;
            size_text=max(size(TextLine));
            i=2;
            while i<size_text
                if strcmp(TextLine(i),';')
                    delimiters=delimiters+1;
                    idx_delimiter(delimiters)=i;
                end
                i=i+1;
            end

            if delimiters==22   

                dummy_Anem_vel=str2num(TextLine(idx_delimiter(16)+1:idx_delimiter(17)-1));
                dummy_Anem_dir=str2num(TextLine(idx_delimiter(18)+1:idx_delimiter(19)-1));
                dummy_day=str2num(TextLine(9:10));
                dummy_month=str2num(TextLine(6:7));
                dummy_year=str2num(TextLine(1:4));
                dummy_hour=str2num(TextLine(12:13));
                dummy_minute=str2num(TextLine(15:16));
                dummy_sec=str2num(TextLine(18:19));


                if max(size(dummy_Anem_vel))==1 && max(size(dummy_Anem_dir))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                    count=count+1; 
                    Anem_vel(count)=dummy_Anem_vel;
                    Anem_dir(count)=dummy_Anem_dir;
                    time_Anem(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                    if time_Anem(count)>(now+4) || time_Anem(count)<datenum(2014,01,01) %Excludes weird dates from MAAP (e.g. future aand more than two years old for GoAmazon dataset.).
                        count=count-1;
                        Anem_vel(end)=[];
                        Anem_dir(end)=[];
                        time_Anem(end)=[];
                    end;
                end;
            end     
        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------
   
Readme_Anem='Data from Lufft anemometer V200. Data filtered for reasonable time strings.';

[time_Anem,idx_sort]=unique(time_Anem);
Anem_vel=Anem_vel(idx_sort);
Anem_dir=Anem_dir(idx_sort);



label_Anem_dir=('Wind direction (^o)');
title_Anem_dir=('Wind direction');
label_Anem_vel=('Wind velocity (m/s)');
title_Anem_vel=('Wind velocity');

if isunix
    fig1 = figure('visible','off');
else
    fig1=figure;
end;
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 

plot(time_Anem,Anem_vel,'k*')
title([title_Anem_vel,station])
xlabel('Date')
ylabel(label_Anem_vel)
ylim([0 20])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Anem_vel' mydir '_Time_series'];


if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;

clear fig1

if isunix
    fig1 = figure('visible','off');
else
    fig1=figure;
end;

set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 

plot(time_Anem(Anem_vel>0.5),Anem_dir(Anem_vel>0.5),'k*')
title([title_Anem_dir,station])
xlabel('Date')
ylabel(label_Anem_dir)
ylim([0 360])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Anem_dir_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;


%Plot each day

days_Anem=unique(floor(time_Anem));

count_days=0;
if exist('days_Anem_OK','var')==1
    if min(size(days_Anem_OK))>0
        days_Anem_OK=unique(days_Anem_OK);
        for i=1:max(size(days_Anem))
            if max(days_Anem(i)==days_Anem_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_Anem(rem_days)=[];
    end;
else
    days_Anem_OK=[];
end;


if min(size(days_Anem))>0
    for i=1:max(size(days_Anem))

         if days_Anem(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/Anem_dir_',mydir,'_',datestr(days_Anem(i),29)];
        elseif days_Anem(i)>datenum(2014,04,01) && days_Anem(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/Anem_dir_',mydir,'_',datestr(days_Anem(i),29)];
        elseif days_Anem(i)>=datenum(2014,08,15) && days_Anem(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/Anem_dir_',mydir,'_',datestr(days_Anem(i),29)];
         end

        clear fig1;

        quick_time_Anem=(time_Anem-days_Anem(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_Anem));
        [diff_end,idx_end]=min(abs(quick_time_Anem - 24));


        if diff_st<1/24 && diff_end<1/24
            days_Anem_OK=[days_Anem_OK days_Anem];
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
            plot(quick_time_Anem(idx_st:idx_end),Anem_dir(idx_st:idx_end),'k*')
            ylim(axes1,[0 360])
            xlim(axes1,[0 24])

            title(['Anem Wind Direction (Lufft)',station,' - ',datestr(days_Anem(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_Anem_dir)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

            
            if isunix
                print(fig1,'-depsc',[fig_name,'.eps']);
                eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])
                eval(['delete ',fig_name,'.eps '])
            else
                eval(['export_fig ',fig_name,' -png -transparent'])
            end;
    
        end;
    end;
end;

%{
fid = fopen('0_Ascii-files/Anem.csv','wt');
fprintf(fid,'Date(UTC), Anem mixing ratio (ppbv)\n');
for i=1:max(size(time_Anem_avg))
    fprintf(fid,'%s, %2.2f\n',datestr(time_Anem_avg(i)),Anem_avg(i));
end;
fclose(fid);
%}

!rm -f mat-files/Anem.mat
save mat-files/Anem.mat
