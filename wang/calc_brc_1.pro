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


n1 = n_elements(bondmie.aae)

    AAE675 = -alog(abs2/abs3)/alog(675./870.)

    for i = 0, n1-1 do begin

      if AAE675 ge bondmie[i].aae-0.1 and $
         AAE675 lt bondmie[i].aae+0.1 then begin

        AAE440 = -alog(abs1/abs2)/alog(440./870.)
        realdef = exp(AAE440) / exp(AAE675) 
        
        if realdef gt bondmie[i].maxdef then begin

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
          BCAAOD = abs1
          BrCont = 0
        endelse

      endif
       
    endfor

result = [BrAAOD, BrAAOD_r, BrCont, BrCont_r, BCAAOD]

return, result



  
end


