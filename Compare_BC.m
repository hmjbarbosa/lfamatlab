clear
close all
clc

load mat-files/MAAP_156.mat

MAAP_156=BC_avg;
time_MAAP_156=time_BC_avg;

load mat-files/MAAP_158.mat

MAAP_158=BC_avg;
time_MAAP_158=time_BC_avg;

load mat-files/MAAP_244.mat

MAAP_244=BC_avg;
time_MAAP_244=time_BC_avg;

load mat-files/AE33_192.mat

AE33_192=Aeth_avg;
time_AE33_192=time_Aeth_avg;

load mat-files/AE33_193.mat

AE33_193=Aeth_avg;
time_AE33_193=time_Aeth_avg;

days_BC=unique(floor(time_AE33_193));

for i=1:max(size(days_BC))

    fig_name=['fig/BC_',mydir,'_',datestr(days_BC(i),29)];

    clear fig1;

    [a,idx_MAAP_156_st]=min(abs(time_MAAP_156-days_BC(i)));
    [a,idx_MAAP_156_end]=min(abs(time_MAAP_156-(days_BC(i)+1)));
    
    
    [a,idx_MAAP_158_st]=min(abs(time_MAAP_158-days_BC(i)));
    [a,idx_MAAP_158_end]=min(abs(time_MAAP_158-(days_BC(i)+1)));
    
    
    [a,idx_MAAP_244_st]=min(abs(time_MAAP_244-days_BC(i)));
    [a,idx_MAAP_244_end]=min(abs(time_MAAP_244-(days_BC(i)+1)));
    
    
    [a,idx_AE33_192_st]=min(abs(time_AE33_192-days_BC(i)));
    [a,idx_AE33_192_end]=min(abs(time_AE33_192-(days_BC(i)+1)));
    
    
    [a,idx_AE33_193_st]=min(abs(time_AE33_193-days_BC(i)));
    [a,idx_AE33_193_end]=min(abs(time_AE33_193-(days_BC(i)+1)));
    
    
    
    %Calculate sunrise/sunset
    [rs,t,d,z,a,r]=suncycle(-3.07,60,days_BC(i));

    rs=rs+8;

    if idx_AE33_193_end>idx_AE33_193_st+4

        fig1 = figure('visible','off');            
        set(fig1,'InvertHardcopy','on');
        set(gca,'FontSize', 12, 'LineWidth', 2); 

        axis('off');
        axes1 = axes('Parent',fig1,...
        'XTickLabel',{'0','2','4','6','8','10','12','14','16','18','20','22','24'},...
        'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);


        hold on

        rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),20000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
        plot(24.*(time_MAAP_156(idx_MAAP_156_st:idx_MAAP_156_end)-days_BC(i)),MAAP_156(idx_MAAP_156_st:idx_MAAP_156_end),'b')
        plot(24.*(time_MAAP_158(idx_MAAP_158_st:idx_MAAP_158_end)-days_BC(i)),MAAP_158(idx_MAAP_158_st:idx_MAAP_158_end),'r')
        plot(24.*(time_MAAP_244(idx_MAAP_244_st:idx_MAAP_244_end)-days_BC(i)),MAAP_244(idx_MAAP_244_st:idx_MAAP_244_end),'g')
        plot(24.*(time_AE33_192(idx_AE33_192_st:idx_AE33_192_end)-days_BC(i)),AE33_192(idx_AE33_192_st:idx_AE33_192_end),'k')
        plot(24.*(time_AE33_193(idx_AE33_193_st:idx_AE33_193_end)-days_BC(i)),AE33_193(idx_AE33_193_st:idx_AE33_193_end),'m')
        
        ylim(axes1,[0 max(AE33_192(idx_AE33_192_st:idx_AE33_192_end))])
        xlim(axes1,[0 24])

        title(['BC concentration ',station,' - ',datestr(days_BC(i),1)])
        xlabel('Time (UTC)')
        ylabel(label_Aeth)
        box on
        legend('MAAP 156','MAAP 158','MAAP 244','AE33 192','AE33 193')

        set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

        %eval(['export_fig ',fig_name,'  -png -transparent'])
        print(fig1,'-depsc',[fig_name,'.eps']);
        eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])


    end;
end;


[time_corr,MAAP_156_corr,MAAP_158_corr,MAAP_244_corr,AE33_192_corr,AE33_193_corr]=Time_sync(MAAP_156,time_MAAP_156,MAAP_158,time_MAAP_158,MAAP_244,time_MAAP_244,AE33_192,time_AE33_192,AE33_193,time_AE33_193);

fid = fopen('0_Ascii-files/BC_data.csv','wt');

fprintf(fid,'MAAP 244 - PM10 inlet 38m high\n');
fprintf(fid,'MAAP 156 - PM10 inlet 3m high\n');
fprintf(fid,'MAAP 158 - PM2.5 inlet 3m high\n');
fprintf(fid,'AE33 192 - PM10 inlet 3m high\n');
fprintf(fid,'AE33 193 - PM2.5 inlet 3m high\n\n');

fprintf(fid,'Date, MAAP 156, MAAP 158, MAAP 244, AE33 192, AE33 193\n');
fprintf(fid,'(UTC), BC (ug m-3),  BC (ug m-3), BC (ug m-3), BC (ug m-3), BC (ug m-3)\n');

for i=1:max(size(time_corr))
    fprintf(fid,'%s, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f\n',datestr(time_corr(i)),MAAP_156_corr(i),MAAP_158_corr(i),MAAP_244_corr(i),AE33_192_corr(i),AE33_193_corr(i));
end;
fclose(fid);

