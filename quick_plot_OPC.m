%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the OPC  ascii file and plots daily values for a %
%a quick look. It saves a .mat with read data.                       %
%                                                                    %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clear
clc
close all
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='OPCGrimm/';

disp('OPC')

%-------------------------------

if exist('mat-files/OPC.mat')>0
    load mat-files/OPC.mat
    count_rem=0;
    fl=dir([fl_dir,'*opc*']);
    if isunix
        fl=[fl;dir([fl_dir,'*OPC*'])];
    end;
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
    fl=dir([fl_dir,'*opc*']);
    if isunix
        fl=[fl;dir([fl_dir,'*OPC*'])];
    end;
    count=0;
    count_old=1;
    time_OPC_avg=[];
    OPC_total_avg=[];
    OPC_coarse_avg=[];
    fl_old=fl;
end;



if size(fl,1)==0 && count==0

    return
elseif min(size(fl))>0

    for fl_number=1:max(size(fl))

        fid = fopen([fl_dir,fl(fl_number).name]);
        total_lines=0;
        TextLine = fgetl(fid);
        time_flag=0;
        while ~feof(fid)
            total_lines=total_lines+1;
            n_delimiters=0;
            size_text=max(size(TextLine));
            i=2;

            while i<size_text
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
            
            if n_delimiters==16 && strcmp(TextLine(1:idx_delimiter(1)-1),'P')
                
                dummy_month=str2num((TextLine(idx_delimiter(2)+1:idx_delimiter(3)-1)));
                dummy_day=str2num((TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1)));
                dummy_year=str2num((TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1)))+2000;
                dummy_hour=str2num((TextLine(idx_delimiter(4)+1:idx_delimiter(5)-1)));
                dummy_minute=str2num((TextLine(idx_delimiter(5)+1:idx_delimiter(6)-1)));
                dummy_sec=str2num((TextLine(idx_delimiter(6)+1:idx_delimiter(7)-1)));
                
                if max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                   dummy_time_OPC=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                end;
                time_flag=1;
            end;
            
            if n_delimiters==8 && time_flag==1  && (strcmp(TextLine(1),'C') || strcmp(TextLine(1),'c')) 

                if strcmp(TextLine(3),':') && strcmp(TextLine(1),'C')
                    for j=1:7
                        dummy_dist(str2num(TextLine(2))+1,j)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
                    end;
                    dummy_dist(str2num(TextLine(2))+1,8)=str2num(TextLine(idx_delimiter(8)+1:end));
                elseif strcmp(TextLine(3),';') && strcmp(TextLine(1),'C')
                     for j=1:7
                        dummy_dist(str2num(TextLine(2))+1,j+8)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
                    end;
                    dummy_dist(str2num(TextLine(2))+1,16)=str2num(TextLine(idx_delimiter(8)+1:end));
                elseif strcmp(TextLine(3),':') && strcmp(TextLine(1),'c')
                     for j=1:7
                        dummy_dist(str2num(TextLine(2))+1,j+16)=str2num(TextLine(idx_delimiter(j)+1:idx_delimiter(j+1)-1));
                    end;
                    dummy_dist(str2num(TextLine(2))+1,24)=str2num(TextLine(idx_delimiter(8)+1:end));
                end;
                    
                if strcmp(TextLine(1:3),'c9;')
                    count=count+1; 
                    distr_part_OPC(count,:)=mean(dummy_dist);
                    time_OPC(count)=dummy_time_OPC;
                    time_flag=0;
                end;
            end;            
        
              
            % get next line of text
            TextLine = fgetl(fid);

        end;
        status=fclose(fid);
    end;
end;
    %--------------------------------


    
[time_OPC,idx]=unique(time_OPC);
distr_part_OPC=distr_part_OPC(idx,:);

size_part_OPC= [0.25 0.28 0.3 0.35 0.4 0.45 0.5 0.58 0.65 0.7 0.8 1 1.3 1.6 2 2.5 3 3.5 4 5 6.5 7.5 8.5 10];

OPC_total=distr_part_OPC(:,1);
OPC_coarse=distr_part_OPC(:,15);

%{
for i=1:max(size(size_part_OPC))-1
    distr_part_OPC(i,:)=distr_part_OPC(i,:)-distr_part_OPC(i+1,:);
    distr_part_OPC(i,:)=distr_part_OPC(i,:)./log10(size_part_OPC(i+1)./size_part_OPC(i));
end;
%}

label_OPC=('Particle concentration (#/cm^3)');
title_OPC=('OPC Grimm particle count');


while count_old < count
    S=0;
    D=0;
    i=1;
    while S<300 && D<1 && (count_old+i)<max(size(time_OPC))
        [D, S] = DateDiff(time_OPC(count_old),time_OPC(count_old+i));
        i=i+1;
    end;
    if i>3
        time_OPC_avg=[time_OPC_avg (time_OPC(count_old)+time_OPC(i+count_old))/2];
        OPC_total_avg=[OPC_total_avg mean(OPC_total(count_old:count_old+i))];
        OPC_coarse_avg=[OPC_coarse_avg mean(OPC_coarse(count_old:count_old+i))];
    end;
    count_old=count_old+i+1;
end;



fig1 = figure('visible','off');
set(fig1,'InvertHardcopy','on');
set(gca, 'FontSize', 12, 'LineWidth', 2); 

plot(time_OPC,OPC_total,'k*')
title(['OPC (Grimm)',station])
xlabel('Date')
ylabel(label_OPC)
ylim([0 300])
box on
dynamicDateTicks([], [], 'dd/mm');

set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
nome=['fig/OPC_' mydir '_Time_series']
print(fig1,'-depsc',[nome,'.eps']);
eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
eval(['delete ',nome,'.eps'])

%Plot each day

days_OPC=unique(floor(time_OPC));

count_days=0;
if exist('days_OPC_OK','var')==1
    if min(size(days_OPC_OK))>0
        days_OPC_OK=unique(days_OPC_OK);
        for i=1:max(size(days_OPC))
            if max(days_OPC(i)==days_OPC_OK)>0
                count_days=count_days+1;
                rem_days(count_days)=i;
            end;
        end;
        days_OPC(rem_days)=[];
    end;
else
    days_OPC_OK=[];
end;


if min(size(days_OPC))>0
    for i=1:max(size(days_OPC))

         if days_OPC(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/OPC_',mydir,'_',datestr(days_OPC(i),29)];
        elseif days_OPC(i)>datenum(2014,04,01) && days_OPC(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/OPC_',mydir,'_',datestr(days_OPC(i),29)];
        elseif days_OPC(i)>=datenum(2014,08,15) && days_OPC(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/OPC_',mydir,'_',datestr(days_OPC(i),29)];
         end

        clear fig1;

        quick_time_OPC=(time_OPC-days_OPC(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_OPC));
        [diff_end,idx_end]=min(abs(quick_time_OPC - 24));


        if diff_st<1/24 && diff_end<1/24
            days_OPC_OK=[days_OPC_OK days_OPC];
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
            rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
            plot(quick_time_OPC(idx_st:idx_end),OPC_total(idx_st:idx_end),'k*')
            ylim(axes1,[min(OPC_total(idx_st:idx_end)) max(OPC_total(idx_st:idx_end))])
            xlim(axes1,[0 24])

            title(['OPC (Grimm)',station,' - ',datestr(days_OPC(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_OPC)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

            print(fig1,'-depsc',[fig_name,'.eps']);
            eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])
            eval(['delete ',fig_name,'.eps '])

        end;
    end;
end;

fid = fopen('0_Ascii-files/OPC.csv','wt');
fprintf(fid,'Date(UTC), OPC total concentration (cm-3), OPC coarse concentration (cm-3)\n');
for i=1:max(size(time_OPC_avg))
    fprintf(fid,'%s, %2.2f, %2.2f\n',datestr(time_OPC_avg(i)),OPC_total_avg(i),OPC_coarse_avg(i));
end;
fclose(fid);


!rm -f mat-files/OPC.mat
save mat-files/OPC.mat
