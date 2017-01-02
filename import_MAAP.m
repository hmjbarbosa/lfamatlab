%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Written by Joel Brito - 14/Aug/2014                                 %
%                                                                    %
%This routine reads the MAAP ascii file and plots daily BC values    % 
% for a quick look. It saves a .mat with read data.                  %
%                                                                    %
%Latest changes:                                                     %
%To improve processing time now the routine reads the previous mat   %
%file (if existing) and imports only updated ascii files. The same is%
%valid for making new plots                                          %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function import_MAAP(MAAP_name)

    
    disp('MAAP')
    close all
    [tmp,mydir]=fileparts(pwd);
     if  strcmp(mydir,'Manacapuru')
        mydir='T3';
    elseif strcmp(mydir,'Tiwa')
        mydir='T2';
    end;
    
    if strcmp(mydir,'A_T2')
        station=' - T2 (Tiwa)';
    else
        station=[' - ' mydir];    
    end;

    
    if strcmp(MAAP_name,'')
       name='BC_MAAP';
       fl_dir='MAAP/raw/';
    else
        name=['BC_MAAP_',MAAP_name];
        fl_dir=['MAAP_',MAAP_name,'/raw/'];
    end;


    if exist(['mat-files/',name,'.mat'])>0
        eval(['load mat-files/',name,'.mat'])
        count_rem=0;
        clear rem_idx
        fl=dir([fl_dir,'MAAP*.*']);
        if isunix
            fl=[fl;dir([fl_dir,'maap*.*'])];
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
        
        fl=dir([fl_dir,'MAAP*.*']);
        if isunix
            fl=[fl;dir([fl_dir,'maap*.*'])];
        end;
        count=0;
        count_old=1;
        time_BC_avg=[];
        BC_avg=[];
        fl_old=fl;
    end;


    
    %-------------------------------

    if size(fl,1)==0 && count==0

        return
    elseif min(size(fl))>0
        
        for fl_number=1:max(size(fl))

            fid = fopen([fl_dir,fl(fl_number).name]);
            total_lines=0;

            while ~feof(fid)
                TextLine = fgetl(fid);
                total_lines=total_lines+1;
                spaces=0;
                size_text=max(size(TextLine));
                i=2;
                while i<size_text
                    if strcmp(TextLine(i),' ')
                        if strcmp(TextLine(i-1),' ') 
                            TextLine(i)=[];
                            size_text=size_text-1;
                            i=i-1;
                        else
                            spaces=spaces+1;
                            idx_space(spaces)=i;
                        end;
                    end
                    i=i+1;
                end

                if spaces==16   

                    dummy_BC_trans=str2num(TextLine(idx_space(16)+1:end));
                    dummy_BC=str2num(TextLine(idx_space(15)+1:idx_space(16)-1));
                    dummy_n_it=str2num(TextLine(idx_space(11)+1:idx_space(12)-1));
                    dummy_day=str2num(TextLine(7:8));
                    dummy_month=str2num(TextLine(4:5));
                    dummy_year=str2num(TextLine(1:2))+2000;
                    dummy_hour=str2num(TextLine(10:11));
                    dummy_minute=str2num(TextLine(13:14));
                    dummy_sec=str2num(TextLine(16:17));

                    if size(dummy_BC_trans,1)==1 && size(dummy_BC,1)==1 && size(dummy_n_it,1)==1 && size(dummy_day,1)==1 && size(dummy_month,1)==1 && size(dummy_year,1)==1 && size(dummy_hour,1)==1 && size(dummy_minute,1)==1 && size(dummy_sec,1)==1 && size(dummy_BC_trans,2)==1 && size(dummy_BC,2)==1 && size(dummy_n_it,2)==1 && size(dummy_day,2)==1 && size(dummy_month,2)==1 && size(dummy_year,2)==1 && size(dummy_hour,2)==1 && size(dummy_minute,2)==1 && size(dummy_sec,2)==1
                        if dummy_BC_trans<80 && dummy_BC<80 && dummy_n_it<60 && dummy_BC_trans>-2 && dummy_BC>-2 && dummy_n_it>0
                            count=count+1;  
                            BC_trans(count)=dummy_BC_trans;
                            BC(count)=dummy_BC;
                            n_it(count)=dummy_n_it;
                            time_BC(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);

                            if time_BC(count)>(now+4) || time_BC(count)< datenum(2014,01,01) %Excludes weird dates from MAAP (e.g. future aand more than two years old for GoAmazon dataset.).
                                count=count-1;
                                BC_trans(end)=[];
                                BC(end)=[];
                                n_it(end)=[];
                                time_BC(end)=[];
                            end;
                        end;
                    end;
                end   
            end;
            status=fclose(fid);
        end;
    end;
    %--------------------------------

    
    
    Readme_MAAP='Data from MAAP 5012. Data filtered for reasonable time strings and -2<BC<80 and #iterations smaller than 60.';
    
    [time_BC,idx_sort]=unique(time_BC);

    BC=BC(idx_sort);
    n_it=n_it(idx_sort);
    BC_trans=BC_trans(idx_sort);



    if exist('mat-files/Troca_silica.mat') && (strcmp(MAAP_name,'156') || strcmp(MAAP_name,'158'))
        load mat-files/Troca_silica.mat
        for i=1:max(size(time_Silica_st));
            BC(time_BC>time_Silica_st(i)&time_BC<time_Silica_end(i))=[];
            n_it(time_BC>time_Silica_st(i)&time_BC<time_Silica_end(i))=[];
            BC_trans(time_BC>time_Silica_st(i)&time_BC<time_Silica_end(i))=[];
            time_BC(time_BC>time_Silica_st(i)&time_BC<time_Silica_end(i))=[];
        end;                                                                                                                                                         a       end;
    end;


    while count_old < count
        S=0;
        D=0;
        i=1;
        while S<1800 && D<1 && (count_old+i)<max(size(BC))
            [D, S] = DateDiff(time_BC(count_old),time_BC(count_old+i));
            i=i+1;
        end;
        if i>3
            time_BC_avg=[time_BC_avg (time_BC(count_old)+time_BC(i+count_old))/2];
            BC_avg=[BC_avg mean(BC(count_old:count_old+i))];
        end;
        count_old=count_old+i+1;
    end;

    label_BC='BC_e concentration (\mug/m^3)';
    title_BC=['BC_e (MAAP', MAAP_name ,')'];


    if isunix
        fig1 = figure('visible','off');
    else
        fig1=figure;
    end;
    set(fig1,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    plot(time_BC_avg,BC_avg,'k*')
    title(['BC_e',station])
    xlabel('Date')
    ylabel(label_BC)
    ylim([0 5])
    box on
    dynamicDateTicks([], [], 'dd/mm');
    set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
    nome=['fig/BC_MAAP_' MAAP_name '_' mydir '_Time_series'];
    
if isunix
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
    eval(['delete ',nome,'.eps'])
else
    eval(['export_fig ',nome,' -png -transparent'])
end;
%{

    clear fig1

    fig1 = figure('visible','off');
    set(fig1,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    plot(time_BC,n_it,'k*')
    title(['Number of iteractions - MAAP',station])
    xlabel('Date')
    ylabel('#')
    box on
    dynamicDateTicks([], [], 'dd/mm');
    set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
    nome=['fig/BC_MAAP_n_it_' MAAP_name '_' mydir '_Time_series']
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])


    clear fig1

    fig1 = figure('visible','off');
    set(fig1,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    plot(BC,BC_trans,'k*')
    title(['BC vs BC trans - MAAP',station])
    xlabel('BC (MAAP)')
    ylabel('BC Trans (MAAP)')
    box on
    set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.775]);
    nome=['fig/BC_BC_Trans_MAAP_' MAAP_name '_' mydir '']
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])
%}

    %Plot each day

    days_BC=unique(floor(time_BC));

    count_days=0;
    if exist('days_BC_OK','var')==1
        if min(size(days_BC_OK))>0
            for i=1:max(size(days_BC))
                if max(days_BC(i)==days_BC_OK)>0
                    count_days=count_days+1;
                    rem_days(count_days)=i;
                end;
            end;
            days_BC(rem_days)=[];
        end;
    else
        days_BC_OK=[];
    end;

    for i=1:max(size(days_BC))

        
         if days_BC(i)<=datenum(2014,04,01)
            fig_name=['fig/IOP1/BC_MAAP_',mydir,'_',datestr(days_BC(i),29)];
        elseif days_BC(i)>datenum(2014,04,01) && days_BC(i)<datenum(2014,08,15)
            fig_name=['fig/April_to_Aug_2014/BC_MAAP_',mydir,'_',datestr(days_BC(i),29)];
        elseif days_BC(i)>=datenum(2014,08,15) && days_BC(i)<=datenum(2014,10,15)
            fig_name=['fig/IOP2/BC_MAAP_',mydir,'_',datestr(days_BC(i),29)];
         end

        clear fig1;

        quick_time_BC=(time_BC-days_BC(i)).*24;

        [diff_st,idx_st]=min(abs(quick_time_BC));
        [diff_end,idx_end]=min(abs(quick_time_BC - 24));

        
        if diff_st<1/24 && diff_end<1/24
            days_BC_OK=[days_BC_OK days_BC(i)];
        end;

    
        %Calculate sunrise/sunset
        [rs,t,d,z,b,r]=suncycle(-3.07,60,i);

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
            plot(quick_time_BC(idx_st:idx_end),BC(idx_st:idx_end),'k*')
            ylim(axes1,[min(BC(idx_st:idx_end)) max(BC(idx_st:idx_end))])
            xlim(axes1,[0 24])

            title(['BC_e (MAAP ',MAAP_name,')',station,' - ',datestr(days_BC(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_BC)
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

    if strcmp(MAAP_name,'')
        save mat-files/BC_MAAP.mat
        ascii_name='BC_MAAP.csv';
        !chmod 777 mat-files/BC_MAAP.mat
        
    else
        eval(['save mat-files/BC_MAAP_',MAAP_name,'.mat']);
        eval(['!chmod 777 mat-files/BC_MAAP_',MAAP_name,'.mat']);
        eval(['ascii_name=''BC_MAAP_',MAAP_name,'.csv''']);
        
    end;

    fid = fopen(['0_Ascii-files/',ascii_name],'wt');

    fprintf(fid,'Date(UTC),BC concentration (cm-3)\n');

    for i=1:max(size(time_BC))
        fprintf(fid,'%2.0f, %2.2f\n',(time_BC(i)-datenum(2014,02,01)).*24.*60.*60,BC(i));
    end;
    fclose(fid);

    eval(['!chmod 777 0_Ascii-files/',ascii_name])
end