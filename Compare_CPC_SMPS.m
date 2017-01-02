clear
close all
clc

load mat-files/SMPS_TSI.mat

load mat-files/CPC3772.mat

bin_tick=round((time_CPC(end)-time_CPC(1))./4);
    
custom_x_ticks = floor(time_CPC(1)):bin_tick:ceil(time_CPC(end));
    
fig1 = figure('visible','off');
%fig1 = figure;
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_SMPS_TSI,SMPS_TSI_CPC,'k')
hold on
plot(time_CPC,CPC,'r')
title(['Aerosol number concentration',station])
xlabel('Date')
ylabel(label_CPC)
box on
legend('SMPS','CPC 3772')
axis([custom_x_ticks(1) custom_x_ticks(end) 0 25000])
set(gca, 'XTick', custom_x_ticks);
datetick('x', 'dd-mmm-yyyy', 'keepticks')
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Aerosol_Number_SMPS_TSI_CPC3772_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

%eval(['export_fig ',nome,'  -png -transparent'])
