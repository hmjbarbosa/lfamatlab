%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 17/Aug/2014                                 %
%This routine reads the CPC ascii file and plots daily aerosol conc. %
%values for a quick look. It saves a .mat with read data.            %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
[tmp,mydir]=fileparts(pwd);
if strcmp(mydir,'Tiwa')
    station=' - T2';
else
    station=[' - ' mydir];    
end;

fl_dir='WCPC-UEA-total/';

%-------------------------------

if exist('mat-files/WCPC3787.mat')>0
  load mat-files/WCPC3787.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'*.DAT']);

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
  
  if count_rem>0
    fl(rem_idx)=[];
    fl_old=[fl_old;fl];
  end;

else
  fl=dir([fl_dir,'*.DAT']);
  count=0;
  count_old=1;
  time_CPC_avg=[];
  CPC_avg=[];
  fl_old=fl;
end;

%-------------------------------

if size(fl,1)==0 && count==0
  return
elseif min(size(fl))>0
  % data every 2s
  CPC=NaN(numel(fl)*1440*30,1);
  time_CPC=NaN(numel(fl)*1440*30,1);

  for fl_number=1:numel(fl)

    fname=[fl_dir,fl(fl_number).name];
    disp([num2str(fl_number) ' / ' num2str(numel(fl)) ' = ' fname]);

    % WCPC files are too big
    % read all file at once to make it faster
    fdata=read_mixed_csv2(fname,',',6);
    
    dummy_CPC=real(str2doubleq(fdata(:,3)));
    dummy_Pres=real(str2doubleq(fdata(:,7)));
    dummy_Status=real(str2doubleq(fdata(:,11)));
    dummy_time=strcat(fdata(:,1),{' '},fdata(:,2));
    dummy_length=cellfun('length',dummy_time);

    % some quality check
    QC= dummy_CPC<0 | isnan(dummy_CPC) | isnan(dummy_Pres) | ...
        isnan(dummy_Status) | dummy_Status<0 | dummy_Pres<950 | ...
        dummy_length<17 | dummy_length>19;

    if any(QC)
      disp(['Warn: quality check removes ' num2str(sum(QC))...
            ' out of ' num2str(numel(QC)) ' lines'])
      dummy_CPC(QC)=[];
      dummy_Pres(QC)=[];
      dummy_Status(QC)=[];
      dummy_time(QC)=[];
%      fdata(QC,:)=[];
    end
    % now check time selection interval
    dummy_time=datenum(dummy_time,'YYYY/m/dd HH:MM:SS');
    QC=dummy_time<datenum(2015,12,1) | dummy_time>datenum(2016,5,1);
    if any(QC)
      disp(['Warn: date selection removes ' num2str(sum(QC))...
            ' out of ' num2str(numel(QC)) ' lines'])
      dummy_CPC(QC)=[];
      dummy_Pres(QC)=[];
      dummy_Status(QC)=[];
      dummy_time(QC)=[];
%      fdata(QC,:)=[];
    end

    dummy_count=numel(dummy_CPC);

    CPC(count+1:count+dummy_count)=dummy_CPC;
    time_CPC(count+1:count+dummy_count)=dummy_time;
    count=count+dummy_count;

    figure ; hold on
    plot(dummy_time,dummy_CPC)
    dateaxis('x',2)
    title(fname)

  end;
end;

if count < size(CPC,1)
  CPC(count+1:end)=[];
  time_CPC(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')   
[time_CPC,idx]=unique(time_CPC);
CPC=CPC(idx);

if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    CPC(time_CPC>time_Silica_st(i)&time_CPC<time_Silica_end(i),:)=[];
    time_CPC(time_CPC>time_Silica_st(i)&time_CPC<time_Silica_end(i))=[];
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
time_CPC_avg=NaN(ndt,1);
CPC_avg=NaN(ndt,1);

% round our observational times into the time bins
% that means +- 0.5*dt
% the 1sec / dt is to avoid precision problems in matlab
idx=floor((time_CPC-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_CPC_avg(i,1)=tstart + (i-1)*dt/86400;
  CPC_avg(i,:)=nanmean(CPC(idx==i,:),1);
end

days_CPC=unique(floor(time_CPC));
save mat-files/WCPC3787.mat

%--------------------------------
disp('Making figures...')

label_CPC='Number concentriton (cm-3)';
title_CPC='WCPC 3787';

fig1 = figure('visible','off');
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
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(CPC_avg, dtperday, numel(CPC_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_CPC_avg(1:dtperday)-time_CPC_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_CPC(1));

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
title([title_CPC,station])
xlabel('Hour (UTC)')
ylabel(label_CPC)
ylim([-5 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/WCPC3787_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

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


for i=1:max(size(days_CPC))
  if rem(i,floor(numel(days_CPC)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_CPC))])
  end
  fig_name=['fig/WCPC3787_',mydir,'_',datestr(days_CPC(i),29)];

  clear fig1;

  quick_time_CPC=(time_CPC-days_CPC(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_CPC));
  [diff_end,idx_end]=min(abs(quick_time_CPC - 24));


  if diff_st<1/24 && diff_end<1/24
    days_CPC_OK=[days_CPC_OK days_CPC];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,i);

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
    rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_CPC(idx_st:idx_end),CPC(idx_st:idx_end),'k*')
    ylim(axes1,[min(CPC(idx_st:idx_end)) max(CPC(idx_st:idx_end))])
    xlim(axes1,[0 24])

    title([title_CPC,station,' - ',datestr(days_CPC(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_CPC)
    prettify(gca)
    box on; grid on;
          
    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


%
