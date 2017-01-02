function [time_corr,X_1,X_2,X_3,X_4,X_5,X_6,X_7,X_8,X_9,X_10]=Time_sync(x1,time_x1,x2,time_x2,x3,time_x3,x4,time_x4,x5,time_x5,x6,time_x6,x7,time_x7,x8,time_x8,x9,time_x9,x10,time_x10)

if nargin==18
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';    
elseif nargin==16
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';    
elseif nargin==14
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';
    x8=zeros(1,2);
    time_x8=zeros(1,2);
    X_8='';
elseif nargin==12
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';
    x8=zeros(1,2);
    time_x8=zeros(1,2);
    X_8='';
    x7=zeros(1,2);
    time_x7=zeros(1,2);
    X_7='';
elseif nargin==10
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';
    x8=zeros(1,2);
    time_x8=zeros(1,2);
    X_8='';
    x7=zeros(1,2);
    time_x7=zeros(1,2);
    X_7='';
    x6=zeros(1,2);
    time_x6=zeros(1,2);
    X_6='';
elseif nargin==8
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';
    x8=zeros(1,2);
    time_x8=zeros(1,2);
    X_8='';
    x7=zeros(1,2);
    time_x7=zeros(1,2);
    X_7='';
    x6=zeros(1,2);
    time_x6=zeros(1,2);
    x5=zeros(1,2);
    time_x5=zeros(1,2);
    X_6='';
    X_5='';
elseif nargin==6
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';
    x8=zeros(1,2);
    time_x8=zeros(1,2);
    X_8='';
    x7=zeros(1,2);
    time_x7=zeros(1,2);
    X_7='';
    x6=zeros(1,2);
    time_x6=zeros(1,2);
    x5=zeros(1,2);
    time_x5=zeros(1,2);
    x4=zeros(1,2);
    time_x4=zeros(1,2);    
    X_4='';
    X_5='';
    X_6='';
elseif nargin==4
    x10=zeros(1,2);
    time_x10=zeros(1,2);
    X_10='';
    x9=zeros(1,2);
    time_x9=zeros(1,2);
    X_9='';
    x8=zeros(1,2);
    time_x8=zeros(1,2);
    X_8='';
    x7=zeros(1,2);
    time_x7=zeros(1,2);
    X_7='';
    x6=zeros(1,2);
    time_x6=zeros(1,2);
    X_6='';
    x5=zeros(1,2);
    time_x5=zeros(1,2);
    X_5='';
    x4=zeros(1,2);
    time_x4=zeros(1,2);    
    X_4='';
    x3=zeros(1,2);
    time_x3=zeros(1,2);
    X_3='';
end;

for i=1:10
    eval(['time_x',num2str(i),'(isnan(x',num2str(i),'))=[];']);
    eval(['x',num2str(i),'(isnan(x',num2str(i),'))=[];']);
    eval(['x',num2str(i),'=Vert(x',num2str(i),');']);
    eval(['time_x',num2str(i),'=Vert(time_x',num2str(i),');']);
    eval(['samp_period(i)=median(gradient(time_x',num2str(i),'));']);
end;

time_corr=[];
for i=1:10
    eval(['X_',num2str(i),'=[];'])
end;

header=1:10;

[dummy,idx]=max(samp_period);
samp_period_slower=samp_period(idx);
eval(['slower=x',num2str(idx),';']);
eval(['time_slower=time_x',num2str(idx),';']);

header((samp_period)==0)=[];
header(idx)=[];
    
k=0;
    for i=1:length(slower)
        for j=1:max(size(header))
            eval(['[val_start(header(j)),index_start(header(j))]=min(abs(time_x',num2str(header(j)),'-(time_slower(i)-0.95.*samp_period_slower./2)));']);
            eval(['[val_end(header(j)),index_end(header(j))]=min(abs(time_x',num2str(header(j)),'-(time_slower(i)+0.95.*samp_period_slower./2)));']);

            if abs(val_start(header(j)))<samp_period_slower/2 && abs(val_end(header(j)))<samp_period_slower/2 && index_start(header(j))<=index_end(header(j))
                test(header(j))=0;
            else
                test(header(j))=1;
            end;
            
        end;
            
        if max(test)==0
            k=k+1;
            eval(['X_',num2str(idx),'(k)=slower(i);']);
            time_corr(k)=time_slower(i);
            for j=1:max(size(header))
                eval(['X_',num2str(header(j)),'(k)=mean(x',num2str(header(j)),'(index_start(header(j)):index_end(header(j))));']);
            end;
        end;
    end;
    
    
end
    
