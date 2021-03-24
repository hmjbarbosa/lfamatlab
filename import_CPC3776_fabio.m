clear all
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];    

fl_dir='CPC_3776151301sn/';
fl=dir([fl_dir,'T1*csv']);
  
%-------------------------------

count=0;
if size(fl,1)==0
  return
elseif size(fl,1)>0
  % data every 1 sec
  CPC_time=NaN(numel(fl)*1440*60,1);
  CPC=CPC_time;
  CPC_Erro=CPC_time;
  CPC_Tsat=CPC_time;
  CPC_Tcon=CPC_time;
  CPC_Topt=CPC_time;
  CPC_Tcab=CPC_time;
  CPC_Pamb=CPC_time;
  CPC_Poro=CPC_time;
  CPC_Pnoz=CPC_time;
  CPC_Ilas=CPC_time;
  
  for fl_number=1:max(size(fl))

    fname=[fl_dir,fl(fl_number).name];
    disp([num2str(fl_number) ' / ' num2str(numel(fl)) ' = ' fname]);

    % faster reading
    % data format saved from the RS232
    %  2    3    4          5      6        7         8           9
    % ,Date,Time,Conc(#cm3),errors,T_sat(C),T_cond(C),T_optics(C),T_cab(C)
    %  10          11              12             13          14
    %  P_amb(mbar),P_orifice(mbar),P_nozzle(mbar),I_laser(mA),liq_level
    fdata=read_mixed_csv2(fname,',',0);

    dummy_time=strcat(fdata(:,2),{' '},fdata(:,3));
    dummy_CPC =real(str2doubleq(fdata(:, 4)));
    dummy_Erro=real(str2doubleq(fdata(:, 5)));
    dummy_Tsat=real(str2doubleq(fdata(:, 6)));
    dummy_Tcon=real(str2doubleq(fdata(:, 7)));
    dummy_Topt=real(str2doubleq(fdata(:, 8)));
    dummy_Tcab=real(str2doubleq(fdata(:, 9)));
    dummy_Pamb=real(str2doubleq(fdata(:,10)));
    dummy_Poro=real(str2doubleq(fdata(:,11)));
    dummy_Pnoz=real(str2doubleq(fdata(:,12)));
    dummy_Ilas=real(str2doubleq(fdata(:,13)));
    dummy_length=cellfun('length',dummy_time);

    % some quality check
    QC= isnan(dummy_CPC) | isnan(dummy_Erro) | dummy_length~=19;
    if any(QC)
      disp(['Warn: quality check removes ' num2str(sum(QC))...
            ' out of ' num2str(numel(QC)) ' lines'])
      dummy_time(QC)=[];
      dummy_CPC (QC)=[];
      dummy_Erro(QC)=[];
      dummy_Tsat(QC)=[];
      dummy_Tcon(QC)=[];
      dummy_Topt(QC)=[];
      dummy_Tcab(QC)=[];
      dummy_Pamb(QC)=[];
      dummy_Poro(QC)=[];
      dummy_Pnoz(QC)=[];
      dummy_Ilas(QC)=[];
    end
    dummy_count=numel(dummy_CPC);
    if dummy_count==0
      continue
    end

    % now check time selection interval
    dummy_time=datenum(dummy_time,'YYYY-mm-dd HH:MM:SS');
    QC=dummy_time<datenum(2015,12,1) | dummy_time>datenum(2016,5,1);
    if any(QC)
      disp(['Warn: date selection removes ' num2str(sum(QC)) ...
            ' out of ' num2str(numel(QC)) ' lines'])
      dummy_time(QC)=[];
      dummy_CPC (QC)=[];
      dummy_Erro(QC)=[];
      dummy_Tsat(QC)=[];
      dummy_Tcon(QC)=[];
      dummy_Topt(QC)=[];
      dummy_Tcab(QC)=[];
      dummy_Pamb(QC)=[];
      dummy_Poro(QC)=[];
      dummy_Pnoz(QC)=[];
      dummy_Ilas(QC)=[];
    end
    dummy_count=numel(dummy_CPC);
    if dummy_count==0
      continue
    end

    CPC_time(count+1:count+dummy_count)=dummy_time;
    CPC     (count+1:count+dummy_count)=dummy_CPC;
    CPC_Erro(count+1:count+dummy_count)=dummy_Erro;
    CPC_Tsat(count+1:count+dummy_count)=dummy_Tsat;
    CPC_Tcon(count+1:count+dummy_count)=dummy_Tcon;
    CPC_Topt(count+1:count+dummy_count)=dummy_Topt;
    CPC_Tcab(count+1:count+dummy_count)=dummy_Tcab;
    CPC_Pamb(count+1:count+dummy_count)=dummy_Pamb;
    CPC_Poro(count+1:count+dummy_count)=dummy_Poro;
    CPC_Pnoz(count+1:count+dummy_count)=dummy_Pnoz;
    CPC_Ilas(count+1:count+dummy_count)=dummy_Ilas;

    count=count+dummy_count;

  end;
end;

% Eliminate extra space in the end
if count < size(CPC,1)
  CPC_time(count+1:end)=[];
  CPC     (count+1:end)=[];
  CPC_Tsat(count+1:end)=[];
  CPC_Tcon(count+1:end)=[];
  CPC_Topt(count+1:end)=[];
  CPC_Tcab(count+1:end)=[];
  CPC_Pamb(count+1:end)=[];
  CPC_Poro(count+1:end)=[];
  CPC_Pnoz(count+1:end)=[];
  CPC_Ilas(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')    
[CPC_time,idx]=unique(CPC_time);
CPC=CPC(idx);
CPC_Erro=CPC_Erro(idx);
CPC_Tsat=CPC_Tsat(idx);
CPC_Tcon=CPC_Tcon(idx);
CPC_Topt=CPC_Topt(idx);
CPC_Tcab=CPC_Tcab(idx);
CPC_Pamb=CPC_Pamb(idx);
CPC_Poro=CPC_Poro(idx);
CPC_Pnoz=CPC_Pnoz(idx);
CPC_Ilas=CPC_Ilas(idx);

if exist('mat-files/Troca_silica.mat','file')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st))
    QC=CPC_time>time_Silica_st(i)&CPC_time<time_Silica_end(i);
    CPC_time(QC)=[];
    CPC     (QC)=[];
    CPC_Erro(QC)=[];
    CPC_Tsat(QC)=[];
    CPC_Tcon(QC)=[];
    CPC_Topt(QC)=[];
    CPC_Tcab(QC)=[];
    CPC_Pamb(QC)=[];
    CPC_Poro(QC)=[];
    CPC_Pnoz(QC)=[];
    CPC_Ilas(QC)=[];
  end         
end

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
idx=floor((CPC_time-tstart)*86400/dt + 0.5 + 1/dt);

for i=1:ndt
  if rem(i,floor(ndt/20))==0
    disp([num2str(i) ' / ' num2str(ndt)])
  end
  time_CPC_avg(i,1)=tstart + (i-1)*dt/86400;
  CPC_avg(i,:)=nanmean(CPC(idx==i,:),1);
end

%clear dummy* fl* count* fdata fname idx mydir tmp QC
days_CPC=unique(floor(CPC_time));
save mat-files/CPC.mat
%
%
%--------------------------------
disp('Making figures...')

label_CPC='Particles (#/cm3)';
title_CPC='CPC 3776 (TSI)';

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on'); 
set(gcf,'PaperUnits','points','PaperSize',[775 390],...
        'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
set(gca, 'FontSize', 12, 'LineWidth', 2);
plot(CPC_time,CPC,'k*')
title([title_CPC,station])
xlabel('Date')
ylabel(label_CPC)
%ylim([0 15])
box on
dynamicDateTicks([], [], 'dd/mm');
nome=['fig/CPC_' mydir '_Time_series'];
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
ylim([-0.5 max(xm+xs)*1.1])
prettify(gca)
box on; grid on;
nome=['fig/CPC_' mydir '_diurnal'];
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

days_CPC=unique(floor(CPC_time));

count_days=0;
clear rem_days;
if exist('days_CPC_OK','var')==1
  if min(size(days_CPC_OK))>0
    days_CPC_OK=unique(days_CPC_OK);
    for i=1:max(size(days_CPC))
      if max(days_CPC(i)==days_CPC_OK)>0
        count_days=count_days+1;
        rem_days(count_days)=i;
      end;
    end;
    if count_days>0
      days_CPC(rem_days)=[];
    end
  end;
else
  days_CPC_OK=[];
end;


for i=1:max(size(days_CPC))
  if rem(i,floor(numel(days_CPC)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_CPC))])
  end

  fig_name=['fig/CPC_',mydir,'_',datestr(days_CPC(i),29)];

  clear fig1;

  quick_time_CPC=(CPC_time-days_CPC(i)).*24;

  [diff_st,idx_st]=min(abs(quick_time_CPC));
  [diff_end,idx_end]=min(abs(quick_time_CPC - 24));


  if diff_st<1/24 && diff_end<1/24
    days_CPC_OK=[days_CPC_OK days_CPC];
  end;

  %Calculate sunrise/sunset
  rs=suncycle(-3.07,-60,days_CPC(i));

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
    plot(quick_time_CPC(idx_st:idx_end),CPC(idx_st:idx_end),'k*')
    tmp=[min(CPC(idx_st:idx_end)) max(CPC(idx_st:idx_end))];
    if (tmp(1)==0 & tmp(2)==0)
      tmp=[-0.5 0.5];
    end
    if (tmp(1)==tmp(2))
      tmp=[0.95 1.05]*tmp(1);
    end
    ylim(axes1,tmp)

    title([title_CPC,station,' - ',datestr(days_CPC(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_CPC)
    prettify(gca)
    box on; grid on;
          
    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;
%