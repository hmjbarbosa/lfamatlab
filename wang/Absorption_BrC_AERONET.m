% Example of the use of WANG's algorithm to compute BrC from AERONET data

% Need to change dir?
%cd 'D:\Documentos\Google Drive\Doutorado\AERONET_util_rapido\marco\atto\AAOD_absorcao\ABS\total_2019\'
photometer = import_abs_AERONET('AAOD_1_5_Almucanter_Amazon_ATTO_Tower.tab');

% Columns
% 1 - dd:mm:yyyy
% 2 - hh:mm:ss
% 3 - AAOD em 440
% 4 - AAOD em 675
% 5 - AAOD em 870

% Compute Matlab time
dateStr = [char(photometer{1}) char(photometer{2})];
date = datenum(dateStr,'dd:mm:yyyyHH:MM:SS');

% Assign columns
abs1 = photometer{3}; % AAOD 440nm
abs2 = photometer{4}; % AAOD 675nm
abs3 = photometer{5}; % AAOD 870nm

%hmjb para verificar que isso sao mesmos vetores:
%figure(1); clf; grid on; box on; hold on
%plot(abs1,'-r')
%plot(abs2,'-g')
%plot(abs3,'-b')
%legend('440', '675', '870')

%hmjb aqui ta calculando o Absorp. Angs. entre 675 e 870
% Sera que os dados da Bond sao justamente neste intervalo?? precisa verificar...
AAE675 = -log(abs2./abs3)./log(675/870);

%hmjb pra ter certeza que a formula ta certa, deixa eu calcular para 440-870
% e comparar com a coluna #7 da aeronet
AAE440_870 = -log(abs1./abs3)./log(440/870);

%hmjb Sao Parecidos mas nao sao iguais... porque? 
%figure(2); clf; grid on; box on; hold on
%plot(cell2mat(photometer(:,7)),'-r')
%plot(AAE440_870,'-b')
%legend('AAE870 Aeronet', 'AAE870 script')
%
%figure(3); clf; grid on; box on; hold on
%plot(cell2mat(photometer(:,7)),AAE440_870,'o')
%xlabel('AAE870 Aeronet')
%ylabel('AAE870 script')

clear isel
%hmjb inicializa od dados
AAE440 = nan(length(AAE675), 1);
realdef = nan(length(AAE675), 1);

BrAAOD   = nan(length(AAE675), 1);
BrAAOD_r = nan(length(AAE675), 1);
BrCont   = ones(length(AAE675), 1)*100;
BrCont_r = nan(length(AAE675), 1);
BCAAOD   = nan(length(AAE675), 1);

ok(1:8)=0;
%hmjb Para cada faixa de AAE na tabela da Bond
for i = 1:length(bondmie.data(:,1))
  
  %hmjb vamos percorrer o vetor de medidas da Aeronet (eixo do tempo!!!)
  for ii = 1:length(AAE675)
    
    %hmjb se o ii-esimo tempo for compativel com a linha certa da tabela
    %da Bond, entao vamos processar usando esta linha
    
    % duplicada a ulitma linha da tabela para incluir o caso do AAE675 
    % entre 1.4 e 1.5
    %hmjb - nova solucao, agora vamos manter a tabela original e corrigir
    %aqui:
    
    lowlim = bondmie.data(i,1)-0.1;
    if i==length(bondmie.data(:,1))
      lowlim = bondmie.data(i,1)-0.2;
    end
    
    if AAE675(ii) >= lowlim & AAE675(ii) < bondmie.data(i,1)+0.1
        if ok(i)==0
          ok(i)=1;
          disp([i, lowlim, bondmie.data(i,1)+0.1])
        end
      %hmjb grava a linha escolhida para cada tempo do vetor
      isel(ii) = i;
      
      %hmjb ta errado! isso abs1 e abs2 sao vetores que contem todas as
      %medidas!! devia ser feito apenas para a posicao (ii)
      %AAE440 = -log(abs1./abs2)./log(440/675);
      %AAE440(ii) = -log(abs1(ii)/abs2(ii))/log(440/675);
      
      % sera que isso eh um BUG no algoritmo do Wang?
      % pega o abs1/abs2, mas usa 440 e 870? 
      % devia ser abs3? 
      % ou 870? 
      % ou t� certo mesmo?
      %=> conferir no paper
      AAE440(ii) = -log(abs1(ii)/abs3(ii))/log(440/870);
      
      %hmjb ta fazendo a razao do 440/675 para o 675/870
      % porque? o que isso significa? 
      
      % mas tambem ta errado, pois ta fazendo para TODAS as posicoes
      % (tempos). 
      %realdef) = exp(AAE440)./exp(AAE675);
      realdef(ii) = exp(AAE440(ii))/exp(AAE675(ii));
      
      % hmjb
      % a coluna #3 eh a coluna do MAX da bond... Era mesmo para fazer s�
      % se fosse maior que o maximo? Porque entao a bonda teria valores
      % de minimo e de middle??? Se sempre tem que ser maior que o
      % maximo? 
      
      if realdef(ii) > bondmie.data(i,3);
        %bcaae(ii) = AAE675(ii)+log(bondmie.data(i,2));
        bcaae(ii) = AAE675(ii)+log(bondmie.data(i,4));
        BCAAOD(ii) = abs3(ii)*exp(-bcaae(ii)*log(440/870));
        BrAAOD(ii) = abs1(ii)-BCAAOD(ii);
        
        bcaae_max(ii) = AAE675(ii)+log(bondmie.data(i,3));
        bcaaod_max(ii) = abs3(ii)*exp(-bcaae_max(ii)*log(440/870));
        braaod_min(ii) = abs1(ii)-bcaaod_max(ii);
        BrAAOD_r(ii) = BrAAOD(ii)-braaod_min(ii);
        
        BrCont(ii) = 100*BrAAOD(ii)/abs1(ii);
        BrCont_r(ii) = 100*BrAAOD_r(ii)/abs1(ii);
        
        %hmjb esse fim de loop tambem ta errado!!! nao ta assim no codigo
        %do Wang. O ELSE deveria ser para o caso de ser < que o Max da
        %Bond
        
        % do jeito que ta para todas as linhas do loop em (i, linhas da
        % bond), exceto uma, o codigo vai entrar aqui em baixo
      else
        BCAAOD(ii) = abs1(ii);
        BrCont(ii) = 0;
      end
    end
    
  end
end

%hmjb acabou de rodar, vamos mostrar os resultados para os tempos= 1 e 2

for t=1:2
disp(['======================= tempo ',num2str(t)])
disp(['abs1/abs2/abs3=' , num2str(abs1(t)), num2str(abs2(t)), num2str(abs3(t))])
disp(['BrAAOD='         ,num2str(BrAAOD(t))])
disp(['BrCont='         ,num2str(BrCont(t))])
disp(['BCAAOD='         ,num2str(BCAAOD(t))])
disp(['AAE440='         ,num2str(AAE440(t))])
disp(['AAE675='         ,num2str(AAE675(t))])
disp(['realdef='        ,num2str(realdef(t))])
disp(['bond max='       ,num2str(bondmie.data(isel(t),3))])
disp(['line bond table=',num2str(isel(t))])
end


data_ATTO_ok=[date BrAAOD BrAAOD_r BrCont BrCont_r BCAAOD]; 
return

clear AAE440 AAE675 abs1 abs2 abs3 bcaae bcaae_max bondmie BrAAOD braaod_min
clear BCAAOD bcaaod_max BrAAOD_r BrCont BrCont_r i ii inv realdef sd date
clear AltaFloresta ATTO Cuiaba ElAltoBolivia JiParana ManausEMBRAPA photometer SaoPaulo
    
%cd 'D:\Documentos\Google Drive\Doutorado\AERONET_util_rapido\marco\atto\AAOD_absorcao\ABS\total_2019\'
    
save data_Absorption_BrC_ATTO.mat

%% 
clear all;
%clc;
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
writetable(t,'BrC_BC_photometer_470nm_corrected.dat');

figure,
plot(data_ATTO(:,1),data_ATTO(:,7),'.k',data_ATTO(:,1),data_ATTO(:,2),'.y',...
    data_ATTO(:,1),(data_ATTO(:,7)+data_ATTO(:,2)),'.b',...
    data_ATTO(:,1),data_ATTO(:,6),'.r')
legend('BC', 'BrC','Soma BC + BrC', 'AAOD440')
ylabel('AAOD')
%dynamicDateTicks

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

%% Gerando os gr�ficos


figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes('Parent',figure1,'LineWidth',1.2,'FontWeight','bold','FontSize',14);
box(axes1,'on');
hold on (axes1,'all');
plot(Mensal(:,1),Mensal(:,4),'MarkerSize',14,'Marker','.','LineStyle','none','Color','b')
errorbar(Mensal(:,1),Mensal(:,4),Mensal(:,5),'LineStyle','none','Color','r')
%dynamicDateTicks

xlabel('Data','FontWeight','bold','FontSize',14)
ylabel('%BrC','FontWeight','bold','FontSize',14)
title('Porcentagem de BrC em rela��o ao total de AAOD 440nm RIO BRANCO ','FontWeight','bold','FontSize',14)
legend ('BrC m�dias mensais')
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

xlabel('M�s do ano','FontWeight','bold','FontSize',14)
ylabel('%BrC','FontWeight','bold','FontSize',14)
title('Porcentagem de BrC em rela��o ao total de AAOD 440nm RIO BRANCO','FontWeight','bold','FontSize',14)

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


%% calculando as medias Porcentagem de BrC em rela��o AAO440nm

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

M_RB = nanmean(data_RB) %m�dia Rio Branco
Std_RB = nanstd(data_RB) %desvio padr�o

%m�dia e erro
todos = vertcat(M_AF,M_ATTO,M_CB,M_JP,M_ME,M_SP,M_RB,M_EAB);
sitios = {' ','AF ','ATTO ','CB ','JP ','MAO ','SP ','RB ','El Alto'};
errorbar(1:length(todos(:,4)),todos(:,4),todos(:,5),'.')
set(gca,'xticklabel',sitios.')
refline([0 mean(todos(:,4))])


xlabel('Site','FontWeight','bold','FontSize',14)
ylabel('%BrC','FontWeight','bold','FontSize',14)
title('M�dias e desvio padr�o %BrC em Rela��o AAOD440nm ','FontWeight','bold','FontSize',14)

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



