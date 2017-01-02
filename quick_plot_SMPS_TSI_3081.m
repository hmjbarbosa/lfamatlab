clear
clc
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='SMPS/';

%-------------------------------

count=0;
distr_part=[];

fl=dir([fl_dir,'*SMPS*.txt']);

if min(size(fl))>0
    for fl_number=1:max(size(fl))

        fl_dir,fl(fl_number).name
        
        fid = fopen([fl_dir,fl(fl_number).name]);
        total_lines=0;
        TextLine = fgetl(fid);
        while ~feof(fid)
            total_lines=total_lines+1;
            n_delimiters=0;
            size_text=max(size(TextLine));
            i=2;
            while i<size_text
                if strcmp(TextLine(i),'	')
                    TextLine(i)=' ';
                end;
                if strcmp(TextLine(i),' ')
                    if strcmp(TextLine(i-1),' ') 
                        TextLine(i)=[];
                        size_text=size_text-1;
                        i=i-1;
                    else
                        n_delimiters=n_delimiters+1;
                        idx_delimiter(n_delimiters)=i;
                    end;
                end;
            i=i+1;
            end
    
            if n_delimiters==176 && strcmp(TextLine(1:6),'Sample')
                for j=20:127
                    size_part(j-19)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
                end;
            end;

            if n_delimiters==135   

                clear dummy_distr_part
               for j=3:110
                    dummy_distr_part(j-2)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
                end;

                dummy_mean_Dpg=str2num(TextLine(idx_delimiter(130)+1:idx_delimiter(131)-1));
                dummy_SMPS_TSI_CPC=str2num(TextLine(idx_delimiter(135)+1:end));
                dummy_month=str2num((TextLine(idx_delimiter(1)+1:idx_delimiter(1)+2)));
                dummy_day=str2num((TextLine(idx_delimiter(1)+4:idx_delimiter(1)+5)));
                dummy_year=str2num((TextLine(idx_delimiter(1)+7:idx_delimiter(1)+8)))+2000;
                dummy_hour=str2num((TextLine(idx_delimiter(2)+1:idx_delimiter(2)+2)));
                dummy_minute=str2num((TextLine(idx_delimiter(2)+4:idx_delimiter(2)+5)));
                dummy_sec=str2num((TextLine(idx_delimiter(2)+7:idx_delimiter(2)+8)));


                if max(size(dummy_distr_part))==108 && max(size(dummy_mean_Dpg))==1  && max(size(dummy_SMPS_TSI_CPC))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                    count=count+1; 
                    mean_DPg(count)=dummy_mean_Dpg;
                    SMPS_TSI_CPC(count)=dummy_SMPS_TSI_CPC;
                    distr_part=[distr_part;dummy_distr_part];
                    time_SMPS_TSI(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                    if time_SMPS_TSI(count)>now || time_SMPS_TSI(count)< (now-2*365) %Excludes weird dates from MAAP (e.g. future aand more than two years old for GoAmazon dataset.).
                        count=count-1;
                        distr_part(:,end)=[];
                        SMPS_TSI_CPC(end)=[];
                        mean_DPg(end)=[];
                        time_SMPS_TSI(end)=[];
                    end;
                end;
            end   
           
            % get next line of text
            TextLine = fgetl(fid);

        end;
        status=fclose(fid);
    end;
end;
%--------------------------------


distr_part=distr_part';

[time_SMPS_TSI,idx]=unique(time_SMPS_TSI);
distr_part=distr_part(:,idx);
SMPS_TSI_CPC=SMPS_TSI_CPC(idx);
mean_DPg=mean_DPg(idx);


label_mean_DPg=('Average particle diameter (m)');
title_mean_DPg=('Average particle diameter');

label_SMPS_TSI_CPC=('Particle concentration (#/cm^3)');
label_SMPS_TSI_TEOM=('Particle mass concentration (\mug m^{-3})');
label_SMPS_TSI_surf=('Particle surface (cm^2)');

title_SMPS_TSI_CPC=('SMPS TSI particle count');
title_SMPS_TSI_TEOM=('SMPS TSI mass concentration');
title_SMPS_TSI_surf=('SMPS TSI particle surface');

size_part=size_part./1e7; %Now in cm

calc_SMPS_TSI_CPC=zeros(1,size(distr_part,2));

for i=1:max(size(time_SMPS_TSI))
    for j=1:size(distr_part,1)-1
        calc_SMPS_TSI_CPC(i)=calc_SMPS_TSI_CPC(i)+distr_part(j,i).*log10(size_part(j+1)/size_part(j));
   end;
end;

%Calculates particle surface and volume distribution
for i=1:max(size(size_part))
    surf_part(i,:)=distr_part(i,:).*size_part(i).^2.*pi;
    vol_part(i,:)=distr_part(i,:).*size_part(i).^3.*pi./6; 
end;

SMPS_TSI_TEOM=zeros(1,size(distr_part,2));
SMPS_TSI_surf=zeros(1,size(distr_part,2));

for i=1:max(size(time_SMPS_TSI))
    for j=1:size(distr_part,1)-1
        SMPS_TSI_TEOM(i)=SMPS_TSI_TEOM(i)+1.2.*vol_part(j,i).*log10(size_part(j+1)/size_part(j)); %Should be in grams now
        SMPS_TSI_surf(i)=SMPS_TSI_surf(i)+surf_part(j,i).*log10(size_part(j+1)/size_part(j));
    end;

    SMPS_TSI_TEOM(i)=SMPS_TSI_TEOM(i).*1e6; %conversion to micrograms/cm3
    SMPS_TSI_TEOM(i)=SMPS_TSI_TEOM(i).*1e6; %conversion to micrograms/m3
end;


size_part=size_part.*1e7; %Back to nm


fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_SMPS_TSI,SMPS_TSI_CPC,'k*')
title([title_SMPS_TSI_CPC,station])
xlabel('Date')
ylabel(label_SMPS_TSI_CPC)
box on
dynamicDateTicks([], [], 'dd/mm');
ylim([0 2e4])
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Aerosol_Number_SMPS_TSI_3081' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
eval(['delete ',nome,'.eps'])


clear fig1

fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_SMPS_TSI,SMPS_TSI_TEOM,'k*')
title([title_SMPS_TSI_TEOM,station])
xlabel('Date')
ylabel(label_SMPS_TSI_TEOM)
box on
dynamicDateTicks([], [], 'dd/mm');
ylim([0 30])
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/SMPS_3081_Mass_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
eval(['delete ',nome,'.eps'])


%time_SMPS_TSI(SMPS_TSI_CPC>4.*prctile(SMPS_TSI_CPC,90))=[];
%SMPS_TSI_TEOM(SMPS_TSI_CPC>4.*prctile(SMPS_TSI_CPC,90))=[];
%distr_part(:,SMPS_TSI_CPC>4.*prctile(SMPS_TSI_CPC,90))=[];
%SMPS_TSI_CPC(SMPS_TSI_CPC>4.*prctile(SMPS_TSI_CPC,90))=[];


%Plot each day

days_SMPS_TSI=unique(floor(time_SMPS_TSI));

for i=1:max(size(days_SMPS_TSI))

            
         if days_SMPS_TSI(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/Aerosol_Number_SMPS_TSI_3081_',mydir,'_',datestr(days_SMPS_TSI(i),29)];
        elseif days_SMPS_TSI(i)>datenum(2014,04,01) && days_SMPS_TSI(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/Aerosol_Number_SMPS_TSI_3081_',mydir,'_',datestr(days_SMPS_TSI(i),29)];
        elseif days_SMPS_TSI(i)>=datenum(2014,08,15) && days_SMPS_TSI(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/Aerosol_Number_SMPS_TSI_3081_',mydir,'_',datestr(days_SMPS_TSI(i),29)];
         end

        
    clear fig1;
    


    quick_time_SMPS_TSI=(time_SMPS_TSI-days_SMPS_TSI(i)).*24;

    [a,idx_st]=min(abs(quick_time_SMPS_TSI));
    [a,idx_end]=min(abs(quick_time_SMPS_TSI - 24));

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
        rectangle('Parent',axes1,'Position',[rs(1),-100000,rs(2)-rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
        plot(quick_time_SMPS_TSI(idx_st:idx_end),SMPS_TSI_CPC(idx_st:idx_end),'k*')
        ylim(axes1,[min(SMPS_TSI_CPC(idx_st:idx_end)) max(SMPS_TSI_CPC(idx_st:idx_end))])
        xlim(axes1,[0 24])

        title(['Aerosol number concentration (SMPS TSI)',station,' - ',datestr(days_SMPS_TSI(i),1)])
        xlabel('Time (UTC)')
        ylabel(label_SMPS_TSI_CPC)
        box on

        set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
        print(fig1,'-depsc',[fig_name,'.eps']);
        eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])
        eval(['delete ',fig_name,'.eps'])

    
    end;
end;

save mat-files/SMPS_TSI_3081.mat


fid = fopen('0_Ascii-files/SMPS_TSI_3081.csv','wt');

fprintf(fid,['Date(UTC),Number concentration (cm-3), Mass concentration (ugm-3), Median Diameter(nm),', repmat('%2.1f, ', 1, size(size_part, 2)) '\n'],size_part);

for i=1:max(size(time_SMPS_TSI))
    fprintf(fid,['%s, %2.1f, %2.2f,', repmat('%2.1f, ', 1, size(size_part, 2)) '\n'],datestr(time_SMPS_TSI(i)),SMPS_TSI_CPC(i),SMPS_TSI_TEOM(i),distr_part(:,i));
end;
fclose(fid);