function [N2O,CO,time_N2O_CO]=import_N2O_CO(fl)

    fid = fopen(fl);
    count=0;
    total_lines=0;
    TextLine = fgetl(fid);
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
               end;
            end;
            i=i+1;
        end

        i=1;
        while i<size_text
            if strcmp(TextLine(i),',')
                n_delimiters=n_delimiters+1;
                idx_delimiter(n_delimiters)=i;
            end;
            i=i+1;
        end
        
        if n_delimiters>15

            dummy_N2O=str2num(TextLine(idx_delimiter(3)+1:idx_delimiter(4)-1));
            dummy_CO=str2num(TextLine(idx_delimiter(1)+1:idx_delimiter(2)-1));
            dummy_day=str2num(TextLine(5:6));
            dummy_month=str2num(TextLine(2:3));
            dummy_year=str2num(TextLine(8:9))+2000;
            dummy_hour=str2num(TextLine(11:12));
            dummy_minute=str2num(TextLine(14:15));
            dummy_sec=str2num(TextLine(17:18));


            if max(size(dummy_N2O))==1 && max(size(dummy_CO))==1 && max(size(dummy_day))==1 && max(size(dummy_month))==1 && max(size(dummy_year))==1 && max(size(dummy_hour))==1 && max(size(dummy_minute))==1 && max(size(dummy_sec))==1 
                count=count+1; 
                N2O(count)=dummy_N2O.*1000;
                CO(count)=dummy_CO.*1000;
                time_N2O_CO(count)=datenum([dummy_year dummy_month dummy_day dummy_hour dummy_minute dummy_sec]);
            end;
        end;
        % get next line of text
        TextLine = fgetl(fid);

    end;
    status=fclose(fid);
    %--------------------------------

    if count>0

        N2O(time_N2O_CO<datenum(2014,01,01))=[];
        CO(time_N2O_CO<datenum(2014,01,01))=[];
        time_N2O_CO(time_N2O_CO<datenum(2014,01,01))=[];

        N2O(CO<0|CO>4000)=[];
        time_N2O_CO(CO<0|CO>4000)=[];
        CO(CO<0|CO>4000)=[];
    end;
    if count<3
        N2O=[];
        CO=[];
        time_N2O_CO=[];
    end;
end