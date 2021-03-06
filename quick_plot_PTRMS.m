%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 17/Aug/2014                                 %
%                                                                    %
%This routine reads the CPC ascii file and plots daily aerosol conc. %
%values for a quick look. It saves a .mat with read data.            %
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

disp('PTRMS')

%-------------------------------

if exist('mat-files/PTRMS.mat')>0
    load mat-files/PTRMS.mat
    count_rem=0;
    fl_dir='PTRMS/raw/';
    clear rem_idx
    fl=dir([fl_dir,'Data__2014_08_*_1.tdms']);
    fl=[fl;dir([fl_dir,'Data__2014_09_*_1.tdms'])];
    fl=[fl;dir([fl_dir,'Data__2014_10_*_1.tdms'])];
    fl=[fl;dir([fl_dir,'Data__2014_08_*_2.tdms'])];
    fl=[fl;dir([fl_dir,'Data__2014_09_*_2.tdms'])];
    fl=[fl;dir([fl_dir,'Data__2014_10_*_2.tdms'])];


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
    fl_dir='PTRMS/raw/';
    fl=dir([fl_dir,'Data__2014_08_*.tdms']);
    fl=[fl;dir([fl_dir,'Data__2014_09_*.tdms'])];
    fl=[fl;dir([fl_dir,'Data__2014_10_*.tdms'])];
    count=0;
    count_old=1;
    cps=[];
    DO=[];
    fl_old=fl;
    time_cps=[];
    time_BG=[];
    time_Cal=[];
    Cal=[];
    BG=[];
end;



if size(fl,1)==0 && count==0
    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))
        [ConvertedData,ConvertVer,ChanNames]=convertTDMS(false,[fl_dir,fl(fl_number).name]);
        if size(ChanNames{1,1},1)>115 && count==0
            header_cps=ConvertedData.Data.MeasuredData(1,3).Data';
            cps=ones(1,max(size(header_cps)));
            DO=ones(1,8);

        end;
        
        clear dummy
        clear dummy_DO
        
        check_DO=0;
        for j=1:max(size(ConvertedData.Data.MeasuredData))
            if strcmp(ConvertedData.Data.MeasuredData(1,j).Name,'Time / Cycle/Abs Time [sec]')
                time_cps = [time_cps ; (ConvertedData.Data.MeasuredData(1,j).Data./(24*60*60)+ datenum(1904,1,1,0,0,0))];
            end;

            if max(size(ConvertedData.Data.MeasuredData(1,j).Name))==12
                dummy_name=ConvertedData.Data.MeasuredData(1,j).Name;
                if strcmp(dummy_name(1:11),'Misc/X1 DO ')
                    dummy_size=ConvertedData.Data.MeasuredData(1,j).Total_Samples;
                    dummy_channel=str2num(dummy_name(12));
                    dummy_DO(:,dummy_channel)=ConvertedData.Data.MeasuredData(1,j).Data(1:dummy_size);
                    check_DO=1;
                end;
            end;
            if max(size(ConvertedData.Data.MeasuredData(1,j).Name))>24
                if strcmp(ConvertedData.Data.MeasuredData(1,j).Name(1:24),'Raw signal intensities/m')
                    for k=1:max(size(header_cps))
                        dummy_header=num2str(header_cps(k));
                        if strcmp(ConvertedData.Data.MeasuredData(1,j).Name(25:25+max(size(dummy_header))-1),dummy_header)
                            dummy(:,k)=ConvertedData.Data.MeasuredData(1,j).Data;
                        end;
                    end;
                end;
            end;
        end;
        
        if size(dummy,2)==31
            count=count+size(cps,1);
            cps = [cps ; dummy];
            DO = [DO ; dummy_DO];        
        end;
    end;
end;
    %--------------------------------

    
[time_cps,idx]=unique(time_cps);
cps=cps(idx,:);
DO=DO(idx,:);

cps(time_cps==0,:)=[];
DO(time_cps==0,:)=[];
time_cps(time_cps==0)=[];

Readme_PTRMS='Data from PTR-MS. Data filtered for OFR cycles.';

label_21='Primary ion (cps)';
label_28='m/z 28             ';
label_30='NO+ (cps)';
label_31='Formaldehyde       ';
label_32='O2+ (cps)';
label_33='Methanol           ';
label_37='H3O+(H2O) (cps)';
label_42='Acetonitrile       ';
label_45='Acetaldehyde       ';
label_45='Acetaldehyde       ';
label_46='m/z 46             ';
label_47='Ethanol/Formic Acid';
label_57='m/z 57             ';
label_59='Acetone            ';
label_60='m/z 60             ';
label_61='Acetic Acid        ';
label_63='DMS                ';
label_69='Isoprene           ';
label_71='MVK + MACR         ';
label_73='MEK                ';
label_77='PAN                ';
label_79='Benzene            ';
label_81='Monoterpenes       ';
label_83='eighty-three       ';
label_89='m/z 89             ';
label_93='Toluene            ';
label_95='m/z 95             ';
label_105='m/z 105            ';
label_107='C8 Aromatics       ';
label_121='m/z 121            ';
label_125='one-two-five       ';
label_129='C9 Aromatics       ';
label_137='Monoterpenes       ';
label_205='Sesquiterpenes     ';

vocs=cps;
time_PTRMS=time_cps;

header=header_cps;
header_BG=header_cps;
header_Cal=header_cps;

time_BG=time_PTRMS(DO(:,1)==1 & DO(:,4)==1 & DO(:,5)==1);
BG=vocs(DO(:,1)==1 & DO(:,4)==1 & DO(:,5)==1,:);

time_Cal=time_PTRMS(DO(:,1)==1 & DO(:,2)==1 & DO(:,3)==1 & DO(:,5)==1);
Cal=vocs(DO(:,1)==1 & DO(:,2)==1 & DO(:,3)==1 & DO(:,5)==1,:);

time_PTRMS(DO(:,1)==1)=[];
vocs(DO(:,1)==1,:)=[];




k=1;
for i=1:size(header,2);
    if header(i)==21
        Prim=vocs(:,i);
        if mean(Prim)<1e6
            Prim=Prim.*500;
        end;
        idx_remove(k)=i;
        k=k+1;
    elseif header(i)==25
        idx_remove(k)=i;
        k=k+1;
    elseif header(i)==30
        m30=vocs(:,i);
        idx_remove(k)=i;
        k=k+1;
    elseif header(i)==32
        m32=vocs(:,i);
        idx_remove(k)=i;
        k=k+1;
    elseif header(i)==37
        m37=vocs(:,i);
        idx_remove(k)=i;
        k=k+1;
    end;
end;


%Remove primary and products
if k>1 
    vocs(:,idx_remove)=[];
    header(idx_remove)=[];
end;

%Correct for fluctuations in primary
for i=1:size(vocs,1)
    vocs(i,1:end)=vocs(i,1:end).*mean(Prim)./Prim(i);
end;

%Retrieve VOC index
for i=1:max(size(header))
    eval(['Idx',num2str(header(i)),'=i;']);
    eval(['title_',num2str(header(i)),'=label_',num2str(header(i)),';']);
end;


title_PTRMS='VOCs';
label_PTRMS='Mixing ratio (ppbv)';

%--------------------------------------------------------
%Here it loads and applies the BG corrections
BG_PTRMS 
%Ignore BG for now

%--------------------------------------------------------
%Here it loads and applies the Cal corrections
Cal_PTRMS


if exist('mat-files/flag_OFR.mat')
    load mat-files/flag_OFR.mat
   
    count_OFR=0;
    clear idx_PTRMS_OFR
    if min(size(time_OFR))>0
        for i=1:max(size(time_OFR))
            [diff,idx]=min(abs(time_PTRMS-time_OFR(i)));
            [a,idx_end]=min(abs(time_PTRMS-(time_OFR(i)+3./(24.*60))));
            if diff<1./(60.*24) && valve_status(i)==1
              count_OFR=count_OFR+1;
              idx_PTRMS_OFR(count_OFR)=idx;
              count_OFR=count_OFR+1;
              idx_PTRMS_OFR(count_OFR)=idx_end;
            end;
        end

        if count_OFR>0
            idx_PTRMS_OFR=unique(idx_PTRMS_OFR);
            vocs_OFR=vocs(idx_PTRMS_OFR,:);
            time_PTRMS_OFR=time_PTRMS(idx_PTRMS_OFR);
            count=count-max(size(time_PTRMS(idx_PTRMS_OFR)));
            vocs(idx_PTRMS_OFR,:)=[];
            time_PTRMS(idx_PTRMS_OFR)=[];
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

plot(time_PTRMS,vocs(:,Idx69),'g')
hold on
plot(time_PTRMS,vocs(:,Idx71),'r')
plot(time_PTRMS,vocs(:,Idx79),'k')
plot(time_PTRMS,vocs(:,Idx93),'y')
title([title_PTRMS,station])
legend('Isoprene','MVK+MACR','Benzene','Toluene')
xlabel('Date')
ylabel(label_PTRMS)
ylim([0 25])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/PTRMS_' mydir '_Time_series'];

if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;

%Plot each day

days_PTRMS=unique(floor(time_PTRMS));

count_days=0;
if exist('days_PTRMS_OK','var')==1
    if min(size(days_PTRMS_OK))>0
        days_PTRMS_OK=unique(days_PTRMS_OK);
        for i=1:max(size(days_PTRMS))
            if max(days_PTRMS(i)==days_PTRMS_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_PTRMS(rem_days)=[];
    end;
else
    days_PTRMS_OK=[];
end;

if min(size(days_PTRMS))>0
    for i=1:max(size(days_PTRMS))

         if days_PTRMS(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/PTRMS_',mydir,'_',datestr(days_PTRMS(i),29)];
        elseif days_PTRMS(i)>datenum(2014,04,01) && days_PTRMS(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/PTRMS_',mydir,'_',datestr(days_PTRMS(i),29)];
        elseif days_PTRMS(i)>=datenum(2014,08,15) && days_PTRMS(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/PTRMS_',mydir,'_',datestr(days_PTRMS(i),29)];
         end

        clear fig1;

        quick_time_PTRMS=(time_PTRMS-days_PTRMS(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_PTRMS));
        [diff_end,idx_end]=min(abs(quick_time_PTRMS - 24));


        if diff_st<1/24 && diff_end<1/24
            days_PTRMS_OK=[days_PTRMS_OK days_PTRMS];
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
            rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),200000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])

            plot(quick_time_PTRMS(idx_st:idx_end),vocs(idx_st:idx_end,Idx69),'g')
            plot(quick_time_PTRMS(idx_st:idx_end),vocs(idx_st:idx_end,Idx71),'r')
            plot(quick_time_PTRMS(idx_st:idx_end),vocs(idx_st:idx_end,Idx79),'k')
            plot(quick_time_PTRMS(idx_st:idx_end),vocs(idx_st:idx_end,Idx93),'y')
            legend('Isoprene','MVK+MACR','Benzene','Toluene')
            
            
            ylim(axes1,[0 nanmax(nanmax([vocs(idx_st:idx_end,Idx69) vocs(idx_st:idx_end,Idx71) vocs(idx_st:idx_end,Idx79) vocs(idx_st:idx_end,Idx93)]))])
            xlim(axes1,[0 24])

            title([title_PTRMS,station,' - ',datestr(days_PTRMS(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_PTRMS)
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



if isunix

    %CHECK WHAT TO WRITE IN THE ASCII FILE!!
    %{
    fid = fopen('0_Ascii-files/PTRMS.csv','wt');
    fprintf(fid,'Date(UTC), Number concentration (ug m-3)\n');
    for i=1:max(size(time_PTRMS_avg))
        fprintf(fid,'%s, %2.2f\n',datestr(time_PTRMS_avg(i)),CPC_avg(i));
    end;
    fclose(fid);
%}
    !chmod 777 0_Ascii-files/PTRMS.csv
    !rm -f mat-files/PTRMS.mat
end;



save mat-files/PTRMS.mat

if isunix
    !chmod 777 mat-files/PTRMS.mat
end