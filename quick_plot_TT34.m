
cd /server/ftproot/public/ZF2
addpath /server/ftproot/public/matlab

%read_Logbook_Silica

quick_plot_TEOM

quick_plot_MAAP

quick_plot_AE33

Compare_BC

quick_plot_O3

import_Neph_AirPhoton('1014')

import_Neph_AirPhoton('1012')

quick_plot_Neph_TSI

%Compare_Nephs

%quick_plot_DMPS

%quick_plot_CPC3772

%Compare_CPC_SMPS

%quick_plot_Picarro

quit
%