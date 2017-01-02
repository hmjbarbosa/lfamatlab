clear
clc
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
if  strcmp(mydir,'Manacapuru')
    mydir='T3';
elseif strcmp(mydir,'Tiwa')
    mydir='T2';
end;

fl_dir='CPC3772/';

%-------------------------------

count=0;

fl=dir([fl_dir,'*CPC3772*.csv']);

if min(size(fl))>0
    for fl_number=1:max(size(fl))

        fl_dir,fl(fl_number).name
        
        fid = fopen([fl_dir,fl(fl_number).name]);
        total_lines=0;
        TextLine = fgetl(fid);
        while ~feof(fid)
            total_lines=total_lines+1;
            n_delimiters=0;
            size_text=max(size(TextLine));
            i=2;
            while i<size_text
                if strcmp(TextLine(i),',')
                    n_delimiters=n_delimiters+1;
                    idx_delimiter(n_delimiters)=i;
                end;
            i=i+1;
            end
    
            if n_delimiters>12
                if max(size(str2num(TextLine(1:idx_delimiter(1)-1))))==1 

                     dummy_month=str2num((TextLine(idx_delimiter(1)+1:idx_delimiter(1)+2)));
                    dummy_day=str2num((TextLine(idx_delimiter(1)+4:idx_delimiter(1)+5)));
                    dummy_year=str2num((TextLine(idx_delimiter(1)+7:idx_delimiter(1)+8)))+2000;
                    dummy_hour=str2num((TextLine(idx_delimiter(2)+1:idx_delimiter(2)+2)));
                    dummy_minute=str2num((TextLine(idx_delimiter(2)+4:idx_delimiter(2)+5)));
                    dummy_sec=str2num((TextLine(idx_delimiter(2)+7:idx_delimiter(2)+8)));
                    sample_length=str2num((TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1)));
                    avg_time=str2num((TextLine(idx_delimiter(4)+1:idx_delimiter(5)-1)));

                    if max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                       dummy_time_CPC_st=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                        for i=12:n_delimiters
                            if i<n_delimiters
                                dummy_CPC=str2num(TextLine(idx_delimiter(i)+1:idx_delimiter(i+1)-1));
                            else
                                dummy_CPC=str2num(TextLine(idx_delimiter(i)+1:end));
                            end;
                            if max(size(dummy_CPC))==1
                                count=count+1; 
                                CPC(count)=dummy_CPC;
                                time_CPC(count)=30./(24*60*60) + dummy_time_CPC_st+(i-12).*sample_length./(avg_time.*60.*24.*60);
                             %   clc
                              %  CPC(count)
                               % datestr(time_CPC(count))
                            end;
                        end;

                    end;
                end   
            end;
            % get next line of text
            TextLine = fgetl(fid);

        end;
        status=fclose(fid);
    end;
end;
%--------------------------------


[time_CPC,idx]=unique(time_CPC);
CPC=CPC(idx);

time_CPC(CPC<100)=[];
CPC(CPC<100)=[];

if exist('mat-files/Troca_silica.mat','file')
    load mat-files/Troca_silica.mat
    for i=1:max(size(time_Silica_st))
        CPC(time_CPC>time_Silica_st(i)&time_CPC<time_Silica_end(i))=[];
        time_CPC(time_CPC>time_Silica_st(i)&time_CPC<time_Silica_end(i))=[];
    end         
end

rem_count=0;
for i=2:max(size(time_CPC))-1
    if CPC(i)<CPC(i-1)*0.2 && CPC(i)<CPC(i+1)*0.2 
        rem_count=rem_count+1;
        rem_idx(rem_count)=i;
    end;
end;

if rem_count>1
    time_CPC(rem_idx)=[];
    CPC(rem_idx)=[];
end;

label_CPC=('Particle concentration (#/cm^3)');

title_CPC=('CPC 3772 particle count');

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_CPC,CPC,'*')
title([title_CPC,station])
xlabel('Date')
ylabel(label_CPC)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Aerosol_Number_CPC3772_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])


%Plot each day

days_CPC=unique(floor(time_CPC));

for i=1:max(size(days_CPC))

        fig_name=['fig/Aerosol_Number_CPC3772_',mydir,'_',datestr(days_CPC(i),29)];
        
    clear fig1;
    


    quick_time_CPC=(time_CPC-days_CPC(i)).*24;

    [diff,idx_st]=min(abs(quick_time_CPC));
    [diff,idx_end]=min(abs(quick_time_CPC - 24));

    %Calculate sunrise/sunset
    [rs,t,d,z,b,r]=suncycle(-3.07,60,i);

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
%            rectangle('Parent',axes1,'Position',[0,-1000,rs(1),2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
%            rectangle('Parent',axes1,'Position',[rs(2),-1000,24,2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
        rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
        plot(quick_time_CPC(idx_st:idx_end),CPC(idx_st:idx_end),'*')
        ylim(axes1,[min(CPC(idx_st:idx_end)) max(CPC(idx_st:idx_end))])
        xlim(axes1,[0 24])

        title(['Aerosol number concentration (CPC 3772)',station,' - ',datestr(days_CPC(i),1)])
        xlabel('Time (UTC)')
        ylabel(label_CPC)
        box on

        set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
        print(fig1,'-depsc',[fig_name,'.eps']);
        eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])

    
    end;
end;
save mat-files/CPC3772.mat