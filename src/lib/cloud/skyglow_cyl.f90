
       subroutine skyglow_cyl(altsource_in,azisource_in,blog_v_roll,elong_roll,od_atm_a &
                             ,minalt,maxalt,minazi,maxazi,alt_scale,azi_scale)

       include 'trigd.inc'

       real*8 xs,ys,zs,xo,yo,zo              
       real*8 magn_r8,elong_r8,altdif_r8,al1_r8,al2_r8,elgms_r8,elgmc_r8
       real*8 al_t_r8,als_ct_r8,alm_best_r8
       real*8 maglimd_r8,maglimt_r8,maglimn_r8,maglim_r8
       real*8 vis_r8
       character*1 c_observe

       logical l_process_azi(minazi:maxazi)

!      real blog_s(minalt:maxalt,minazi:maxazi)
       real blog_v(minalt:maxalt,minazi:maxazi)
       real blog_v_out(minalt:maxalt,minazi:maxazi)
       real blog_v_roll(minalt:maxalt,minazi:maxazi)
       real elong_a(minalt:maxalt,minazi:maxazi)
       real elong_out(minalt:maxalt,minazi:maxazi)
       real elong_roll(minalt:maxalt,minazi:maxazi)
!      real rmaglim_s(minalt:maxalt,minazi:maxazi)
       real rmaglim_v(minalt:maxalt,minazi:maxazi)

       real*8 PI, RPD                            
       PI = 3.1415926535897932d0; RPD = PI/180.d0

       blog_v = 0.
       elong_a = 0.

       degint_alt = 2.

       call get_val(minalt,minalt,alt_scale,altmin)
       call get_val(maxalt,minalt,alt_scale,altmax)

       skyglow_in = 1.0
       patm = 0.85

       write(6,*)' Start skyglow_cyl for ',altsource_in,azisource_in

       write(6,*)
       write(6,*)'   alt   skyglow_in   skyglow_out  diff_mag del-logb'   

       rmag = -26.9
       azisource = 180.

       l_process_azi = .false.
       do iazi = minazi,maxazi/2,nint(10./azi_scale)
           l_process_azi(iazi) = .true.
       enddo
       do iazi = nint(160./azi_scale),maxazi/2,nint(2./azi_scale)              
           l_process_azi(iazi) = .true.
       enddo
       do iazi = nint(170./azi_scale),maxazi/2,nint(1./azi_scale)              
           l_process_azi(iazi) = .true.
       enddo

       if(.true.)then                      
!          altsource = max(altsource_in,0.)
           altsource = altsource_in     
           write(6,*)
           write(6,*)'                     Solar Altitude = ',altsource
           do aziobj = 0.,180.,azi_scale                   
             call get_idx(aziobj,minazi,azi_scale,jazi)
             if(l_process_azi(jazi) .eqv. .true.)then
               write(6,*)' Aziobj/jazi = ',aziobj,jazi
               do altobj = altmax,altmin,-degint_alt
!                  write(6,*)' Altobj = ',altobj
                   xs = cosd(altsource) * cosd(azisource)
                   ys = cosd(altsource) * sind(azisource)
                   zs = sind(altsource)

                   xo = cosd(altobj) * cosd(aziobj)
                   yo = cosd(altobj) * sind(aziobj)
                   zo = sind(altobj)

                   call anglevectors(xs,ys,zs,xo,yo,zo,elong_r8)
                   elong_r8 = elong_r8 / rpd
                   elong = elong_r8            

                   if(aziobj .eq. 180. .OR. aziobj .eq. 0.)then
                       idebug = 1
                       write(6,*)
                       write(6,*)'Debug for alt/az/elong ',altobj,aziobj,elong
                   else
                       idebug = 0
                   endif

!                  Schaeffer routine
!                  call get_skyglow(rmag,altsource,altobj,elong,patm,skyglow)

                   call get_idx(altobj,minalt,alt_scale,ialt)
!                  blog_s(ialt,jazi) = log10(skyglow)
                   call calc_extinction(90.      ,patm,airmass,zenext)
                   altobj_e = max(altobj,.001)
                   call calc_extinction(altobj_e,patm,airmass,totexto)
!                  rmaglim_s(ialt,jazi) = b_to_maglim(skyglow) - (totexto - zenext)

!                  VI routine
                   magn_r8 = -10.
                   altdif_r8 = -1.0
                   al1_r8 = 0.     
                   al2_r8 = 0.
                   elgms_r8 = 0.
                   elgmc_r8 = 180.
                   al_t_r8 = max(altobj,.001)
                   als_ct_r8 = altsource
                   alm_best_r8 = 0.
                   elong_r8 = max(elong_r8,1.50d0)

!                  Consider settings for the moon

                   if(altsource .ge. 0.)then
                     call vi(magn_r8,elong_r8,altdif_r8,al1_r8,al2_r8,elgms_r8,elgmc_r8 &
                          ,al_t_r8,als_ct_r8,alm_best_r8,od_atm_a &
                          ,maglimd_r8,maglimt_r8,maglimn_r8,maglim_r8 &
                          ,vis_r8,c_observe)
                     if(maglim_r8 .lt. -900.d0)then
                       write(6,*)' warning in vi (maglim/elong) ',maglim_r8,elong_r8
                     endif
                     rmaglim_v(ialt,jazi) = maglim_r8
                     rmaglim_v_noextinction = maglim_r8 + (totexto - zenext)
                     skyglow = rmaglim_to_b(rmaglim_v_noextinction)

                   else ! twilight (sun below horizon)
                     call vi2(magn_r8,elong_r8,altdif_r8,al1_r8,al2_r8,elgms_r8,elgmc_r8 &
                          ,al_t_r8,als_ct_r8,alm_best_r8,od_atm_a &
                          ,maglimd_r8,maglimt_r8,maglimn_r8,maglim_r8 &
                          ,idebug,vis_r8,c_observe)
                     if(maglim_r8 .lt. -900.d0)then
                       write(6,*)' warning in vi (maglim/elong) ',maglim_r8,elong_r8
                     endif
                     rmaglim_v(ialt,jazi) = maglim_r8
                     rmaglim_v_noextinction = maglim_r8 + (totexto - zenext)
!                    skyglow = rmaglim_to_b(rmaglim_v_noextinction)
                     skyglow = rmaglim_to_b(rmaglim_v(ialt,jazi))    

                   endif

                   if(skyglow .le. 0.)then
                       write(6,*)' Error in skyglow value ',skyglow,rmaglim_v_noextinction,maglim_r8,totexto,zenext
                       stop
                   endif
                   blog_v(ialt,jazi) = log10(skyglow)
                   elong_a(ialt,jazi) = elong                
                   if(idebug .eq. 1)then
                       write(6,101)maglim_r8,altobj_e,totexto,rmaglim_v_noextinction,blog_v(ialt,jazi)
101                    format(' maglim/altobj_e/totexto/maglim_noext/blog_v',5f8.3)
                   endif
               enddo ! altobj
             endif ! process this azimuth
           enddo ! aziobj

           write(6,*)

           do altobj = altmax,altmin,-10.
               call get_idx(altobj,minalt,alt_scale,ialt)
               write(6,13)altobj,(blog_v(ialt,jazi),jazi=0,maxazi,maxazi/12)
13             format('altobj,blog_v ',f8.2,13f6.2)
           enddo ! altobj
!          lun = 41                            
!          write(lun,*)blog_v         

           write(6,*)
!          Fill in altitudes with blog_v/elong     
           write(6,*)' Fill interpolated altitudes in blog_v/elong'
           ialt_delt = nint(2. / alt_scale)
           do altobj = altmax,altmin,-alt_scale
!            if(altobj .ne. nint(altobj/2.) * 2.)then ! odd altitudes
!              ialt = nint((altobj-altmin)/alt_scale)
               call get_idx(altobj,minalt,alt_scale,ialt)
               call get_interp_parms(minalt,maxalt,ialt_delt,ialt &     ! I
                                    ,fm,fp,ialtm,ialtp,ir,istatus)      ! O
               write(6,*)' altobj/fm/fp/ialtm/ialtp',altobj,fm,fp,ialtm,ialtp
               if(ir .ne. 0)then
                 blog_v(ialt,:)  = fm * blog_v(ialtm,:)  + fp * blog_v(ialtp,:)
                 elong_a(ialt,:) = fm * elong_a(ialtm,:) + fp * elong_a(ialtp,:)
               endif
!            endif
           enddo ! altobj

           blog_v_out  = blog_v
           elong_out = elong_a

!          Fill in azimuths with blog_v
           write(6,*)' Fill interpolated azimuths in blog_v_out'  
           do iazi = minazi,maxazi/2,1
               if(blog_v(0,iazi) .gt. 0.)then
!                  write(6,*)' azi already filled ',iazi
               else
                   do iazim = iazi-1,0,-1
                       if(blog_v(0,iazim) .gt. 0.)then
                           iazi_m = iazim
                           distm = iazi - iazim
                           goto 21
                       endif
                   enddo
21                 do iazip = iazi+1,maxazi/2,+1
                       if(blog_v(0,iazip) .gt. 0.)then
                           iazi_p = iazip
                           distp = iazip - iazi 
                           goto 22
                       endif
                   enddo
22                 continue
!                  write(6,*)' fill azi ',iazi_m,iazi,iazi_p
                   dist = distm + distp
                   frac = distm / dist
                   if(iazi_m .lt. 0 .or. iazi_m .gt. maxazi .or. iazi_p .lt. 0 .or. iazi_p .gt. maxazi)then
                       write(6,*)' ERROR in iazi values'
                       stop
                   endif
                   blog_v_out(:,iazi) = blog_v(:,iazi_m) * (1. - frac)  &
                                      + blog_v(:,iazi_p) *       frac
                   elong_out(:,iazi)  = elong_a(:,iazi_m) * (1. - frac)  &
                                      + elong_a(:,iazi_p) *       frac
               endif

               iazi_mirror = maxazi - iazi
               blog_v_out(:,iazi_mirror) = blog_v_out(:,iazi)
               elong_out(:,iazi_mirror)  = elong_out(:,iazi)

           enddo ! iazi

       endif ! true       

       iroll = nint((azisource_in - azisource)/azi_scale)

       write(6,*)' Roll image by azimuth ',iroll,azisource_in

       do iazir = 0,maxazi
           iazio = iazir - iroll
           if(iazio .gt. maxazi)iazio = iazio - maxazi
           if(iazio .lt.   0)iazio = iazio + maxazi
           blog_v_roll(:,iazir) = blog_v_out(:,iazio)
           elong_roll(:,iazir)  = elong_out(:,iazio)
           if(iazir .le. 10)write(6,*)'iazio,iazir',iazio,iazir
       enddo ! iazir

       do altobj = altmax,altmin,-10.
           call get_idx(altobj,minalt,alt_scale,ialt)
           write(6,23)altobj,(blog_v_roll(ialt,jazi),jazi=0,maxazi,maxazi/12)
23         format('altobj,blog_v_roll ',f8.2,13f6.2)
       enddo ! altobj

       write(6,*)' End of skyglow_cyl'

       return
       end

       subroutine get_interp_parms(minidx,maxidx,intidx,idx &         ! I
                                  ,fm,fp,im,ip,ir,istatus)            ! O

       istatus = 1

       ir = mod(idx-minidx,intidx)
       if(ir .ne. 0)then
           im = idx - ir
           ip = im + intidx
           fp = float(ir) / float(intidx)
           fm = 1.0 - fp
       else ! interp not needed
           im = idx
           ip = idx
           fp = 1.0
           fm = 0.0
       endif

       if(ip .gt. maxidx .OR. im .lt. minidx)then
           write(6,*)' ERROR in get_interp_parms',minidx,maxidx,idx,im,ip
           istatus = 0
       endif

       return
       end
       

        subroutine get_idx(val,minidx,scale,idx)

        idx = nint(val / scale)

        return
        end

        subroutine get_val(idx,minidx,scale,val)

        val = float(idx) * scale

        return
        end
