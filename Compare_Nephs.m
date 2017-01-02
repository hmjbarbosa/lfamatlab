clear
close all
clc

load mat-files/Neph_Aurora_JCTM.mat

Scatt_JCTM=Scatt;
time_Neph_JCTM=time_Neph;

load mat-files/Neph_Aurora.mat

bin_tick=round((time_Neph_JCTM(end)-time_Neph_JCTM(1))./4);
    
custom_x_ticks = floor(time_Neph_JCTM(1)):bin_tick:ceil(time_Neph_JCTM(end));
    
fig1 = figure('visible','off');
%fig1 = figure;
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Neph,Scatt(:,2),'k')
hold on
plot(time_Neph_JCTM,Scatt_JCTM(:,2),'r')
title(['Aerosol light scattering (Ecotech Aurora 3000) - 550nm',station])
xlabel('Date')
ylabel(label_Scatt)
box on
legend('PM2.5','PM10')
%axis([time_Neph_JCTM(1) time_Neph_JCTM(end) 0 100])
axis([custom_x_ticks(1) custom_x_ticks(end) 0 100])
set(gca, 'XTick', custom_x_ticks);
datetick('x', 'dd-mmm-yyyy', 'keepticks')
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Scattering_Ecotech_Aurora_',mydir,'_PM2_5_PM10_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

%eval(['export_fig ',nome,'  -png -transparent'])
