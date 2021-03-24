function [data] = calc_brc_1(abs1,abs2,abs3,wave1,wave2,wave3)

% This is an IDL script to seperate BC and BrC AAOD from AERONET
% measurements. The method is described in:
% 
% Wang, X., C.L. Heald, A.J. Sedlacek, S.S. de Sa, S.T. Martin,
% M.L. Alexander, T.B. Watson, A.C. Aiken, S.R. Springston, P. Artaxo
% (2016), Deriving Brown Carbon from Multi-Wavelength Absorption
% Measurements: Method and Application to Aethalometer Observations
% Atmos. Chem. Phys., 16, 12733-12752, doi:10.5194/acp-16-12733-2016.
% 
% How to use:
% 
% 1) You need to put both ".pro" and ".sav" files in the same location
% as your processing directory.
% 
% 2) Note that this approach is for separating brown and black carbon
% absorptions. If there are dust absorption contributing your
% measurements, you may need to exclude them first.
% 
% 3) Use the function calc_brc_1 in IDL environment, for example:
% 
% result = calc_brc_1(a, b, c)
% 
% Input: a, b, and c are the original AERONET AAOD at 440, 675 and 870nm
% 
% Output is a 5-elements array: [result[0], result[1], result[2], result[3], result[4]]
% 
% result[0] is the calculated brown carbon AAOD at 440nm
% result[1] is the methodology uncertainty of result[0]
% result[2] is the calculated contribution of brown carbon AAOD to total AAOD at 440nm, in %
% result[3] is the methodology uncertainty of result[2]
% result[4] is the calculated BC AAOD at 440nm
% 
% Contact: Xuan Wang, xuanw12@mit.edu

% cálculo da contribuição de Brown carbon na absorção

% BrAAOD = é o BrC calculado AAOD a 440nm
% BrAAOD_r = é a incerteza metodológica do resultado BrAAOD
% BrCont = é a contribuição calculada de BrC AAOD para AAOD total a 440nm, em %
% BrCont_r = é a incerteza metodológica do resultado BrCont
% BCAAOD = considerando BC calculado AAOD a 440nm = AAOD 440nm

% col_01 Date
% col_02 BrC calculado AAOD 440nm
% col_03 Incerteza do BrC calculado AAOD 440nm 
% col_04 Porcentagem de BrC AAOD 440nm em relação ao total de AAOD 440nm
% col_05 Incerteza da medida col_04
% col_06 AAOD 440nm
% col_07 BC real 440nm (AAOD 440nm - BrC 440nm)

%clear all;
%clc;

% Mie calculations as discussed in Wang's paper
% Shared as a binary IDL file named "basemie_AERONET.sav"
% bondmie = [...
%     0.1,       0.856656,       0.971063,       0.913860 ;...
%     0.3,       0.818784,       0.923744,       0.871264 ;...
%     0.5,       0.778845,       0.904880,       0.841863 ;...
%     0.7,       0.764685,       0.877989,       0.821337 ;...
%     0.9,       0.753013,       0.890559,       0.821786 ;...
%     1.1,       0.752517,       1.051050,       0.901783 ;...
%     1.3,       0.767029,       1.089620,       0.928326 ;...
%     1.6,       0.811395,       1.030230,       0.920813  ];
% bondmie_aae, bondmie_mindef, bondmie_maxdef, bondmie_middef
bondmie.aae    = [     0.1,      0.3,      0.5,      0.7,      0.9,      1.1,      1.3,      1.6];
bondmie.mindef = [0.856656, 0.818784, 0.778845, 0.764685, 0.753013, 0.752517, 0.767029, 0.811395];
bondmie.maxdef = [0.971063, 0.923744, 0.904880, 0.877989, 0.890559, 1.051050, 1.089620, 1.030230];
bondmie.middef = [0.913860, 0.871264, 0.841863, 0.821337, 0.821786, 0.901783, 0.928326, 0.920813];

% Initialize all variables
AAE13    = nan(size(abs1));
%AAE23    = nan(size(abs1));
realdef  = nan(size(abs1));
BrAAOD   = nan(size(abs1));
BrAAOD_r = nan(size(abs1));
BrCont   = nan(size(abs1));
BrCont_r = nan(size(abs1));
bcaae    = nan(size(abs1));
bcaae_max = nan(size(abs1));
bcaaod_max = nan(size(abs1));
braaod_min = nan(size(abs1));
BCAAOD   = nan(size(abs1));
isel     = nan(size(abs1));

% If you decide to use different wavelengths than Wang's, note that they
% should still be "compatible" with those used in his Mie simulation, i.e.,
% you should expect the AAE to be similar even though the wavelengths are
% not equal.

% Compute AAE between wave2 and wave3 
AAE23 = -log(abs2./abs3)/log(wave2/wave3);

% Now between wave1 and wave3
% NOTE: Wang's original code had a bug and used abs1/abs2
AAE13 = -log(abs1./abs3)/log(wave1/wave3);

% The ratio between these AAE tells give the "curvature" of the spectral
% response curve
realdef = exp(AAE13)./exp(AAE23);

%% LOOP on MIE table lines
for i = 1:length(bondmie.aae)
  %% LOOP on time 
  for t = 1:length(AAE23)
    
    % Fix problem with range around AAE in last line of mie table
    lowlim  = bondmie.aae(i)-0.1;
    highlim = bondmie.aae(i)+0.1; 
    
    if i==length(bondmie.aae)
      lowlim = bondmie.aae(i)-0.2;
    end
    
    if (AAE23(t) >= lowlim) & (AAE23(t) < highlim)
      % Save MIE table line number used for each time t
      isel(t) = i;
      
      % Compute AAE between wave1 and wave3
      % NOTE: Wang's original code had a bug and used abs1/abs2
      %AAE13(t) = -log(abs1(t)/abs3(t))/log(wave1/wave3);
      
      % Change in slope
      %realdef(t) = exp(AAE13(t))/exp(AAE23(t));
      
      % We found BrC (for sure) if the change in slope is larger than the
      % maximum change in the MIE calculations (which included only BC)
      if realdef(t) > bondmie.maxdef(i);

        % extrapolate BC AAE to wave1
        bcaae(t) = AAE23(t)+log(bondmie.middef(i));
        % use it to compute AAOD
        BCAAOD(t) = abs3(t)*exp(-bcaae(t)*log(wave1/wave3));
        % BrC AAOD will be the residual
        BrAAOD(t) = abs1(t)-BCAAOD(t);

        % estimate the uncertainty in AAOD
        bcaae_max(t) = AAE23(t)+log(bondmie.maxdef(i));
        bcaaod_max(t) = abs3(t)*exp(-bcaae_max(t)*log(wave1/wave3));
        braaod_min(t) = abs1(t)-bcaaod_max(t);
        BrAAOD_r(t) = BrAAOD(t)-braaod_min(t);
        
        % calculate the BrC contribution
        BrCont(t) = 100*BrAAOD(t)/abs1(t);
        BrCont_r(t) = 100*BrAAOD_r(t)/abs1(t);
        
      else
        % In case there is no BrC, all absorption is due to BC
        BCAAOD(t) = abs1(t);
        BrCont(t) = 0;
        %BrAAOD(t) = 0;
      end
    end
    
  end
end

%BrCont = 100*BrAAOD./abs1;
%BrCont_r = 100*BrAAOD_r./abs1;

%hmjb acabou de rodar, vamos mostrar os resultados para os tempos= 1 e 2

for t=1:1
  disp(['======================= tempo ',num2str(t)])
  disp(['abs1/abs2/abs3=' , num2str(abs1(t)), num2str(abs2(t)), num2str(abs3(t))])
  disp(['BrAAOD='         ,num2str(BrAAOD(t))])
  disp(['BrCont='         ,num2str(BrCont(t))])
  disp(['BCAAOD='         ,num2str(BCAAOD(t))])
  disp(['AAE13='         ,num2str(AAE13(t))])
  disp(['AAE23='         ,num2str(AAE23(t))])
  disp(['realdef='        ,num2str(realdef(t))])
  disp(['bond max='       ,num2str(bondmie.maxdef(isel(t)))])
  disp(['line bond table=',num2str(isel(t))])
end

data = [BrAAOD BrAAOD_r BrCont BrCont_r BCAAOD isel AAE23]; 

