%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%This routine reads the SO2 monitor ascii file and plots daily values %
% for a quick look. It saves a .mat with read data.                  %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];    

fl_dir='Thermo_43i_SO2/';

%-------------------------------

if exist('mat-files/SO2.mat')>0
  load mat-files/SO2.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'43*']);

  for i=1:numel(fl_old)
    for j=1:numel(fl)
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
  fl=dir([fl_dir,'43*']);
  count=0;
  count_old=1;
  time_SO2_avg=[];
  SO2_avg=[];
  fl_old=fl;
end;

%-------------------------------

if size(fl,1)==0 && count==0
  return
elseif size(fl,1)>0
  % data every 1min
  SO2=NaN(numel(fl)*1440,1);
  time_SO2=NaN(numel(fl)*1440,1);

  for fl_number=1:numel(fl)

    fname=[fl_dir,fl(fl_number).name];
    disp([num2str(fl_number) ' / ' num2str(numel(fl)) ' = ' fname]);

    fid = fopen(fname);
    TextLine = fgetl(fid);
    while ~feof(fid)
      delimiters=0;
      size_text=max(size(TextLine));
      i=2;
      while i<size_text
        if strcmp(TextLine(i),' ')
          if strcmp(TextLine(i-1),' ') 
            TextLine(i)=[];
            size_text=size_text-1;
            i=i-1;
          else
            delimiters=delimiters+1;
            idx_delimiter(delimiters)=i;
          end;
        elseif strcmp(TextLine(i),'	')
          delimiters=delimiters+1;
          idx_delimiter(delimiters)=i;  
        end
        i=i+1;
      end

      if delimiters==12   

        dummy_SO2=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
        dummy_year=str2num(TextLine(13:14))+2000;
        dummy_month=str2num(TextLine(7:8));
        dummy_day=str2num(TextLine(10:11));
        dummy_hour=str2num(TextLine(1:2));
        dummy_minute=str2num(TextLine(4:5));
        dummy_sec=0;

        if max(size(dummy_SO2))==1 && dummy_SO2<10 && dummy_SO2>-0.5 ...
              && max(size(dummy_day))==1 && max(size(dummy_month))==1 ...
              && max(size(dummy_year))==1 && max(size(dummy_hour))==1 ...
              && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
          count=count+1; 
          SO2(count)=dummy_SO2;
          time_SO2(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
          if time_SO2(count)>(now+4) || time_SO2(count)< datenum(2015,12,1) 
            SO2(count)=[];
            time_SO2(count)=[];
            count=count-1;
          end;
        end;
      end;
      % get next line of text
      TextLine = fgetl(fid);
    
    end;
    status=fclose(fid);
  end;
end;

if count < size(SO2,1)
  SO2(count+1:end)=[];
  time_SO2(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')    
[time_SO2,idx]=unique(time_SO2);
SO2=SO2(idx);

if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    SO2(time_SO2>time_Silica_st(i)&time_SO2<time_Silica_end(i),:)=[];
    time_SO2(time_SO2>time_Silica_st(i)&time_SO2<time_Silica_end(i))=[];
  end;
end;

%--------------------------------
disp('Averaging...')
dt=300; % sec
% start time-bin
tstart=datenum(2015,12,1,0,0,0);
% end time-bin
tend=datenum(2016,5,1,0,0,0);
% number of "dt" intervals
ndt=(tend-tstart)*86400/dt;
% initialize 
time_SO2_avg=NaN(ndt,1);
SO2_avg=NaN(ndt,1);

% round our observational times into the time bins
% that means +- 0.5*dt
% the 1sec / dt is to avoid precision problems in matlab
idx=floor((time_SO2-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_SO2_avg(i,1)=tstart + (i-1)*dt/86400;
  SO2_avg(i,:)=nanmean(SO2(idx==i,:),1);
end

days_SO2=unique(floor(time_SO2));
save mat-files/SO2.mat

%--------------------------------
disp('Making figures...')

label_SO2='SO2 mixing ratio (ppbv)';
title_SO2='SO2 (Thermo)';

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on'); 
set(gcf,'PaperUnits','points','PaperSize',[775 390],...
        'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
set(gca, 'FontSize', 12, 'LineWidth', 2);
plot(time_SO2,SO2,'k*')
title(['SO2 (Thermo)',station])
xlabel('Date')
ylabel(label_SO2)
ylim([0 15])
box on
dynamicDateTicks([], [], 'dd/mm');
nome=['fig/SO2_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(SO2_avg, dtperday, numel(SO2_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_SO2_avg(1:dtperday)-time_SO2_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_SO2(1));

fig1 = figure('visible','off'); clf;
set(fig1,'InvertHardcopy','on');
% units in pixels!
set(gcf,'PaperUnits','points','PaperSize',[775 390],...
        'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
set(gca,'FontSize', 12, 'LineWidth', 2); 
axis('off');
axes1 = axes('Parent',fig1, 'XTickLabel',{'0','2','4', ...
                    '6','8','10','12','14','16','18','20','22','24'}, ...
             'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);

hold on
rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-...
                    rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
plot(quicktime,xm,'-k*')
plot(quicktime,xm+xs,'k--')
plot(quicktime,xm-xs,'k--')
title(['SO2 (Thermo)',station])
xlabel('Hour (UTC)')
ylabel(label_SO2)
ylim([-0.5 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/SO2_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

days_SO2=unique(floor(time_SO2));

count_days=0;
clear rem_days;
if exist('days_SO2_OK','var')==1
  if min(size(days_SO2_OK))>0
    days_SO2_OK=unique(days_SO2_OK);
    for i=1:max(size(days_SO2))
      if max(days_SO2(i)==days_SO2_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    if count_days>0
      days_SO2(rem_days)=[];
    end
  end;
else
  days_SO2_OK=[];
end;


for i=1:max(size(days_SO2))
  if rem(i,floor(numel(days_SO2)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_SO2))])
  end

  fig_name=['fig/SO2_',mydir,'_',datestr(days_SO2(i),29)];

  clear fig1;

  quick_time_SO2=(time_SO2-days_SO2(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_SO2));
  [diff_end,idx_end]=min(abs(quick_time_SO2 - 24));


  if diff_st<1/24 && diff_end<1/24
    days_SO2_OK=[days_SO2_OK days_SO2];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_SO2(i));

  if idx_end>idx_st+30

    fig1 = figure('visible','off');            
    set(fig1,'InvertHardcopy','on');
    % units in pixels!
    set(gcf,'PaperUnits','points','PaperSize',[775 390],...
            'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
    set(gca,'FontSize', 12, 'LineWidth', 2); 
          
    axis('off');
    axes1 = axes('Parent',fig1, 'XTickLabel',{'0','2','4', ...
                    '6','8','10','12','14','16','18','20','22','24'}, ...
                 'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);

    hold on
    rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)- ...
                    rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_SO2(idx_st:idx_end),SO2(idx_st:idx_end),'k*')
    tmp=[min(SO2(idx_st:idx_end)) max(SO2(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)

    title(['SO2 (Thermo)',station,' - ',datestr(days_SO2(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_SO2)
    prettify(gca)
    box on; grid on;
          
    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


%