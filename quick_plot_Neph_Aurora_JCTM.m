clear
clc
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='Ecotech_Aurora3000/';

%-------------------------------

count=0;

fl=dir([fl_dir,'*NEPH_JCTM*.txt']);

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
                if strcmp(TextLine(i),',')
                        delimiters=delimiters+1;
                        idx_delimiter(delimiters)=i;
                end
                i=i+1;
            end

            if delimiters==8
                dummy_Scatt_1=str2num(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1));
                dummy_Scatt_2=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
                dummy_Scatt_3=str2num(TextLine(idx_delimiter(4)+1:idx_delimiter(5)-1));
                
                dummy_day=str2num(TextLine(1:2));
                dummy_month=str2num(TextLine(4:5));
                dummy_year=str2num(TextLine(7:10));
                dummy_hour=str2num(TextLine(12:13));
                dummy_minute=str2num(TextLine(15:16));
                dummy_sec=str2num(TextLine(18:19));

                if dummy_year==2015
                    test=1
                end;

                    if max(size(dummy_Scatt_1))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                        count=count+1;  
                        Scatt(count,:)=[dummy_Scatt_1;dummy_Scatt_2;dummy_Scatt_3];
                        time_Neph(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                end;
            end   
            % get next line of text
            TextLine = fgetl(fid);

        end;
        status=fclose(fid);
    end;
end;
%--------------------------------


[time_Neph,idx_sort]=unique(time_Neph);
Scatt=Scatt(idx_sort,:);

Scatt(time_Neph<datenum(2014,03,01),:)=[];
time_Neph(time_Neph<datenum(2014,03,01))=[];



if exist('mat-files/Troca_silica.mat')
    load mat-files/Troca_silica.mat
    for i=1:max(size(time_Silica_st));
        Scatt(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
        time_Neph(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i))=[];
    end;
end;


%{
k=1;
j=1;
i=1;
while j < max(size(BC))
    S=0;
    D=0;
    i=1;
    while S<1800 && D<1 && (j+i)<max(size(BC))
        [D, S] = DateDiff(time_Neph(j),time_Neph(j+i));
        i=i+1;
    end;
    if i>3
        time_Neph_avg(k)=(time_Neph(j)+time_Neph(i+j))/2;
        BC_avg(k)=mean(BC(j:j+i));
        k=k+1;
    end;
    j=j+i+1;
end;

BC_avg=BC_avg';
%}

label_Scatt='Aerosol light scattering (Mm^{-1})';
title_Scatt='Aerosol light scattering (Ecotech Aurora 3000) - PM10';


fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Neph,Scatt(:,1))
hold on
plot(time_Neph,Scatt(:,2),'g')
plot(time_Neph,Scatt(:,3),'r')
title([title_Scatt,station])
xlabel('Date')
ylabel(label_Scatt)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Scattering_Ecotech_Aurora_' mydir '_Time_series']
%print(fig1,'-depsc',[nome,'.eps']);
%eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

eval(['export_fig ',nome,'  -png -transparent'])

%Plot each day

days_Neph=unique(floor(time_Neph));

for i=1:max(size(days_Neph))

        fig_name=['fig/Scattering_Ecotech_Aurora_',mydir,'_',datestr(days_Neph(i),29)];
        
    clear fig1;
    
    quick_time_Neph=(time_Neph-days_Neph(i)).*24;

    [a,idx_st]=min(abs(quick_time_Neph));
    [a,idx_end]=min(abs(quick_time_Neph - 24));

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
        plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,1),'b')
        plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,2),'g')
        plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,3),'r')
        ylim(axes1,[min(Scatt(idx_st:idx_end,3)) max(Scatt(idx_st:idx_end,1))])
        xlim(axes1,[0 24])

        title(['Aerosol light scattering (Ecotech Aurora) - PM10',station,' - ',datestr(days_Neph(i),1)])
        xlabel('Time (UTC)')
        ylabel(label_Scatt)
        box on

        set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
       
        eval(['export_fig ',fig_name,'  -png -transparent'])
        %print(fig1,'-depsc',[fig_name,'.eps']);
        %eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])


    end;
end;
save mat-files/Neph_Aurora_JCTM.mat
