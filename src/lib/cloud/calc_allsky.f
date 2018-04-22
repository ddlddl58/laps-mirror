
          subroutine calc_allsky(i4time_solar,exposure ! ,clwc_3d,cice_3d
!    1                     ,heights_3d                              ! I
!    1                     ,rain_3d,snow_3d                         ! I
!    1                     ,pres_3d,aod_3d                          ! I
     1                     ,topo_sfc,topo,swi_2d                    ! I
     1                     ,topo_albedo_2d,land_frac,snow_cover     ! I
     1                     ,htagl                                   ! I
     1                     ,aod_ref                                 ! I
     1                     ,NX_L,NY_L,NZ_L,newloc                   ! I
     1                     ,ri_obs,rj_obs                           ! I
     1                     ,alt_a_roll,azi_a_roll                   ! I
     1                     ,sol_alt_2d,sol_azi_2d                   ! I
     1                     ,solar_alt,solar_az                      ! I
     1                     ,solar_lat,solar_lon                     ! I
     1                     ,alt_norm                                ! I
     1                     ,moon_alt_2d,moon_azi_2d,alm,azm         ! I
     1                     ,moon_mag,moon_mag_thr,elgms             ! I
     1                     ,l_solar_eclipse,eobsc,emag              ! I
     1                     ,rlat,rlon,lat,lon                       ! I
     1                     ,minalt,maxalt,minazi,maxazi,nc,nsp      ! I
     1                     ,ni_cyl,nj_cyl                           ! O
     1                     ,alt_scale,azi_scale                     ! I
     1                     ,grid_spacing_m,r_missing_data           ! I
     1                     ,l_binary,l_terrain_following            ! I
     1                     ,mode_cloud_mask,camera_cloud_mask       ! I
     1                     ,cloud_od,dist_2_topo                    ! O
     1                     ,sky_rgb_cyl,istatus)                    ! O

        use mem_allsky
        use mem_namelist, ONLY: earth_radius

        include 'trigd.inc'

        addlogs(x,y) = log10(10.**x + 10.**y)
        angdist(p1,p2,dlon) = acosd(sind(p1) * sind(p2)
     1                      + cosd(p1) * cosd(p2) * cosd(dlon))

!       Input arrays
!       real clwc_3d(NX_L,NY_L,NZ_L)      ! Control Variable
!       real cice_3d(NX_L,NY_L,NZ_L)      ! Control Variable
!       real heights_3d(NX_L,NY_L,NZ_L)   ! Control Variable
!       real rain_3d(NX_L,NY_L,NZ_L)      ! Control Variable
!       real snow_3d(NX_L,NY_L,NZ_L)      ! Control Variable
!       real pres_3d(NX_L,NY_L,NZ_L)      ! Control Variable
!       real aod_3d(NX_L,NY_L,NZ_L)       
        real topo(NX_L,NY_L)
        real land_frac(NX_L,NY_L)
        real snow_cover(NX_L,NY_L)
        real du_2d(NX_L,NY_L)
        real aod_2d(NX_L,NY_L)
        real swi_2d(NX_L,NY_L)
        real topo_albedo_2d(nc,NX_L,NY_L)
        real alt_a_roll(minalt:maxalt,minazi:maxazi)
        real azi_a_roll(minalt:maxalt,minazi:maxazi)
        real sol_alt_2d(NX_L,NY_L)
        real sol_azi_2d(NX_L,NY_L)
        real alt_norm(NX_L,NY_L)   ! Solar Alt w.r.t. terrain normal
        real eobsc(NX_L,NY_L)
        real moon_alt_2d(NX_L,NY_L)
        real moon_azi_2d(NX_L,NY_L)
        real lat(NX_L,NY_L)
        real lon(NX_L,NY_L)
        integer camera_cloud_mask(minalt:maxalt,minazi:maxazi)
        integer sim_cloud_mask(minalt:maxalt,minazi:maxazi)
        integer diff_cloud_mask(minalt:maxalt,minazi:maxazi)

!       Output arrays
        real sky_rgb_cyl(0:2,minalt:maxalt,minazi:maxazi) ! Observed Variable
        real cloud_od(minalt:maxalt,minazi:maxazi)
        real*8 dist_2_topo(minalt:maxalt,minazi:maxazi)

!       Local arrays (e.g. outputs from get_cloud_rays)
!       real transm_3d(NX_L,NY_L,NZ_L)
!       real transm_4d(NX_L,NY_L,NZ_L,nc) 

        real r_cloud_3d(minalt:maxalt,minazi:maxazi)
        real cloud_od_sp(minalt:maxalt,minazi:maxazi,nsp)
        real airmass_2_cloud_3d(minalt:maxalt,minazi:maxazi)
        real airmass_2_topo_3d(minalt:maxalt,minazi:maxazi)
        real topo_swi(minalt:maxalt,minazi:maxazi)
        real topo_albedo(nc,minalt:maxalt,minazi:maxazi)
        real topo_lf(minalt:maxalt,minazi:maxazi)
        real topo_sc(minalt:maxalt,minazi:maxazi)
        real du_a(minalt:maxalt,minazi:maxazi)
        real aod_a(minalt:maxalt,minazi:maxazi)
        real topo_ri(minalt:maxalt,minazi:maxazi)
        real topo_rj(minalt:maxalt,minazi:maxazi)
        real topo_lat(minalt:maxalt,minazi:maxazi)
        real topo_lon(minalt:maxalt,minazi:maxazi)
        real trace_ri(minalt:maxalt,minazi:maxazi)
        real trace_rj(minalt:maxalt,minazi:maxazi)
        real topo_solalt(minalt:maxalt,minazi:maxazi)
        real topo_solazi(minalt:maxalt,minazi:maxazi)
        real trace_solalt(minalt:maxalt,minazi:maxazi)
        real eobsc_sky(minalt:maxalt,minazi:maxazi)
        real gtic(nc,minalt:maxalt,minazi:maxazi)
        real dtic(nc,minalt:maxalt,minazi:maxazi)
        real btic(nc,minalt:maxalt,minazi:maxazi)
        real emic(nc,minalt:maxalt,minazi:maxazi)
        real aod_2_cloud(minalt:maxalt,minazi:maxazi)
        real aod_2_topo(minalt:maxalt,minazi:maxazi)
        real aod_ill(minalt:maxalt,minazi:maxazi)
        real aod_ill_dir(minalt:maxalt,minazi:maxazi)
        real aod_tot(minalt:maxalt,minazi:maxazi)
        real r_cloud_rad(minalt:maxalt,minazi:maxazi)
        real cloud_rad_c(nc,minalt:maxalt,minazi:maxazi)
        real cloud_rad_w(minalt:maxalt,minazi:maxazi)
        real cloud_sfc_c(nc,minalt:maxalt,minazi:maxazi)  
        real clear_rad_c(nc,minalt:maxalt,minazi:maxazi)
        real clear_radf_c(nc,minalt:maxalt,minazi:maxazi)
        real clear_rad_c_nt(nc,minalt:maxalt,minazi:maxazi)

!       Other Local Arrays
        real blog_moon_roll(minalt:maxalt,minazi:maxazi)
        real blog_sun_roll(minalt:maxalt,minazi:maxazi)
        real glow_stars(nc,minalt:maxalt,minazi:maxazi)

        real ext_g(nc)               ! od per airmass
        real moon_mag,moon_mag_thr
        logical l_solar_eclipse, l_binary, l_zod, l_phase
        logical l_terrain_following

        integer mode_cloud_mask ! 1 is ignore cloud mask
                                ! 2 is display cloud mask differences
                                ! 3 perform cloud mask clearing
        
        write(6,*)' subroutine calc_allsky...'

        pi = 3.14159265
        rpd = pi / 180.

        ext_g(1) = .090 ! 0.14 * (wa/.55)**(-4)
        ext_g(2) = .144 ! 0.14 * (wa/.55)**(-4)
        ext_g(3) = .312 ! 0.14 * (wa/.55)**(-4)

        iobs = nint(ri_obs)
        jobs = nint(rj_obs)

        if(iobs .lt. 1 .or. iobs .gt. NX_L .OR. 
     1     jobs .lt. 1 .or. jobs .gt. NY_L)then
          write(6,*)' ERROR, viewpoint outside of domain',iobs,jobs
          return
        endif

        isound = iobs
        jsound = jobs

        swi_obs = swi_2d(iobs,jobs) ! initialize
        write(6,*)' swi_2d at observer location 1 = ',swi_obs,'W/m^2'
        eobsl = eobsc(iobs,jobs)
        write(6,*)' eobsl = ',eobsl
        eobsc_sky = 0. ! initialize

        write(6,*)' call get_cloud_rays...'

!         Get line of sight from isound/jsound
          call get_cloud_rays(i4time_solar,clwc_3d,cice_3d
     1                     ,heights_3d                              ! I
     1                     ,rain_3d,snow_3d                         ! I
     1                     ,pres_3d,aod_3d,topo_sfc,topo            ! I
     1                     ,topo_albedo_2d                          ! I
     1                     ,swi_2d                                  ! I
     1                     ,topo_swi,topo_albedo                    ! O
     1                     ,gtic,dtic,btic,emic                     ! O
     1                     ,topo_ri,topo_rj                         ! O
     1                     ,trace_ri,trace_rj                       ! O
     1                     ,swi_obs                                 ! O
!    1                     ,ghi_2d,dhi_2d                           ! O
     1                     ,aod_vrt,aod_2_cloud,aod_2_topo          ! O
     1                     ,dist_2_topo                             ! O
     1                     ,aod_ill,aod_ill_dir                     ! O
     1                     ,aod_tot,transm_obs,obs_glow_zen         ! O
     1                     ,transm_3d,transm_4d                     ! O
     1                     ,r_cloud_3d,cloud_od,cloud_od_sp         ! O
     1                     ,r_cloud_rad,cloud_rad_c,cloud_rad_w     ! O
     1                     ,clear_rad_c,clear_radf_c,patm           ! O
     1                     ,clear_rad_c_nt                          ! O
     1                     ,airmass_2_cloud_3d,airmass_2_topo_3d    ! O
     1                     ,htmsl,horz_dep,twi_0                    ! O
!    1                     ,solalt_limb_true                        ! O
     1                     ,htagl                                   ! I
     1                     ,aod_ref                                 ! I
     1                     ,NX_L,NY_L,NZ_L,isound,jsound,newloc     ! I
     1                     ,ri_obs,rj_obs                           ! I
     1                     ,alt_a_roll,azi_a_roll                   ! I
     1                     ,sol_alt_2d,sol_azi_2d                   ! I
     1                     ,alt_norm                                ! I
     1                     ,moon_alt_2d,moon_azi_2d                 ! I
     1                     ,moon_mag,moon_mag_thr                   ! I
     1                     ,l_solar_eclipse,eobsc,rlat,rlon,lat,lon ! I
     1                     ,minalt,maxalt,minazi,maxazi             ! I
     1                     ,alt_scale,azi_scale                     ! I
     1                     ,l_binary,l_terrain_following            ! I
     1                     ,grid_spacing_m,r_missing_data           ! I
     1                     ,istatus)                                ! O

          write(6,*)' Return from get_cloud_rays: ',a9time
     1             ,' aod_vrt is ',aod_vrt

          write(6,*)' observer htagl/htmsl ',htagl,htmsl
          write(6,*)' swi_2d at observer location 2 = ',swi_obs,'W/m^2'

          solalt_limb_true = solar_alt + horz_dep
          write(6,*)' solalt_true = ',solar_alt
          write(6,*)' solalt_limb_true = ',solalt_limb_true

!         Moon glow in cylindrical coordinates (add color info)?                   
          blog_moon_roll = 0.
!         if(moon_mag .lt. moon_mag_thr .AND.
          if(.true.                     .AND.
     1       alm      .gt. 0.           .AND.
     1       l_solar_eclipse .eqv. .false.    )then
            write(6,*)' Moon glow being calculated: ',alm,azm
            diam_deg = 0.5
            l_phase = .true.
            call great_circle(alm,azm,solar_alt,solar_az,gcdist,va)
            rill = (1. - cosd(elgms)) / 2.
            write(6,*)' vertex angle / rill is ',va,rill
            call get_glow_obj(i4time,alt_a_roll,azi_a_roll
     1                       ,minalt,maxalt,minazi,maxazi 
     1                       ,alt_scale,azi_scale
     1                       ,htmsl,patm
     1                       ,alm,azm,moon_mag,.false.
     1                       ,l_phase,rill,va
     1                       ,dum1,dum2,dum3
     1                       ,diam_deg,horz_dep,blog_moon_roll)

            write(6,*)' range of blog_moon_roll is',
     1          minval(blog_moon_roll),maxval(blog_moon_roll)
          endif

!         Sun glow in cylindrical coordinates, treated as round?
          blog_sun_roll = 0.
          if(l_solar_eclipse .eqv. .true.)then
              if(eobsl .ge. 1.0)then ! totality
                  s_mag = -12.5
              else                   ! partial
                  s_mag = -26.74 - (log10(1.0-eobsl))*2.5
              endif
              diam_deg = 8.0    
              write(6,*)' Corona glow being calculated: '
              l_phase = .false.
              call get_glow_obj(i4time,alt_a_roll,azi_a_roll
     1                     ,minalt,maxalt,minazi,maxazi 
     1                     ,alt_scale,azi_scale
     1                     ,htmsl,patm
     1                     ,solar_alt,solar_az,s_mag,l_solar_eclipse
     1                     ,l_phase,rill,va
     1                     ,alm,azm,emag ! used for solar eclipse
     1                     ,diam_deg,horz_dep,blog_sun_roll)
              write(6,31)minval(blog_sun_roll)
     1                  ,maxval(blog_sun_roll),eobsl,s_mag
 31           format('  range of blog_sun_roll (corona) is',4f10.4)
          endif

          if(emag .lt. 1.0)then
            s_mag = -26.74      ! at mean distance
            diam_deg = 0.533239 ! at mean distance
            write(6,*)' Sun glow being calculated: '
            l_phase = .false.
            call get_glow_obj(i4time,alt_a_roll,azi_a_roll
     1                     ,minalt,maxalt,minazi,maxazi 
     1                     ,alt_scale,azi_scale
     1                     ,htmsl,patm
     1                     ,solar_alt,solar_az,s_mag,l_solar_eclipse
     1                     ,l_phase,rill,va
     1                     ,alm,azm,emag ! used for solar eclipse
     1                     ,diam_deg,horz_dep,blog_sun_roll)
            write(6,*)' range of blog_sun_roll is',
     1          minval(blog_sun_roll),maxval(blog_sun_roll),diam_deg
          else
            write(6,*)' Total eclipse, sun glow not calculated'
          endif

!         if(solar_alt .ge. 0.)then
!         if(.true.)then
          I4_elapsed = ishow_timer()
!         write(6,*)' call get_skyglow_cyl for sun or moon...'

!         Get all sky for cyl   
          ni_cyl = maxalt - minalt + 1
          nj_cyl = maxazi - minazi + 1

          I4_elapsed = ishow_timer()

          if(solar_alt .lt. 0. .OR. l_solar_eclipse .eqv. .true.)then
              write(6,*)' call get_starglow with cyl data'
              l_zod = (.not. l_solar_eclipse)
              call get_starglow(i4time_solar,alt_a_roll,azi_a_roll       ! I
     1                     ,minalt,maxalt,minazi,maxazi                  ! I
     1                     ,rlat,rlon,alt_scale,azi_scale,horz_dep       ! I
     1                     ,l_zod                                        ! I
     1                     ,glow_stars)                                  ! O

              write(6,*)' range of glow_stars (before) is',
     1             minval(glow_stars(2,:,:)),maxval(glow_stars(2,:,:))

              write(6,*)' range of moonglow is',
     1             minval(blog_moon_roll),maxval(blog_moon_roll)

              write(6,*)' Moonglow is being added to starlight'       
              do j = minazi,maxazi
              do i = minalt,maxalt
                do ic = 1,nc
                  glow_stars(ic,i,j) = 
     1              addlogs(glow_stars(ic,i,j),blog_moon_roll(i,j))
                enddo ! ic
              enddo ! i 
              enddo ! j 

              write(6,*)' range of glow_stars (after) is',
     1             minval(glow_stars(2,:,:)),maxval(glow_stars(2,:,:))
          else
              glow_stars(:,:,:) = 0. ! initialize
          endif

          I4_elapsed = ishow_timer()

          if(solar_alt .gt. -3.)then
                call get_idx(solar_alt,minalt,alt_scale,ialt_sun)
                call get_idx(solar_az ,minazi,azi_scale,jazi_sun)
                ialt_sun = ialt_sun - minalt + 1
                jazi_sun = jazi_sun - minazi + 1
                write(6,*)' solar_alt,minalt,alt_scale = '
     1                     ,solar_alt,minalt,alt_scale
                write(6,*)' ialt_sun,jazi_sun = ',ialt_sun,jazi_sun
          endif

          do j = minazi,maxazi
          do i = minalt,maxalt

!            Initialize
             trace_solalt(i,j) = solar_alt
             topo_solalt(i,j) = solar_alt
             topo_solazi(i,j) = solar_az
             topo_lf(i,j) = 1.
             topo_sc(i,j) = 0.

             itrace = nint(trace_ri(i,j))
             jtrace = nint(trace_rj(i,j))
             if(htmsl .gt. 7000. .and. alt_a_roll(i,j) .lt. 0.)then
                if(itrace .ge. 1 .and. itrace .le. NX_L .and.
     1             jtrace .ge. 1 .and. jtrace .le. NY_L)then
                   trace_solalt(i,j) = sol_alt_2d(itrace,jtrace)
                   eobsc_sky(i,j) = eobsc(itrace,jtrace)
                else ! outside domain - estimate solar altitude at sea level
                   htmsl = htagl + topo_sfc
                   if(azi_a_roll(i,j) .eq. 90.)then
                      iverbose = 1
                   else
                      iverbose = 0
                   endif

                   if(dist_2_topo(i,j) .gt. 0.)then ! ray hits sfc
                     call latlon_ray(rlat,rlon,htmsl,alt_a_roll(i,j)
     1               ,azi_a_roll(i,j),dist_2_topo(i,j),rlat_sfc,rlon_sfc
     1               ,iverbose,istatus)
                     solzen_sfc = angdist(rlat_sfc,solar_lat 
     1                                   ,rlon_sfc-solar_lon)
                     trace_solalt(i,j) = 90. - solzen_sfc
                     if(iverbose .eq. 1)then
                       write(6,41)i,j,alt_a_roll(i,j),azi_a_roll(i,j)
     1                          ,dist_2_topo(i,j),rlat_sfc,rlon_sfc
     1                          ,trace_solalt(i,j)
41                     format(' setting trace_solalt outside domain: '
     1                      ,2i6,2f9.3,f10.1,3f9.3)
                     endif

                   else                             ! ray misses sfc
                     gcdist_km = (horz_dep * rpd * earth_radius) / 1000.
                     call RAzm_Lat_Lon_GM(rlat,rlon,gcdist_km 
     1                     ,azi_a_roll(i,j),rlat_limb,rlon_limb,istatus)
                     solzen_sfc = angdist(rlat_limb,solar_lat 
     1                                   ,rlon_limb-solar_lon)
                     trace_solalt(i,j) = 90. - solzen_sfc
                     if(iverbose .eq. 1)then
                       write(6,42)i,j,alt_a_roll(i,j),azi_a_roll(i,j)
     1                          ,gcdist_km,rlat_limb,rlon_limb
     1                          ,trace_solalt(i,j)
42                     format(' setting trace_solalt off limb: '
     1                      ,2i6,2f9.3,f10.1,3f9.3)
                     endif

                   endif ! dist_2_topo > 0
                endif
             endif

             itopo = nint(topo_ri(i,j))
             jtopo = nint(topo_rj(i,j))
             if(itopo .ge. 1 .and. itopo .le. NX_L .and.
     1          jtopo .ge. 1 .and. jtopo .le. NY_L)then
                    topo_solalt(i,j) = sol_alt_2d(itopo,jtopo)
                    topo_solazi(i,j) = sol_azi_2d(itopo,jtopo)
                    eobsc_sky(i,j) = eobsc(itopo,jtopo)
                    topo_lat(i,j) = lat(itopo,jtopo) ! bilin interp?
                    topo_lon(i,j) = lon(itopo,jtopo) ! bilin interp?
                    topo_lf(i,j) = land_frac(itopo,jtopo) ! bilin interp?
                    if(snow_cover(itopo,jtopo) .ne. r_missing_data)then
                        topo_sc(i,j) = snow_cover(itopo,jtopo)
                    else
                        topo_sc(i,j) = 0.
                    endif
                    du_a(i,j) = du_2d(itopo,jtopo) ! bilin interp?
                    aod_a(i,j) = aod_2d(itopo,jtopo) ! bilin interp?
             endif

             if(alt_a_roll(i,j) .eq. -90. .and. j .eq. 1)then
                write(6,*)' nadir info'
                write(6,*)' i/j/lat/lon/lf',itopo,jtopo
     1                       ,topo_lat(i,j),topo_lon(i,j),topo_lf(i,j)
     1                       ,topo_albedo(:,i,j)
             endif

          enddo ! i
          enddo ! j

          if(l_binary .eqv. .false.)then
              write(6,*)' call get_sky_rgb with cyl data'
              if(htagl .ge. 1000e3)then                    ! High alt
                corr1_in = 9.1             ! for high scattering angle
              elseif(htagl .eq. 300.)then                  ! BAO
                if(solar_alt .lt. 30.)then
                  corr1_in = 9.2                            ! low sun
                elseif(solar_alt .gt. 60.)then
                  corr1_in = 8.9                            ! high sun
                else
                  corr1_in = 9.2 - (solar_alt-30.)*(0.3/30.)! med sun
                endif
              else
                corr1_in = 9.1
                if(solar_alt .lt. 0.)corr1_in = 9.26 ! volcanic value
              endif
              corr1_in = corr1_in ! - log10(exposure)

              write(6,*)' corr1 in calc_allsky ',corr1_in

!             This can be more accurate by using surface pressure
              patm_sfc = ztopsa(topo(isound,jsound)) / 1013.25
              patm_sfc = max(patm_sfc,patm)

              write(6,*)' patm/patm_sfc in calc_allsky ',patm,patm_sfc

              write(6,*)' call get_sky_rgb with cyl data '
     1                   ,l_solar_eclipse
              call get_sky_rgb(r_cloud_3d    ! cloud opacity
     1                    ,cloud_od          ! cloud optical depth
     1                    ,cloud_od_sp,nsp   ! cloud species optical depth
     1                    ,r_cloud_rad       ! cloud solar transmittance
     1                    ,cloud_rad_c       ! cloud solar transmittance / color
     1                    ,cloud_rad_w       ! cloud solar transmittance * rad
     1                    ,cloud_sfc_c       ! cld rad from sfc lighting (sru)
     1                    ,clear_rad_c       ! clear sky illumination by sun     
     1                    ,l_solar_eclipse,i4time_solar,rlat,rlon,eobsl
     1                    ,clear_radf_c      ! clear sky frac illumination by sun     
     1                    ,patm,patm_sfc,htmsl
     1                    ,clear_rad_c_nt    ! night sky brightness
!    1                    ,blog_v_roll       ! skyglow
     1                    ,blog_sun_roll     ! sunglow
     1                    ,blog_moon_roll    ! moonglow
     1                    ,glow_stars        ! starglow
     1                    ,ext_g
     1                    ,aod_vrt,aod_ref 
     1                    ,transm_obs,obs_glow_zen ! observer illumination
     1                    ,ialt_sun,jazi_sun ! sun location
     1                    ,airmass_2_cloud_3d      
     1                    ,airmass_2_topo_3d      
     1                    ,swi_obs           ! sw at ground below observer 
     1                    ,topo_swi,topo_albedo,gtic,dtic,btic,emic
     1                    ,topo_albedo_2d(:,isound,jsound)
     1                    ,topo_lat,topo_lon,topo_lf,topo_sc            ! I
     1                    ,aod_2_cloud,aod_2_topo,aod_ill,aod_ill_dir
     1                    ,aod_tot
     1                    ,dist_2_topo,topo_solalt,topo_solazi
     1                    ,trace_solalt,eobsc_sky
     1                    ,alt_a_roll,azi_a_roll ! I   
     1                    ,ni_cyl,nj_cyl,azi_scale  
     1                    ,solar_alt,solar_az                           ! I
     1                    ,solar_lat,solar_lon                          ! I
     1                    ,minalt,maxalt,minazi,maxazi                  ! I
     1                    ,twi_0,horz_dep
     1                    ,solalt_limb_true
     1                    ,alm,azm,moon_mag  ! moon alt/az/mag
     1                    ,corr1_in,exposure
     1                    ,sky_rgb_cyl)                                 ! O   

!             Add bounds to rgb values
              do j = minazi,maxazi
              do i = minalt,maxalt
                final_scaling = 1.0
                sky_rgb_cyl(:,i,j) = 
     1            max(min(sky_rgb_cyl(:,i,j)*final_scaling,255.),0.)
              enddo ! i
              enddo ! j

          else
              continue ! use cloud_od to drive categorical output

          endif ! l_binary

!         Cloud mask section
          if(mode_cloud_mask .eq. 1)then
              write(6,*)' Skipping camera_cloud_mask processing'
          else
              write(6,*)' Showing cloud mask differences'
      
              write(6,*)' camera cloud mask...'
              do ialt = maxalt,minalt,-10
                 write(6,61)ialt,(camera_cloud_mask(ialt,ia)
     1                          ,ia=minazi,maxazi,6)
61               format(1x,i3,1x,300i1)
              enddo ! ialt
      
              do j = minazi,maxazi
              do i = minalt,maxalt
                  if(cloud_od(i,j) .gt. 0.3)then
                      sim_cloud_mask(i,j) = 2
                  else
                      sim_cloud_mask(i,j) = 1
                  endif
              enddo ! i
              enddo ! j
              write(6,*)' simulated cloud mask...'
              do ialt = maxalt,minalt,-10
                 write(6,61)ialt,(sim_cloud_mask(ialt,ia)
     1                          ,ia=minazi,maxazi,6)
              enddo ! ialt
      
              write(6,*)' difference cloud mask...'
              do j = minazi,maxazi
              do i = minalt,maxalt
                  if(camera_cloud_mask(i,j) .eq. 0)then
                      if(camera_cloud_mask(i,j) .eq. 2 .and.
     1                   sim_cloud_mask(i,j)    .eq. 1        )then
                          diff_cloud_mask(i,j) = 2 ! add cloud (potentially)
                      elseif(camera_cloud_mask(i,j) .eq. 1 .and.
     1                       sim_cloud_mask(i,j)    .eq. 2        )then
                          diff_cloud_mask(i,j) = 1 ! clearing
                      else
                          diff_cloud_mask(i,j) = 0 ! no change
                      endif
                  else
                      diff_cloud_mask(i,j) = 0     ! no change
                  endif                      
              enddo ! i
              enddo ! j
              do ialt = maxalt,minalt,-10
                 write(6,61)ialt,(diff_cloud_mask(ialt,ia)
     1                          ,ia=minazi,maxazi,6)
              enddo ! ialt

              if(mode_cloud_mask .eq. 3)then
                  write(6,*)' Performing camera_cloud_mask clearing'
!                 call clear_3d_mask()
              endif
          endif

          write(6,*)' End of calc_allsky...'

          return
          end

          subroutine latlon_ray(rlat,rlon,htmsl,altray,aziray,tpdist
     1                         ,tlat,tlon,iverbose,istatus)

          use mem_namelist, ONLY: r_missing_data,earth_radius
          
          include 'trigd.inc'

          real*8 tpdist,dslant1_h
          real*8 dsdst,dradius_start,daltray,dcurvat2

          dcurvat2(dsdst,dradius_start,daltray) = 
     1        sqrt(dsdst**2 + dradius_start**2 
     1   - (2D0*dsdst*dradius_start*cosd(90D0+daltray))) - dradius_start   

          dradius_start = earth_radius + htmsl

!         sinarc = sind(90d0+dble(altray))*tpdist/dble(earth_radius)

          dz1_h = dcurvat2(dslant1_h,dradius_start,dble(altray))   
          gc_deg = asind(cosd(altray)
     1           *     tpdist / (dradius_start+dz1_h)) 
          
          ycost = cosd(aziray)

!         Obtain latlon from spherical geometry
          TLat = ASinD(ycost*SinD(gc_deg)*CosD(rLat) 
     1         + SinD(rLat)*CosD(gc_deg))

          CosDLon = (CosD(gc_deg) - SinD(rLat)*SinD(TLat)) 
     1            / (CosD(rLat)*CosD(TLat))
          If(Abs(CosDLon).gt.1.)CosDLon=Sign(1.,CosDLon)
          DLon = ACosD(CosDLon)
                  
          If(aziray.ge..0.and.aziray.le.180.)Then ! east
             TLon=rLon+DLon
          Else ! west
             TLon=rLon-DLon
          EndIf

          if(iverbose .eq. 1)then
            write(6,11)rlat,rlon,htmsl,altray,aziray,tpdist
     1                ,dradius_start,dlon,tlat,tlon
11          format('   latlon_ray ',2f9.3,f12.1,2f9.3,2f12.1,3f9.3)
          endif

          istatus = 1
          
          return
          end
