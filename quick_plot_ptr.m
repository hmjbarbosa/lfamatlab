clear
close all
clc
[tmp,mydir]=fileparts(pwd);
station=[' - ' mydir];
fl_dir='PTRMS/';

disp('PTRMS')

data_mat=0;

%check for the last day
a=now-1;
ontem=datestr(a);
tog=num2str(ontem(1:2));
mon=num2str(month(ontem),'%02d');
yea=num2str(ontem(8:11));



fl_file=dir(['PTRMS/Data__',yea,'_',mon,'_',tog,'*.mat']); %creates the filename of yesterday that will be searched on the directory

if max(size(fl_file))>1

    for i=1:size(fl_file,1)
        eval(['load ', fl_file(i).name]);

        if size(ChanNames{1,1},1)<115
            delete(fl_file(i).name)
        else
            if i==1
                data_mat=1;
                header=ConvertedData.Data.MeasuredData(1,3).Data';
                vocs=ones(1,max(size(header)));
                DO=ones(1,8);
                time_PTRMS=[];
                pr=ones(1);

            end;

            clear dummy
            clear dummy_DO
            clear dummy_pr
            clear dummy_IScur
            clear dummy_ISflow

            check_DO=0;
            for j=1:max(size(ConvertedData.Data.MeasuredData))
                if strcmp(ConvertedData.Data.MeasuredData(1,j).Name,'Time / Cycle/Abs Time [sec]')
                    time_PTRMS = [time_PTRMS ; (ConvertedData.Data.MeasuredData(1,j).Data./(24*60*60)+ datenum(1904,1,1,0,0,0))];
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
                        for k=1:max(size(header))
                            dummy_header=num2str(header(k));
                            if strcmp(ConvertedData.Data.MeasuredData(1,j).Name(25:25+max(size(dummy_header))-1),dummy_header)
                                dummy(:,k)=ConvertedData.Data.MeasuredData(1,j).Data;
                            end;
                        end;
                    end;
                end;
                if strcmp(ConvertedData.Data.MeasuredData(1,j).Name,'Instrument/Drift Pressure [mbar]')
                     dummy_pr(:,1)=ConvertedData.Data.MeasuredData(1,j).Data;
                end

            end;
            if size(dummy,1)~=size(dummy_DO,1)
                test=0;
            end;
            vocs = [vocs ; dummy];
            DO = [DO ; dummy_DO];
            pr = [pr ; dummy_pr];

            if check_DO==0
                test=1;
            end;

        end;

    end


    clear dummy dummy_DO dummy_pr dummy_IScur dummy_ISflow j

    cd PTRMS

    addpath ../../matlab

    fl_file=dir(['Data__',yea,'_',mon,'_',tog,'*.tdms']); %creates the filename that will be searched on the directory
        for i=1:size(fl_file,1)
            [ConvertedData,ConvertVer,ChanNames]=convertTDMS(false,fl_file(i).name);

            if size(ChanNames{1,1},1)>=115
           %     movefile(fl_file(i).name,'Raw/tdms/rest');
           % else
                %movefile(fl_file(i).name,'Raw/tdms/');
                if i==1 && data_mat==0
                    data_mat=1;
                    header=ConvertedData.Data.MeasuredData(1,3).Data';
                    vocs=ones(1,max(size(header)));
                    DO=ones(1,8);
                    time_PTRMS=[];
                    pr=ones(1);

                end;

                clear dummy
                clear dummy_DO
                clear dummy_pr
                clear dummy_IScur
                clear dummy_ISflow

                check_DO=0;
                for j=1:max(size(ConvertedData.Data.MeasuredData))
                    if strcmp(ConvertedData.Data.MeasuredData(1,j).Name,'Time / Cycle/Abs Time [sec]')
                        time_PTRMS = [time_PTRMS ; (ConvertedData.Data.MeasuredData(1,j).Data./(24*60*60)+ datenum(1904,1,1,0,0,0))];
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
                            for k=1:max(size(header))
                                dummy_header=num2str(header(k));
                                if strcmp(ConvertedData.Data.MeasuredData(1,j).Name(25:25+max(size(dummy_header))-1),dummy_header)
                                    dummy(:,k)=ConvertedData.Data.MeasuredData(1,j).Data;
                                end;
                            end;
                        end;
                    end;
                    if strcmp(ConvertedData.Data.MeasuredData(1,j).Name,'Instrument/Drift Pressure [mbar]')
                         dummy_pr(:,1)=ConvertedData.Data.MeasuredData(1,j).Data;
                    end

                end;
                if size(dummy,1)~=size(dummy_DO,1)
                    test=0;
                end;
                vocs = [vocs ; dummy];
                DO = [DO ; dummy_DO];        
                pr=[pr ; dummy_pr];

            end;
        end;

    clear dummy dummy_DO dummy_pr dummy_IScur j k

    cd ..


    try
    %Retrieve header and exclude from data
    vocs(1,:)=[];
    DO(1,:)=[];
    pr(1,:)=[];

    catch err
        if (strcmp(err.identifier,'MATLAB:index_to_remove_exceeds_matrix_dimensions'))
            test='error'
            fig3=figure('visible','off');
            hold on;
            title('No plot since no data from yesterday encountered');
            fig3_name=['Error',yea,'_',mon,'_',tog];
            print(fig3,'-depsc',['fig/',fig3_name,'.eps']);
            eval(['!convert -density 300 fig/',fig3_name,'.eps fig/',fig3_name,'.png'])
            %movefile([fig3_name,'.eps'],'/fig');
        end
    end


    try
    %sort the files
    [time_PTRMS,sorted_idx]=sort(time_PTRMS);
    vocs=vocs(sorted_idx,:);
    DO=DO(sorted_idx,:);
    catch err 
        if (strcmp(err.identifier,'MATLAB:index_to_remove_exceeds_matrix_dimensions'))
        break
        end
    end



    time_BG=time_PTRMS(DO(:,1)==1 & DO(:,4)==1 & DO(:,5)==1);
    BG=vocs(DO(:,1)==1 & DO(:,4)==1 & DO(:,5)==1,:);
    pr_bg=pr(DO(:,1)==1 & DO(:,4)==1 & DO(:,5)==1);


    BG(time_BG>datenum(2013,02,01) & time_BG<datenum(2013,02,20),:)=[];
    time_BG(time_BG>datenum(2013,02,01) & time_BG<datenum(2013,02,20))=[];


    time_Cal=time_PTRMS(DO(:,1)==1 & DO(:,2)==1 & DO(:,3)==1 & DO(:,5)==1);
    Cal=vocs(DO(:,1)==1 & DO(:,4)==1 & DO(:,5)==1,:);
    cal_pr=pr(DO(:,1)==1 & DO(:,2)==1 & DO(:,3)==1 & DO(:,5)==1);

    time_PTRMS(DO(:,1)==1)=[];
    vocs(DO(:,1)==1,:)=[];
    pr(DO(:,1)==1,:)=[];
    % 
    % %find the last day and the data for it
    % for i=1:length(time_PTRMS)
    %     if time_PTRMS(i)<=datenum(clock)-datenum(0,0,0,24,0,0);
    %     time_PTRMS(i)=[];
    %     vocs(i,:)=[];
    %     end    
    % end
    % clear i;

    for k=1:length(header)
        if header(k)==21
            Prim=vocs(:,k);
            if mean(Prim)<1e6
                Prim=Prim.*500;
            end;
            idx_remove=k;       
        end
    end

    vocs(:,idx_remove)=[];
    header(:,idx_remove)=[];

    %Correct for fluctuations in primary change to signal m21
    for i=1:size(vocs,1)
        vocs(i,1:end)=vocs(i,1:end).*mean(Prim)./Prim(i);
    end;

    %remove all columns but the necessary

    sel_header=[32 37 69 31 45 71 79 83 93];

    for i=1:length(sel_header)
        [a,b]=max(header==sel_header(i));
        if a==1
            eval(['m',num2str(sel_header(i)),'=vocs(:,b);']);
        end;
    end;

    clear header;
    clear vocs;
    clear k;

    %semilog y m83, m69 and m71 call raw data
    fig1=figure('visible','off');
    set(fig1,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    hold on;
    semilogy(time_PTRMS,m69,time_PTRMS,m71,time_PTRMS,m83);
    box on;
    title('Preliminary raw data - PTRMS - T2');
    legend('Isoprene','Mvk-Macr','mass 83');
    dynamicDateTicks([], [], 'dd/mm');
    fig1_name=strcat('PTRMS_Isopreonids_',yea,'_',mon,'_',tog);
    print(fig1,'-depsc',['fig/',fig1_name,'.eps']);
    eval(['!convert -density 300 fig/',fig1_name,'.eps fig/',fig1_name,'.png'])



    %semilogy m93 m79 call rawdata

    fig2=figure('visible','off');
    set(fig2,'InvertHardcopy','on');
    set(gca, 'FontSize', 12, 'LineWidth', 2); 
    semilogy(time_PTRMS,m93,time_PTRMS,m79);
    hold on;
    box on;
    title('Preliminary raw data - PTRMS - T2');
    legend('Toluene','Benzene');
    dynamicDateTicks([], [], 'dd/mm');
    fig2_name=strcat('PTRMS_Aromatics_',yea,'_',mon,'_',tog);
    print(fig2,'-depsc',['fig/',fig2_name,'.eps']);
    eval(['!convert -density 300 fig/',fig2_name,'.eps fig/',fig2_name,'.png'])


end;


