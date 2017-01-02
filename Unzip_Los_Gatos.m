function Unzip_Los_Gatos(fl_dir)

    if exist('mat-files/Los_Gatos_N2O_CO_Zip_list.mat')>0
        load mat-files/Los_Gatos_N2O_CO_Zip_list.mat
        count_rem_zip=0;
        clear rem_idx_zip
        cd(fl_dir)
        
        if isunix
            fl_zip=rdir('**/n2o*.txt');
        else
            fl_zip=rdir('**\*.zip');
        end;

        for i=1:max(size(fl_zip_old))
            for j=1:max(size(fl_zip))
                if strcmp(fl_zip(j).name,fl_zip_old(i).name)
                    if fl_zip(j).bytes==fl_zip_old(i).bytes
                        count_rem_zip=count_rem_zip+1;
                        rem_idx_zip(count_rem_zip)=j;
                    end;
                end;
            end;
        end;

        if count_rem_zip>0
            fl_zip(rem_idx_zip)=[];
            fl_zip_old=[fl_zip_old;fl_zip];
        end;
    else
        cd(fl_dir)
        if isunix
            fl_zip=rdir('**/n2o*.txt');
        else
            fl_zip=rdir('**\*.zip');
        end;
        fl_zip_old=fl_zip;
    end;

    if min(size(fl_zip))>0
        for fl_number=1:max(size(fl_zip))
            if isunix
              eval(['!cp ',fl_zip(fl_number).name,' ./Ascii/'])
            else
                unzip(fl_zip(fl_number).name,'./Ascii/')
            end;
        end
    end

    cd ..

    save mat-files/Los_Gatos_N2O_CO_Zip_list.mat

end

