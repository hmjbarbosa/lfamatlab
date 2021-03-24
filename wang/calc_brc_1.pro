function calc_brc_1, abs1,abs2,abs3

;==========================================================
;calculate BrC absorptions at 440nm based on derivation curves
;for multiple-wav measurements at 440/675/870 or any similar conditions
;the input aae1 is the 3 absorption/AAOD at the 3 wavelength
;the returned value is a 5-elements- array of :
;[mid-estimate BrC abs/AAOD ,uncertainty,
; mid-estimate BrC contribution,uncertainty,
; mid-estimate BC abs/AAOD] at 440nm
;xnw, 20150309
;==========================================================

restore, './basemie_AERONET.sav'

BrAAOD = -999.
BCAAOD = -999.
BrAAOD_r = -999.
BrCont = -999.
BrCont_r = -999.

;hmjb init AAE
AAE440 = -999.
;hmjb save Bond table line number
isel = -1

n1 = n_elements(bondmie.aae)

    AAE675 = -alog(abs2/abs3)/alog(675./870.)

    for i = 0, n1-1 do begin

;hmjb Table has values for .1, .3, .5, .7, .9, 1.1, 1.3 and 1.6
; Hence, the test bellow means a gap for 1.4 < AAE <= 1.5 because it
; is not in the +-0.1 range. For the last table line (1.6) the lower
; limit has to be 1.6-0.2 = 1.4
       
;      if AAE675 ge bondmie[i].aae-0.1 and $
;         AAE675 lt bondmie[i].aae+0.1 then begin

      lowlim = bondmie[i].aae-0.1
      if i eq n1-1 then begin
         lowlim = bondmie[i].aae-0.2
      endif
    
      if AAE675 ge lowlim and $
         AAE675 lt bondmie[i].aae+0.1 then begin

;hmjb Should be AAE between 440 (abs1) and 880 (abs3)
;bug        AAE440 = -alog(abs1/abs2)/alog(440./870.)
        AAE440 = -alog(abs1/abs3)/alog(440./870.)
        realdef = exp(AAE440) / exp(AAE675) 
;hmjb save selected line
        isel = i
        
        if realdef gt bondmie[i].maxdef then begin
;hmjb
          print, 'There is BrC!'
          bcaae = AAE675 + alog(bondmie[i].middef)
          BCAAOD = abs3 *  exp(-bcaae * alog(440./870.))
          BrAAOD = abs1 - BCAAOD
          
          bcaae_max = AAE675 + alog(bondmie[i].maxdef)
          bcaaod_max = abs3 * exp(-bcaae_max * alog(440./870.))
          braaod_min = abs1 - bcaaod_max
          BrAAOD_r = BrAAOD - braaod_min

          BrCont = 100* BrAAOD / abs1
          BrCont_r = 100* BrAAOD_r / abs1

        endif else begin
;hmjb
          print, 'Could not find BrC :-('
          BCAAOD = abs1
          BrCont = 0
        endelse

      endif
       
    endfor

result = [BrAAOD, BrAAOD_r, BrCont, BrCont_r, BCAAOD]

;hmjb print some helpful output
print, 'BrC_AAOD=',BrAAOD
print, 'BrC_Cont=',BrCont
print, 'BC_AAOD=',BCAAOD
print, 'AAE_440_880=',AAE440
print, 'AAE_675_880=',AAE675
print, 'realdef=',realdef
print, 'bond max=',bondmie[isel].maxdef
;hmjb IDL start counting from 0, but we want table lines starting at 1
print, 'line bond table=',isel+1

return, result



  
end


