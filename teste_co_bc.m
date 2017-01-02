clear all
close all

load mat-files/co-bc.mat
Aeth_avg(Aeth_avg<0.01)=nan;

mask1=time_Aeth_avg>datenum(2015,12,1,0,0,0) & ...
      time_Aeth_avg<datenum(2015,12,8,0,0,0);

mask2=time_Aeth_avg>datenum(2015,12,8,0,0,0) & ...
      time_Aeth_avg<datenum(2015,12,9,0,0,0);

mask3=time_Aeth_avg>datenum(2015,12,9,0,0,0) & ...
      time_Aeth_avg<datenum(2015,12,10,0,0,0);

mask4=time_Aeth_avg>datenum(2015,12,10,0,0,0) & ...
      time_Aeth_avg<datenum(2015,12,11,0,0,0);

mask5=time_Aeth_avg>datenum(2015,12,11,0,0,0) & ...
      time_Aeth_avg<datenum(2016,2,21,0,0,0);

mask6=time_Aeth_avg>datenum(2016,2,25,0,0,0);

%

figure(1); clf; hold on
xlim([0 15]); ylim([0 1000])

plot(Aeth_avg(mask1,6),CO_avg(mask1),'.r','markerfacecolor','r')
p1=plot(Aeth_avg(mask2,6),CO_avg(mask2),'.g','markerfacecolor','g');
plot(Aeth_avg(mask3,6),CO_avg(mask3),'.b','markerfacecolor','b')
plot(Aeth_avg(mask4,6),CO_avg(mask4),'.m','markerfacecolor','m')
plot(Aeth_avg(mask5,6),CO_avg(mask5),'.y','markerfacecolor','y')
p2=plot(Aeth_avg(mask6,6),CO_avg(mask6),'.k','markerfacecolor','k');

legend('< 7/dez 23:59',...
        '8/dez 0:00 to 23:59', ...
        '9/dez 0:00 to 23:59', ...
       '10/dez 0:00 to 23:59',...
       '11/dez 0:00 to 20/fev 23:59',...
       '> 25/fev 0:00')

uistack(p1,'top')
uistack(p2,'bottom')

ylabel('CO conc LosGatos (ppbv)');
xlabel('BC conc AE33 880nm (\mug m^{-3})');
prettify(gca)
grid on; box on;

%
%figure(2); clf; hold on
%xlim([0 20]); ylim([0 1000])
%plot(Aeth_avg(mask1,6),CO_avg(mask1),'.r','markerfacecolor','r')
%plot(Aeth_avg(mask5,6),CO_avg(mask5),'.y','markerfacecolor','y')
%p2=plot(Aeth_avg(mask6,6),CO_avg(mask6),'.k','markerfacecolor','k');

f=@(a,x) a(1)*x+a(2);
[B1,R1,J1,C1,MSE1,ER1] = ...
    nlinfitwxy(Aeth_avg(mask1,6), CO_avg(mask1), ...
               ones(sum(mask1),1), ones(sum(mask1),1), ...
               f, [100 0]);

[B5,R5,J5,C5,MSE5,ER5] = ...
    nlinfitwxy(Aeth_avg(mask5,6), CO_avg(mask5), ...
               ones(sum(mask5),1), ones(sum(mask5),1), ...
               f, [100 0]);

[B6,R6,J6,C6,MSE6,ER6] = ...
    nlinfitwxy(Aeth_avg(mask6,6), CO_avg(mask6), ...
               ones(sum(mask6),1), ones(sum(mask6),1), ...
               f, [100 0]);

plot(Aeth_avg(mask1,6),f(B1,Aeth_avg(mask1,6)),'c','linewidth',2);
plot(Aeth_avg(mask5,6),f(B5,Aeth_avg(mask5,6)),'c','linewidth',2);
plot(Aeth_avg(mask6,6),f(B6,Aeth_avg(mask6,6)),'c','linewidth',2);

[B,R,J,C,MSE,ER] = ...
    nlinfitwxy(Aeth_avg(mask6|mask1,6), CO_avg(mask6|mask1), ...
               ones(sum(mask6|mask1),1), ones(sum(mask6|mask1),1), ...
               f, [100 0]);

%[a1, b1, fval1, sa1, sb1, chi2red1, ndf1]=fastfit(Aeth_avg(mask1,6),CO_avg(mask1));
%[a5, b5, fval5, sa5, sb5, chi2red5, ndf5]=fastfit(Aeth_avg(mask5,6),CO_avg(mask5));
%[a6, b6, fval6, sa6, sb6, chi2red6, ndf6]=fastfit(Aeth_avg(mask6,6),CO_avg(mask6));
%plot(Aeth_avg(mask1,6),fval1,'r');
%plot(Aeth_avg(mask5,6),fval5,'y');
%plot(Aeth_avg(mask6,6),fval6,'k');

%legend('< 7/dez 23:59',...
%       '11/dez 0:00 to 20/fev 23:59',...
%       '> 25/fev 0:00')

%ylabel('CO conc LosGatos (ppbv)');
%xlabel('BC conc AE33 880nm (\mug m^{-3})');
%prettify(gca)
%grid on; box on;
%

CObom=B(1)*( (CO_avg(mask5)-B5(2))/B5(1) ) + B(2);

figure(3); clf; hold;

plot(time_CO_avg(mask1), CO_avg(mask1),'*-b')
plot(time_CO_avg(mask5), CO_avg(mask5),'*-r')
plot(time_CO_avg(mask6), CO_avg(mask6),'*-b')

plot(time_CO_avg(mask5), CObom,'o-k')
ylabel('CO conc LosGatos (ppbv)');
xlabel('Date')
ylim([0 2000])
x=xlim;
dynamicDateTicks([], [], 'dd/mm');
xlim(x);
set(3,'InvertHardcopy','on');
% units in pixels!
set(gcf,'PaperUnits','points','PaperSize',[775 390],...
        'PaperPosition',[0 0 775 390],'position',[0,0,775,390]);
set(gca,'FontSize', 12, 'LineWidth', 2); 
prettify(gca);
grid on ; box on

%
