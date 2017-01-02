%clear all
%close all

%-------------------------------

if ~exist('CPC','var') | ~exist('CPC_time','var')
  if exist('mat-files/CPC.mat')
    load mat-files/CPC.mat
  else
    disp(['nothing to process...'])
    return
  end
end;

%--------------------------------

if exist('mat-files/Troca_silica.mat','file')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st))
    QC=time_CPC>time_Silica_st(i)&time_CPC<time_Silica_end(i);
    time_CPC(QC)=[];
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
% some quality check
QC=  abs(diff(CPC_Tsat))>0.1 | abs(diff(CPC_Tcon))>0.15 | ...
     abs(diff(CPC_Topt))>0.1 | abs(diff(CPC_Tcab))>0.15 | ...
     abs(diff(CPC_Pamb))>0.3 | abs(diff(CPC_Poro))>2.5 | ...
     abs(diff(CPC_Pnoz))>0.1;
QC(end+1)=0;
QC = QC | CPC_Erro>0;
    
if any(QC)
  disp(['Warn: quality check removes ' num2str(sum(QC))...
        ' out of ' num2str(numel(QC)) ' lines'])
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

%time_CPC(CPC<100)=[];
%CPC(CPC<100)=[];
%
%rem_count=0;
%for i=2:max(size(time_CPC))-1
%  if CPC(i)<CPC(i-1)*0.2 && CPC(i)<CPC(i+1)*0.2 
%    rem_count=rem_count+1;
%    rem_idx(rem_count)=i;
%  end;
%end;
%
%if rem_count>1
%  time_CPC(rem_idx)=[];
%  CPC(rem_idx)=[];
%end;

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
save mat-files/CPC.mat

%--------------------------------
disp('Making figures...')

label_CPC=('Particle concentration (#/cm^3)');
title_CPC=('CPC 3772 particle count');

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_CPC,CPC,'k*')
title([title_CPC,station])
xlabel('Date')
ylabel(label_CPC)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Aerosol_Number_CPC3776_' mydir '_Time_series']
print(fig1,'-dpng',[nome,'.png']);

%-------------------------------- DIURNAL

dtperday=86400/dt;
x=reshape(CPC_avg, dtperday, numel(CPC_avg)/dtperday);
xm=nanmean(x,2);
xs=nanstd(x,0,2);
quicktime=(time_CPC_avg(1:dtperday)-time_CPC_avg(1))*24;
%Calculate sunrise/sunset
rs=suncycle(-3.07,-60,days_CPC(1));

clear fig1
fig1 = figure('visible','off'); clf;
set(fig1,'InvertHardcopy','off');
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
title(['CPC (Thermo)',station])
xlabel('Hour (UTC)')
ylabel(label_CPC)
ylim([0 max(xm+xs)*1.1])
xlim([0 24])
prettify(gca)
box on; grid on;
nome=['fig/Aerosol_Number_CPC3776_' mydir '_diurnal']
print(fig1,'-dpng',[nome,'.png']);

%Plot each day

days_CPC=unique(floor(time_CPC));

for i=1:max(size(days_CPC))
  if rem(i,floor(numel(days_CPC)/20))==0
    disp(['day = ' num2str(i) ' / ' num2str(numel(days_CPC))])
  end

  fig_name=['fig/Aerosol_Number_CPC3776_',mydir,'_',datestr(days_CPC(i),29)];
        
  clear fig1;
    
  quick_time_CPC=(time_CPC-days_CPC(i)).*24;

  [diff,idx_st]=min(abs(quick_time_CPC));
  [diff,idx_end]=min(abs(quick_time_CPC - 24));

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
    rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)- ...
                    rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
    plot(quick_time_CPC(idx_st:idx_end),CPC(idx_st:idx_end),'k*')
    ylim(axes1,[min(CPC(idx_st:idx_end)) max(CPC(idx_st:idx_end))])
    xlim(axes1,[0 24])

    title(['Aerosol number concentration (CPC 3776)',station,' - ',datestr(days_CPC(i),1)])
    xlabel('Time (UTC)')
    ylabel(label_CPC)
    prettify(gca)
    box on; grid on;

    print(fig1,'-dpng',[fig_name,'.png']);
  end;
end;


%