function [brcdata] = calc_brc_1(abs1,abs2,abs3,wave1,wave2,wave3,tidx)
%CALC_BRC_1   Estimate BrC from absorption measurements.
%   [brcdata] = CALC_BRC_1(abs1,abs2,abs3,wave1,wave2,wave3) uses absorption
%   measurements (abs1, abs2, and abs3) at three wavelengths (wave1, wave2,
%   wave3) to estimate the brown carbon. Wavelengths are expected in nm, and
%   absorptions can be either AAOD (no units) or Extinction (Mm-1),
%   typically as Nx1 arrays (e.g. from in-situ measurement). brcdata will
%   be Nx5, with output columns corresponding to:
%
%      col1) BrC absorption
%      col2) uncertainty of BrC absorption
%      col3) Relative contribution (%) of BrC to absorption
%      col4) uncertainty of Relative contribution (%) of BrC to absorption
%      col5) BC absorption 
%
%   CALC_BRC_1(...,tidx) will print detailed information for all array
%   indexes (i.e. times) given in tidx. 
%
%   METHOD
%
%   Abs values at wave2 and wave3 are assumed to be influenced by BC alone.
%   Together with a look-up-table based on MIE calculations, they are used
%   to extrapolate the BC absorption to wave1. The effect of the brown
%   carbon is then computed as the total absorption at wave1 subtracted by
%   the extrapolated BC absorption. The 3 wavelengths are those from
%   AERONET: 
%
%      wave1) UV (440nm)
%      wave2) Visible (675nm)
%      wave3) NIR (870nm)
%
%   If you decide to use different wavelengths, note that they should still
%   be "compatible" with those used in the Mie simulation, i.e., you should
%   expect the AAE to be similar for your wavelengths and the original ones.
%
%   Also note that this approach for separating brown and black carbon
%   absorptions assumes that you only have BC and BrC. If there are dust
%   particles contributing to your absorption measurements, you may need to
%   exclude them first.
%
%   The methodology was developed by Xuan Wang and is described in: 
%
%      Wang, X., et al., 2016: Deriving Brown Carbon from Multi-Wavelength
%         Absorption Measurements: Method and Application to AERONET and
%         Aethalometer Observations Atmos. Chem. Phys., 16, 12733-12752,
%         doi:10.5194/acp-16-12733-2016.
% 
%   HISTORY
%
%   24-March-2021 Revamped Matlab version by Henrique Barbosa (USP). 
%                 This includes major bug fixes: 
%                 - Handling of time series
%                 - Correct abs for AAE440
%                 - Correct AAE intervals in MIE table
%                 - Extrapolate BC using mid value instead of min
%                 - Numerical optimization
%
%            2018 Matlab version by Rafael Palacios (UFMT)
%
%   10-April-2017 Original IDL code from Xuan Wang (MIT)
%
%   CONTACT: hmjbarbosa@gmail.com
%

%%

% Check if all inputs are present
if nargin<6
  error('Expected at least 6 arguments, 3 absorptions and 3 wavelengths.')
end
% Check arrays have the same length
if (numel(abs1) ~= numel(abs2)) | (numel(abs2) ~= numel(abs3))
  error('Absorption arrays must have the same lengths.')
end
% Check arrays are 1-D
if (min(size(abs1))>1) | (min(size(abs2))>1) | (min(size(abs3))>1)
  error('Absorption arrays must be 1-dimension (vary only with time).')
end
% Check arrays are Nx1
if size(abs1,1)==1; abs1 = abs1'; end
if size(abs2,1)==1; abs2 = abs2'; end
if size(abs3,1)==1; abs3 = abs3'; end
% Check wavelengths are numbers
if (numel(wave1)~=1) | (numel(wave2)~=1) | (numel(wave3)~=1)
  error('Wavelengths are numbers, not arrays.')
end
% Check they are increasing
if ~( (wave1<wave2) & (wave2<wave3) )
  error('Condition wave1 < wave2 < wave3 not satisfied.')
end
% Check units (kind of...)
if (wave1<1e2) | (wave2<1e2) | (wave3<1e2) | ...
   (wave1>1e3) | (wave2>1e3) | (wave3>1e3)
  error('Wavelengths must be given in nm.')
end
% Check for reasonable values
if (wave1<400) | (wave1>500)
  error(['Unreasonable wave1 = ' num2str(wave1) ' nm'])
end
if (wave2<625) | (wave2>725)
  error(['Unreasonable wave2 = ' num2str(wave2) ' nm'])
end
if (wave3<820) | (wave3>920)
  error(['Unreasonable wave3 = ' num2str(wave3) ' nm'])
end

%%

% Mie calculations as discussed in Wang's paper
% Shared as a binary IDL file named "basemie_AERONET.sav"
% basemie = [...
%     0.1,       0.856656,       0.971063,       0.913860 ;...
%     0.3,       0.818784,       0.923744,       0.871264 ;...
%     0.5,       0.778845,       0.904880,       0.841863 ;...
%     0.7,       0.764685,       0.877989,       0.821337 ;...
%     0.9,       0.753013,       0.890559,       0.821786 ;...
%     1.1,       0.752517,       1.051050,       0.901783 ;...
%     1.3,       0.767029,       1.089620,       0.928326 ;...
%     1.6,       0.811395,       1.030230,       0.920813  ];
% basemie_aae, basemie_mindef, basemie_maxdef, basemie_middef
basemie_aae    = [     0.1,      0.3,      0.5,      0.7,      0.9,      1.1,      1.3,      1.6];
basemie_Hlim   = [     0.2,      0.4,      0.6,      0.8,      1.0,      1.2,      1.4,      1.7];
basemie_Llim   = [     0.0,      0.2,      0.4,      0.6,      0.8,      1.0,      1.2,      1.4];
basemie_mindef = [0.856656, 0.818784, 0.778845, 0.764685, 0.753013, 0.752517, 0.767029, 0.811395];
basemie_maxdef = [0.971063, 0.923744, 0.904880, 0.877989, 0.890559, 1.051050, 1.089620, 1.030230];
basemie_middef = [0.913860, 0.871264, 0.841863, 0.821337, 0.821786, 0.901783, 0.928326, 0.920813];
basemie_N = length(basemie_aae);

% Initialize all variables
ntimes = numel(abs1);
AAE13    = nan(ntimes,1);
%AAE23    = nan(ntimes,1);
realdef    = nan(ntimes,1);
BrAAOD     = nan(ntimes,1);
BrAAOD_r   = nan(ntimes,1);
BrCont     = nan(ntimes,1);
BrCont_r   = nan(ntimes,1);
bcaae      = nan(ntimes,1);
bcaae_max  = nan(ntimes,1);
bcaaod_max = nan(ntimes,1);
braaod_min = nan(ntimes,1);
BCAAOD     = nan(ntimes,1);
isel       = nan(ntimes,1);

% Compute AAE between wave2 and wave3 
AAE23 = -log(abs2./abs3)/log(wave2/wave3);

% Compute AAE between wave1 and wave3
% NOTE: Wang's original code had a bug and used abs1/abs2
AAE13 = -log(abs1./abs3)/log(wave1/wave3);

%% LOOP on time 
for t = 1:ntimes
  
  %% LOOP on MIE table lines
  for i = 1:basemie_N
    
    if (AAE23(t) >= basemie_Llim(i)) & (AAE23(t) < basemie_Hlim(i))
      % Save MIE table line number used for each time t
      isel(t) = i;
      
      % Compute AAE between wave1 and wave3
      % NOTE: Wang's original code had a bug and used abs1/abs2
      %AAE13(t) = -log(abs1(t)/abs3(t))/log(wave1/wave3);
      
      % Change in slope
      realdef(t) = exp(AAE13(t))/exp(AAE23(t));
      
      % We found BrC (for sure) if the change in slope is larger than the
      % maximum change in the MIE calculations (which included only BC)
      if realdef(t) > basemie_maxdef(i);

        % extrapolate BC AAE to wave1
        bcaae(t) = AAE23(t)+log(basemie_middef(i));
        % use it to compute AAOD
        BCAAOD(t) = abs3(t)*exp(-bcaae(t)*log(wave1/wave3));
        % BrC AAOD will be the residual
        BrAAOD(t) = abs1(t)-BCAAOD(t);

        % estimate the uncertainty in AAOD
        bcaae_max(t) = AAE23(t)+log(basemie_maxdef(i));
        bcaaod_max(t) = abs3(t)*exp(-bcaae_max(t)*log(wave1/wave3));
        braaod_min(t) = abs1(t)-bcaaod_max(t);
        BrAAOD_r(t) = BrAAOD(t)-braaod_min(t);
        
        % calculate the BrC contribution
        BrCont(t) = 100*BrAAOD(t)/abs1(t);
        BrCont_r(t) = 100*BrAAOD_r(t)/abs1(t);
        
      else
        % In case there is no BrC, all absorption is due to BC
        BCAAOD(t)   = abs1(t);
        BrCont(t)   = 0;
        BrCont_r(t) = 0;
        BrAAOD(t)   = 0;
        BrAAOD_r(t) = 0;
      end
    end
    
  end
end

% detailed results for tidx
if exist('tidx')
  for t=tidx
    disp(['======================= Time= ',num2str(t)])
    disp(['abs1/abs2/abs3 = ', num2str([abs1(t), abs2(t), abs3(t)])])
    disp(['BrC_AAOD       = ', num2str(BrAAOD(t))])
    disp(['BrC_Cont(%)    = ', num2str(BrCont(t))])
    disp(['BC_AAOD        = ', num2str(BCAAOD(t))])
    disp(['AAE_13         = ', num2str(AAE13(t))])
    disp(['AAE_23         = ', num2str(AAE23(t))])
    disp(['realdef        = ', num2str(realdef(t))])
    disp(['table line#    = ', num2str(isel(t))])
    if ~isnan(isel(t))
      disp(['maxdef         = ', num2str(basemie_maxdef(isel(t)))])
    else
      disp(['maxdef         = ', num2str(nan)])
    end
  end
end

% output
brcdata.BrAAOD    = BrAAOD;
brcdata.BrAAOD_r  = BrAAOD_r;
brcdata.BrCont    = BrCont;
brcdata.BrCont_r  = BrCont_r;
brcdata.BCAAE     = bcaae;
brcdata.BCAAOD    = BCAAOD;
brcdata.AAOD      = abs1;
brcdata.tableline = isel;
brcdata.AAE13     = AAE13;
brcdata.AAE23     = AAE23;
brcdata.ABS = [abs1,abs2,abs3];
brcdata.WAVE = [wave1,wave2,wave3];

