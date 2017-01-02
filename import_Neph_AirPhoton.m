function import_Neph_AirPhoton(Neph_name)

    clc
    close all
    [tmp,mydir]=fileparts(pwd);
    if  strcmp(mydir,'Manacapuru')
        mydir='T3';
    elseif strcmp(mydir,'Tiwa')
        mydir='T2';
    end;
    station=[' - ' mydir];
    fl_dir=['AirPhoton_Neph_',Neph_name,'/'];

    %-------------------------------

    fl=dir([fl_dir,'IN*.CSV']);

    count=0;    
    if isempty(fl(1).name)==0
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
                    if strcmp(TextLine(i),',')
                        if strcmp(TextLine(i-1),',') 
                            TextLine(i)=[];
                            size_text=size_text-1;
                            i=i-1;
                       else
                            delimiters=delimiters+1;
                            idx_delimiter(delimiters)=i;
                       end;
                    elseif strcmp(TextLine(i),',')
                        delimiters=delimiters+1;
                        idx_delimiter(delimiters)=i;  
                    end
                    i=i+1;
                end

                if delimiters==26

                    dummy_Scatt_3=str2num(TextLine(idx_delimiter(23)+1:idx_delimiter(24)-1));
                    dummy_Scatt_2=str2num(TextLine(idx_delimiter(24)+1:idx_delimiter(25)-1));
                    dummy_Scatt_1=str2num(TextLine(idx_delimiter(25)+1:idx_delimiter(26)-1));

                    dummy_BScatt_3=str2num(TextLine(idx_delimiter(20)+1:idx_delimiter(21)-1));
                    dummy_BScatt_2=str2num(TextLine(idx_delimiter(21)+1:idx_delimiter(22)-1));
                    dummy_BScatt_1=str2num(TextLine(idx_delimiter(22)+1:idx_delimiter(23)-1));

                    dummy_date=TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1);

                    if max(size(dummy_date))>10

                        if strcmp(dummy_date(2),'/')
                            dummy_date=['0',dummy_date];
                        end;

                        if strcmp(dummy_date(5),'/')
                            dummy_date(5:end+1)=dummy_date(4:end);
                            dummy_date(4)='0';
                        end;

                        if strcmp(dummy_date(11),':')
                            dummy_date(11:end+1)=dummy_date(10:end);
                            dummy_date(10)='0';
                        end;
                        
                       if strcmp(dummy_date(14),':')
                            dummy_date(14:end+1)=dummy_date(13:end);
                            dummy_date(13)='0';
                        end;
                    
                        dummy_date=datenum(dummy_date,'mm/dd/yy HH:MM:SS');
                    end;
                    
                  
                    
                    if max(size(dummy_Scatt_1))==1 && isnumeric(dummy_date)
                        
                        if dummy_date>datenum(2014,01,01) && dummy_date<now
                            count=count+1; 
                            Scatt(count,:)=[dummy_Scatt_1;dummy_Scatt_2;dummy_Scatt_3];
                            BScatt(count,:)=[dummy_BScatt_1;dummy_BScatt_2;dummy_BScatt_3];
                            time_Neph(count)=dummy_date;
                        end
                    end;
                end   
                % get next line of text
                TextLine = fgetl(fid);

            end;
            status=fclose(fid);
        end;
    end;
        %--------------------------------

    
    [time_Neph,idx_sort]=unique(time_Neph);

    Scatt=Scatt(idx_sort,:);
    BScatt=BScatt(idx_sort,:);

    if exist('mat-files/Troca_silica.mat')
        load mat-files/Troca_silica.mat
        for i=1:max(size(time_Silica_st));
            Scatt(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
            BScatt(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i),:)=[];
            time_Neph(time_Neph>time_Silica_st(i)&time_Neph<time_Silica_end(i))=[];
        end;
    end;

    label_Scatt='Aerosol light scattering (Mm^{-1})';
    title_Scatt='Aerosol light scattering (AirPhoton) - PM2.5';


    fig1 = figure('visible','off');
    set(fig1,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    plot(time_Neph,Scatt(:,1))
    hold on
    plot(time_Neph,Scatt(:,2),'g')
    plot(time_Neph,Scatt(:,3),'r')
    title([title_Scatt,station])
    xlabel('Date')
    ylabel(label_Scatt)
    box on
    dynamicDateTicks([], [], 'dd/mm');
    ylim([0 100]);
    set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);
    nome=['fig/Scatt_AirPhoton_', mydir ,'_', Neph_name ,'_Time_series']
    
    %print(fig1,'-dpng',[nome,'.png']);
    print(fig1,'-depsc',[nome,'.eps']);
    eval(['!convert -density 300 ',nome,'.eps ',nome,'.png'])

    %Plot each day

    days_Neph=unique(floor(time_Neph));

    for i=1:max(size(days_Neph))

          fig_name=['fig/Scatt_AirPhoton_', mydir ,'_', Neph_name, '_',datestr(days_Neph(i),29)];

        clear fig1;

        quick_time_Neph=(time_Neph-days_Neph(i)).*24;

        [a,idx_st]=min(abs(quick_time_Neph));
        [a,idx_end]=min(abs(quick_time_Neph - 24));

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
            plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,1),'b')
            plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,2),'g')
            plot(quick_time_Neph(idx_st:idx_end),Scatt(idx_st:idx_end,3),'r')
            ylim(axes1,[min(Scatt(idx_st:idx_end,3)) max(Scatt(idx_st:idx_end,1))])
            xlim(axes1,[0 24])

            title(['Aerosol light scattering (AirPhoton) - PM2.5',station,' - ',datestr(days_Neph(i),1)])
            xlabel('Time (UTC)')
            ylabel(label_Scatt)
            box on

            set(gca,'Units','normalized','Position',[0.13 0.11 0.775 0.515]);

           % eval(['export_fig ',fig_name,'  -png -transparent'])
            print(fig1,'-depsc',[fig_name,'.eps']);
            eval(['!convert -density 300 ',fig_name,'.eps ',fig_name,'.png'])


        end;
    end;


    eval(['save mat-files/Neph_AirPhoton_',Neph_name,'.mat']);
end