%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the Neph Aurora ascii file and plots daily values%
% for a quick look. It saves a .mat with read data.                  %
%                                                                    %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all
[tmp,mydir]=fileparts(pwd);

if strcmp(mydir,'A_T2')
    station=' - T2 (Tiwa)';
else
    station=[' - ' mydir];    
end;


disp('Ecotech Aurora')

%-------------------------------

if exist('mat-files/Neph_Aurora.mat')>0
    load mat-files/Neph_Aurora.mat
    fl_dir='Ecotech_Aurora3000/raw/';
    count_rem=0;
    clear rem_idx
    fl=dir([fl_dir,'*Aurora*.txt']);
    fl=[fl;dir([fl_dir,'*NEPH*.txt'])]
    
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

    if count_rem>0
        fl(rem_idx)=[];
        fl_old=[fl_old;fl];
    end;

else
    fl_dir='Ecotech_Aurora3000/raw/';
    fl=dir([fl_dir,'*Aurora*.txt']);
    fl=[fl;dir([fl_dir,'*NEPH*.txt'])];
    count=0;
    count_old=1;
    time_Neph_avg=[];
    Neph_avg=[];
    fl_old=fl;
end;




if size(fl,1)==0 && count==0

    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);
        total_lines=0;
        while ~feof(fid)
            TextLine = fgetl(fid);
            total_lines=total_lines+1;
            delimiters=0;
            size_text=max(size(TextLine));
            i=2;
            if max(size(fl(fl_number).name))>15
                while i<size_text
                    if strcmp(TextLine(i),',')
                            delimiters=delimiters+1;
                            idx_delimiter(delimiters)=i;
                    end
                    i=i+1;
                end


                if delimiters==11
                    dummy_Scatt_1=str2num(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1));
                    dummy_Scatt_2=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
                    dummy_Scatt_3=str2num(TextLine(idx_delimiter(4)+1:idx_delimiter(5)-1));

                    dummy_BScatt_1=str2num(TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1));
                    dummy_BScatt_2=str2num(TextLine(idx_delimiter(6)+1:idx_delimiter(7)-1));
                    dummy_BScatt_3=str2num(TextLine(idx_delimiter(7)+1:idx_delimiter(8)-1));

                    dummy_Status=strcmp(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1),'1 min instant');

                     try
                        dummy_time=datenum(TextLine(1:idx_delimiter(1)-1),'dd/mm/yyyy HH:MM:SS');
                        time_error=0;
                    catch error_message
                        time_error=1;
                     end

                    if max(size(dummy_Scatt_1))==1 && time_error==0 && dummy_Status==1
                        count=count+1;  
                        Scatt(count,:)=[dummy_Scatt_1;dummy_Scatt_2;dummy_Scatt_3];
                        BScatt(count,:)=[dummy_BScatt_1;dummy_BScatt_2;dummy_BScatt_3];
                        time_Neph(count)=dummy_time;
                        if time_Neph(count)<datenum(2014,02,01) || Scatt(count,1)<-5 || Scatt(count,1)>500
                            count=count-1;
                            Scatt(end,:)=[];
                            BScatt(end,:)=[];
                            time_Neph(end)=[];
                        end;
                    end;
                else
                    test=0;
                end;


                if delimiters==8
                    dummy_Scatt_1=str2num(TextLine(idx_delimiter(6)+1:idx_delimiter(7)-1));
                    dummy_Scatt_2=str2num(TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1));
                    dummy_Scatt_3=str2num(TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1));

                    dummy_BScatt_1=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
                    dummy_BScatt_2=str2num(TextLine(idx_delimiter(7)+1:idx_delimiter(8)-1));
                    dummy_BScatt_3=str2num(TextLine(idx_delimiter(8)+1:end));

                    dummy_Status=strcmp(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1),'1 min instant');

                    try
                        dummy_time=datenum(TextLine(1:idx_delimiter(1)-1),'dd/mm/yyyy HH:MM:SS');
                        time_error=0;
                    catch error_message
                        time_error=1;
                    end

                    if max(size(dummy_Scatt_1))==1 && time_error==0 && dummy_Status==1
                        count=count+1;  
                        Scatt(count,:)=[dummy_Scatt_1;dummy_Scatt_2;dummy_Scatt_3];
                        BScatt(count,:)=[dummy_BScatt_1;dummy_BScatt_2;dummy_BScatt_3];
                        time_Neph(count)=dummy_time;
                        if time_Neph(count)<datenum(2014,02,01) || Scatt(count,1)<-5 || Scatt(count,1)>500
                            count=count-1;
                            Scatt(end,:)=[];
                            BScatt(end,:)=[];
                            time_Neph(end)=[];
                        end;
                    end;
                end
            end;
        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------

[time_Neph,idx_sort]=unique(time_Neph);
Scatt=Scatt(idx_sort,:);
BScatt=BScatt(idx_sort,:);
  

Readme_Neph='Data from Nephelometer Ecotech Aurora 3000. Data filtered for reasonable time strings and limited to maximum of 500Mm-1 and minimum of -5Mm-1.';


label_Scatt='Aerosol light scattering (Mm^{-1})';
title_Scatt='Ecotech Aurora 3000 - PM2.5';


if exist('mat-files/Troca_silica.mat')
    load mat-files/Troca_silica.mat
    for i=1:max(size(time_Silica_st));
        count=count-max(size(time_Neph(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i))));
        Scatt(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
        BScatt(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
        time_Neph(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i))=[];
    end;
end;
  

%{
%Fine method for extracting Neph-OFR data
if exist('mat-files/OFR.mat')
    load mat-files/OFR.mat
    count_OFR=0;
    clear idx_OFR
    count_rem=0;
    clear idx_rem
    for i=1:max(size(time_Neph))
        [a,idx_end]=min(abs(time_OFR-time_Neph(i)));
        [a,idx_st]=min(abs(time_OFR-(time_Neph(i)-2./(24*60))));

        if a<1/(24*60)
            if valve_status(idx_st)==valve_status(idx_end)
                if valve_status(idx_st)==1
                    count_OFR=count_OFR+1;
                    idx_OFR(count_OFR)=i;
                end
            else
                count_rem=count_rem+1;
                idx_rem(count_rem)=i;
            end;
        end
    end;
    
    if count_rem+count_OFR>0
        Scatt_OFR=[Scatt_OFR Scatt(idx_OFR,:)];
        time_Neph_OFR=[time_Neph_OFR time_Neph(idx_OFR)];
        
        count=count-max(size(time_Neph([idx_OFR idx_rem])));
        time_Neph([idx_OFR idx_rem])=[];
        Scatt([idx_OFR idx_rem],:)=[];
    end;
end;
%}  

if exist('mat-files/flag_OFR.mat')
    load mat-files/flag_OFR.mat
    if exist('time_OFR_old','var')
        [C,idx_old,idx_new]=intersect(time_OFR_old,time_OFR);
        valve_status(idx_new)=[];
        time_OFR(idx_new)=[];
    end;
    
    count_OFR=0;
    clear idx_Neph_OFR
    if min(size(time_OFR))>0
        for i=1:max(size(time_OFR))
            [diff,idx]=min(abs(time_Neph-time_OFR(i)));
            [a,idx_end]=min(abs(time_Neph-(time_OFR(i)+3./(24.*60))));
            if diff<1./(60.*24) && valve_status(i)==1
              count_OFR=count_OFR+1;
              idx_Neph_OFR(count_OFR)=idx;
              count_OFR=count_OFR+1;
              idx_Neph_OFR(count_OFR)=idx_end;
            end;
        end

        if count_OFR>0
        idx_Neph_OFR=unique(idx_Neph_OFR);
            Scatt_OFR=Scatt(idx_Neph_OFR,:);
            time_Neph_OFR=time_Neph(idx_Neph_OFR);
            count=count-max(size(time_Neph(idx_Neph_OFR)));
            Scatt(idx_Neph_OFR,:)=[];
            time_Neph(idx_Neph_OFR)=[];

            time_OFR_old=time_OFR;
        end;
    end;
end





if isunix
    fig1 = figure('visible','off');
else
    fig1=figure;
end;
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 
plot(time_Neph(time_Neph>datenum(2014,02,01)),Scatt(time_Neph>datenum(2014,02,01),1))
hold on
plot(time_Neph(time_Neph>datenum(2014,02,01)),Scatt(time_Neph>datenum(2014,02,01),2),'g')
plot(time_Neph(time_Neph>datenum(2014,02,01)),Scatt(time_Neph>datenum(2014,02,01),3),'r')
title([title_Scatt,station])
xlabel('Date')
ylabel(label_Scatt)
ylim([0 200])
box on
dynamicDateTicks([], [], 'dd/mm');
set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/Scattering_Aurora_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;
%Plot each day

days_Neph=unique(floor(time_Neph));

count_days=0;
clear rem_days
if exist('days_Neph_OK','var')==1
    if min(size(days_Neph_OK))>0
        days_Neph_OK=unique(days_Neph_OK);
        for i=1:max(size(days_Neph))
            if max(days_Neph(i)==days_Neph_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_Neph(rem_days)=[];
    end;
else
    days_Neph_OK=[];
end;



if min(size(days_Neph))>0
    for i=1:max(size(days_Neph))

         if days_Neph(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/Neph_',mydir,'_',datestr(days_Neph(i),29)];
        elseif days_Neph(i)>datenum(2014,04,01) && days_Neph(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/Neph_',mydir,'_',datestr(days_Neph(i),29)];
        elseif days_Neph(i)>=datenum(2014,08,15) && days_Neph(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/Neph_',mydir,'_',datestr(days_Neph(i),29)];
        elseif days_Neph(i)>=datenum(2014,10,15) 
            fig_name=['fig/After_IOP2/Neph_',mydir,'_',datestr(days_Neph(i),29)];
         end

        clear fig1;

        quick_time_Neph=(time_Neph-days_Neph(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_Neph));
        [diff_end,idx_end]=min(abs(quick_time_Neph - 24));


        if diff_st<1/24 && diff_end<1/24
            days_Neph_OK=[days_Neph_OK days_Neph];
        end;

        %Calculate sunrise/sunset
        [rs,t,d,z,a,r]=suncycle(-3.07,60,i);

        rs=rs+8;

        if idx_end>idx_st+30


            if isunix
                fig1 = figure('visible','off');
            else
                fig1=figure;
            end;
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
            plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,1),'r')
            plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,2),'g')
            plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,3),'b')
            ylim(axes1,[0 max(Scatt(idx_st:idx_end,3))])
            xlim(axes1,[0 24])

            title(['Aerosol light scattering (Aurora)',station,' - ',datestr(days_Neph(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_Scatt)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

    
            if isunix
                print(fig1,'-depsc',[fig_name,'.eps']);
                eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])
                eval(['delete ',fig_name,'.eps '])
            else
                eval(['export_fig ',fig_name,' -png -transparent'])
            end;
        end;
    end;
end;

fid = fopen('0_Ascii-files/Neph_Aurora.csv','wt');
fprintf(fid,'Date(UTC),Scattering Blue (Mm-1), Scattering Green (Mm-1), Scattering Red, Back Scattering Blue (Mm-1), Back Scattering Green (Mm-1), Back Scattering Red (Mm-1)\n');
for i=1:max(size(time_Neph))
    fprintf(fid,'%s, %2.1f, %2.1f, %2.1f, %2.1f, %2.1f, %2.1f\n',datestr(time_Neph(i)),Scatt(i,1),Scatt(i,2),Scatt(i,3),BScatt(i,1),BScatt(i,2),BScatt(i,3));
end;
fclose(fid);


!rm -f mat-files/Neph_Aurora.mat
save mat-files/Neph_Aurora.mat
