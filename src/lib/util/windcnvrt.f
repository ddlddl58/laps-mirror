cdis   
cdis    Open Source License/Disclaimer, Forecast Systems Laboratory
cdis    NOAA/OAR/FSL, 325 Broadway Boulder, CO 80305
cdis    
cdis    This software is distributed under the Open Source Definition,
cdis    which may be found at http://www.opensource.org/osd.html.
cdis    
cdis    In particular, redistribution and use in source and binary forms,
cdis    with or without modification, are permitted provided that the
cdis    following conditions are met:
cdis    
cdis    - Redistributions of source code must retain this notice, this
cdis    list of conditions and the following disclaimer.
cdis    
cdis    - Redistributions in binary form must provide access to this
cdis    notice, this list of conditions and the following disclaimer, and
cdis    the underlying source code.
cdis    
cdis    - All modifications to this software must be clearly documented,
cdis    and are solely the responsibility of the agent making the
cdis    modifications.
cdis    
cdis    - If significant modifications or enhancements are made to this
cdis    software, the FSL Software Policy Manager
cdis    (softwaremgr@fsl.noaa.gov) should be notified.
cdis    
cdis    THIS SOFTWARE AND ITS DOCUMENTATION ARE IN THE PUBLIC DOMAIN
cdis    AND ARE FURNISHED "AS IS."  THE AUTHORS, THE UNITED STATES
cdis    GOVERNMENT, ITS INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND
cdis    AGENTS MAKE NO WARRANTY, EXPRESS OR IMPLIED, AS TO THE USEFULNESS
cdis    OF THE SOFTWARE AND DOCUMENTATION FOR ANY PURPOSE.  THEY ASSUME
cdis    NO RESPONSIBILITY (1) FOR THE USE OF THE SOFTWARE AND
cdis    DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL SUPPORT TO USERS.
cdis   
cdis
cdis
cdis   
cdis
        subroutine windcnvrt(uwind,vwind,direction,speed)
c
c-----  Given wind components, calculate the corresponding speed and direction.
c-----  Hacked up from the windcnvrt_gm program.

c
C Argument      I/O     Type                    Description
C --------      ---     ----    -----------------------------------------------
C UWind          I      R*4     U-component of wind
C VWind          I      R*4     V-component of wind
C Direction      O      R*4     Wind direction (meteorological degrees)
C Speed          O      R*4     Wind speed (same units as input arguments)
c
C-----  If magnitude of UWind or VWind > 1E18, Speed and Direction set to -99.
c
        real          Flag
        Parameter      (Flag=1.e37)
c
        Real          UWind,VWind,Direction,Speed
c
        If(Abs(UWind).gt.1E18.or.Abs(VWind).gt.1E18)Then
         Speed=Flag
         Direction=Flag
        ElseIF(Uwind.eq.0.0.and.VWind.eq.0.0)Then
         Speed=0.0
         Direction=0.0                                  !Undefined
        Else
         Speed=SqRt(UWind*UWind+VWind*VWind)            !Wind speed
         Direction=57.2957795*(ATan2(UWind,VWind))+180. !Wind direction (deg)
        EndIf
c
        Return
        End
