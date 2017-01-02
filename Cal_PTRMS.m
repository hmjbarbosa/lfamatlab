
%Using both litterature (De Gouw 2003 and Warneke 2003) and factory
%calibration factors

%When appliying calibration factors from literature, values have been
%multiplied by 0.7 to match factory calibrtion factors

factor_31=2.*1.076; %Proportional to perm tubes
%factor_31=2; %Factory calibration factor table

factor_33=15.*1.076; %Proportional to perm tubes
%factor_33=15; %Factory calibration factor table
%factor_33=23.6; %De Gouw 2003

factor_42=22.*1.076; %Proportional to perm tubes
%factor_42=22; %Factory calibration factor table
%factor_42=48.8; %De Gouw 2003

factor_45=21.*1.076; %Proportional to perm tubes
%factor_45=21; %Factory calibration factor table
%factor_45=26.6; %De Gouw 2003

factor_46=10; %Randon value

factor_47=3.*1.076; %Proportional to perm tubes
%factor_47=3; %Factory calibration factor table

factor_59=49.*1.076; %Proportional to perm tubes
%factor_59=49; %Factory calibration factor table
%factor_59=64; %De Gouw 2003

factor_60=10; %Randon value

factor_61=5.6.*1.076; %Proportional to perm tubes
%factor_61=5.6; % De Gouw 2003 corrected by 0.7 - Acetic Acid
%factor_61=8; %De Gouw 2003 - Acetic Acid

factor_69=8.*1.076; %Proportional to perm tubes
%factor_69=8; %Factory calibration factor table
%factor_69=32.3; %De Gouw 2003

factor_71=35.7.*1.076; %Proportional to perm tubes
%factor_71=35.7; %Warneke et al. 2003 corrected by 0.7 - MACR + MVK
%factor_71=51.1; %Warneke et al. 2003 - MACR + MVK

factor_73=29.8.*1.076; %Proportional to perm tubes
%factor_73=29.8; %Warneke et al. 2003 corrected by 0.7 - MEK
%factor_73=42.6; %Warneke et al. 2003 - MEK

factor_79=26.*1.076; %Proportional to perm tubes
%factor_79=26; %Factory calibration factor table - Benzene
%factor_79=33.8; %De Gouw 2003 - Benzene

factor_81=10; %Random Value - Check that!

factor_93=32.2789; %Calibration using Perm tubes
%factor_93=30; %Factory calibration factor table  - Toluene
%factor_93=45.4; %De Gouw 2003  - Toluene

factor_107=13.1.*1.076; %Proportional to perm tubes
%factor_107=13.1; %Warneke et al. 2003 corrected by 0.7 - Xylenes
%factor_107=18.7; %Warneke et al. 2003 - Xylenes


factor_129=10; %Arbitrary!

factor_137=20.4.*1.076; %Proportional to perm tubes
%factor_137=20.4; %Warneke et al. 2003 corrected by 0.7 - Monoterpenes
%factor_137=29.2; %Warneke et al. 2003 - Monoterpenes


factor_205=10; %Arbitrary!


new_cal=0;
%Imports PTRMS' Background data
%if size(Cal,1)>0
if new_cal==1;
    
    %Cal Concentrations
    Conc=[79 93]; %Masses that should use calibration Every mass that is not found here will be estimated using factory calibration factors or calculated reaction rates
    Conc(2,:)=[16.24 30.98]; %Concentration in ppbv - Calculate from perm tubes/dilution or from gas cylinder
    
    %Conc=[1 2]; %Do not use any calibration values yet. Perm tubes to be measured.
    %Conc(2,:)=[1 2];
    
  
    
    
    k=1;
    for i=1:size(header_Cal,2);
        if header_Cal(i)==21
            Prim_Cal=Cal(:,i);
            if mean(Prim_Cal)<1e6
                Prim_Cal=Prim_Cal.*500;
            end;
            idx_remove(k)=i;
            k=k+1;
        elseif header_Cal(i)==25
            idx_remove(k)=i;
            k=k+1;
        elseif header_Cal(i)==30
            m30_Cal=Cal(:,i);
            idx_remove(k)=i;
            k=k+1;
        elseif header_Cal(i)==32
            m32_Cal=Cal(:,i);
            idx_remove(k)=i;
            k=k+1;
        elseif header_Cal(i)==37
            m37_Cal=Cal(:,i);
            idx_remove(k)=i;
            k=k+1;
        end;
    end;

    %Remove primary and products
    if k>1 
        Cal(:,idx_remove)=[];
        header_Cal(idx_remove)=[];
    end;
    

    %Separates between calibrated compounds or not.
    conc_count=0;
    non_conc_count=0;
    for i=1:size(header,2)
        [diff,idx]=min(abs(Conc(1,:)-header(i)));
        if diff==0
            conc_count=conc_count+1;
            calib_compounds(conc_count)=i;
            idx_calib_compounds(conc_count)=idx;
        else
            non_conc_count=non_conc_count+1;
            non_calib_compounds(non_conc_count)=i;
        end;
    end;
        
    %Converts to mixing ratios the non calibrated compounds using factory
    %calibration
    for i=1:size(non_calib_compounds,2)
        eval(['vocs(:,non_calib_compounds(i))=vocs(:,non_calib_compounds(i))./(factor_',num2str(header(non_calib_compounds(i))),'.*Prim./1e6);']);
    end;
        
    
    
    %This piece of code identifies the number of Cal cycles
    %Check before measurement
    Cal_count=0;
    if time_Cal(1)<time_PTRMS(1)
        Cal_count=Cal_count+1;
        time_start=time_Cal(1)+1/(24*60);
        [diff,dummy_idx]=min(abs(time_Cal - time_start));
        Cal_cycle(Cal_count,:)=mean(Cal(time_Cal<time_PTRMS(1),:));%averages skipping the first minute of Cal check
        time_Cal_cycle(Cal_count,:)=mean(time_Cal(time_Cal<time_PTRMS(1),:));%averages skipping the first minute of Cal check
    end;
    %Check between measurements
    for i=1:max(size(time_PTRMS))-1
        if size(Cal(time_Cal>time_PTRMS(i) & time_Cal<time_PTRMS(i+1)),1)>0
            Cal_count=Cal_count+1;

            Cal_dummy=Cal(time_Cal>time_PTRMS(i) & time_Cal<time_PTRMS(i+1),:);
            time_Cal_dummy=time_Cal(time_Cal>time_PTRMS(i) & time_Cal<time_PTRMS(i+1));

            time_start=time_Cal_dummy(1)+1/(24*60);
            [diff,dummy_idx]=min(abs(time_Cal_dummy - time_start));
            Cal_cycle(Cal_count,:)=mean(Cal_dummy(dummy_idx:end,:));%averages skipping the first minute of Cal check
            time_Cal_cycle(Cal_count,:)=mean(time_Cal_dummy(dummy_idx:end));%averages skipping the first minute of Cal check
        end;
    end;

    %Check after measurements
    if time_Cal(end)>time_PTRMS(end)
        Cal_count=Cal_count+1;

        Cal_dummy=Cal(time_Cal>time_PTRMS(end));
        time_Cal_dummy=time_Cal(time_Cal>time_PTRMS(end));
    end;
    
    factor_79=interp1(time_Cal_cycle,Cal_cycle(:,Idx79),time_BG_cycle,'linear');
    factor_79=(factor_79-BG_cycle(:,Idx79))./(17.6*Conc(2,1));
    
    factor_93=interp1(time_Cal_cycle,Cal_cycle(:,Idx93),time_BG_cycle,'linear');
    factor_93=(factor_93-BG_cycle(:,Idx93))./(17.6*Conc(2,2));
    
    plot(time_BG_cycle,factor_93)
    dynamicDateTicks([], [], 'dd/mm');
    
    
    %{
%Finds calibration cycles and retrieves average values for each cycle.
    idx_last=1;
    Cal_count=0;
    for i=1:size(time_PTRMS)
     
        [diff,idx]=min(abs(time_PTRMS(i)-time_Cal));
     
        if idx~=idx_last && time_PTRMS(i)>time_Cal(idx)
            time_start=time_Cal(idx_last)+1/(24*60);
            datestr(time_start)
            [diff,idx_start]=min(abs(time_Cal - time_start));
            Cal_count=Cal_count+1;
            start_vocs_cycle(Cal_count)=i; %The first sampling cycle after the Cal has finished.
            Cal_cycle(Cal_count,:)=(mean(Cal(idx_start:idx,:)) - BG_cycle(Cal_count,:)).*1e6./mean(Prim_Cal(idx_start:idx)); %Retrieves the values during calibration removed from background and divided by primary counts
            idx_last=idx;
        end;
    end;
    if time_Cal(end)>time_PTRMS(end)
            [diff,idx]=min(abs(time_PTRMS(end)-time_Cal));
            time_start=time_Cal(idx)+1/(24*60);
            [diff,idx_start]=min(abs(time_Cal - time_start));
            Cal_count=Cal_count+1;
            start_vocs_cycle(Cal_count)=size(time_PTRMS,1); %Last value of vocs data 
            Cal_cycle(Cal_count,:)=(mean(Cal(idx:end,:)) - BG_cycle(Cal_count,:)).*1e6./mean(Prim_Cal(idx:end)); %Retrieves the values during calibration removed from background and divided by primary counts
    end;
    
    %  norm_cal = counts / (conc * Prim/1e6) (ncps/ppbv)
    %  conc = counts / (norm_cal * Prim / 1e6) (ppbv)

    if Cal_count==1 %If there is only one calibration cycle
        for i=1:size(calib_compounds,2)
            vocs(:,calib_compounds(i))=vocs(:,calib_compounds(i)).*1e6.*Conc(2,idx_calib_compounds(i))./(Cal_cycle(1,calib_compounds(i)) .* Prim);
        end;
    
    elseif Cal_count>1
        if start_vocs_cycle(1)~=1 %If vocss prior performing calibration
            for i=1:size(calib_compounds,2)
                vocs(1:start_vocs_cycle(1),calib_compounds(i))=vocs(1:start_vocs_cycle(1),calib_compounds(i)).*1e6.*Conc(2,idx_calib_compounds(i))./(Cal_cycle(1,calib_compounds(i)) * Prim(1:start_vocs_cycle(1)));
            end;
        end; 
        for j=1:Cal_count-1
            idx_start=start_vocs_cycle(j);
            if j==Cal_count-1
                idx_end=start_vocs_cycle(j+1);
            else
                idx_end=start_vocs_cycle(j+1)-1;
            end;
            tot=idx_end-idx_start; %Number of sampling points between these cycles
           
            for k=idx_start:idx_end %Run through the sampling points between cycle j and j+1
                Cal_dummy=Cal_cycle(j+1,:).*(k-idx_start)./tot + Cal_cycle(j,:).*(idx_end-k)./tot;
                for i=1:size(calib_compounds,2)
                    vocs(k,calib_compounds(i))=vocs(k,calib_compounds(i)).*1e6.*Conc(2,idx_calib_compounds(i))./(Cal_dummy(1,calib_compounds(i)) * Prim(k));
                end;
            end;
        end;
        
        if time_PTRMS(end)>time_Cal(end) %If vocss after last cal check
            for i=1:size(calib_compounds,2)
                vocs(start_vocs_cycle(Cal_count):end,calib_compounds(i))=vocs(start_vocs_cycle(Cal_count):end,calib_compounds(i)).*1e6.*Conc(2,idx_calib_compounds(i))./(Cal_cycle(1,calib_compounds(i)) * Prim(start_vocs_cycle(Cal_count):end));
            end;
        end;
        
    
    end;
    %}
else
    
    
    %Retrieve VOC indexes
    for i=1:size(header,2)

        eval(['dummy=exist(''factor_',num2str(header(i)),''',''var'');'])
        if dummy==0
            eval(['factor_',num2str(header(i)),'=10;'])
        end;
        eval(['vocs(:,i)=vocs(:,i)./(factor_',num2str(header(i)),'.*Prim./1e6);']);
    end;

    clear dummy
end;


    for i=1:size(header,2)
        eval(['label_',num2str(header(i)),'=[label_',num2str(header(i)),', '' (ppbv)''];']);
    end;
