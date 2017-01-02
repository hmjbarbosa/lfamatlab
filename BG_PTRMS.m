
%{
%Doesn't seem to work - original values must be lower
test_BG_31=236;
test_BG_33=960;
test_BG_42=29;
test_BG_45=660;
test_BG_47=1245;
test_BG_59=280;
test_BG_61=0; %Check that
test_BG_69=35;
test_BG_71=55;
test_BG_73=210;
test_BG_79=14;
test_BG_81=17.7;
test_BG_93=110; 
test_BG_107=160; 
test_BG_129=17.7;
test_BG_137=16; 
test_BG_205=0.8; 

test_BG_31=0;
test_BG_33=3.8e-4*mean(m32);
test_BG_42=0;
test_BG_45=0;
test_BG_47=0;
test_BG_59=0;
test_BG_61=0; %Check that
test_BG_69=0;
test_BG_71=0;
test_BG_73=0;
test_BG_79=0;
test_BG_81=0;
test_BG_93=0; 
test_BG_107=0; 
test_BG_129=0;
test_BG_137=0; 
test_BG_205=0; 
%}


if max(size(time_BG))>4

    plot_BG=1;


    k=1;
    for i=1:size(header_BG,2);
        if header_BG(i)==21
            Prim_BG=BG(:,i);
            if mean(Prim_BG)<1e6
                Prim_BG=Prim_BG.*500;
            end;
            idx_remove(k)=i;
            k=k+1;
        elseif header_BG(i)==25
            idx_remove(k)=i;
            k=k+1;
        elseif header_BG(i)==30
            m30_BG=BG(:,i);
            idx_remove(k)=i;
            k=k+1;
        elseif header_BG(i)==32
            m32_BG=BG(:,i);
            idx_remove(k)=i;
            k=k+1;
        elseif header_BG(i)==37
            m37_BG=BG(:,i);
            idx_remove(k)=i;
            k=k+1;
        end;
    end;

    %Remove primary and products
    if k>1 
        BG(:,idx_remove)=[];
        header_BG(idx_remove)=[];
    end;


    %This piece of code identifies the number of BG cycles
    %Check before measurement
    BG_count=0;
    clear BG_cycle
    clear time_BG_cycle
    if time_BG(1)<time_PTRMS(1)
        BG_count=BG_count+1;
        time_start=time_BG(1)+1/(24*60);
        [diff,dummy_idx]=min(abs(time_BG - time_start));
        BG_cycle(BG_count,:)=mean(BG(time_BG<time_PTRMS(1),:),1);%averages skipping the first minute of BG check
        time_BG_cycle(BG_count,:)=mean(time_BG(time_BG<time_PTRMS(1),:));%averages skipping the first minute of BG check
    end;
    %Check between measurements
    for i=1:max(size(time_PTRMS))-1
        if size(BG(time_BG>time_PTRMS(i) & time_BG<time_PTRMS(i+1)),1)>0
            BG_count=BG_count+1;

            BG_dummy=BG(time_BG>time_PTRMS(i) & time_BG<time_PTRMS(i+1),:);
            time_BG_dummy=time_BG(time_BG>time_PTRMS(i) & time_BG<time_PTRMS(i+1));

            time_start=time_BG_dummy(1)+1/(24*60);
            [diff,dummy_idx]=min(abs(time_BG_dummy - time_start));
            BG_cycle(BG_count,:)=mean(BG_dummy(dummy_idx:end,:));%averages skipping the first minute of BG check
            time_BG_cycle(BG_count,:)=mean(time_BG_dummy(dummy_idx:end));%averages skipping the first minute of BG check
        end;
    end;

    %Check after measurements
    if time_BG(end)>time_PTRMS(end)
        BG_count=BG_count+1;

        BG_dummy=BG(time_BG>time_PTRMS(end));
        time_BG_dummy=time_BG(time_BG>time_PTRMS(end));
    end;

     if plot_BG==1 && isunix==0
        for i=1:max(size(header))
            figure
            eval(['logy_circ(time_PTRMS,vocs(:,Idx',num2str(header(i)),'))']);
            hold on
            eval(['logy_circ(time_BG,BG(:,Idx',num2str(header(i)),'),''r'')']);
            eval(['logy_circ(time_BG_cycle,BG_cycle(:,Idx',num2str(header(i)),'),''g'')']);
            dynamicDateTicks([], [], 'dd/mm')
            eval(['title(label_',(num2str(header(i))),')'])
            legend('Measurement','BG','Avg BG')
            eval(['print -djpeg 1_pics\BG_Meas_',num2str(header(i)),'.jpg'])
        end;
    end;

%{
    i=11;
    figure
    eval(['logy_circ(time_PTRMS,vocs(:,Idx',num2str(header(i)),'))']);
    hold on
    eval(['logy_circ(time_BG,BG(:,Idx',num2str(header(i)),'),''r'')']);
    eval(['logy_circ(time_BG_cycle,BG_cycle(:,Idx',num2str(header(i)),'),''g'')']);
    dynamicDateTicks([], [], 'dd/mm')
    eval(['title(label_',(num2str(header(i))),')'])
%}
    count=0;
    %This piece of code removes the BG cycles from the measurement data
    if BG_count==1
        for i=1:max(size(header))
            vocs(:,i)=vocs(:,i)-BG_cycle(1,i);
        end;
    elseif BG_count>1
        for j=1:max(size(time_PTRMS))
            if time_PTRMS(j)<time_BG_cycle(1);
                vocs(j,:)=vocs(j,:)-BG_cycle(1,:);
            elseif time_PTRMS(j)>time_BG_cycle(end);
                vocs(j,:)=vocs(j,:)-BG_cycle(end,:);
            else
                [diff, idx]=min(abs(time_PTRMS(j) - time_BG_cycle));
                if time_PTRMS(j)>time_BG_cycle(idx)
                    idx_before=idx;
                    idx_after=idx+1;
                else
                    idx_before=idx-1;
                    idx_after=idx;
                end;

                tot_time=time_BG_cycle(idx_after)-time_BG_cycle(idx_before);
                count=count+1;
                BG_prop(count,:)=BG_cycle(idx_after,:).*(time_PTRMS(j)-time_BG_cycle(idx_before))./tot_time + BG_cycle(idx_before,:).*(time_BG_cycle(idx_after)-time_PTRMS(j))./tot_time;        
                vocs(j,:)=vocs(j,:)-BG_prop(count,:); %Simply subtracts the first BG check
                time_BG_prop(count)=time_PTRMS(j);
            end;                

        end;

  % logy_circ(time_BG_prop,BG_prop(:,11),'m');
  % legend('Measurement','BG','Avg BG','Prop BG')
    end;

end;