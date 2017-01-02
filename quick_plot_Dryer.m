clear
clc
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='Dryer/';

%-------------------------------


fl=dir([fl_dir,'Dryerlog.txt']);

count=0;

if size(fl,1)>0
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
                    TextLine(i)=' ';
                end;
                if strcmp(TextLine(i),' ')
                    if strcmp(TextLine(i-1),' ') 
                        TextLine(i)=[];
                        size_text=size_text-1;
                        i=i-1;
                    else
                        delimiters=delimiters+1;
                        idx_delimiter(delimiters)=i;
                    end;
                end
                i=i+1;
            end

            if delimiters==10
                bar=0;
                dots=0;
                i=1;
                while i<idx_delimiter(2)

                    if strcmp(TextLine(i),'/') && bar==0
                        dummy_month=str2num(TextLine(1:i-1));
                        idx_bar=i;
                        bar=1;
                        i=i+1;
                    end;

                    if strcmp(TextLine(i),'/') && bar==1
                        dummy_day=str2num(TextLine(idx_bar+1:i-1));
                        dummy_year=str2num(TextLine(i+1:idx_delimiter(1)-1));
                        i=i+1;
                    end;

                    if strcmp(TextLine(i),':') && dots==0
                        dummy_hour=str2num(TextLine(idx_delimiter(1)+1:i-1));
                        dots=1;
                        idx_dots=i;
                    end;

                    if strcmp(TextLine(i),':') && dots==1
                        dummy_minute=str2num(TextLine(idx_dots+1:i-1));    
                        dummy_sec=str2num(TextLine(i+1:idx_delimiter(2)-1));    
                    end;     
                    i=i+1;
                end;


                dummy_hour=dummy_hour+strcmp(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1),'PM').*12; %Taking in account hour correction for PM

                dummy_Dryer_1=str2num(TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1));
                dummy_Dryer_2=str2num(TextLine(idx_delimiter(6)+1:idx_delimiter(7)-1));
                dummy_RH=str2num(TextLine(idx_delimiter(7)+1:idx_delimiter(8)-1));

                if max(size(dummy_Dryer_1))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 

                    count=count+1;  
                    Dryer_1(count)=dummy_Dryer_1;
                    Dryer_2(count)=dummy_Dryer_2;
                    RH_Container(count)=dummy_RH;
                    time_Dryer(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);

                end   
            end
            % get next line of text
            TextLine = fgetl(fid);

        end;
        status=fclose(fid);
    end;
end;
%--------------------------------

[time_Dryer,idx_sort]=unique(time_Dryer);

Dryer_1=Dryer_1(idx_sort);
Dryer_2=Dryer_2(idx_sort);
RH_Container=RH_Container(idx_sort);

Dryer_1(time_Dryer<datenum(2014,05,01))=[];
Dryer_2(time_Dryer<datenum(2014,05,01))=[];
RH_Container(time_Dryer<datenum(2014,05,01))=[];
time_Dryer(time_Dryer<datenum(2014,05,01))=[];

label_Dryer='Relative Humidity (%)';

title_Dryer='TT34 dryer';


fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Dryer,Dryer_1)
hold on
plot(time_Dryer,Dryer_2,'r')
legend('Inlet line','Heating line')
title([title_Dryer,station])
xlabel('Date')
ylabel(label_Dryer)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Dryer_RH_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

%eval(['export_fig ',nome,'  -png -transparent'])

%Plot each day

days_Dryer=unique(floor(time_Dryer));

for i=1:max(size(days_Dryer))

        fig_name=['fig/Dryer_RH_',mydir,'_',datestr(days_Dryer(i),29)];
        
    clear fig1;
    
    quick_time_Dryer=(time_Dryer-days_Dryer(i)).*24;

    [a,idx_st]=min(abs(quick_time_Dryer));
    [a,idx_end]=min(abs(quick_time_Dryer - 24));

    %Calculate sunrise/sunset
    [rs,t,d,z,a,r]=suncycle(-3.07,60,i);

    rs=rs+8;

    if idx_end>idx_st+30

        fig1 = figure('visible','off');            
        set(fig1,'InvertHardcopy','on');
        set(gca,'FontSize', 12, 'LineWidth', 2); 

        axis('off');
        axes1 = axes('Parent',fig1,...
        'XTickLabel',{'0','2','4','6','8','10','12','14','16','18','20','22','24'},...
        'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);


        hold on
%       rectangle('Parent',axes1,'Position',[0,-1000,rs(1),2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
%       rectangle('Parent',axes1,'Position',[rs(2),-1000,24,2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
        rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
        plot(quick_time_Dryer(idx_st:idx_end),Dryer_1(idx_st:idx_end),'b')
        plot(quick_time_Dryer(idx_st:idx_end),Dryer_2(idx_st:idx_end),'r')
        ylim(axes1,[min(Dryer_2(idx_st:idx_end)) max(Dryer_1(idx_st:idx_end))])
        xlim(axes1,[0 24])
        legend('Inlet line','Heating line')
        title(['RH Dryer ',station,' - ',datestr(days_Dryer(i),1)])
        xlabel('Time (UTC)')
        ylabel(label_Dryer)
        box on

        set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
       
        %eval(['export_fig ',fig_name,'  -png -transparent'])
        print(fig1,'-depsc',[fig_name,'.eps']);
        eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])


    end;
end;
save mat-files/TT34_Dryer.mat

