function import_AE33(AE33_name)

    
    clc
    close all
    [tmp,mydir]=fileparts(pwd);
    if strcmp(mydir,'Tiwa')
        station=' -  T2';
    else
        station=[' - ' mydir];
    end

    fl_dir=['AE33_',AE33_name,'/'];

    %-------------------------------

    count=0;

    fl=dir([fl_dir,'*AE33*.dat']);

    if size(fl,1)>0
        for fl_number=1:max(size(fl))

            fid = fopen([fl_dir,fl(fl_number).name]);
            total_lines=0;
            TextLine = fgetl(fid);
            while ~feof(fid)
                total_lines=total_lines+1;
                delimiters=0;
                size_text=max(size(TextLine));
                i=2;
                while i<size_text
                    if strcmp(TextLine(i),' ')
                            delimiters=delimiters+1;
                            idx_delimiter(delimiters)=i;
                    end
                    i=i+1;
                end

                if delimiters==70
                    dummy_BC_1=str2num(TextLine(idx_delimiter(40)+1:idx_delimiter(41)-1));
                    dummy_BC_2=str2num(TextLine(idx_delimiter(43)+1:idx_delimiter(44)-1));
                    dummy_BC_3=str2num(TextLine(idx_delimiter(46)+1:idx_delimiter(47)-1));
                    dummy_BC_4=str2num(TextLine(idx_delimiter(49)+1:idx_delimiter(50)-1));
                    dummy_BC_5=str2num(TextLine(idx_delimiter(52)+1:idx_delimiter(53)-1));
                    dummy_BC_6=str2num(TextLine(idx_delimiter(55)+1:idx_delimiter(56)-1));
                    dummy_BC_7=str2num(TextLine(idx_delimiter(58)+1:idx_delimiter(59)-1));

                    dummy_day=str2num(TextLine(9:10));
                    dummy_month=str2num(TextLine(6:7));
                    dummy_year=str2num(TextLine(1:4));
                    dummy_hour=str2num(TextLine(12:13));
                    dummy_minute=str2num(TextLine(15:16));
                    dummy_sec=str2num(TextLine(18:19));

                    dummy_status=TextLine(idx_delimiter(36)+1:idx_delimiter(37)-1);

                        if strcmp(dummy_status,'00000') && max(size(dummy_BC_1))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                            count=count+1;  
                            Aeth(count,:)=[dummy_BC_1;dummy_BC_2;dummy_BC_3;dummy_BC_4;dummy_BC_5;dummy_BC_6;dummy_BC_7];
                            time_Aeth(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
                    end;
                end   
                % get next line of text
                TextLine = fgetl(fid);

            end;
            status=fclose(fid);
        end;
    end;
    %--------------------------------

    [time_Aeth,idx_sort]=unique(time_Aeth);

    Aeth=Aeth(idx_sort,:)./1000;


    if exist('mat-files/Troca_silica.mat')
        load mat-files/Troca_silica.mat
        for i=1:max(size(time_Silica_st));
            Aeth(time_Aeth>time_Silica_st(i)&time_Aeth<time_Silica_end(i),:)=[];
            time_Aeth(time_Aeth>time_Silica_st(i)&time_Aeth<time_Silica_end(i))=[];
        end;
    end;



    k=1;
    j=1;
    i=1;
    while j < max(size(Aeth))
        S=0;
        D=0;
        i=1;
        while S<600 && D<1 && (j+i)<max(size(Aeth))
            [D, S] = DateDiff(time_Aeth(j),time_Aeth(j+i));
            i=i+1;
        end;
        if i>3
            time_Aeth_avg(k)=(time_Aeth(j)+time_Aeth(i+j))/2;
            Aeth_avg(k)=mean(Aeth(j:j+i,6));
            k=k+1;
        end;
        j=j+i+1;
    end;



    label_Aeth='BC concentration (\mug m^{-3})';
    title_Aeth=['BC concentration (Aethalometer AE33 ',AE33_name,' - 880nm)'];


    fig1 = figure('visible','off');
    set(fig1,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    plot(time_Aeth_avg,Aeth_avg)
    title([title_Aeth,station])
    xlabel('Date')
    ylabel(label_Aeth)
    box on
    dynamicDateTicks([], [], 'dd/mm');
    set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
    nome=['fig/Aethalometer_AE33_' mydir '_' AE33_name '_Time_series']
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

    %eval(['export_fig ',nome,'  -png -transparent'])

    %Plot each day

    days_Aeth=unique(floor(time_Aeth));

    for i=1:max(size(days_Aeth))

            fig_name=['fig/Aethalometer_AE33_',mydir,'_',AE33_name,'_',datestr(days_Aeth(i),29)];

        clear fig1;

        quick_time_Aeth=(time_Aeth-days_Aeth(i)).*24;

        [a,idx_st]=min(abs(quick_time_Aeth));
        [a,idx_end]=min(abs(quick_time_Aeth - 24));

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
    %       rectangle('Parent',axes1,'Position',[0,-1000,rs(1),2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
    %       rectangle('Parent',axes1,'Position',[rs(2),-1000,24,2000],'FaceColor',[0.95 0.95 0.95],'EdgeColor',[0.9 0.9 0.9])
            rectangle('Parent',axes1,'Position',[rs(1),-1000,rs(2)-rs(1),2000],'FaceColor',[1 1 0.7],'EdgeColor',[1 1 0.7])
            plot(quick_time_Aeth(idx_st:idx_end),Aeth(idx_st:idx_end,6),'b')
            ylim(axes1,[min(Aeth(idx_st:idx_end,6)) max(Aeth(idx_st:idx_end,6))])
            xlim(axes1,[0 24])

            title(['BC concentration (Aethalometer AE33 - 880nm) ',AE33_name,station,' - ',datestr(days_Aeth(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_Aeth)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

            %eval(['export_fig ',fig_name,'  -png -transparent'])
            print(fig1,'-depsc',[fig_name,'.eps']);
            eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])


        end;
    end;
    eval(['save mat-files/AE33_',AE33_name,'.mat']);

end
%{
fid = fopen('0_Ascii-files/Aeth_Aurora.csv','wt');

fprintf(fid,'Date(UTC),Aethering Blue (Mm-1), Aethering Green (Mm-1), Aethering Red, Back Aethering Blue (Mm-1), Back Aethering Green (Mm-1), Back Aethering Red (Mm-1)\n');

for i=1:max(size(time_Aeth))
    fprintf(fid,'%s, %2.1f\n',time_Aeth,Aeth(:,1),Aeth(:,2),Aeth(:,3),BAeth(:,1),BAeth(:,2),BAeth(:,3));
end;
fclose(fid);
%}