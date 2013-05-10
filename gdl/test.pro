;
; Load the samples from the file
;
pro load,name,items

  openr,1,name

  s=findgen(items+1,items+1)

  for i=0,items do begin;
     for j=0,items do begin;
        readf,1,x,y,intensity
        s[i,j]=intensity
     endfor
  endfor

  close,1

  surface,s,title='Spherical Oscillator'
  return
end

;
; Read the configuration file
;
pro load_cfg,name 
   openr,lun,name+'.cfg',/get_lun

   line=''
   WHILE NOT EOF(lun) DO BEGIN ;
      READF, lun, line
       
      pos=strpos(line, '=' )
      if( pos GT -1 ) then begin
          tag=strmid(line,0,pos)
          value=strmid(line,pos+1)

          result[tag]=value
       endif
   ENDWHILE

   free_lun,lun

   return

end





