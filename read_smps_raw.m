%function [fout]=read_smps_raw(dir,mask)
% -------------------------------------------------------------------------
% search files
dir='/Users/hbarbosa/DATA/UEA/SMPS_71331078sn_CPC_71025292sn/';
mask='*.txt';
smps_flist=dirpath(dir,mask);
smps_nfile=length(smps_flist);
disp(['read_smps:: input= ' dir '/' mask]);
disp(['read_smps:: nfiles= ' num2str(smps_nfile)]);
%clear dir mask

% read SMPS data
clear tmp data smps_jd smps_data smps_flag smps_cn smps_size

nn=0;
disp(['read_smps:: reading data files...']);
for i=1:smps_nfile
  disp([num2str(i) ' / ' num2str(smps_nfile) '  ' smps_flist{i}]);
  tmp=read_mixed_csv(smps_flist{i},';');
  % check if file was empty
  if (length(tmp))
    
%% -------------------------------------------------------------------------
%% READ HEADER
%% -------------------------------------------------------------------------
    idx1=0; idx2=0; idxTot=0; idxFlag=0; idxFlowR=0; hline=0;
    for j=1:size(tmp,1)

      % search charge correction
      if strcmp(tmp{j,1},'Multiple Charge Correction')
        if ~strcmp(tmp{j,2},'TRUE')
          disp('Warn: double charge not corrected!');
        end
      end
      
      % find last header line
      if strcmp(tmp{j,1},'Sample #')
        % search columns we need
        for k=1:size(tmp,2)
          if strcmp(tmp{j,k},'Diameter Midpoint') & idx1==0
            idx1=k+1;
          end
          if strncmp(tmp{j,k},'Scan',4) & idx2==0
            idx2=k-1;
          end
          if strcmp(tmp{j,k},'Sheath Flow(lpm)') & idxFlowR==0
            idxFlowR=k;
          end
          if strcmp(tmp{j,k},'Status Flag') & idxFlag==0
            idxFlag=k;
          end
          if strncmp(tmp{j,k},'Total Conc',10) & idxTot==0
            idxTot=k;
          end
        end
        % save the header line position
        hline=j;
        break
      end
    end

    % get sizes
    for k=idx1:idx2
      smps_size(k-idx1+1)=str2num(tmp{j,k});
    end

    % keep only the part we need
    tmp=tmp(hline+1:end,:);
    
%% -------------------------------------------------------------------------
%% READ DATA
%% -------------------------------------------------------------------------

    % read the rest of the file, with the data
    nn0=nn+1;
    for j=1:size(tmp,1)
      nn=nn+1;
      
      % size distribution
      for k=idx1:idx2 
        if isempty(tmp{j,k})
          data(k)=nan;
        else
          x=str2num(tmp{j,k});
          if isempty(x)
            data(k)=nan;
          else
            data(k)=x;
          end
        end
      end
      smps_data(nn,:)=data(idx1:idx2); 
      
      % status flag
      if isempty(tmp{j,idxFlag}) | ~strcmp(tmp{j,idxFlag},'Normal Scan')
        smps_flag(nn)=0;
      else
        smps_flag(nn)=1;
      end
      
      % flow ratio
      x=str2num(tmp{j,idxFlowR});
      y=str2num(tmp{j,idxFlowR+1});
      if isempty(x) | isempty(y)
        smps_flowr(nn)=nan;
      else
        smps_flowr(nn)=x+y/10;
      end      
      
      % counts
      x=str2num(tmp{j,idxTot}); 
      if isempty(x)
        smps_cn(nn)=nan;
      else
        smps_cn(nn)=x;
      end      
      
      % julian date
      smps_jd(nn)=datenum([tmp{j,2} ' ' tmp{j,3}],'mm/dd/yy HH:MM:SS');
    end
    
    figure ; hold on
    x=smps_jd(nn0:nn);
    y=smps_cn(nn0:nn);
    w=smps_flag(nn0:nn);
    plot(x,y)
    plot(x(w==0),y(w==0),'r*')
    dateaxis('x',2)
    title(smps_flist{i})
    
    grid
    drawnow

  end

end
disp('sorting...')
[smps_jd,idx]=sort(smps_jd);
smps_cn=smps_cn(idx);
smps_flag=smps_flag(idx);
smps_flowr=smps_flowr(idx);
smps_data=smps_data(idx,:);

disp(['read_smps:: data length= ' num2str(size(data,1))]);
disp(['read_smps:: data start= ' datestr(nanmin(smps_jd))]);
disp(['read_smps:: data end= ' datestr(nanmax(smps_jd))]);
disp(['read_smps:: number of diam= ' num2str(length(smps_size))]);
disp(['read_smps:: dian(nm)= ']);
disp(sprintf('%5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f \n',smps_size))
%
%clear tmp i j k nn data x
fout='smps_raw_data.mat';
save(fout,'smps_cn','smps_data','smps_flist','smps_jd', ...
     'smps_nfile','smps_size','smps_flag','smps_flowr')
%