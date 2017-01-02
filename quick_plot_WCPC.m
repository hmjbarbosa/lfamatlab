
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 17/Aug/2014                                 %
%                                                                    %
%This routine reads the CPC ascii file and plots daily aerosol conc. %
%values for a quick look. It saves a .mat with read data.            %
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

disp('WCPC')

%-------------------------------

if exist('mat-files/WCPC3787.mat')>0
    load mat-files/WCPC3787.mat
    count_rem=0;
    clear rem_idx
    fl_dir='WCPC3787/raw/';
    fl=dir([fl_dir,'*.dat']);

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

    if count_rem>0
        fl(rem_idx)=[];
        fl_old=[fl_old;fl];
    end;

else
    fl_dir='WCPC3787/raw/';
    fl=dir([fl_dir,'*.dat']);
    count=0;
    count_old=1;
    time_CPC_avg=[];
    CPC_avg=[];
    fl_old=fl;
end;



if size(fl,1)==0 && count==0
    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);
        while ~feof(fid)
            TextLine = fgetl(fid);
            delimiters=0;
            date_delim=0;
            hour_delim=0;
            size_text=max(size(TextLine));
            i=2;
             while i<size_text
                if strcmp(TextLine(i),',')
                    delimiters=delimiters+1;
                    idx_delimiter(delimiters)=i;  
                end
                i=i+1;
            end

            if delimiters==10
                if max(size(TextLine(1:idx_delimiter(1))))>7
    
                    dummy_CPC=str2num(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1));
                    i=1;
                    try
                        dummy_time=datenum([TextLine(1:idx_delimiter(1)-1),' ', TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1)],'YYYY/m/dd HH:MM:SS');
                        time_error=0;
                    catch error_message
                        time_error=1;
                    end
                    %{
                        while i<idx_delimiter(2)
                        if strcmp(TextLine(i),'/')
                            date_delim=date_delim+1;
                            idx_date_delim(date_delim)=i;  
                        end
                        if strcmp(TextLine(i),':')
                            hour_delim=hour_delim+1;
                            idx_hour_delim(hour_delim)=i;  
                        end
                        i=i+1;
                    end;
                    %}

                    if max(size(dummy_CPC))==1 && time_error==0;
                            count=count+1; 
                            CPC(count)=dummy_CPC;
                            time_CPC(count)=dummy_time;
                            if time_CPC(count)>(now+4) || time_CPC(count)< datenum(2014,06,01) 
                                count=count-1;
                                CPC(end)=[];
                                time_CPC(end)=[];
                            end;
                    end;
                end;
            end   

        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------

    
[time_CPC,idx]=unique(time_CPC);
CPC=CPC(idx);

Readme_WCPC='Data from TSI WCPC 3787. Data filtered for reasonable time strings.';

label_CPC='Number concentriton (cm-3)';
title_CPC='WCPC 3787';

while count_old < count
    S=0;
    D=0;
    i=1;
    while S<300 && D<1 && (count_old+i)<max(size(time_CPC))
        [D, S] = DateDiff(time_CPC(count_old),time_CPC(count_old+i));
        i=i+1;
    end; 
    if i>3
        time_CPC_avg=[time_CPC_avg (time_CPC(count_old)+time_CPC(i+count_old))/2];
        CPC_avg=[CPC_avg mean(CPC(count_old:count_old+i))];
    end;
    count_old=count_old+i+1;
end;

if isunix
    fig1 = figure('visible','off');
else
    fig1=figure;
end;

set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 

plot(time_CPC,CPC,'k*')
title([title_CPC,station])
xlabel('Date')
ylabel(label_CPC)
ylim([0 5e4])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/WCPC3787_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;

%Plot each day

days_CPC=unique(floor(time_CPC));

count_days=0;
if exist('days_CPC_OK','var')==1
    if min(size(days_CPC_OK))>0
        days_CPC_OK=unique(days_CPC_OK);
        for i=1:max(size(days_CPC))
            if max(days_CPC(i)==days_CPC_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_CPC(rem_days)=[];
    end;
else
    days_CPC_OK=[];
end;

if min(size(days_CPC))>0
    for i=1:max(size(days_CPC))

         if days_CPC(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/WCPC3787_',mydir,'_',datestr(days_CPC(i),29)];
        elseif days_CPC(i)>datenum(2014,04,01) && days_CPC(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/WCPC3787_',mydir,'_',datestr(days_CPC(i),29)];
        elseif days_CPC(i)>=datenum(2014,08,15) && days_CPC(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/WCPC3787_',mydir,'_',datestr(days_CPC(i),29)];
         end

        clear fig1;

        quick_time_CPC=(time_CPC-days_CPC(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_CPC));
        [diff_end,idx_end]=min(abs(quick_time_CPC - 24));


        if diff_st<1/24 && diff_end<1/24
            days_CPC_OK=[days_CPC_OK days_CPC];
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
            rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
            plot(quick_time_CPC(idx_st:idx_end),CPC(idx_st:idx_end),'k*')
            ylim(axes1,[min(CPC(idx_st:idx_end)) max(CPC(idx_st:idx_end))])
            xlim(axes1,[0 24])

            title([title_CPC,station,' - ',datestr(days_CPC(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_CPC)
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



if isunix

    fid = fopen('0_Ascii-files/WCPC3787.csv','wt');
    fprintf(fid,'Date(UTC), Number concentration (ug m-3)\n');
    for i=1:max(size(time_CPC_avg))
        fprintf(fid,'%s, %2.2f\n',datestr(time_CPC_avg(i)),CPC_avg(i));
    end;
    fclose(fid);

    !chmod 777 0_Ascii-files/WCPC3787.csv
    !rm -f mat-files/WCPC3787.mat
end;



save mat-files/WCPC3787.mat

if isunix
    !chmod 777 mat-files/WCPC3787.mat
end