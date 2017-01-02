clear all    
close all

AE33_name='193';

[tmp,mydir]=fileparts(pwd);
if strcmp(mydir,'Tiwa')
  station=' -  T2';
else
  station=[' - ' mydir];
end

fl_dir=['AE33_',AE33_name,'/'];

%-------------------------------

fl=dir([fl_dir,'AE33_A*.dat']);
count=0;

%-------------------------------

if size(fl,1)>0
  Aeth=NaN(numel(fl)*1440, 7);
  time_Aeth=NaN(numel(fl)*1440, 1);
  
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
          delimiters=delimiters+1;
          idx_delimiter(delimiters)=i;
        end
        i=i+1;
      end
      
%      if delimiters==70
      if delimiters==79
        dummy_BC_1=str2num(TextLine(idx_delimiter(40)+1:idx_delimiter(41)-1));
        dummy_BC_2=str2num(TextLine(idx_delimiter(43)+1:idx_delimiter(44)-1));
        dummy_BC_3=str2num(TextLine(idx_delimiter(46)+1:idx_delimiter(47)-1));
        dummy_BC_4=str2num(TextLine(idx_delimiter(49)+1:idx_delimiter(50)-1));
        dummy_BC_5=str2num(TextLine(idx_delimiter(52)+1:idx_delimiter(53)-1));
        dummy_BC_6=str2num(TextLine(idx_delimiter(55)+1:idx_delimiter(56)-1));
        dummy_BC_7=str2num(TextLine(idx_delimiter(58)+1:idx_delimiter(59)-1));
        
        dummy_day=str2num(TextLine(9:10));
        dummy_month=str2num(TextLine(6:7));
        dummy_year=str2num(TextLine(1:4));
        dummy_hour=str2num(TextLine(12:13));
        dummy_minute=str2num(TextLine(15:16));
        dummy_sec=str2num(TextLine(18:19));
        
        dummy_status=TextLine(idx_delimiter(36)+1:idx_delimiter(37)-1);
        
        if strcmp(dummy_status,'00000') && max(size(dummy_BC_1))==1 ...
              && max(size(dummy_day))==1 && max(size(dummy_month))==1 ...
              && max(size(dummy_year))==1 && max(size(dummy_hour))==1 ...
              && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
          count=count+1;  
          Aeth(count,:)=[dummy_BC_1;dummy_BC_2;dummy_BC_3;dummy_BC_4;dummy_BC_5;dummy_BC_6;dummy_BC_7];
          time_Aeth(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
        end;
      end   
      % get next line of text
      TextLine = fgetl(fid);
      
    end;
    status=fclose(fid);
  end;
end;

if count < size(Aeth,1)
  Aeth(count+1:end,:)=[];
  time_Aeth(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')
[time_Aeth,idx_sort]=unique(time_Aeth);
Aeth=Aeth(idx_sort,:)./1000;


if exist('mat-files/Troca_silica.mat')
  disp('Excluding silica change times...')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st));
    Aeth(time_Aeth>time_Silica_st(i)&time_Aeth<time_Silica_end(i),:)=[];
    time_Aeth(time_Aeth>time_Silica_st(i)&time_Aeth<time_Silica_end(i))=[];
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
time_Aeth_avg=NaN(ndt,1);
Aeth_avg=NaN(ndt,7);

% round our observational times into the time bins
% that means +- 0.5*dt
% the 1sec / dt is to avoid precision problems in matlab
idx=floor((time_Aeth-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_Aeth_avg(i,1)=tstart + (i-1)*dt/86400;
  Aeth_avg(i,:)=nanmean(Aeth(idx==i,:),1);
end

days_Aeth=unique(floor(time_Aeth));
save(['mat-files/AE33_',AE33_name,'.mat']);

fid = fopen('0_Ascii-files/Aeth_Aurora.csv','wt');

fprintf(fid,'Date(UTC),Aethering Blue (Mm-1), Aethering Green (Mm-1), Aethering Red, Back Aethering Blue (Mm-1), Back Aethering Green (Mm-1), Back Aethering Red (Mm-1)\n');

for i=1:max(size(time_Aeth))
    fprintf(fid,'%s, %2.1f\n',time_Aeth,Aeth(:,1),Aeth(:,2),Aeth(:,3),BAeth(:,1),BAeth(:,2),BAeth(:,3));
end;
fclose(fid);

%--------------------------------
disp('Making figures...')

label_Aeth='BC concentration (\mug m^{-3})';
title_Aeth=['BC concentration (Aethalometer AE33 ',AE33_name,' - 880nm)'];

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Aeth_avg,Aeth_avg(:,6))
title([title_Aeth,station])
xlabel('Date')
ylabel(label_Aeth)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Aethalometer_AE33_' mydir '_' AE33_name '_Time_series']
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL
clear fig1
dtperday=86400/dt;
x=reshape(Aeth_avg(:,6), dtperday, numel(Aeth_avg(:,6))/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_Aeth_avg(1:dtperday)-time_Aeth_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_Aeth(1));

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
title([title_Aeth,station])
xlabel('Hour (UTC)')
ylabel(label_Aeth)
ylim([-0.5 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/Aethalometer_AE33_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

for i=1:numel(days_Aeth)
  if rem(i,floor(numel(days_Aeth)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_Aeth))])
  end
  
  fig_name=['fig/Aethalometer_AE33_',mydir,'_',AE33_name,'_',datestr(days_Aeth(i),29)];
  
  clear fig1;

  quick_time_Aeth=(time_Aeth-days_Aeth(i)).*24;
  
  [a,idx_st]=min(abs(quick_time_Aeth));
  [a,idx_end]=min(abs(quick_time_Aeth - 24));

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_Aeth(i));

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
    plot(quick_time_Aeth(idx_st:idx_end),Aeth(idx_st:idx_end,6),'b')
    
    tmp=[min(Aeth(idx_st:idx_end,6)) max(Aeth(idx_st:idx_end,6))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)
    xlim(axes1,[0 24])
    
    title(['BC concentration (Aethalometer AE33 - 880nm) ',AE33_name,station,' - ',datestr(days_Aeth(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_Aeth)
    prettify(gca)
    box on; grid on;
        
    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


%
