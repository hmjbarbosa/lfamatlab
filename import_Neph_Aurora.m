%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the Neph Aurora ascii file and plots daily values%
% for a quick look. It saves a .mat with read data.                  %
%                                                                    %
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

fl_dir='Ecotech_Aurora3000/';

%-------------------------------

if exist('mat-files/Neph_Aurora.mat')>0
  load mat-files/Neph_Aurora.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'T1-aurora*.raw']);
  fl=[fl;dir([fl_dir,'T1-nef*.txt'])];
  
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
  fl=dir([fl_dir,'T1-aurora*.raw']);
  fl=[fl;dir([fl_dir,'T1-nef*.txt'])];
  count=0;
  count_old=1;
  time_Neph_avg=[];
  Neph_avg=[];
  fl_old=fl;
end;

%-------------------------------

if size(fl,1)==0 && count==0
    return
elseif size(fl,1)>0
  % data every 5sec or 1min
  % the aurora at Tiwa had only scat at 3 wave-lengths: 635nm, 525nm, 450nm.
  %Neph=NaN(numel(fl)*1440*2,7);
  %NephFlag=cell(numel(fl)*1440*2);
  %time_Neph=NaN(numel(fl)*1440*2,1);
  
  for fl_number=1:numel(fl)
%  for fl_number=65:numel(fl)

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

      % RAW files
      % 27/01/2016,00:00:00,22.476,25.944,30.093,29.743,31.158,23.848,1004.307,00,07
      %                     Scat1  Scat2  Scat3  T1_C   T2_C   RH     P
      if delimiters==10
        dummy_Scatt_1=str2num(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1));
        dummy_Scatt_2=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
        dummy_Scatt_3=str2num(TextLine(idx_delimiter(4)+1:idx_delimiter(5)-1));
        dummy_T1=str2num(TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1));
        dummy_T2=str2num(TextLine(idx_delimiter(6)+1:idx_delimiter(7)-1));
        dummy_RH=str2num(TextLine(idx_delimiter(7)+1:idx_delimiter(8)-1));
        dummy_P=str2num(TextLine(idx_delimiter(8)+1:idx_delimiter(9)-1));

        dummy_Flag=TextLine(idx_delimiter(9)+1:end);
        
        try
          dummy_time=datenum(TextLine(1:idx_delimiter(2)-1),'dd/mm/yyyy,HH:MM:SS');
          time_error=0;
        catch error_message
          time_error=1;
        end
         
        if max(size(dummy_Scatt_1))==1 && time_error==0
          count=count+1;  
          Neph(count,:)=[dummy_Scatt_1;dummy_Scatt_2;dummy_Scatt_3;...
                        dummy_T1;dummy_T2;dummy_RH;dummy_P];
          NephFlag{count}=dummy_Flag;
          time_Neph(count)=dummy_time;
          if time_Neph(count)<datenum(2015,12,1) || time_Neph(count)>datenum(2016,5,1) ...
                || Neph(count,1)<-5 || Neph(count,1)>500
            Neph(count,:)=[];
            NephFlag{count}=[];
            time_Neph(count)=[];
            count=count-1;
          end;
        end;
      end;
        
      % TXT files
      % 27/01/2016 20:46:00,1 min instant,25.73,26.87,31.02,302.85,304.32,22.97,1001.90
      %                                   Scat1 Scat2 Scat3 T1_K   T2_K   RH     P
      if delimiters==8
        dummy_Scatt_1=str2num(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1));
        dummy_Scatt_2=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
        dummy_Scatt_3=str2num(TextLine(idx_delimiter(4)+1:idx_delimiter(5)-1));
        dummy_T1=str2num(TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1))-273.15;
        dummy_T2=str2num(TextLine(idx_delimiter(6)+1:idx_delimiter(7)-1))-273.15;
        dummy_RH=str2num(TextLine(idx_delimiter(7)+1:idx_delimiter(8)-1));
        dummy_P=str2num(TextLine(idx_delimiter(8)+1:end));

        dummy_Flag=TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1);
        
        try
          dummy_time=datenum(TextLine(1:idx_delimiter(1)-1),'dd/mm/yyyy HH:MM:SS');
          time_error=0;
        catch error_message
          time_error=1;
        end

        if max(size(dummy_Scatt_1))==1  && time_error==0
          count=count+1;  
          Neph(count,:)=[dummy_Scatt_1;dummy_Scatt_2;dummy_Scatt_3;...
                        dummy_T1;dummy_T2;dummy_RH;dummy_P];
          NephFlag{count}=dummy_Flag;
          time_Neph(count)=dummy_time;
          if time_Neph(count)<datenum(2015,12,1) || time_Neph(count)>datenum(2016,5,1) ...
                || Neph(count,1)<-5 || Neph(count,1)>500
            Neph(count,:)=[];
            NephFlag{count}=[];
            time_Neph(count)=[];
            count=count-1;
          end;
        end;
      end
      
      % get next line of text
      TextLine = fgetl(fid);
    end;
    status=fclose(fid);
  end;
end;
%--------------------------------

disp('Excluding repeated data lines...')
[time_Neph,idx_sort]=unique(time_Neph);
Neph=Neph(idx_sort,:);
NephFlag=NephFlag(idx_sort);
  

if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    Neph(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
    NephFlag(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
    time_Neph(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i))=[];
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
time_Neph_avg=NaN(ndt,1);
Neph_avg=NaN(ndt,7);

% round our observational times into the time bins
% that means +- 0.5*dt
% the 1sec / dt is to avoid precision problems in matlab
idx=floor((time_Neph-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_Neph_avg(i,1)=tstart + (i-1)*dt/86400;
  Neph_avg(i,:)=nanmean(Neph(idx==i,:),1);
end

days_Neph=unique(floor(time_Neph));
save mat-files/Neph_Aurora.mat

%--------------------------------
disp('Making figures...')

label_Scatt='Aerosol light scattering (Mm^{-1})';
title_Scatt='Ecotech Aurora 3000 - PM2.5';

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gcf,'PaperUnits','points','PaperSize',[775 390],...
        'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Neph,Neph(:,1),'r')
hold on
plot(time_Neph,Neph(:,2),'g')
plot(time_Neph,Neph(:,3),'b')
title([title_Scatt,station])
xlabel('Date')
ylabel(label_Scatt)
ylim([0 200])
box on
dynamicDateTicks([], [], 'dd/mm');
nome=['fig/Neph_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL

clear fig1
dtperday=86400/dt;
whos x
for i=1:3
  x(:,:,i)=reshape(Neph_avg(:,i), dtperday, numel(Neph_avg(:,i))/dtperday);
  xm(:,i)=nanmean(x(:,:,i),2);
  xs(:,i)=nanstd(x(:,:,i),0,2);
end
quicktime=(time_Neph_avg(1:dtperday)-time_Neph_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_Neph(1));

fig1 = figure('visible','on'); clf;
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
plot(quicktime,xm(:,1),'-r*'); plot(quicktime,xm(:,1)+xs(:,1),'r--'); plot(quicktime,xm(:,1)-xs(:,1),'r--')
plot(quicktime,xm(:,2),'-g*'); plot(quicktime,xm(:,2)+xs(:,2),'g--'); plot(quicktime,xm(:,1)-xs(:,2),'g--')
plot(quicktime,xm(:,3),'-b*'); plot(quicktime,xm(:,3)+xs(:,3),'b--'); plot(quicktime,xm(:,1)-xs(:,3),'b--')
title([title_Scatt,station])
xlabel('Hour (UTC)')
ylabel(label_Scatt)
ylim([-0.5 max(max(xm+xs))*1.1])
prettify(gca)
box on; grid on;
nome=['fig/Neph_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png'])

%Plot each day

count_days=0;
clear rem_days
if exist('days_Neph_OK','var')==1
  if min(size(days_Neph_OK))>0
    days_Neph_OK=unique(days_Neph_OK);
    for i=1:max(size(days_Neph))
      if max(days_Neph(i)==days_Neph_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    days_Neph(rem_days)=[];
  end;
else
  days_Neph_OK=[];
end;

for i=1:numel(days_Neph)
  if rem(i,floor(numel(days_Neph)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_Neph))])
  end

  fig_name=['fig/Neph_',mydir,'_',datestr(days_Neph(i),29)];

  clear fig1;

  quick_time_Neph=(time_Neph-days_Neph(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_Neph));
  [diff_end,idx_end]=min(abs(quick_time_Neph - 24));
  
  if diff_st<1/24 && diff_end<1/24
    days_Neph_OK=[days_Neph_OK days_Neph];
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
    axes1 = axes('Parent',fig1,...
                 'XTickLabel',{'0','2','4','6','8','10','12','14','16','18','20','22','24'},...
                 'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);


    hold on
    rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_Neph(idx_st:idx_end),Neph(idx_st:idx_end,1),'r')
    plot(quick_time_Neph(idx_st:idx_end),Neph(idx_st:idx_end,2),'g')
    plot(quick_time_Neph(idx_st:idx_end),Neph(idx_st:idx_end,3),'b')

    ylim(axes1,[0 max(Neph(idx_st:idx_end,3))])
    xlim(axes1,[0 24])

    title(['Aerosol light scattering (Aurora)',station,' - ',datestr(days_Neph(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_Scatt)
    prettify(gca)
    box on; grid on;

    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


%
