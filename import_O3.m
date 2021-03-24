%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%This routine reads the O3 monitor ascii file and plots daily values %
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

fl_dir='Thermo_49i_O3/';

%-------------------------------

if exist('mat-files/O3.mat')>0
  load mat-files/O3.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'49*']);

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
  fl=dir([fl_dir,'49*']);
  count=0;
  count_old=1;
  time_O3_avg=[];
  O3_avg=[];
  fl_old=fl;
end;

%-------------------------------

if size(fl,1)==0 && count==0
  return
elseif size(fl,1)>0
  % data every 1min
  O3=NaN(numel(fl)*1440,1);
  time_O3=NaN(numel(fl)*1440,1);

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

        dummy_O3=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
        dummy_year=str2num(TextLine(13:14))+2000;
        dummy_month=str2num(TextLine(7:8));
        dummy_day=str2num(TextLine(10:11));
        dummy_hour=str2num(TextLine(1:2));
        dummy_minute=str2num(TextLine(4:5));
        dummy_sec=0;

        if max(size(dummy_O3))==1 && dummy_O3<150 ...
              && max(size(dummy_day))==1 && max(size(dummy_month))==1 ...
              && max(size(dummy_year))==1 && max(size(dummy_hour))==1 ...
              && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
          count=count+1; 
          O3(count)=dummy_O3;
          time_O3(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
          if time_O3(count)>(now+4) || time_O3(count)< datenum(2015,12,1) 
            O3(count)=[];
            time_O3(count)=[];
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

if count < size(O3,1)
  O3(count+1:end)=[];
  time_O3(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')    
[time_O3,idx]=unique(time_O3);
O3=O3(idx);

if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    O3(time_O3>time_Silica_st(i)&time_O3<time_Silica_end(i),:)=[];
    time_O3(time_O3>time_Silica_st(i)&time_O3<time_Silica_end(i))=[];
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
time_O3_avg=NaN(ndt,1);
O3_avg=NaN(ndt,1);

% round our observational times into the time bins
% that means +- 0.5*dt
% the 1sec / dt is to avoid precision problems in matlab
idx=floor((time_O3-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_O3_avg(i,1)=tstart + (i-1)*dt/86400;
  O3_avg(i,:)=nanmean(O3(idx==i,:),1);
end

days_O3=unique(floor(time_O3));
save mat-files/O3.mat

%--------------------------------
disp('Making figures...')

label_O3='O3 mixing ratio (ppbv)';
title_O3='O3 (Thermo)';

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on'); 
set(gcf,'PaperUnits','points','PaperSize',[775 390],...
        'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
set(gca, 'FontSize', 12, 'LineWidth', 2);
plot(time_O3,O3,'k*')
title([title_O3,station])
xlabel('Date')
ylabel(label_O3)
ylim([0 70])
box on
dynamicDateTicks([], [], 'dd/mm');
nome=['fig/O3_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(O3_avg, dtperday, numel(O3_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_O3_avg(1:dtperday)-time_O3_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_O3(1));

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
title([title_O3,station])
xlabel('Hour (UTC)')
ylabel(label_O3)
ylim([-5 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/O3_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

days_O3=unique(floor(time_O3));

count_days=0;
clear rem_days;
if exist('days_O3_OK','var')==1
  if min(size(days_O3_OK))>0
    days_O3_OK=unique(days_O3_OK);
    for i=1:max(size(days_O3))
      if max(days_O3(i)==days_O3_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    if count_days>0
      days_O3(rem_days)=[];
    end
  end;
else
  days_O3_OK=[];
end;


for i=1:max(size(days_O3))
  if rem(i,floor(numel(days_O3)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_O3))])
  end

  fig_name=['fig/O3_',mydir,'_',datestr(days_O3(i),29)];

  clear fig1;

  quick_time_O3=(time_O3-days_O3(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_O3));
  [diff_end,idx_end]=min(abs(quick_time_O3 - 24));


  if diff_st<1/24 && diff_end<1/24
    days_O3_OK=[days_O3_OK days_O3];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_O3(i));

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
    plot(quick_time_O3(idx_st:idx_end),O3(idx_st:idx_end),'k*')
    tmp=[min(O3(idx_st:idx_end)) max(O3(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)

    title([title_O3,station,' - ',datestr(days_O3(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_O3)
    prettify(gca)
    box on; grid on;
          
    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


%