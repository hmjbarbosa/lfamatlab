clear
close all
[tmp,mydir]=fileparts(pwd);
if strcmp(mydir,'A_T2')
    station=' - T2';
else
    station=[' - ' mydir];
end;
fl_dir='LosGatos_N2O_CO/';
 
disp('N2O_CO')

Unzip_Los_Gatos(fl_dir)

fl_dir='LosGatos_N2O_CO/Ascii/';

if exist('mat-files/Los_Gatos_N2O_CO.mat')>0
    load mat-files/Los_Gatos_N2O_CO.mat
    fl_dir='LosGatos_N2O_CO/';
    
    fl_dir=[fl_dir,'Ascii/'];

    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'n2o*.txt']);

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
    fl=dir([fl_dir,'n2o*.txt']);
    count=0;
    count_old=1;
    time_N2O_CO_avg=[];
    N2O_avg=[];
    CO_avg=[];
    fl_old=fl;
end;


if size(fl,1)==0 && count==0
    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);

        while ~feof(fid)
            TextLine = fgetl(fid);
            n_delimiters=0;
            size_text=max(size(TextLine));
            i=2;
            while i<size_text
                if strcmp(TextLine(i),' ')
                   if strcmp(TextLine(i-1),' ') 
                        TextLine(i)=[];
                        size_text=size_text-1;
                        i=i-1;
                   end;
                end;
                i=i+1;
            end

            i=1;
            while i<size_text
                if strcmp(TextLine(i),',')
                    n_delimiters=n_delimiters+1;
                    idx_delimiter(n_delimiters)=i;
                end;
                i=i+1;
            end

            if n_delimiters>15

                dummy_N2O=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
                dummy_CO=str2num(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1));
                dummy_day=str2num(TextLine(5:6));
                dummy_month=str2num(TextLine(2:3));
                dummy_year=str2num(TextLine(8:9))+2000;
                dummy_hour=str2num(TextLine(11:12));
                dummy_minute=str2num(TextLine(14:15));
                dummy_sec=str2num(TextLine(17:18));


                if max(size(dummy_N2O))==1 && max(size(dummy_CO))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                    count=count+1; 
                    N2O(count)=dummy_N2O.*1000;
                    CO(count)=dummy_CO.*1000;
                    time_N2O_CO(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                    if time_N2O_CO(count)>(now+4) || time_N2O_CO(count)<datenum(2014,01,01) || CO(count)>4000 || CO(count)<-10
                        count=count-1;
                        N2O(end)=[];
                        CO(end)=[];
                        time_N2O_CO(end)=[];
                    end;
                end;
            end;
        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------

[time_N2O_CO,idx]=unique(time_N2O_CO);
N2O=N2O(idx);
CO=CO(idx);

CO(time_N2O_CO==0)=[];
N2O(time_N2O_CO==0)=[];
time_N2O_CO(time_N2O_CO==0)=[];

Readme_CO='Data from Los Gatos N2O CO monitor. Data filtered for reasonable time strings and limited to maximum of 4000ppb and minimum of -10ppb of CO.';

label_CO=('CO mixing ratio (ppbv)');
title_CO=('CO (Los Gatos)');

label_N2O=('N2O mixing ratio (ppbv)');
title_N2O=('N2O (Los Gatos)');


k=1;
j=1;
i=1;
while j < max(size(time_N2O_CO))
    S=0;
    D=0;
    i=1;
    while S<600 && D<1 && (j+i)<max(size(time_N2O_CO))
        [D, S] = DateDiff(time_N2O_CO(j),time_N2O_CO(j+i));
        i=i+1;
    end;
    if i>3
        time_N2O_CO_avg(k)=(time_N2O_CO(j)+time_N2O_CO(i+j))/2;
        CO_avg(k)=mean(CO(j:j+i));
        k=k+1;
    end;
    j=j+i+1;
end;

CO_avg=CO_avg';

if isunix
    fig1 = figure('visible','off');
else
    fig1=figure;
end;

set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_N2O_CO_avg,CO_avg,'k*')
title(['CO',station])
xlabel('Date')
ylim([0 1000])
ylabel(label_CO)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/CO_Los_Gatos_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;

    
fid = fopen('0_Ascii-files/LosGatos_N2O_CO.csv','wt');

fprintf(fid,'Date(UTC), CO mixing ratio (ppbv)\n');
for i=1:max(size(time_N2O_CO_avg))
    fprintf(fid,'%s, %2.2f\n',datestr(time_N2O_CO_avg(i)),CO_avg(i));
end;
fclose(fid);

%Plot each day

days_N2O_CO=unique(floor(time_N2O_CO));

count_days=0;
if exist('days_N2O_CO_OK','var')==1
    if min(size(days_N2O_CO_OK))>0
        days_N2O_CO_OK=unique(days_N2O_CO_OK);
        for i=1:max(size(days_N2O_CO))
            if max(days_N2O_CO(i)==days_N2O_CO_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_N2O_CO(rem_days)=[];
    end;
else
    days_N2O_CO_OK=[];
end;

if min(size(days_N2O_CO))>0
    for i=1:max(size(days_N2O_CO))


         if days_N2O_CO(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/CO_Los_Gatos_',mydir,'_',datestr(days_N2O_CO(i),29)];
        elseif days_N2O_CO(i)>datenum(2014,04,01) && days_N2O_CO(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/CO_Los_Gatos_',mydir,'_',datestr(days_N2O_CO(i),29)];
        elseif days_N2O_CO(i)>=datenum(2014,08,15) && days_N2O_CO(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/CO_Los_Gatos_',mydir,'_',datestr(days_N2O_CO(i),29)];
         end

        clear fig1;

        quick_time_N2O_CO=(time_N2O_CO-days_N2O_CO(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_N2O_CO));
        [diff_end,idx_end]=min(abs(quick_time_N2O_CO - 24));

        if diff_st<1/24 && diff_end<1/24
            days_N2O_CO_OK=[days_N2O_CO_OK days_N2O_CO];
        end;

        %Calculate sunrise/sunset
        [rs,t,d,z,a,r]=suncycle(-3.07,60,i);

        rs=rs+8;

        if idx_end>idx_st+30 && max(CO(idx_st:end))>min(CO(idx_st:idx_end))

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
            rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
            plot(quick_time_N2O_CO(idx_st:idx_end),CO(idx_st:idx_end),'k*')
            ylim(axes1,[min(CO(idx_st:idx_end)) max(CO(idx_st:idx_end))])
            xlim(axes1,[0 24])

            title(['CO (Los Gatos)',station,' - ',datestr(days_N2O_CO(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_CO)
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
    !rm -f mat-files/Los_Gatos_N2O_CO.mat
end;

save mat-files/Los_Gatos_N2O_CO.mat


if isunix
    !chmod 777 0_Ascii-files/Los_Gatos_N2O_CO.csv
    !chmod 777 mat-files/Los_Gatos_N2O_CO.mat
end;


save mat-files/Los_Gatos_N2O_CO.mat
