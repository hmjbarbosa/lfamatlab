% Example of the use of WANG's algorithm to compute BrC from AERONET data

% Need to change dir?
%cd 'D:\Documentos\Google Drive\Doutorado\AERONET_util_rapido\marco\atto\AAOD_absorcao\ABS\total_2019\'

% Read AERONET data. Columns:
%    1 - dd:mm:yyyy
%    2 - hh:mm:ss
%    3 - AAOD em 440
%    4 - AAOD em 675
%    5 - AAOD em 870
attoin = import_abs_AERONET('AAOD_1_5_Almucanter_Amazon_ATTO_Tower.tab');

% Get absorptions
abs1 = attoin{3}; % AAOD 440nm
abs2 = attoin{4}; % AAOD 675nm
abs3 = attoin{5}; % AAOD 870nm

% Compute BrC
% Values are returned in a Matlab object
data_ATTO = calc_brc_1(abs1,abs2,abs3,440.,675.,870., [1]);

% Save Matlab time
dateStr = [char(attoin{1}) char(attoin{2})];
data_ATTO.date = datenum(dateStr,'dd:mm:yyyyHH:MM:SS');

save('data_Absorption_BrC_ATTO.mat','data_ATTO','-v7.3')

% Make some plots
clear all;
close all; 
load('data_Absorption_BrC_ATTO.mat')

figure(1); clf; 
box on; hold on;
plot(data_ATTO.date, data_ATTO.AAOD,'-dk','markerfacecolor','k','markersize',5)
plot(data_ATTO.date, data_ATTO.BCAAOD,'-db','markerfacecolor','b','markersize',5)
plot(data_ATTO.date, data_ATTO.BrAAOD,'-dg','markerfacecolor','g','markersize',5)
plot(data_ATTO.date, data_ATTO.BCAAOD+data_ATTO.BrAAOD,'-dr','markerfacecolor','r','markersize',5)
legend('Measured', 'Estimated BC', 'Estimated BrC','Estimated BC + BrC')
ylabel('AAOD 440 nm')
dynamicDateTicks
grid on; box on

figure(2); clf; 
box on; hold on;
plot(data_ATTO.date, 100*data_ATTO.AAOD./data_ATTO.AAOD,'-dk','markerfacecolor','k','markersize',5)
plot(data_ATTO.date, 100*data_ATTO.BCAAOD./data_ATTO.AAOD,'-db','markerfacecolor','b','markersize',5)
plot(data_ATTO.date, data_ATTO.BrCont,'-dg','markerfacecolor','g','markersize',5)
plot(data_ATTO.date, 100*data_ATTO.BCAAOD./data_ATTO.AAOD+data_ATTO.BrCont,'-dr','markerfacecolor','r','markersize',5)
legend('Measured', 'Estimated BC', 'Estimated BrC','Estimated BC + BrC')
ylabel('Fracton of Total AAOD 440 nm')
dynamicDateTicks
grid on; box on


return

%% medias e desvios
Mensal = media_mensal(data_RB(:,1),[data_RB(:,2:7)]);
Desvio = desvio_mensal(data_RB(:,1),[data_RB(:,2:7)]);

%filtros
Mensal(Mensal(:,4)<0,:)=[];
Desvio(Desvio(:,4)<0,:)=[];

%% Gerando os gráficos


figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1,'LineWidth',1.2,'FontWeight','bold','FontSize',14);
box(axes1,'on');
hold on (axes1,'all');
plot(Mensal(:,1),Mensal(:,4),'MarkerSize',14,'Marker','.','LineStyle','none','Color','b')
errorbar(Mensal(:,1),Mensal(:,4),Mensal(:,5),'LineStyle','none','Color','r')
%dynamicDateTicks

xlabel('Data','FontWeight','bold','FontSize',14)
ylabel('%BrC','FontWeight','bold','FontSize',14)
title('Porcentagem de BrC em relação ao total de AAOD 440nm RIO BRANCO ','FontWeight','bold','FontSize',14)
legend ('BrC médias mensais')
legend1 = legend(axes1,'show');
set(legend1,'FontSize',8);


figure2 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes2 = axes('Parent',figure2,'LineWidth',1.2,'FontWeight','bold','FontSize',14);
box(axes2,'on');
hold on (axes1,'all');
plot(Mensal(:,1),Mensal(:,6),'MarkerSize',14,'Marker','.','LineStyle','-','Color', [0 0.4470 0.7410])
%errorbar(MensalATTO(:,1),MensalATTO(:,6),DesvioATTO(:,6),'LineStyle','none','Color','b')
plot(Mensal(:,1),Mensal(:,7),'MarkerSize',14,'Marker','.','LineStyle','-','Color','k')
%errorbar(MensalATTO(:,1),MensalATTO(:,7),DesvioATTO(:,7),'LineStyle','none','Color','g')
plot(Mensal(:,1),Mensal(:,2),'MarkerSize',14,'Marker','.','LineStyle','-','Color',[0.9290 0.6940 0.1250])
%errorbar(MensalAF(:,1),MensalAF(:,2),DesvioAF(:,2),'LineStyle','none','Color',[0.2 0 0])
%dynamicDateTicks

xlabel('Data','FontWeight','bold','FontSize',14)
ylabel('AAOD','FontWeight','bold','FontSize',14)
title('BC e BrC calculado em AAOD 440nm RIO BRANCO','FontWeight','bold','FontSize',14)
legend('AAOD 440nm', 'BC', 'BrC')
legend1 = legend(axes1,'show');
set(legend1,'FontSize',8);


%% boxplot

figure3 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes3 = axes('Parent',figure3,'LineWidth',1.2,'FontWeight','normal','FontSize',12);
box(axes3,'on');
hold on (axes3,'all');
h=boxplot(data_RB(:,4),month(data_RB(:,1)));
set(h,{'linew'},{2})
set(h(7,:),'Visible','off')

xlabel('Mês do ano','FontWeight','bold','FontSize',14)
ylabel('%BrC','FontWeight','bold','FontSize',14)
title('Porcentagem de BrC em relação ao total de AAOD 440nm RIO BRANCO','FontWeight','bold','FontSize',14)

% figure1 = figure;
% subplot1 = subplot(2,1,1,'Parent',figure1,...
%     'XMinorTick','on','LineWidth',2,'FontWeight','normal','FontSize',10);
% box(subplot1,'on');
% hold(subplot1,'all');
% grid(subplot1,'on');
% h=boxplot(data_AF(:,4),month(data_AF(:,1)));
% set(h,{'linew'},{2})
% set(h(7,:),'Visible','off')
% 
% subplot2 = subplot(2,1,2,'Parent',figure1,...
%     'XMinorTick','on','LineWidth',2,'FontWeight','normal','FontSize',10);
% box(subplot2,'on');
% hold(subplot2,'all');
% grid(subplot2,'on');
% h=boxplot(data_AF(:,5),month(data_AF(:,1)));
% set(h,{'linew'},{2})
% set(h(7,:),'Visible','off')


%% calculando as medias Porcentagem de BrC em relação AAO440nm

clear all;
clc;
load('data_Absorption_BrC_AF.mat')
load('data_Absorption_BrC_ATTO.mat')
load('data_Absorption_BrC_CB.mat')
load('data_Absorption_BrC_JP.mat')
load('data_Absorption_BrC_ME.mat')
load('data_Absorption_BrC_EAB.mat')
load('data_Absorption_BrC_SP.mat')
load('data_Absorption_BrC_RB.mat')

M_AF = nanmean(data_AF)
Std_AF = nanstd(data_AF)

M_ATTO = nanmean(data_ATTO)
Std_ATTO = nanstd(data_ATTO)

M_CB = nanmean(data_CB)
Std_CB = nanstd(data_CB)

M_JP = nanmean(data_JP)
Std_JP = nanstd(data_JP)

M_EAB = nanmean(data_EAB)
Std_EAB = nanstd(data_EAB)

M_ME = nanmean(data_ME)
Std_ME = nanstd(data_ME)

M_SP = nanmean(data_SP)
Std_SP = nanstd(data_SP)

M_RB = nanmean(data_RB) %média Rio Branco
Std_RB = nanstd(data_RB) %desvio padrão

%média e erro
todos = vertcat(M_AF,M_ATTO,M_CB,M_JP,M_ME,M_SP,M_RB,M_EAB);
sitios = {' ','AF ','ATTO ','CB ','JP ','MAO ','SP ','RB ','El Alto'};
errorbar(1:length(todos(:,4)),todos(:,4),todos(:,5),'.')
set(gca,'xticklabel',sitios.')
refline([0 mean(todos(:,4))])


xlabel('Site','FontWeight','bold','FontSize',14)
ylabel('%BrC','FontWeight','bold','FontSize',14)
title('Médias e desvio padrão %BrC em Relação AAOD440nm ','FontWeight','bold','FontSize',14)

%Grafico pizza %BrC e BC 

x = [M_AF(4) (100-M_AF(4))] ;
p = pie(x)
pText = findobj(p,'Type','text');
percentValues = get(pText,'String'); 
title('ALTA FLORESTA','FontWeight','bold','FontSize',14)
set(gcf, 'Color', 'None')

imshow(imread('mapa.jpg'))
hold on

x = [M_AF(4) (100-M_AF(4))] ;
pie(x)



