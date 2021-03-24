% cálculo da contribuição de Brown carbon na absorção

% BrAAOD = é o BrC calculado AAOD a 440nm
% BrAAOD_r = é a incerteza metodológica do resultado BrAAOD
% BrCont = é a contribuição calculada de BrC AAOD para AAOD total a 440nm, em %
% BrCont_r = é a incerteza metodológica do resultado BrCont
% BCAAOD = considerando BC calculado AAOD a 440nm = AAOD 440nm

% col_01 Date
% col_02 BrC calculado AAOD 440nm
% col_03 Incerteza do BrC calculado AAOD 440nm 
% col_04 Porcentagem de BrC AAOD 440nm em relação ao total de AAOD 440nm
% col_05 Incerteza da medida col_04
% col_06 AAOD 440nm
% col_07 BC real 440nm (AAOD 440nm - BrC 440nm)

clear all;
clc;

%load('V3_Data_Inversion_2019_02_lev1_5.mat')

cd 'D:\Documentos\Google Drive\Doutorado\AERONET_util_rapido\marco\atto\AAOD_absorcao\ABS\total_2019\'
RioBranco = import_abs('AAOD_1_5_Almucanter_Amazon_ATTO_Tower.tab');
dateStr = [char(RioBranco(:,1)) char(RioBranco(:,2))];
date = datenum(dateStr,'dd:mm:yyyyHH:MM:SS');

%Incluir aqui data e hora do começo do filtro e data e hora do fim do
%filtro
%Fazer as series temporais e os graficos de pizza

cd 'D:\Documentos\Google Drive\Doutorado\Tratamento\Analises_BrC\'
bondmie = importdata('bondmie.csv');

% date=RioBranco(:,1); % data   Sempre mudar o site 
% abs1=RioBranco(:,11); % AAOD 440nm
% abs2=RioBranco(:,12); % AAOD 675nm
% abs3=RioBranco(:,13); % AAOD 870nm

%date=RioBranco(:,1); % data   Sempre mudar o site 
abs1=cell2mat(RioBranco(:,3)); % AAOD 440nm
abs2=cell2mat(RioBranco(:,4)); % AAOD 675nm
abs3=cell2mat(RioBranco(:,5)); % AAOD 870nm

AAE675 = -log(abs2./abs3)./log(675/870);

for i = 1:length(bondmie.data(:,1));
    for ii = 1:length(AAE675);
    
    if AAE675(ii) >= bondmie.data(i,1)-0.1 & AAE675(ii) < bondmie.data(i,1)+0.1;
        
        AAE440 = -log(abs1./abs2)./log(440/675);
        realdef = exp(AAE440)./exp(AAE675);
        
        if realdef(ii) > bondmie.data(i,3);
            bcaae = AAE675+log(bondmie.data(i,2));
            BCAAOD = abs3.*exp(-bcaae.*log(440/870));
            BrAAOD = abs1-BCAAOD;
            
            bcaae_max = AAE675+log(bondmie.data(i,3));
            bcaaod_max = abs3.*exp(-bcaae_max.*log(440/870));
            braaod_min = abs1-bcaaod_max;
            BrAAOD_r = BrAAOD-braaod_min;
            
            BrCont = 100.*BrAAOD./abs1;
            BrCont_r = 100.*BrAAOD_r./abs1;
            
        end
    else
        BCAAOD = abs1;        
    end
        
    end
end
 
data_ATTO=[date BrAAOD BrAAOD_r BrCont BrCont_r BCAAOD]; 

clear AAE440 AAE675 abs1 abs2 abs3 bcaae bcaae_max bondmie BrAAOD braaod_min
  clear BCAAOD bcaaod_max BrAAOD_r BrCont BrCont_r i ii inv realdef sd date
    clear AltaFloresta ATTO Cuiaba ElAltoBolivia JiParana ManausEMBRAPA RioBranco SaoPaulo
    
    cd 'D:\Documentos\Google Drive\Doutorado\AERONET_util_rapido\marco\atto\AAOD_absorcao\ABS\total_2019\'
    
save data_Absorption_BrC_ATTO.mat

%% 
clear all;
clc;
load('data_Absorption_BrC_ATTO.mat')

%Subtracao devido ao BC+BrC = Total
%A coluna 7 seria o BC real.

data_ATTO(:,7) = data_ATTO(:,6)-data_ATTO(:,2);

dataBC = [];
dataBC.date = datestr(data_ATTO(:,1));
dataBC.BrC440 = data_ATTO(:,2);
dataBC.BC440 = data_ATTO(:,7);
dataBC.AAOD440 = data_ATTO(:,6);

t = struct2table(dataBC)
writetable(t,'BrC_BC_RioBranco_470nm_corrected.dat');

figure,
plot(data_ATTO(:,1),data_ATTO(:,7),'.k',data_ATTO(:,1),data_ATTO(:,2),'.y',...
    data_ATTO(:,1),(data_ATTO(:,7)+data_ATTO(:,2)),'.b',...
    data_ATTO(:,1),data_ATTO(:,6),'.r')
legend('BC', 'BrC','Soma BC + BrC', 'AAOD440')
ylabel('AAOD')
dynamicDateTicks

% data_AF(:,7)= data_AF(:,6)-data_AF(:,2);
% data_ATTO(:,7)= data_ATTO(:,6)-data_ATTO(:,2);
% data_CB(:,7)= data_CB(:,6)-data_CB(:,2);
% data_EAB(:,7)= data_EAB(:,6)-data_EAB(:,2);
% data_JP(:,7)= data_JP(:,6)-data_JP(:,2);
% data_ME(:,7)= data_ME(:,6)-data_ME(:,2);
% data_RB(:,7)= data_RB(:,6)-data_RB(:,2);
% data_SP(:,7)= data_SP(:,6)-data_SP(:,2);
  
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
dynamicDateTicks

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
dynamicDateTicks

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



