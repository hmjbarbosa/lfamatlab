%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 17/Aug/2014                                  %
%                                                                     %
%This routine reads the SMPS ascii file and plots daily aerosol conc. %
%values for a quick look. It saves a .mat with read data.             %
%                                                                     %
%Latest changes:                                                      %
%Corrected according to an independent CPC
%                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='SMPS_71331078sn_CPC_71025292sn/';

disp('SMPS 3082')

%-------------------------------


if exist('mat-files/SMPS_TSI_3082.mat')>0
  load mat-files/SMPS_TSI_3082.mat
  count_rem=0;
  clear rem_idx
  fl=dir([fl_dir,'*SMPS*.txt']);
  
  for i=1:max(size(fl_old))
    for j=1:max(size(fl))
      if strcmp(fl(j).name,fl_old(i).name)
        if fl(j).bytes==fl_old(i).bytes
          count_rem=count_rem+1;
          rem_idx(count_rem)=j;
        end;
      end;
    end;
  end;
  
  fl(rem_idx)=[];
  
  fl_old=[fl_old;fl];
  
else
  fl=dir([fl_dir,'*SMPS*.txt']);
  count=0;
  count_old=1;
  distr_part=[];
  fl_old=fl;
end;


if size(fl,1)==0 && count==0
  return
elseif min(size(fl))>0
  for fl_number=1:max(size(fl))

    fname=[fl_dir,fl(fl_number).name];
    disp([num2str(fl_number) ' / ' num2str(numel(fl)) ' = ' fname]);
        
    fid = fopen(fname);
        
    total_lines=0;
    while ~feof(fid)
      TextLine = fgetl(fid);
      total_lines=total_lines+1;
      n_delimiters=0;
      idx_delimiter=[];
      size_text=max(size(TextLine));
      k=2;
      while k<size_text
        if strcmp(TextLine(k),';')
          n_delimiters=n_delimiters+1;
          idx_delimiter(n_delimiters)=k;
        end;
        k=k+1;
      end
      idx_delimiter(n_delimiters+1)=size_text;
      
      if (n_delimiters==224 || n_delimiters==225) 
        if strcmp(TextLine(1:6),'Sample')
          for j=70:177
            size_part(j-69)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
          end;
        else
          
          dummy_distr_part=zeros(1,108);
          for j=70:177
            if idx_delimiter(j+1)>idx_delimiter(j)+1
              dummy_distr_part(j-69)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
            end;
          end;
          
          dummy_mean_Dpg=str2num(TextLine(idx_delimiter(220)+1:idx_delimiter(221)-1));
          dummy_SMPS_TSI_CPC=str2num(TextLine(idx_delimiter(224)+1:idx_delimiter(225)-1));
          %dummy_day=str2num((TextLine(idx_delimiter(1)+1:idx_delimiter(1)+2)));
          %dummy_month=str2num((TextLine(idx_delimiter(1)+4:idx_delimiter(1)+5)));
          %dummy_year=str2num((TextLine(idx_delimiter(1)+7:idx_delimiter(2)-1)));
          %dummy_hour=str2num((TextLine(idx_delimiter(2)+1:idx_delimiter(2)+2)));
          %dummy_minute=str2num((TextLine(idx_delimiter(2)+4:idx_delimiter(2)+5)));
          %dummy_sec=str2num((TextLine(idx_delimiter(2)+7:idx_delimiter(2)+8)));
          dummy_month=str2num((TextLine(idx_delimiter(1)+1:idx_delimiter(1)+2)));
          dummy_day=str2num((TextLine(idx_delimiter(1)+4:idx_delimiter(1)+5)));
          dummy_year=str2num((TextLine(idx_delimiter(1)+7:idx_delimiter(2)-1)))+2000;
          dummy_hour=str2num((TextLine(idx_delimiter(2)+1:idx_delimiter(2)+2)));
          dummy_minute=str2num((TextLine(idx_delimiter(2)+4:idx_delimiter(2)+5)));
          dummy_sec=str2num((TextLine(idx_delimiter(2)+7:idx_delimiter(2)+8)));
          
          
          if max(size(dummy_distr_part))==108 && max(size(dummy_mean_Dpg))==1  && max(size(dummy_SMPS_TSI_CPC))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
            count=count+1; 
            mean_DPg(count)=dummy_mean_Dpg;
            SMPS_TSI_CPC(count)=dummy_SMPS_TSI_CPC;
            distr_part=[distr_part dummy_distr_part'];
            time_SMPS_TSI(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
            if time_SMPS_TSI(count)>(now+4) || time_SMPS_TSI(count)< datenum(2014,06,01) || SMPS_TSI_CPC(count)<30 || SMPS_TSI_CPC(count)>3e5
              count=count-1;
              distr_part(:,end)=[];
              SMPS_TSI_CPC(end)=[];
              mean_DPg(end)=[];
              time_SMPS_TSI(end)=[];
            end;
          end;
        end   
      end
    end;
    status=fclose(fid);
  end;
end;
%--------------------------------

distr_part=Vert(distr_part)';


[time_SMPS_TSI,idx]=unique(time_SMPS_TSI);
distr_part=distr_part(:,idx);
SMPS_TSI_CPC=SMPS_TSI_CPC(idx);
mean_DPg=mean_DPg(idx);


Readme_SMPS_3082='Data from TSI SMPS 3082. Data filtered for reasonable time strings and limited to maximum of 300 000 #/cm3 and minumum of 50 cm-3 aerosol concentration. Size distribution is corrected by a 0.63 according to an independent CPC.';


label_mean_DPg=('Average particle diameter (m)');


label_SMPS_TSI_CPC=('Particle concentration (#/cm^3)');
label_SMPS_TSI_TEOM=('Particle mass concentration (\mug m^{-3})');
label_SMPS_TSI_surf=('Particle surface (cm^2)');

title_SMPS_TSI_CPC=('SMPS TSI 3082');
title_SMPS_TSI_TEOM=title_SMPS_TSI_CPC;
title_SMPS_TSI_surf=title_SMPS_TSI_CPC;
title_mean_DPg=title_SMPS_TSI_CPC;

size_part=size_part./1e7; %Now in cm

calc_SMPS_TSI_CPC=zeros(1,size(distr_part,2));


factor=0.6413; %From comparison between CPC and SMPS

distr_part=distr_part./factor;


for i=1:max(size(time_SMPS_TSI))
  for j=1:size(distr_part,1)-1
    calc_SMPS_TSI_CPC(i)=calc_SMPS_TSI_CPC(i)+distr_part(j,i).*log10(size_part(j+1)/size_part(j));
  end;
end;

clear surf_part vol_part
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

SMPS_TSI_TEOM=1.7.*SMPS_TSI_TEOM./1.2; %Changing average density from 1.2 to 1.7 g cm-3

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
%ylim([0 5e4])
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Aerosol_Number_SMPS_TSI_3082_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);

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
ylim([0 50])
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/SMPS_3082_Mass_' mydir '_Time_series'];
print(fig1,'-dpng',[nome,'.png']);


%Plot each day

days_SMPS_TSI=unique(floor(time_SMPS_TSI));

count_days=0;
if exist('days_SMPS_TSI_OK','var')==1
    if min(size(days_SMPS_TSI_OK))>0
        days_SMPS_TSI_OK=unique(days_SMPS_TSI_OK);
        for i=1:max(size(days_SMPS_TSI))
            if max(days_SMPS_TSI(i)==days_SMPS_TSI_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_SMPS_TSI(rem_days)=[];
    end;
else
    days_SMPS_TSI_OK=[];
end;

if min(size(days_SMPS_TSI))>0
    for i=1:max(size(days_SMPS_TSI))

             if days_SMPS_TSI(i)<=datenum(2014,04,01)
                fig_name=['fig/IOP1/Aerosol_Number_SMPS_TSI_3082_',mydir,'_',datestr(days_SMPS_TSI(i),29)];
            elseif days_SMPS_TSI(i)>datenum(2014,04,01) && days_SMPS_TSI(i)<datenum(2014,08,15)
                fig_name=['fig/April_to_Aug_2014/Aerosol_Number_SMPS_TSI_3082_',mydir,'_',datestr(days_SMPS_TSI(i),29)];
            elseif days_SMPS_TSI(i)>=datenum(2014,08,15) && days_SMPS_TSI(i)<=datenum(2014,10,15)
                fig_name=['fig/IOP2/Aerosol_Number_SMPS_TSI_3082_',mydir,'_',datestr(days_SMPS_TSI(i),29)];
             end


        clear fig1;



        quick_time_SMPS_TSI=(time_SMPS_TSI-days_SMPS_TSI(i)).*24;


        [diff_st,idx_st]=min(abs(quick_time_SMPS_TSI));
        [diff_end,idx_end]=min(abs(quick_time_SMPS_TSI - 24));


        if diff_st<1/24 && diff_end<1/24
            days_SMPS_TSI_OK=[days_SMPS_TSI_OK days_SMPS_TSI];
        end;

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
            print(fig1,'-dpng',[nome,'.png']);


        end;
    end;
end;


save mat-files/SMPS_TSI_3082.mat

%
%if isunix
%    fid = fopen('0_Ascii-files/SMPS_TSI_3082.csv','wt');
%
%    fprintf(fid,['Date(UTC),Number concentration (cm-3), Mass concentration (ugm-3), Median Diameter(nm),', repmat('%2.1f, ', 1, size(size_part, 2)) '\n'],size_part);
%
%    for i=1:max(size(time_SMPS_TSI))
%        fprintf(fid,['%s, %2.1f, %2.2f,', repmat('%2.1f, ', 1, size(size_part, 2)) '\n'],datestr(time_SMPS_TSI(i)),SMPS_TSI_CPC(i),SMPS_TSI_TEOM(i),distr_part(:,i));
%    end;
%    fclose(fid);
%
%    !chmod 777 0_Ascii-files/SMPS_TSI_3082.csv
%    !rm -f mat-files/SMPS_TSI_3082.mat
%end
%%