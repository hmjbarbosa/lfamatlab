clear all
close all
[tmp,CPC_station]=fileparts(pwd);

CPC_flist_dir='CPC_3776151301sn/';
CPC_flist=dir([CPC_flist_dir,'T1*csv']);
  
%-------------------------------

count=0;
if size(CPC_flist,1)==0
  return
elseif size(CPC_flist,1)>0
  % data every 1 sec
  CPC_time=NaN(numel(CPC_flist)*1440*60,1);
  CPC=CPC_time;
  CPC_Erro=CPC_time;
  CPC_Tsat=CPC_time;
  CPC_Tcon=CPC_time;
  CPC_Topt=CPC_time;
  CPC_Tcab=CPC_time;
  CPC_Pamb=CPC_time;
  CPC_Poro=CPC_time;
  CPC_Pnoz=CPC_time;
  CPC_Ilas=CPC_time;
  
  for fl_number=1:max(size(CPC_flist))

    fname=[CPC_flist_dir,CPC_flist(fl_number).name];
    disp([num2str(fl_number) ' / ' num2str(numel(CPC_flist)) ' = ' fname]);

    % faster reading
    % data format saved from the RS232
    %  2    3    4          5      6        7         8           9
    % ,Date,Time,Conc(#cm3),errors,T_sat(C),T_cond(C),T_optics(C),T_cab(C)
    %  10          11              12             13          14
    %  P_amb(mbar),P_orifice(mbar),P_nozzle(mbar),I_laser(mA),liq_level
    fdata=read_mixed_csv2(fname,',',0);

    dummy_time=strcat(fdata(:,2),{' '},fdata(:,3));
    dummy_CPC =real(str2doubleq(fdata(:, 4)));
    dummy_Erro=real(str2doubleq(fdata(:, 5)));
    dummy_Tsat=real(str2doubleq(fdata(:, 6)));
    dummy_Tcon=real(str2doubleq(fdata(:, 7)));
    dummy_Topt=real(str2doubleq(fdata(:, 8)));
    dummy_Tcab=real(str2doubleq(fdata(:, 9)));
    dummy_Pamb=real(str2doubleq(fdata(:,10)));
    dummy_Poro=real(str2doubleq(fdata(:,11)));
    dummy_Pnoz=real(str2doubleq(fdata(:,12)));
    dummy_Ilas=real(str2doubleq(fdata(:,13)));
    dummy_length=cellfun('length',dummy_time);

    % some quality check
    QC= isnan(dummy_CPC) | isnan(dummy_Erro) | dummy_length~=19;
    if any(QC)
      disp(['Warn: quality check removes ' num2str(sum(QC))...
            ' out of ' num2str(numel(QC)) ' lines'])
      dummy_time(QC)=[];
      dummy_CPC (QC)=[];
      dummy_Erro(QC)=[];
      dummy_Tsat(QC)=[];
      dummy_Tcon(QC)=[];
      dummy_Topt(QC)=[];
      dummy_Tcab(QC)=[];
      dummy_Pamb(QC)=[];
      dummy_Poro(QC)=[];
      dummy_Pnoz(QC)=[];
      dummy_Ilas(QC)=[];
    end
    dummy_count=numel(dummy_CPC);
    if dummy_count==0
      continue
    end

    % now check time selection interval
    dummy_time=datenum(dummy_time,'YYYY-mm-dd HH:MM:SS');
    QC=dummy_time<datenum(2015,12,1) | dummy_time>datenum(2016,5,1);
    if any(QC)
      disp(['Warn: date selection removes ' num2str(sum(QC)) ...
            ' out of ' num2str(numel(QC)) ' lines'])
      dummy_time(QC)=[];
      dummy_CPC (QC)=[];
      dummy_Erro(QC)=[];
      dummy_Tsat(QC)=[];
      dummy_Tcon(QC)=[];
      dummy_Topt(QC)=[];
      dummy_Tcab(QC)=[];
      dummy_Pamb(QC)=[];
      dummy_Poro(QC)=[];
      dummy_Pnoz(QC)=[];
      dummy_Ilas(QC)=[];
    end
    dummy_count=numel(dummy_CPC);
    if dummy_count==0
      continue
    end

    CPC_time(count+1:count+dummy_count)=dummy_time;
    CPC     (count+1:count+dummy_count)=dummy_CPC;
    CPC_Erro(count+1:count+dummy_count)=dummy_Erro;
    CPC_Tsat(count+1:count+dummy_count)=dummy_Tsat;
    CPC_Tcon(count+1:count+dummy_count)=dummy_Tcon;
    CPC_Topt(count+1:count+dummy_count)=dummy_Topt;
    CPC_Tcab(count+1:count+dummy_count)=dummy_Tcab;
    CPC_Pamb(count+1:count+dummy_count)=dummy_Pamb;
    CPC_Poro(count+1:count+dummy_count)=dummy_Poro;
    CPC_Pnoz(count+1:count+dummy_count)=dummy_Pnoz;
    CPC_Ilas(count+1:count+dummy_count)=dummy_Ilas;

    count=count+dummy_count;

    %figure(1) ; clf 
    %semilogy(dummy_time,dummy_CPC); ylim([100 1e5])
    %hold on
    %%dateNtick('x',19)
    %dateaxis('x',15)
    %hold off
    %title([num2str(fl_number) ' ' fname])
    %grid on; box on
    %drawnow
    
  end;
end;

% Eliminate extra space in the end
if count < size(CPC,1)
  CPC_time(count+1:end)=[];
  CPC     (count+1:end)=[];
  CPC_Tsat(count+1:end)=[];
  CPC_Tcon(count+1:end)=[];
  CPC_Topt(count+1:end)=[];
  CPC_Tcab(count+1:end)=[];
  CPC_Pamb(count+1:end)=[];
  CPC_Poro(count+1:end)=[];
  CPC_Pnoz(count+1:end)=[];
  CPC_Ilas(count+1:end)=[];
end
%--------------------------------

disp('Excluding repeated data lines...')    
[CPC_time,idx]=unique(CPC_time);
CPC=CPC(idx);
CPC_Erro=CPC_Erro(idx);
CPC_Tsat=CPC_Tsat(idx);
CPC_Tcon=CPC_Tcon(idx);
CPC_Topt=CPC_Topt(idx);
CPC_Tcab=CPC_Tcab(idx);
CPC_Pamb=CPC_Pamb(idx);
CPC_Poro=CPC_Poro(idx);
CPC_Pnoz=CPC_Pnoz(idx);
CPC_Ilas=CPC_Ilas(idx);

if exist('mat-files/Troca_silica.mat','file')
  load mat-files/Troca_silica.mat
  for i=1:max(size(time_Silica_st))
    QC=CPC_time>time_Silica_st(i)&CPC_time<time_Silica_end(i);
    CPC_time(QC)=[];
    CPC     (QC)=[];
    CPC_Erro(QC)=[];
    CPC_Tsat(QC)=[];
    CPC_Tcon(QC)=[];
    CPC_Topt(QC)=[];
    CPC_Tcab(QC)=[];
    CPC_Pamb(QC)=[];
    CPC_Poro(QC)=[];
    CPC_Pnoz(QC)=[];
    CPC_Ilas(QC)=[];
  end         
end

clear dummy* fl* count* fdata fname idx mydir tmp QC
save mat-files/CPC.mat

%