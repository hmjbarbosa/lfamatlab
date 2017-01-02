clear
clc
close all

load  mat-files/Anem_Lufft.mat


%{
fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Anem,Anem_vel,'k*')
title([title_Anem_vel,station])
xlabel('Date')
ylabel(label_Anem_vel)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Anem_vel_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])


clear fig1

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Anem,Anem_dir,'k*')
title([title_Anem_dir,station])
xlabel('Date')
ylabel(label_Anem_dir)
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Anem_dir_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

%}
clear fig1

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
wind_rose(Anem_dir(Anem_vel>0.5),Anem_vel(Anem_vel>0.5))
title(['Wind rose',station])
box on
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.775]);
nome=['fig/Wind_rose_' mydir '']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])


%Plot each day

%{
days_BC=unique(floor(time_BC));

for i=1:max(size(days_BC))

    fig_name=['fig/',datestr(days_BC(i),1),'_BC_MAAP_',mydir];
        
    clear fig1;
    
    if exist([fig_name,'.png'],'file')==0

        quick_time_BC=(time_BC-days_BC(i)).*24;

        [a,idx_st]=min(abs(quick_time_BC));
        [a,idx_end]=min(abs(quick_time_BC - 24));

        %Calculate sunrise/sunset
        [rs,t,d,z,a,r]=suncycle(-3.07,60,i);

        rs=rs+8;

        if idx_end>idx_st+30

            fig1 = figure('visible','off');            
            set(fig1,'InvertHardcopy','on');
            set(gca,'FontSize', 12, 'LineWidth', 2); 

            axis('off');
            axes1 = axes('Parent',fig1,...
            'XTickLabel',{'0','2','4','6','8','10','12','14','16','18','20','22','24'},...
            'XTick',[0 2 4 6 8 10 12 14 16 18 20 22 24]);
                        
           
            hold on
%            rectangle('Parent',axes1,'Position',[0,-1000,rs(1),2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
%            rectangle('Parent',axes1,'Position',[rs(2),-1000,24,2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
            rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
            plot(quick_time_BC(idx_st:idx_end),BC(idx_st:idx_end),'k*')
            ylim(axes1,[min(BC(idx_st:idx_end)) max(BC(idx_st:idx_end))])
            xlim(axes1,[0 24])
            
            title(['BC_e (MAAP)',station,' - ',datestr(days_BC(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_BC)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
	        print(fig1,'-depsc',[fig_name,'.eps']);
            eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])

        end;
    end;
end;

%}

save mat-files/Anem_Lufft.mat
