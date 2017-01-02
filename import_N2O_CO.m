clear all
close all
[tmp,mydir]=fileparts(pwd);
if strcmp(mydir,'Tiwa')
  station=' - T2';
else
  station=[' - ' mydir];
end;

fl_dir='LosGatos_N2O_CO/';
 
%-------------------------------

fl_dir='LosGatos_N2O_CO/Ascii/';

if exist('mat-files/Los_Gatos_N2O_CO.mat')>0
  load mat-files/Los_Gatos_N2O_CO.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'n2o*.txt']);

  for i=1:numel(fl_old)
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
  time_N2O_avg=[];
  time_CO_avg=[];
  time_H2O_avg=[];
  N2O_avg=[];
  CO_avg=[];
  H2O_avg=[];
  fl_old=fl;
end;

%-------------------------------

if size(fl,1)==0 && count==0
  return
elseif size(fl,1)>0
  % data every 1 sec (about 60 per minute)
  N2O=NaN(numel(fl)*1440*60,1);
  CO=NaN(numel(fl)*1440*60,1);
  H2O=NaN(numel(fl)*1440*60,1);
  time_N2O=NaN(numel(fl)*1440*60,1);

  count=0;
  for fl_number=1:numel(fl)

    fname=[fl_dir,fl(fl_number).name];
    disp([num2str(fl_number) ' / ' num2str(numel(fl)) ' = ' fname]);

    % los gatos data files are too big
    % read all file at once to make it faster
    fdata=read_mixed_csv2(fname,',',2);

    dummy_N2O=real(str2doubleq(fdata(:,4)))*1000;
    dummy_CO=real(str2doubleq(fdata(:,2)))*1000;
    dummy_H2O=real(str2doubleq(fdata(:,6)))*1e-3;

    % some quality check
    QC= dummy_CO>4000 | dummy_CO<-10 | isnan(dummy_N2O) | isnan(dummy_CO) | isnan(dummy_H2O);
    if any(QC)
      dummy_N2O(QC)=[];
      dummy_CO(QC)=[];
      dummy_H2O(QC)=[];
      fdata(QC,:)=[];
    end

    % '02/01/16 16:10:58.984'
    %  MM DD YY hh mm ssss
    dummy_time_N2O=datenum(fdata(:,1),'mm/dd/yy HH:MM:SS.FFF');
        
    dummy_count=numel(dummy_N2O);
    N2O(count+1:count+dummy_count)=dummy_N2O;
    CO(count+1:count+dummy_count)=dummy_CO;
    H2O(count+1:count+dummy_count)=dummy_H2O;
    time_N2O(count+1:count+dummy_count)=dummy_time_N2O;
    count=count+dummy_count;
  end;
end;

if count < size(N2O,1)
  N2O(count+1:end)=[];
  CO(count+1:end)=[];
  H2O(count+1:end)=[];
  time_N2O(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')
[time_N2O,idx]=unique(time_N2O);
N2O=N2O(idx);
CO=CO(idx);
H2O=H2O(idx);

if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    N2O(time_N2O>time_Silica_st(i)&time_N2O<time_Silica_end(i),:)=[];
    CO (time_N2O>time_Silica_st(i)&time_N2O<time_Silica_end(i),:)=[];
    H2O(time_N2O>time_Silica_st(i)&time_N2O<time_Silica_end(i),:)=[];
    time_N2O(time_N2O>time_Silica_st(i)&time_N2O<time_Silica_end(i))=[];
  end;
end;

%--------------------------------
disp('Averaging...')

% only do ave() if we have new data
if size(fl,1)>0
  dt=300; % sec
  % start time-bin
  tstart=datenum(2015,12,1,0,0,0);
  % end time-bin
  tend=datenum(2016,5,1,0,0,0);
  % number of "dt" intervals
  ndt=(tend-tstart)*86400/dt;
  % initialize 
  time_N2O_avg=NaN(ndt,1);
  N2O_avg=NaN(ndt,1);
  CO_avg=NaN(ndt,1);
  H2O_avg=NaN(ndt,1);

  % round our observational times into the time bins
  % that means +- 0.5*dt
  % the 1sec / dt is to avoid precision problems in matlab
  idx=floor((time_N2O-tstart)*86400/dt + 0.5 + 1/dt);

  for i=1:ndt
    if rem(i,floor(ndt/20))==0
      disp([num2str(i) ' / ' num2str(ndt)])
    end
    time_N2O_avg(i,1)=tstart + (i-1)*dt/86400;
    N2O_avg(i,:)=nanmean(N2O(idx==i,:),1);
    CO_avg(i,:)=nanmean(CO(idx==i,:),1);
    H2O_avg(i,:)=nanmean(H2O(idx==i,:),1);
  end

  days_N2O=unique(floor(time_N2O));
  
  % copy times
  time_CO=time_N2O;
  time_H2O=time_N2O;
  
  time_CO_avg=time_N2O_avg;
  time_H2O_avg=time_N2O_avg;
  
  days_CO=days_N2O;
  days_H2O=days_N2O;

  save mat-files/Los_Gatos_N2O_CO.mat
end

%--------------------------------
% CO
%--------------------------------
disp('Making figures... CO')
close all

label_CO=('CO mixing ratio (ppbv)');
title_CO=('CO (Los Gatos)');

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_CO_avg,CO_avg,'k*')
title([title_CO,station])
xlabel('Date')
ylabel(label_CO)
ylim([0 1000])
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/CO_Los_Gatos_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(CO_avg, dtperday, numel(CO_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_CO_avg(1:dtperday)-time_CO_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_CO(1));

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
title([title_CO,station])
xlabel('Hour (UTC)')
ylabel(label_CO)
ylim([-80 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/CO_Los_Gatos_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

count_days=0;
if exist('days_CO_OK','var')==1
  if min(size(days_CO_OK))>0
    days_CO_OK=unique(days_CO_OK);
    for i=1:max(size(days_CO))
      if max(days_CO(i)==days_CO_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    days_CO(rem_days)=[];
  end;
else
  days_CO_OK=[];
end;

for i=1:max(size(days_CO))
  if rem(i,floor(numel(days_CO)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_CO))])
  end
  
  fig_name=['fig/CO_Los_Gatos_',mydir,'_',datestr(days_CO(i),29)];

  clear fig1;

  quick_time_CO=(time_CO-days_CO(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_CO));
  [diff_end,idx_end]=min(abs(quick_time_CO - 24));

  if diff_st<1/24 && diff_end<1/24
    days_CO_OK=[days_CO_OK days_CO];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_CO(i));

  if idx_end>idx_st+30 && max(CO(idx_st:end))>min(CO(idx_st:idx_end))

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
    rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-...
                    rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_CO(idx_st:idx_end),CO(idx_st:idx_end),'k*')
    tmp=[min(CO(idx_st:idx_end)) max(CO(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)
    xlim(axes1,[0 24])

    title([title_CO,station,' - ',datestr(days_CO(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_CO)
    prettify(gca)
    box on; grid on;

    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;

%--------------------------------
% N2O
%--------------------------------
disp('Making figures... N2O')
close all

label_N2O=('N2O mixing ratio (ppbv)');
title_N2O=('N2O (Los Gatos)');

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_N2O_avg,N2O_avg,'k*')
title([title_N2O,station])
xlabel('Date')
ylabel(label_N2O)
ylim([350 410])
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/N2O_Los_Gatos_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
N2O_avg(N2O_avg<350)=nan;
x=reshape(N2O_avg, dtperday, numel(N2O_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_N2O_avg(1:dtperday)-time_N2O_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_N2O(1));

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
title([title_N2O,station])
xlabel('Hour (UTC)')
ylabel(label_N2O)
ylim([370 390])
prettify(gca)
box on; grid on;
nome=['fig/N2O_Los_Gatos_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png'])

%Plot each day

count_days=0;
if exist('days_N2O_OK','var')==1
  if min(size(days_N2O_OK))>0
    days_N2O_OK=unique(days_N2O_OK);
    for i=1:max(size(days_N2O))
      if max(days_N2O(i)==days_N2O_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    days_N2O(rem_days)=[];
  end;
else
  days_N2O_OK=[];
end;

for i=1:max(size(days_N2O))
  if rem(i,floor(numel(days_N2O)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_N2O))])
  end
  
  fig_name=['fig/N2O_Los_Gatos_',mydir,'_',datestr(days_N2O(i),29)];

  clear fig1;

  quick_time_N2O=(time_N2O-days_N2O(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_N2O));
  [diff_end,idx_end]=min(abs(quick_time_N2O - 24));

  if diff_st<1/24 && diff_end<1/24
    days_N2O_OK=[days_N2O_OK days_N2O];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_N2O(i));

  if idx_end>idx_st+30 && max(N2O(idx_st:end))>min(N2O(idx_st:idx_end))

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
    rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-...
                    rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_N2O(idx_st:idx_end),N2O(idx_st:idx_end),'k*')
    tmp=[min(N2O(idx_st:idx_end)) max(N2O(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)
    xlim(axes1,[0 24])

    title([title_N2O,station,' - ',datestr(days_N2O(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_N2O)
    prettify(gca)
    box on; grid on;

    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;



%--------------------------------
% H2O
%--------------------------------
disp('Making figures... H2O')
close all

label_H2O=('H2O mixing ratio (g/kg)');
title_H2O=('H2O (Los Gatos)');

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_H2O_avg,H2O_avg,'k*')
title([title_H2O,station])
xlabel('Date')
ylabel(label_H2O)
ylim([-5 50])
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/H2O_Los_Gatos_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(H2O_avg, dtperday, numel(H2O_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_H2O_avg(1:dtperday)-time_H2O_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_H2O(1));

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
title([title_H2O,station])
xlabel('Hour (UTC)')
ylabel(label_H2O)
ylim([20 40])
prettify(gca)
box on; grid on;
nome=['fig/H2O_Los_Gatos_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png'])

%Plot each day

count_days=0;
if exist('days_H2O_OK','var')==1
  if min(size(days_H2O_OK))>0
    days_H2O_OK=unique(days_H2O_OK);
    for i=1:max(size(days_H2O))
      if max(days_H2O(i)==days_H2O_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    days_H2O(rem_days)=[];
  end;
else
  days_H2O_OK=[];
end;

for i=1:max(size(days_H2O))
  if rem(i,floor(numel(days_H2O)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_H2O))])
  end
  
  fig_name=['fig/H2O_Los_Gatos_',mydir,'_',datestr(days_H2O(i),29)];

  clear fig1;

  quick_time_H2O=(time_H2O-days_H2O(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_H2O));
  [diff_end,idx_end]=min(abs(quick_time_H2O - 24));

  if diff_st<1/24 && diff_end<1/24
    days_H2O_OK=[days_H2O_OK days_H2O];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_H2O(i));

  if idx_end>idx_st+30 && max(H2O(idx_st:end))>min(H2O(idx_st:idx_end))

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
    rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-...
                    rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_H2O(idx_st:idx_end),H2O(idx_st:idx_end),'k*')
    tmp=[min(H2O(idx_st:idx_end)) max(H2O(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)
    xlim(axes1,[0 24])

    title([title_H2O,station,' - ',datestr(days_H2O(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_H2O)
    prettify(gca)
    box on; grid on;

    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


