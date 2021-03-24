This is an IDL script to seperate BC and BrC AAOD from AERONET
measurements. The method is described in:

Wang, X., C.L. Heald, A.J. Sedlacek, S.S. de Sa, S.T. Martin,
M.L. Alexander, T.B. Watson, A.C. Aiken, S.R. Springston, P. Artaxo
(2016), Deriving Brown Carbon from Multi-Wavelength Absorption
Measurements: Method and Application to AERONET and Aethalometer Observations
Atmos. Chem. Phys., 16, 12733-12752, doi:10.5194/acp-16-12733-2016.

How to use:

1) You need to put both ".pro" and ".sav" files in the same location
as your processing directory.

2) Note that this approach is for separating brown and black carbon
absorptions. If there are dust absorption contributing your
measurements, you may need to exclude them first.

3) Use the function calc_brc_1 in IDL environment, for example:

result = calc_brc_1(a, b, c)

Input: a, b, and c are the original AERONET AAOD at 440, 675 and 870nm

Output is a 5-elements array: [result[0], result[1], result[2], result[3], result[4]]

result[0] is the calculated brown carbon AAOD at 440nm
result[1] is the methodology uncertainty of result[0]
result[2] is the calculated contribution of brown carbon AAOD to total AAOD at 440nm, in %
result[3] is the methodology uncertainty of result[2]
result[4] is the calculated BC AAOD at 440nm

Contact: Xuan Wang, xuanw12@mit.edu
