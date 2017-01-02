%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                  %
%                                                                     %
%This routine reads the TEOM ascii file and plots daily values of fine%
% and coarse particles for a quick look. It saves a .mat data.        %
%                                                                     %
%Latest changes:                                                      %
%To improve processing time now the routine reads the previous mat    %
%file (if existing) and imports only updated ascii files. The same is %
%valid for making new plots                                           %
%                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
[tmp,mydir]=fileparts(pwd);

if strcmp(mydir,'ZF2') || strcmp(mydir,'A_T0_ZF2')
    fl_dir='TEOM/raw/1405A522661205/';
    n_delimiters=19;
    idx_coarse=10;
    station=' - T0 (ZF2)';
elseif strcmp(mydir,'Tiwa') || strcmp(mydir,'A_T2')
    fl_dir='Teom/raw/1405A518591108/';
    n_delimiters=18;
    idx_coarse=11;
    station=' - T2 (Tiwa)';
else
    fl_dir='Teom/raw/1405A518591108/';
    n_delimiters=18;
    idx_coarse=11;
    station=[' - ' mydir];
end;

%-------------------------------

if exist('mat-files/TEOM.mat')>0
    load mat-files/TEOM.mat
    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'*.csv']);

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
    fl=dir([fl_dir,'*.csv']);
    count=0;
    count_old=1;
    time_TEOM_avg=[];
    Fine_avg=[];
    Coarse_avg=[];
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
                if strcmp(TextLine(i),',')
                        delimiters=delimiters+1;
                        idx_delimiter(delimiters)=i;
                end
                i=i+1;
            end

            if delimiters==n_delimiters
                dummy_Fine=str2num(TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1));
                dummy_Coarse=str2num(TextLine(idx_delimiter(idx_coarse)+1:idx_delimiter(idx_coarse+1)-1));

                dummy_day=str2num(TextLine(9:10));
                dummy_month=str2num(TextLine(6:7));
                dummy_year=str2num(TextLine(1:4));
                dummy_hour=str2num(TextLine(idx_delimiter(1)+1:idx_delimiter(1)+2));
                dummy_minute=str2num(TextLine(idx_delimiter(1)+4:idx_delimiter(1)+5));
                dummy_sec=str2num(TextLine(idx_delimiter(1)+7:idx_delimiter(1)+8));


                    if max(size(dummy_Fine))==1 && max(size(dummy_Coarse))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                        count=count+1;  
                        Fine(count)=dummy_Fine;
                        Coarse(count)=dummy_Coarse;
                        time_TEOM(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                        if time_TEOM(count)<datenum(2014,07,28) || Fine(count)<-10 || Fine(count)>250 || Coarse(count)<-10 || Coarse(count)>250
                            count=count-1;
                            Coarse(end)=[];
                            Fine(end)=[];
                            time_TEOM(end)=[];
                        end;
                end;
            end   
        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------
    
[time_TEOM,idx_sort]=unique(time_TEOM);
Fine=Fine(idx_sort);
Coarse=Coarse(idx_sort);

Readme_TEOM='Data from Thermo TEOM. Data filtered for reasonable time strings and limited mass concentration between -10 and 250 ugm-3';

if min(size(Fine(time_TEOM<datenum(2014,02,01))))>0
    count=count-max(size(Fine(time_TEOM<datenum(2014,02,01))));
    Fine(time_TEOM<datenum(2014,02,01))=[];
    Coarse(time_TEOM<datenum(2014,02,01))=[];
    time_TEOM(time_TEOM<datenum(2014,02,01))=[];
end;


label_TEOM='Mass Concentration (ug m-3)';
title_TEOM='Aerosol mass concentration';

while count_old < count
    S=0;
    D=0;
    i=1;
    while S<1700 && D<1 && (count_old+i)<max(size(time_TEOM))
        [D, S] = DateDiff(time_TEOM(count_old),time_TEOM(count_old+i));
        i=i+1;
    end;
    if i>2
        time_TEOM_avg=[time_TEOM_avg (time_TEOM(count_old)+time_TEOM(i+count_old))/2];
        Fine_avg=[Fine_avg mean(Fine(count_old:count_old+i))];
        Coarse_avg=[Coarse_avg mean(Coarse(count_old:count_old+i))];
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
plot(time_TEOM,Fine,'k')
hold on
plot(time_TEOM,Coarse,'r')
title([title_TEOM,station])
xlabel('Date')
ylabel(label_TEOM)
box on
dynamicDateTicks([], [], 'dd/mm');
legend('Fine','Coarse')
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/TEOM_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;

%Plot each day

days_TEOM=unique(floor(time_TEOM));

count_days=0;
if exist('days_TEOM_OK','var')==1
    if min(size(days_TEOM_OK))>0
        days_TEOM_OK=unique(days_TEOM_OK);
        for i=1:max(size(days_TEOM))
            if max(days_TEOM(i)==days_TEOM_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_TEOM(rem_days)=[];
    end;
else
    days_TEOM_OK=[];
end;


if min(size(days_TEOM))>0
    for i=1:max(size(days_TEOM))

         if days_TEOM(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/TEOM_',mydir,'_',datestr(days_TEOM(i),29)];
        elseif days_TEOM(i)>datenum(2014,04,01) && days_TEOM(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/TEOM_',mydir,'_',datestr(days_TEOM(i),29)];
        elseif days_TEOM(i)>=datenum(2014,08,15) && days_TEOM(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/TEOM_',mydir,'_',datestr(days_TEOM(i),29)];
         end

        clear fig1;

        quick_time_TEOM=(time_TEOM-days_TEOM(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_TEOM));
        [diff_end,idx_end]=min(abs(quick_time_TEOM - 24));


        if diff_st<1/24 && diff_end<1/24
            days_TEOM_OK=[days_TEOM_OK days_TEOM(i)];
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
            plot(quick_time_TEOM(idx_st:idx_end),Fine(idx_st:idx_end),'k')
            plot(quick_time_TEOM(idx_st:idx_end),Coarse(idx_st:idx_end),'r')
            ylim(axes1,[0 100])
            xlim(axes1,[0 24])

            title(['TEOM (Thermo)',station,' - ',datestr(days_TEOM(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_TEOM)
            legend('Fine','Coarse')
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

    fid = fopen('0_Ascii-files/TEOM.csv','wt');
    fprintf(fid,'Date(UTC), Fine (ugm-3), Coarse (ugm-3)\n');
    for i=1:max(size(time_TEOM))
        fprintf(fid,'%s, %2.2f, %2.2f\n',datestr(time_TEOM(i)),Fine(i),Coarse(i));
    end;
    fclose(fid);
    
    !chmod 777 0_Ascii-files/TEOM.csv

    !rm -f mat-files/TEOM.mat
end;

save mat-files/TEOM.mat
