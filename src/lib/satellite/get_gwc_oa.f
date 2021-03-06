       Subroutine get_gwc_oa(filename,imc_id,rec,ir,istatus)
C
C ***************************************************************************** 
C *****************************************************************************
C	SUBROUTINE TO READ IN AFGWC'S SDHS GOES "ORBIT AND ATTITUDE" (OA) DATA,
C	CONVERT FROM GOULD FLOATING POINT VALUES TO SUN/IBM FOR ULTIMATE USE IN 
C	NOAA'S "GIMLOC" EARTH-LOCATION SOFTWARE.
C
C	ORIGINAL:	BRUCE H. THOMAS, MARCH 1997
C			THE AEROSPACE CORPORATION AND DMSP SPO
C			ENVIRONMENTAL APPLICATIONS CENTER
C
C	PURPOSE:	THE CODE WAS DEVELOPED TO ALLOW SDHS GOES-GVAR DATA TO
C			BE USED WITHIN NOAA/FSL'S LAPS MODEL.  THE PROJECT WAS
C			UNDERTAKEN AS A PROTOTYPE FOR THE GTWAPS PROGRAM.
C
C	NOTES:		CODE IS EXPLICIT WHEN DECODING EACH "O+A" WORD FOR
C			CLARITY AND DOCUMENTATION; COULD BE SIMPLIFIED WITH
C			LOOPS IF SHORTER CODE IS DESIRED!!!!
C
C	SUBROUTINES CALLED: 
C 
C	1) BCD_TO_INT - DECODES THE "BINARY CODED DECIMAL" DATE/TIME FROM O+A
C	2) BYTESWP4   - SWAPS "LITTLE ENDIAN" 4-BYTE INTEGERS INTO "BIG ENDIAN"
C	3) CNVTGLFL   - DECODES "GOULD FLOATING POINT" VALUES FROM O+A
C	4) CNVTINT    - DECODES "GOULD INTEGER" VALUES FROM O+A
C
C *****************************************************************************
C *****************************************************************************
C
      IMPLICIT NONE
C
      LOGICAL PRINT_FLAG
        
      CHARACTER*4 IMC_ID
      INTEGER OADATA(336),I,ir
      INTEGER BYTESWP4
      REAL*8 REC(ir)
      REAL*8 RTIME
c
      Character*255 filename
      Integer     istatus
C
C     DATA PRINT_FLAG / .TRUE. /
      DATA PRINT_FLAG / .FALSE. /
C     DATA REC / 336*0.0D0 /
C
C     EQUIVALENCE (OADATA(1), IMC_ID)
      EQUIVALENCE (OADATA(12), RTIME)
C
      PRINT *,'***************************'
      PRINT *,'GOES_OA: START OF EXECUTION'
      PRINT *,'***************************'
      ISTATUS = 0
c
c J.Smart: 5-13-97. Initialize array rec
c
      do i=1,ir
         rec(i)=0.0D0
      enddo
C
C *****************************************************************************
C     OPEN INPUT FILE THROUGH SOFT LINK TO "FORT.10"
C *****************************************************************************
C
      OPEN(UNIT=10,file=filename,FORM='UNFORMATTED',ACCESS='DIRECT'
     &,STATUS='OLD',RECL=1412,ERR=1010)
C
C *****************************************************************************
C     READ IN THE ORBIT AND ATTITUDE DATA
C *****************************************************************************
C
      READ(10,REC=1,ERR=300) OADATA
C
C *****************************************************************************
C     CLOSE INPUT FILE
C *****************************************************************************
C
      CLOSE(10)
C
C *****************************************************************************
C *****************************************************************************
C     SWAP INPUT DATA FROM "LITTLE ENDIAN (VAX)" TO "BIG ENDIAN (SUN/IBM), AKA
C     CHANGE THE 4-BYTE INTEGER'S BYTE ORDER.
C *****************************************************************************
C *****************************************************************************
C
      DO 100 I=2,336
        OADATA(I)=BYTESWP4(OADATA(I))
100   CONTINUE
C
C *****************************************************************************
C *****************************************************************************
C *****************************************************************************
C     CONVERT THE "GOULD FLOATING POINT" INTO SUN/IBM DOUBLE PRECISION USING
C     THE SUBROUTINE "CNVTGLFL."
C *****************************************************************************
C *****************************************************************************
C *****************************************************************************
C
C *****************************************************************************
C     WORD 1 IS THE FOUR BYTE CHARACTER "IMC IDENTIFIER"
C     WORDS 2-4 ARE SPARES
C *****************************************************************************
      write(imc_id,112)oadata(1)
112   format(a)

      CALL CNVTGLFL(OADATA(005),REC(005))	! REFERENCE LONGITUDE (+ EAST)
      CALL CNVTGLFL(OADATA(006),REC(006))	! REFERENCE RADIAL DISTANCE FROM NOMINAL
      CALL CNVTGLFL(OADATA(007),REC(007))	! REFERENCE LATITUDE (+ NORTH)
      CALL CNVTGLFL(OADATA(008),REC(008))	! REFERENCE ORBIT YAW
      CALL CNVTGLFL(OADATA(009),REC(009))	! REFERENCE ATTITUDE: ROLE
      CALL CNVTGLFL(OADATA(010),REC(010))	! REFERENCE ATTITUDE: PITCH
      CALL CNVTGLFL(OADATA(011),REC(011))	! REFERENCE ATTITUDE: YAW
C *****************************************************************************
C     INPUT WORDS 12 AND 13 REPRESENT THE "BINARY-CODED-DECIMAL" EPOCH TIME
C     - CONVERT THE "BINARY-CODED-DECIMAL" (BCD) INTO TIME CODE REQUIRED
C *****************************************************************************
      CALL BCDTOINT (OADATA(12), OADATA(13), RTIME)
      REC(12) = RTIME
C *****************************************************************************
C     SPACECRAFT COMPENSATION ROLL, PITCH, AND YAW
C     CHANGE IN LONGITUDE FROM REFERENCE (13 VALUES)
C     CHANGE IN RADIAL DISTANCE (11 VALUES)
C     SINE IN GEOCENTRIC LATITUDE (9 VALUES)
C     SINE ORBIT YAW (9 VALUES)
C     DAILY SOLAR RATE
C     EXPONENTIAL START TIME FROM EPOCH
C *****************************************************************************
      CALL CNVTGLFL(OADATA(014),REC(014))	! IMC SET ENABLE TIME FROM EPOCH
      CALL CNVTGLFL(OADATA(015),REC(015))	! SPACECRAFT COMPENSATION ROLL
      CALL CNVTGLFL(OADATA(016),REC(016))	! SPACECRAFT COMPENSATION PITCH
      CALL CNVTGLFL(OADATA(017),REC(017))	! SPACECRAFT COMPENSATION YAW
      CALL CNVTGLFL(OADATA(018),REC(018))	! CHANGE IN LONG FROM REF #01
      CALL CNVTGLFL(OADATA(019),REC(019))	! CHANGE IN LONG FROM REF #02
      CALL CNVTGLFL(OADATA(020),REC(020))	! CHANGE IN LONG FROM REF #03
      CALL CNVTGLFL(OADATA(021),REC(021))	! CHANGE IN LONG FROM REF #04
      CALL CNVTGLFL(OADATA(022),REC(022))	! CHANGE IN LONG FROM REF #05
      CALL CNVTGLFL(OADATA(023),REC(023))	! CHANGE IN LONG FROM REF #06
      CALL CNVTGLFL(OADATA(024),REC(024))	! CHANGE IN LONG FROM REF #07
      CALL CNVTGLFL(OADATA(025),REC(025))	! CHANGE IN LONG FROM REF #08
      CALL CNVTGLFL(OADATA(026),REC(026))	! CHANGE IN LONG FROM REF #09
      CALL CNVTGLFL(OADATA(027),REC(027))	! CHANGE IN LONG FROM REF #10
      CALL CNVTGLFL(OADATA(028),REC(028))	! CHANGE IN LONG FROM REF #11
      CALL CNVTGLFL(OADATA(029),REC(029))	! CHANGE IN LONG FROM REF #12
      CALL CNVTGLFL(OADATA(030),REC(030))	! CHANGE IN LONG FROM REF #13
      CALL CNVTGLFL(OADATA(031),REC(031))	! CHANGE IN RADIAL DIST FROM REF #01
      CALL CNVTGLFL(OADATA(032),REC(032))	! CHANGE IN RADIAL DIST FROM REF #02
      CALL CNVTGLFL(OADATA(033),REC(033))	! CHANGE IN RADIAL DIST FROM REF #03
      CALL CNVTGLFL(OADATA(034),REC(034))	! CHANGE IN RADIAL DIST FROM REF #04
      CALL CNVTGLFL(OADATA(035),REC(035))	! CHANGE IN RADIAL DIST FROM REF #05
      CALL CNVTGLFL(OADATA(036),REC(036))	! CHANGE IN RADIAL DIST FROM REF #06
      CALL CNVTGLFL(OADATA(037),REC(037))	! CHANGE IN RADIAL DIST FROM REF #07
      CALL CNVTGLFL(OADATA(038),REC(038))	! CHANGE IN RADIAL DIST FROM REF #08
      CALL CNVTGLFL(OADATA(039),REC(039))	! CHANGE IN RADIAL DIST FROM REF #09
      CALL CNVTGLFL(OADATA(040),REC(040))	! CHANGE IN RADIAL DIST FROM REF #10
      CALL CNVTGLFL(OADATA(041),REC(041))	! CHANGE IN RADIAL DIST FROM REF #11
      CALL CNVTGLFL(OADATA(042),REC(042))	! SINE GEOCENTRIC LAT, TOTAL #01
      CALL CNVTGLFL(OADATA(043),REC(043))	! SINE GEOCENTRIC LAT, TOTAL #02
      CALL CNVTGLFL(OADATA(044),REC(044))	! SINE GEOCENTRIC LAT, TOTAL #03
      CALL CNVTGLFL(OADATA(045),REC(045))	! SINE GEOCENTRIC LAT, TOTAL #04
      CALL CNVTGLFL(OADATA(046),REC(046))	! SINE GEOCENTRIC LAT, TOTAL #05
      CALL CNVTGLFL(OADATA(047),REC(047))	! SINE GEOCENTRIC LAT, TOTAL #06
      CALL CNVTGLFL(OADATA(048),REC(048))	! SINE GEOCENTRIC LAT, TOTAL #07
      CALL CNVTGLFL(OADATA(049),REC(049))	! SINE GEOCENTRIC LAT, TOTAL #08
      CALL CNVTGLFL(OADATA(050),REC(050))	! SINE GEOCENTRIC LAT, TOTAL #09
      CALL CNVTGLFL(OADATA(051),REC(051))	! SINE ORBIT YAW, TOTAL #01
      CALL CNVTGLFL(OADATA(052),REC(052))	! SINE ORBIT YAW, TOTAL #02
      CALL CNVTGLFL(OADATA(053),REC(053))	! SINE ORBIT YAW, TOTAL #03
      CALL CNVTGLFL(OADATA(054),REC(054))	! SINE ORBIT YAW, TOTAL #04
      CALL CNVTGLFL(OADATA(055),REC(055))	! SINE ORBIT YAW, TOTAL #05
      CALL CNVTGLFL(OADATA(056),REC(056))	! SINE ORBIT YAW, TOTAL #06
      CALL CNVTGLFL(OADATA(057),REC(057))	! SINE ORBIT YAW, TOTAL #07
      CALL CNVTGLFL(OADATA(058),REC(058))	! SINE ORBIT YAW, TOTAL #08
      CALL CNVTGLFL(OADATA(059),REC(059))	! SINE ORBIT YAW, TOTAL #09
      CALL CNVTGLFL(OADATA(060),REC(060))	! DAILY SOLAR RATE
      CALL CNVTGLFL(OADATA(061),REC(061))	! EXPONENTIAL START TIME FROM EPOCH
C *****************************************************************************
C *****************************************************************************
C     BLOCK OF CODE APPLYS TO ROLL ATTITUDE ANGLE:
C *****************************************************************************
C *****************************************************************************
      CALL CNVTGLFL(OADATA(062),REC(062))	! EXPONENTIAL MAGNITUDE 
      CALL CNVTGLFL(OADATA(063),REC(063))	! EXPONENTIAL TIME CONSTANT
      CALL CNVTGLFL(OADATA(064),REC(064))	! CONSTANT, MEAN ATTITUDE ANGLE
      CALL CNVTINT(OADATA(065))
      REC(065) = DFLOAT(OADATA(065))		! NUMBER OF SINUSOIDS/ANGLES
C *****************************************************************************
C     MAGNITUDE/PHASE ANGLE OF FIRST->FIFTEENTH ORDER SINUSOIDS 
C *****************************************************************************
      CALL CNVTGLFL(OADATA(066),REC(066))	! MAGNITUDE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(067),REC(067))	! PHASE ANGLE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(068),REC(068))	! MAGNITUDE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(069),REC(069))	! PHASE ANGLE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(070),REC(070))	! MAGNITUDE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(071),REC(071))	! PHASE ANGLE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(072),REC(072))	! MAGNITUDE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(073),REC(073))	! PHASE ANGLE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(074),REC(074))	! MAGNITUDE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(075),REC(075))	! PHASE ANGLE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(076),REC(076))	! MAGNITUDE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(077),REC(077))	! PHASE ANGLE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(078),REC(078))	! MAGNITUDE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(079),REC(079))	! PHASE ANGLE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(080),REC(080))	! MAGNITUDE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(081),REC(081))	! PHASE ANGLE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(082),REC(082))	! MAGNITUDE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(083),REC(083))	! PHASE ANGLE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(084),REC(084))	! MAGNITUDE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(085),REC(085))	! PHASE ANGLE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(086),REC(086))	! MAGNITUDE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(087),REC(087))	! PHASE ANGLE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(088),REC(088))	! MAGNITUDE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(089),REC(089))	! PHASE ANGLE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(090),REC(090))	! MAGNITUDE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(091),REC(091))	! PHASE ANGLE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(092),REC(092))	! MAGNITUDE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(093),REC(093))	! PHASE ANGLE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(094),REC(094))	! MAGNITUDE OF 15TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(095),REC(095))	! PHASE ANGLE OF 15TH ORDER SINUSOID
      CALL CNVTINT(OADATA(096))
      REC(096) = DFLOAT(OADATA(096))		! NUMBER OF MONOMIAL SINUSOIDS
      CALL CNVTINT(OADATA(097))
      REC(097) = DFLOAT(OADATA(097))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(098))
      REC(098) = DFLOAT(OADATA(098))		! ORDER OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(099),REC(099))	! MAGNITUDE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(100),REC(100))	! PHASE ANGLE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(101),REC(101))	! ANGLE FROM EPOCH WHERE 1ST MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(102))
      REC(102) = DFLOAT(OADATA(102))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(103))
      REC(103) = DFLOAT(OADATA(103))		! ORDER OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(104),REC(104))	! MAGNITUDE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(105),REC(105))	! PHASE ANGLE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(106),REC(106))	! ANGLE FROM EPOCH WHERE 2ND MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(107))
      REC(107) = DFLOAT(OADATA(107))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(108))
      REC(108) = DFLOAT(OADATA(108))		! ORDER OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(109),REC(109))	! MAGNITUDE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(110),REC(110))	! PHASE ANGLE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(111),REC(111))	! ANGLE FROM EPOCH WHERE 3RD MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(112))
      REC(112) = DFLOAT(OADATA(112))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(113))
      REC(113) = DFLOAT(OADATA(113))		! ORDER OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(114),REC(114))	! MAGNITUDE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(115),REC(115))	! PHASE ANGLE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(116),REC(116))	! ANGLE FROM EPOCH WHERE 4TH MONOMIAL IS ZERO
C *****************************************************************************
C *****************************************************************************
C     BLOCK OF CODE APPLYS TO PITCH ATTITUDE ANGLE:
C *****************************************************************************
C *****************************************************************************
      CALL CNVTGLFL(OADATA(117),REC(117))	! EXPONENTIAL MAGNITUDE 
      CALL CNVTGLFL(OADATA(118),REC(118))	! EXPONENTIAL TIME CONSTANT
      CALL CNVTGLFL(OADATA(119),REC(119))	! CONSTANT, MEAN ATTITUDE ANGLE
      CALL CNVTINT(OADATA(120))
      REC(120) = DFLOAT(OADATA(120))		! NUMBER OF SINUSOIDS/ANGLES
C *****************************************************************************
C     MAGNITUDE/PHASE ANGLE OF FIRST->FIFTEENTH ORDER SINUSOIDS 
C *****************************************************************************
      CALL CNVTGLFL(OADATA(121),REC(121))	! MAGNITUDE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(122),REC(122))	! PHASE ANGLE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(123),REC(123))	! MAGNITUDE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(124),REC(124))	! PHASE ANGLE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(125),REC(125))	! MAGNITUDE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(126),REC(126))	! PHASE ANGLE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(127),REC(127))	! MAGNITUDE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(128),REC(128))	! PHASE ANGLE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(129),REC(129))	! MAGNITUDE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(130),REC(130))	! PHASE ANGLE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(131),REC(131))	! MAGNITUDE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(132),REC(132))	! PHASE ANGLE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(133),REC(133))	! MAGNITUDE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(134),REC(134))	! PHASE ANGLE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(135),REC(135))	! MAGNITUDE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(136),REC(136))	! PHASE ANGLE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(137),REC(137))	! MAGNITUDE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(138),REC(138))	! PHASE ANGLE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(139),REC(139))	! MAGNITUDE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(140),REC(140))	! PHASE ANGLE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(141),REC(141))	! MAGNITUDE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(142),REC(142))	! PHASE ANGLE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(143),REC(143))	! MAGNITUDE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(144),REC(144))	! PHASE ANGLE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(145),REC(145))	! MAGNITUDE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(146),REC(146))	! PHASE ANGLE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(147),REC(147))	! MAGNITUDE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(148),REC(148))	! PHASE ANGLE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(149),REC(149))	! MAGNITUDE OF 15TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(150),REC(150))	! PHASE ANGLE OF 15TH ORDER SINUSOID
      CALL CNVTINT(OADATA(151))
      REC(151) = DFLOAT(OADATA(151))		! NUMBER OF MONOMIAL SINUSOIDS
      CALL CNVTINT(OADATA(152))
      REC(152) = DFLOAT(OADATA(152))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(153))
      REC(153) = DFLOAT(OADATA(153))		! ORDER OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(154),REC(154))	! MAGNITUDE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(155),REC(155))	! PHASE ANGLE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(156),REC(156))	! ANGLE FROM EPOCH WHERE 1ST MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(157))
      REC(157) = DFLOAT(OADATA(157))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(158))
      REC(158) = DFLOAT(OADATA(158))		! ORDER OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(159),REC(159))	! MAGNITUDE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(160),REC(160))	! PHASE ANGLE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(161),REC(161))	! ANGLE FROM EPOCH WHERE 2ND MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(162))
      REC(162) = DFLOAT(OADATA(162))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(163))
      REC(163) = DFLOAT(OADATA(163))		! ORDER OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(164),REC(164))	! MAGNITUDE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(165),REC(165))	! PHASE ANGLE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(166),REC(166))	! ANGLE FROM EPOCH WHERE 3RD MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(167))
      REC(167) = DFLOAT(OADATA(167))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(168))
      REC(168) = DFLOAT(OADATA(168))		! ORDER OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(169),REC(169))	! MAGNITUDE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(170),REC(170))	! PHASE ANGLE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(171),REC(171))	! ANGLE FROM EPOCH WHERE 4TH MONOMIAL IS ZERO
C *****************************************************************************
C *****************************************************************************
C     BLOCK OF CODE APPLYS TO YAW ATTITUDE ANGLE:
C *****************************************************************************
C *****************************************************************************
      CALL CNVTGLFL(OADATA(172),REC(172))	! EXPONENTIAL MAGNITUDE 
      CALL CNVTGLFL(OADATA(173),REC(173))	! EXPONENTIAL TIME CONSTANT
      CALL CNVTGLFL(OADATA(174),REC(174))	! CONSTANT, MEAN ATTITUDE ANGLE
      CALL CNVTINT(OADATA(175))
      REC(175) = DFLOAT(OADATA(175))		! NUMBER OF SINUSOIDS/ANGLES
C *****************************************************************************
C     MAGNITUDE/PHASE ANGLE OF FIRST->FIFTEENTH ORDER SINUSOIDS 
C *****************************************************************************
      CALL CNVTGLFL(OADATA(176),REC(176))	! MAGNITUDE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(177),REC(177))	! PHASE ANGLE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(178),REC(178))	! MAGNITUDE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(179),REC(179))	! PHASE ANGLE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(180),REC(180))	! MAGNITUDE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(181),REC(181))	! PHASE ANGLE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(182),REC(182))	! MAGNITUDE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(183),REC(183))	! PHASE ANGLE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(184),REC(184))	! MAGNITUDE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(185),REC(185))	! PHASE ANGLE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(186),REC(186))	! MAGNITUDE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(187),REC(187))	! PHASE ANGLE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(188),REC(188))	! MAGNITUDE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(189),REC(189))	! PHASE ANGLE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(190),REC(190))	! MAGNITUDE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(191),REC(191))	! PHASE ANGLE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(192),REC(192))	! MAGNITUDE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(193),REC(193))	! PHASE ANGLE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(194),REC(194))	! MAGNITUDE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(195),REC(195))	! PHASE ANGLE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(196),REC(196))	! MAGNITUDE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(197),REC(197))	! PHASE ANGLE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(198),REC(198))	! MAGNITUDE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(199),REC(199))	! PHASE ANGLE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(200),REC(200))	! MAGNITUDE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(201),REC(201))	! PHASE ANGLE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(202),REC(202))	! MAGNITUDE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(203),REC(203))	! PHASE ANGLE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(204),REC(204))	! MAGNITUDE OF 15TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(205),REC(205))	! PHASE ANGLE OF 15TH ORDER SINUSOID
      CALL CNVTINT(OADATA(206))
      REC(206) = DFLOAT(OADATA(206))		! NUMBER OF MONOMIAL SINUSOIDS
      CALL CNVTINT(OADATA(207))
      REC(207) = DFLOAT(OADATA(207))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(208))
      REC(208) = DFLOAT(OADATA(208))		! ORDER OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(209),REC(209))	! MAGNITUDE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(210),REC(210))	! PHASE ANGLE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(211),REC(211))	! ANGLE FROM EPOCH WHERE 1ST MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(212))
      REC(212) = DFLOAT(OADATA(212))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(213))
      REC(213) = DFLOAT(OADATA(213))		! ORDER OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(214),REC(214))	! MAGNITUDE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(215),REC(215))	! PHASE ANGLE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(216),REC(216))	! ANGLE FROM EPOCH WHERE 2ND MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(217))
      REC(217) = DFLOAT(OADATA(217))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(218))
      REC(218) = DFLOAT(OADATA(218))		! ORDER OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(219),REC(219))	! MAGNITUDE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(220),REC(220))	! PHASE ANGLE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(221),REC(221))	! ANGLE FROM EPOCH WHERE 3RD MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(222))
      REC(222) = DFLOAT(OADATA(222))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(223))
      REC(223) = DFLOAT(OADATA(223))		! ORDER OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(224),REC(224))	! MAGNITUDE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(225),REC(225))	! PHASE ANGLE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(226),REC(226))	! ANGLE FROM EPOCH WHERE 4TH MONOMIAL IS ZERO
C *****************************************************************************
C *****************************************************************************
C     BLOCK OF CODE APPLYS TO ROLL MISALIGNMENT ANGLE:
C *****************************************************************************
C *****************************************************************************
      CALL CNVTGLFL(OADATA(227),REC(227))	! EXPONENTIAL MAGNITUDE 
      CALL CNVTGLFL(OADATA(228),REC(228))	! EXPONENTIAL TIME CONSTANT
      CALL CNVTGLFL(OADATA(229),REC(229))	! CONSTANT, MEAN ATTITUDE ANGLE
      CALL CNVTINT(OADATA(230))
      REC(230) = DFLOAT(OADATA(230))		! NUMBER OF SINUSOIDS/ANGLES
C *****************************************************************************
C     MAGNITUDE/PHASE ANGLE OF FIRST->FIFTEENTH ORDER SINUSOIDS 
C *****************************************************************************
      CALL CNVTGLFL(OADATA(231),REC(231))	! MAGNITUDE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(232),REC(232))	! PHASE ANGLE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(233),REC(233))	! MAGNITUDE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(234),REC(234))	! PHASE ANGLE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(235),REC(235))	! MAGNITUDE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(236),REC(236))	! PHASE ANGLE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(237),REC(237))	! MAGNITUDE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(238),REC(238))	! PHASE ANGLE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(239),REC(239))	! MAGNITUDE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(240),REC(240))	! PHASE ANGLE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(241),REC(241))	! MAGNITUDE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(242),REC(242))	! PHASE ANGLE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(243),REC(243))	! MAGNITUDE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(244),REC(244))	! PHASE ANGLE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(245),REC(245))	! MAGNITUDE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(246),REC(246))	! PHASE ANGLE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(247),REC(247))	! MAGNITUDE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(248),REC(248))	! PHASE ANGLE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(249),REC(249))	! MAGNITUDE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(250),REC(250))	! PHASE ANGLE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(251),REC(251))	! MAGNITUDE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(252),REC(252))	! PHASE ANGLE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(253),REC(253))	! MAGNITUDE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(254),REC(254))	! PHASE ANGLE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(255),REC(255))	! MAGNITUDE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(256),REC(256))	! PHASE ANGLE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(257),REC(257))	! MAGNITUDE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(258),REC(258))	! PHASE ANGLE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(259),REC(259))	! MAGNITUDE OF 15TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(260),REC(260))	! PHASE ANGLE OF 15TH ORDER SINUSOID
      CALL CNVTINT(OADATA(261))
      REC(261) = DFLOAT(OADATA(261))		! NUMBER OF MONOMIAL SINUSOIDS
      CALL CNVTINT(OADATA(262))
      REC(262) = DFLOAT(OADATA(262))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(263))
      REC(263) = DFLOAT(OADATA(263))		! ORDER OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(264),REC(264))	! MAGNITUDE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(265),REC(265))	! PHASE ANGLE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(266),REC(266))	! ANGLE FROM EPOCH WHERE 1ST MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(267))
      REC(267) = DFLOAT(OADATA(267))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(268))
      REC(268) = DFLOAT(OADATA(268))		! ORDER OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(269),REC(269))	! MAGNITUDE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(270),REC(270))	! PHASE ANGLE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(271),REC(271))	! ANGLE FROM EPOCH WHERE 2ND MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(272))
      REC(272) = DFLOAT(OADATA(272))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(273))
      REC(273) = DFLOAT(OADATA(273))		! ORDER OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(274),REC(274))	! MAGNITUDE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(275),REC(275))	! PHASE ANGLE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(276),REC(276))	! ANGLE FROM EPOCH WHERE 3RD MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(277))
      REC(277) = DFLOAT(OADATA(277))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(278))
      REC(278) = DFLOAT(OADATA(278))		! ORDER OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(279),REC(279))	! MAGNITUDE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(280),REC(280))	! PHASE ANGLE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(281),REC(281))	! ANGLE FROM EPOCH WHERE 4TH MONOMIAL IS ZERO
C *****************************************************************************
C *****************************************************************************
C     BLOCK OF CODE APPLYS TO PITCH MISALIGNMENT ANGLE:
C *****************************************************************************
C *****************************************************************************
      CALL CNVTGLFL(OADATA(282),REC(282))	! EXPONENTIAL MAGNITUDE 
      CALL CNVTGLFL(OADATA(283),REC(283))	! EXPONENTIAL TIME CONSTANT
      CALL CNVTGLFL(OADATA(284),REC(284))	! CONSTANT, MEAN ATTITUDE ANGLE
      CALL CNVTINT(OADATA(285))
      REC(285) = DFLOAT(OADATA(285))		! NUMBER OF SINUSOIDS/ANGLES
C *****************************************************************************
C     MAGNITUDE/PHASE ANGLE OF FIRST->FIFTEENTH ORDER SINUSOIDS 
C *****************************************************************************
      CALL CNVTGLFL(OADATA(286),REC(286))	! MAGNITUDE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(287),REC(287))	! PHASE ANGLE OF 1ST ORDER SINUSOID
      CALL CNVTGLFL(OADATA(288),REC(288))	! MAGNITUDE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(289),REC(289))	! PHASE ANGLE OF 2ND ORDER SINUSOID
      CALL CNVTGLFL(OADATA(290),REC(290))	! MAGNITUDE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(291),REC(291))	! PHASE ANGLE OF 3RD ORDER SINUSOID
      CALL CNVTGLFL(OADATA(292),REC(292))	! MAGNITUDE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(293),REC(293))	! PHASE ANGLE OF 4TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(294),REC(294))	! MAGNITUDE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(295),REC(295))	! PHASE ANGLE OF 5TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(296),REC(296))	! MAGNITUDE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(297),REC(297))	! PHASE ANGLE OF 6TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(298),REC(298))	! MAGNITUDE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(299),REC(299))	! PHASE ANGLE OF 7TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(300),REC(300))	! MAGNITUDE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(301),REC(301))	! PHASE ANGLE OF 8TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(302),REC(302))	! MAGNITUDE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(303),REC(303))	! PHASE ANGLE OF 9TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(304),REC(304))	! MAGNITUDE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(305),REC(305))	! PHASE ANGLE OF 10TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(306),REC(306))	! MAGNITUDE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(307),REC(307))	! PHASE ANGLE OF 11TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(308),REC(308))	! MAGNITUDE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(309),REC(309))	! PHASE ANGLE OF 12TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(310),REC(310))	! MAGNITUDE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(311),REC(311))	! PHASE ANGLE OF 13TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(312),REC(312))	! MAGNITUDE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(313),REC(313))	! PHASE ANGLE OF 14TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(314),REC(314))	! MAGNITUDE OF 15TH ORDER SINUSOID
      CALL CNVTGLFL(OADATA(315),REC(315))	! PHASE ANGLE OF 15TH ORDER SINUSOID
      CALL CNVTINT(OADATA(316))
      REC(316) = DFLOAT(OADATA(316))		! NUMBER OF MONOMIAL SINUSOIDS
      CALL CNVTINT(OADATA(317))
      REC(317) = DFLOAT(OADATA(317))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(318))
      REC(318) = DFLOAT(OADATA(318))		! ORDER OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(319),REC(319))	! MAGNITUDE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(320),REC(320))	! PHASE ANGLE OF 1ST MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(321),REC(321))	! ANGLE FROM EPOCH WHERE 1ST MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(322))
      REC(322) = DFLOAT(OADATA(322))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(323))
      REC(323) = DFLOAT(OADATA(323))		! ORDER OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(324),REC(324))	! MAGNITUDE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(325),REC(325))	! PHASE ANGLE OF 2ND MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(326),REC(326))	! ANGLE FROM EPOCH WHERE 2ND MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(327))
      REC(327) = DFLOAT(OADATA(327))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(328))
      REC(328) = DFLOAT(OADATA(328))		! ORDER OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(329),REC(329))	! MAGNITUDE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(330),REC(330))	! PHASE ANGLE OF 3RD MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(331),REC(331))	! ANGLE FROM EPOCH WHERE 3RD MONOMIAL IS ZERO
      CALL CNVTINT(OADATA(332))
      REC(332) = DFLOAT(OADATA(332))		! ORDER OF APPLICABLE SINUSOID
      CALL CNVTINT(OADATA(333))
      REC(333) = DFLOAT(OADATA(333))		! ORDER OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(334),REC(334))	! MAGNITUDE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(335),REC(335))	! PHASE ANGLE OF 4TH MONOMIAL SINUSOID
      CALL CNVTGLFL(OADATA(336),REC(336))	! ANGLE FROM EPOCH WHERE 4TH MONOMIAL IS ZERO
C *****************************************************************************
C     PRINT OUT THE RESULTS TO THE USER
C *****************************************************************************
      IF (PRINT_FLAG) THEN
        DO 200 I = 2,336
          WRITE(6,1100) I,REC(I)
200     CONTINUE
      ENDIF
C *****************************************************************************
C     PRINT TERMINATION MESSAGE, THEN SKIP ERROR MESSAGE
C *****************************************************************************
      PRINT *,'GOES_OA OBTAINED. NORMAL TERMINATION!'
      GOTO 400
C *****************************************************************************
C     WRITE I/O ERROR MESSAGE FOR INPUT READ, THEN STOP!
C *****************************************************************************
300   WRITE(6,1000)
      STOP
C
400   CONTINUE
C
      PRINT *,'*************************'
C
C *****************************************************************************
C     FORMAT STATEMENTS:
C *****************************************************************************
C
1000  FORMAT(T2,'GOES_OA: IO ERROR ON READ OF INPUT DATA....')
1100  FORMAT(T2,'REC = ',I3.3,', VALUE = ',E22.15)
C
      GOTO 9999

1010  WRITE(6,*)'ERROR OPENING GWC O AND A'
      ISTATUS = -1

9999  RETURN
      END
