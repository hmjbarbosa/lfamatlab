%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014 % %
%This routine reads the CAPS NO2 monitor ascii file and plots daily  %
% NO2 values for a quick look. It saves a .mat with read data.  % %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
[tmp,mydir]=fileparts(pwd);
if strcmp(mydir,'Tiwa')
  station=' - T2';
else
  station=[' - ' mydir]; 
end;

fl_dir='NO2/';

%-------------------------------

if exist('mat-files/NO2.mat')>0
  load mat-files/NO2.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'CAPS*.dat']);
  
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
  fl=dir([fl_dir,'CAPS*.dat']);
  count=0;
  count_old=1;
  time_NO2_avg=[];
  NO2_avg=[];
  fl_old=fl;
end;

%-------------------------------

if size(fl,1)==0 && count==0
  return
elseif size(fl,1)>0
  % data every 2 or 3 sec (about 30 per minute)
  NO2=NaN(numel(fl)*1440*30,1);
  time_NO2=NaN(numel(fl)*1440*30,1);
  
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
        if strcmp(TextLine(i),',')
          delimiters=delimiters+1;
          idx_delimiter(delimiters)=i;  
        end
        i=i+1;
      end
      
      if delimiters==9 && max(size(TextLine(idx_delimiter(9):end)))>10
          
        dummy_NO2=str2num(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1));
        dummy_year=str2num(TextLine(idx_delimiter(9)+1:idx_delimiter(9)+4));
        dummy_month=str2num(TextLine(idx_delimiter(9)+6:idx_delimiter(9)+7));
        dummy_day=str2num(TextLine(idx_delimiter(9)+9:idx_delimiter(9)+10));
        dummy_hour=str2num(TextLine(idx_delimiter(9)+12:idx_delimiter(9)+13));
        dummy_minute=str2num(TextLine(idx_delimiter(9)+15:idx_delimiter(9)+16));
        dummy_sec=str2num(TextLine(idx_delimiter(9)+18:idx_delimiter(9)+19));
        
        if max(size(dummy_NO2))==1 ...
              && max(size(dummy_day))==1 && max(size(dummy_month))==1 ...
              && max(size(dummy_year))==1  && max(size(dummy_hour))==1 ...
              && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
          count=count+1; 
          NO2(count)=dummy_NO2;
          time_NO2(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
        end;
      end   
      % get next line of text
      TextLine = fgetl(fid);
    
    end;
    status=fclose(fid);
  end;
end;

if count < size(NO2,1)
  NO2(count+1:end)=[];
  time_NO2(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')
[time_NO2,idx]=unique(time_NO2);
NO2=NO2(idx);

%NO2(time_NO2==0)=[];
%time_NO2(time_NO2==0)=[];

if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    NO2(time_NO2>time_Silica_st(i)&time_NO2<time_Silica_end(i),:)=[];
    time_NO2(time_NO2>time_Silica_st(i)&time_NO2<time_Silica_end(i))=[];
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
time_NO2_avg=NaN(ndt,1);
NO2_avg=NaN(ndt,1);

% round our observational times into the time bins
% that means +- 0.5*dt
% the 1sec / dt is to avoid precision problems in matlab
idx=floor((time_NO2-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_NO2_avg(i,1)=tstart + (i-1)*dt/86400;
  NO2_avg(i,:)=nanmean(NO2(idx==i,:),1);
end

days_NO2=unique(floor(time_NO2));
save mat-files/NO2.mat
  
%--------------------------------
disp('Making figures...')

label_NO2=['NO2 mixing ratio (ppbv)'];
title_NO2='NO2 (CAPS)';

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on'); 
set(gca, 'FontSize', 12, 'LineWidth', 2);
plot(time_NO2,NO2,'k*') 
title(['NO2 (CAPS)',station]) 
xlabel('Date') 
ylabel(label_NO2)
ylim([0 40]) 
box on 
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/NO2_' mydir '_Time_series']; 
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(NO2_avg, dtperday, numel(NO2_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_NO2_avg(1:dtperday)-time_NO2_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_NO2(1));

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
title(['NO2 (CAPS)',station]) 
xlabel('Hour (UTC)')
ylabel(label_NO2)
ylim([-5 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/NO2_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

count_days=0;
if exist('days_NO2_OK','var')==1
  if min(size(days_NO2_OK))>0
    days_NO2_OK=unique(days_NO2_OK);
    for i=1:max(size(days_NO2))
      if max(days_NO2(i)==days_NO2_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    days_NO2(rem_days)=[];
  end;
else
  days_NO2_OK=[];
end;
    
for i=1:max(size(days_NO2))
  if rem(i,floor(numel(days_NO2)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_NO2))])
  end
    
  fig_name=['fig/NO2_',mydir,'_',datestr(days_NO2(i),29)];
        
  clear fig1;
        
  quick_time_NO2=(time_NO2-days_NO2(i)).*24;
    
  [diff_st,idx_st]=min(abs(quick_time_NO2));
  [diff_end,idx_end]=min(abs(quick_time_NO2 - 24));
                
  if diff_st<1/24 && diff_end<1/24
    days_NO2_OK=[days_NO2_OK days_NO2];
  end;
        
  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_NO2(i));
        
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
    plot(quick_time_NO2(idx_st:idx_end),NO2(idx_st:idx_end),'k*')

    tmp=[min(NO2(idx_st:idx_end)) max(NO2(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)
    xlim(axes1,[0 24])
    
    title(['NO2 (CAPS)',station,' - ',datestr(days_NO2(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_NO2)
    prettify(gca)
    box on; grid on;
          
    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;
    
    
%
