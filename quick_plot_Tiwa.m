if isunix
    cd /server/ftproot/public/Tiwa
    addpath /server/ftproot/public/matlab
end

clc

try
    read_Logbook_Silica
    
catch ME
    disp('Error silica')
end

try
    read_OFR
    
catch ME
    disp('Error OFR')
end


try 
    quick_plot_Anem    
catch ME

   disp('Error ') 
end


try 
    import_MAAP('')
catch ME
    disp('Error MAAP') 
end


try 
    quick_plot_NO2
catch ME
   disp('Error NO2') 
end


%quick_plot_AE33

%Compare_BC


try 
    quick_plot_O3    
catch ME
   disp('Error O3') 
end


try 
     quick_plot_SO2
catch ME
   disp('Error SO2') 
end

try 
    quick_plot_Neph_Aurora    
catch ME
   disp('Error Neph Aurora') 
end

%{
try 
    quick_plot_OPC
catch ME_
   disp('Error ') 
end
%}

try 
    quick_plot_N2O_CO
catch ME
   disp('Error N2O/CO') 
end
%quick_plot_Neph_Aurora_JCTM

%Compare_Nephs

try 
    quick_plot_SMPS_TSI_3082
catch ME
   disp('Error SMPS 3082') 
end

try 
    quick_plot_WCPC
catch ME
   disp('Error WCPC') 
end

try 
    quick_plot_TEOM    
catch ME
   disp('Error TEOM') 
end


try 
    quick_plot_PTRMS
catch ME
   disp('Error PTRMS') 
end


%quick_plot_CPC3772

%Compare_CPC_SMPS

%{
try 
    quick_plot_ptr    
catch ME_
   disp('Error PTRMS') 
end
%}

%Sort_ACSM_OFR

%quit
%