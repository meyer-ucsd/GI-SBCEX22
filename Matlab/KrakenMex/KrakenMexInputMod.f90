MODULE KrakenMexInputMod

  USE KrakenMod
  USE sspMod
  USE SourceReceiverPositions
  USE SubTabulate
  USE SortMod
  USE FatalError

  IMPLICIT NONE

  REAL (KIND=8), PARAMETER :: DepthTol = 1.0D-9

CONTAINS

  SUBROUTINE InitKrakenMex( frq, frqCount, nl, note1, b, nc, sspIn, note2, bsig, clh, rng, nsr, zsr, zsrCount, nrc, zrc, zrcCount, freq0 )

    REAL      (KIND=8), INTENT( IN ) :: frq( * ), b( nl, 3 ), sspIn( nc, 6 ), bsig, clh( 2 ), rng, zsr( * ), zrc( * )
    REAL      (KIND=8), INTENT( OUT ) :: freq0
    INTEGER,            INTENT( IN ) :: frqCount, nl, nc, nsr, zsrCount, nrc, zrcCount
    CHARACTER,          INTENT( IN ) :: note1( 3 ), note2( 1 )

    INTEGER            :: Medium, Nneeded
    REAL      (KIND=8) :: c, deltaz
    CHARACTER (LEN=8)  :: TopOptLocal, BotOptLocal

    CALL ResetMexInputState()

    IF ( frqCount <= 0 ) CALL ERROUT( 'InitKrakenMex', 'Need at least one frequency' )
    IF ( ANY( frq( 1 : frqCount ) <= 0.0D0 ) ) CALL ERROUT( 'InitKrakenMex', 'All frequencies must be positive' )
    IF ( nl <= 0 ) CALL ERROUT( 'InitKrakenMex', 'nl must be positive' )
    IF ( nc <= 0 ) CALL ERROUT( 'InitKrakenMex', 'nc must be positive' )
    IF ( nl > MaxMedium ) CALL ERROUT( 'InitKrakenMex', 'Too many media for KrakenMod' )
    IF ( nc > MaxSSP ) CALL ERROUT( 'InitKrakenMex', 'Too many SSP points for sspMod' )
    IF ( clh( 1 ) >= clh( 2 ) ) CALL ERROUT( 'InitKrakenMex', 'Need phase speeds cLow < cHigh' )

    freq0 = MAXVAL( frq( 1 : frqCount ) )

    Title       = 'KRAKEN-MEX'
    TopOptLocal = '        '
    BotOptLocal = '        '

    TopOptLocal( 1 : 1 ) = note1( 1 )
    TopOptLocal( 2 : 2 ) = note1( 2 )
    TopOptLocal( 3 : 3 ) = note1( 3 )
    BotOptLocal( 1 : 1 ) = note2( 1 )

    TopOpt = TopOptLocal
    BotOpt = BotOptLocal

    SSP%NMedia    = nl
    SSP%Type      = TopOpt( 1 : 1 )
    SSP%AttenUnit = TopOpt( 3 : 4 )

    IF ( SSP%Type == 'A' ) CALL ERROUT( 'InitKrakenMex', 'The legacy Matlab interface does not expose analytic SSP parameters' )
    IF ( SSP%AttenUnit( 1 : 1 ) == 'm' ) CALL ERROUT( 'InitKrakenMex', 'The legacy Matlab interface does not expose beta/fT attenuation parameters' )

    CALL InitHalfspaces( TopOpt( 2 : 2 ), BotOpt( 1 : 1 ), sspIn, nc )
    CALL CopyStackedSSP( b, nl, sspIn, nc )

    DO Medium = 1, nl
       NG( Medium ) = NINT( b( Medium, 1 ) )
       SSP%sigma( Medium ) = b( Medium, 2 )
       SSP%beta( Medium )  = 0.0D0
       SSP%fT( Medium )    = freq0

       c = SSP%alphaR( SSP%Loc( Medium ) + SSP%NPts( Medium ) )
       IF ( SSP%betaR( SSP%Loc( Medium ) + SSP%NPts( Medium ) ) > 0.0D0 ) &
            c = SSP%betaR( SSP%Loc( Medium ) + SSP%NPts( Medium ) )

       deltaz  = c / freq0 / 20.0D0
       Nneeded = INT( ( SSP%Depth( Medium + 1 ) - SSP%Depth( Medium ) ) / deltaz )
       Nneeded = MAX( Nneeded, 10 )

       IF ( NG( Medium ) == 0 ) THEN
          NG( Medium ) = Nneeded
       ELSE IF ( NG( Medium ) < Nneeded / 2 ) THEN
          CALL ERROUT( 'InitKrakenMex', 'Mesh is too coarse' )
       END IF
    END DO

    cLow = clh( 1 )
    cHigh = clh( 2 )
    RMax = rng / 1000.0D0

    HSTop%beta = 0.0D0
    HSTop%fT   = freq0
    HSBot%beta = 0.0D0
    HSBot%fT   = freq0
    SSP%sigma( nl + 1 ) = bsig

    CALL UpdateSSPLoss( freq0, freq0 )
    CALL UpdateHSLoss(  freq0, freq0 )
    CALL InitDepthVectors( nsr, zsr, zsrCount, nrc, zrc, zrcCount )
    CALL InitFrequencyVector( frq, frqCount )

  END SUBROUTINE InitKrakenMex

  SUBROUTINE ResetMexInputState()

    IF ( ALLOCATED( freqVec ) ) DEALLOCATE( freqVec )

    IF ( ALLOCATED( Pos%iSz ) ) DEALLOCATE( Pos%iSz )
    IF ( ALLOCATED( Pos%iRz ) ) DEALLOCATE( Pos%iRz )
    IF ( ALLOCATED( Pos%ws  ) ) DEALLOCATE( Pos%ws  )
    IF ( ALLOCATED( Pos%wr  ) ) DEALLOCATE( Pos%wr  )
    IF ( ALLOCATED( Pos%Sz  ) ) DEALLOCATE( Pos%Sz  )
    IF ( ALLOCATED( Pos%Rz  ) ) DEALLOCATE( Pos%Rz  )
    IF ( ALLOCATED( Pos%Sx  ) ) DEALLOCATE( Pos%Sx  )
    IF ( ALLOCATED( Pos%Sy  ) ) DEALLOCATE( Pos%Sy  )
    IF ( ALLOCATED( Pos%Rr  ) ) DEALLOCATE( Pos%Rr  )
    IF ( ALLOCATED( Pos%theta ) ) DEALLOCATE( Pos%theta )

    Pos%NSx    = 1
    Pos%NSy    = 1
    Pos%NSz    = 1
    Pos%NRz    = 1
    Pos%NRr    = 1
    Pos%Ntheta = 1

    IF ( ALLOCATED( EVMat ) ) DEALLOCATE( EVMat, Extrap, k, VG )
    IF ( ALLOCATED( B1 ) ) DEALLOCATE( B1, B1C, B2, B3, B4, rho )

    IRecProfile = 1
    ModeCount   = 0
    CountModes  = .FALSE.

  END SUBROUTINE ResetMexInputState

  SUBROUTINE InitHalfspaces( TopBC, BotBC, sspIn, nc )

    CHARACTER,          INTENT( IN ) :: TopBC, BotBC
    REAL      (KIND=8), INTENT( IN ) :: sspIn( nc, 6 )
    INTEGER,            INTENT( IN ) :: nc

    HSTop%BC          = TopBC
    HSTop%alphaR      = 0.0D0
    HSTop%alphaI      = 0.0D0
    HSTop%betaR       = 0.0D0
    HSTop%betaI       = 0.0D0
    HSTop%rho         = 0.0D0
    HSTop%BumpDensity = 0.0D0
    HSTop%eta         = 0.0D0
    HSTop%xi          = 0.0D0

    HSBot%BC          = BotBC
    HSBot%alphaR      = 0.0D0
    HSBot%alphaI      = 0.0D0
    HSBot%betaR       = 0.0D0
    HSBot%betaI       = 0.0D0
    HSBot%rho         = 0.0D0
    HSBot%BumpDensity = 0.0D0
    HSBot%eta         = 0.0D0
    HSBot%xi          = 0.0D0

    SELECT CASE ( HSTop%BC )
    CASE ( 'V', 'R' )
    CASE ( 'A' )
       HSTop%alphaR = 1500.0D0
       HSTop%rho    = 1.0D0
    CASE DEFAULT
       CALL ERROUT( 'InitKrakenMex', 'Only top boundary conditions V, R, and A are supported by the legacy Matlab interface' )
    END SELECT

    SELECT CASE ( HSBot%BC )
    CASE ( 'V', 'R' )
    CASE ( 'A' )
       HSBot%alphaR = sspIn( nc, 2 )
       HSBot%betaR  = sspIn( nc, 3 )
       HSBot%rho    = sspIn( nc, 4 )
       HSBot%alphaI = sspIn( nc, 5 )
       HSBot%betaI  = sspIn( nc, 6 )
    CASE DEFAULT
       CALL ERROUT( 'InitKrakenMex', 'Only bottom boundary conditions V, R, and A are supported by the legacy Matlab interface' )
    END SELECT

  END SUBROUTINE InitHalfspaces

  SUBROUTINE CopyStackedSSP( b, nl, sspIn, nc )

    REAL      (KIND=8), INTENT( IN ) :: b( nl, 3 ), sspIn( nc, 6 )
    INTEGER,            INTENT( IN ) :: nl, nc

    INTEGER            :: Medium, StartRow, EndRow, Npts, iSSP, iRow
    REAL      (KIND=8) :: zBottom, nextZ

    StartRow = 1

    DO Medium = 1, nl
       zBottom = b( Medium, 3 )
       EndRow  = StartRow

       DO WHILE ( EndRow <= nc )
          IF ( ABS( sspIn( EndRow, 1 ) - zBottom ) <= DepthTol ) EXIT
          EndRow = EndRow + 1
       END DO

       IF ( EndRow > nc ) CALL ERROUT( 'InitKrakenMex', 'Unable to partition the stacked SSP input into layers' )

       Npts = EndRow - StartRow + 1
       IF ( Npts < 2 ) CALL ERROUT( 'InitKrakenMex', 'Each layer needs at least two SSP points' )

       IF ( Medium == 1 ) THEN
          SSP%Loc( Medium ) = 0
       ELSE
          SSP%Loc( Medium ) = SSP%Loc( Medium - 1 ) + SSP%NPts( Medium - 1 )
       END IF

       SSP%NPts( Medium )    = Npts
       SSP%Depth( Medium + 1 ) = zBottom

       DO iRow = StartRow, EndRow
          iSSP            = SSP%Loc( Medium ) + ( iRow - StartRow + 1 )
          SSP%z(      iSSP ) = sspIn( iRow, 1 )
          SSP%alphaR( iSSP ) = sspIn( iRow, 2 )
          SSP%betaR(  iSSP ) = sspIn( iRow, 3 )
          SSP%rho(    iSSP ) = sspIn( iRow, 4 )
          SSP%alphaI( iSSP ) = sspIn( iRow, 5 )
          SSP%betaI(  iSSP ) = sspIn( iRow, 6 )
       END DO

       IF ( Medium == 1 ) SSP%Depth( 1 ) = SSP%z( 1 )

       StartRow = EndRow + 1
       IF ( StartRow <= nc ) THEN
          nextZ = sspIn( StartRow, 1 )
          IF ( ABS( nextZ - zBottom ) > DepthTol ) StartRow = EndRow
       END IF
    END DO

  END SUBROUTINE CopyStackedSSP

  SUBROUTINE InitDepthVectors( nsr, zsr, zsrCount, nrc, zrc, zrcCount )

    INTEGER,            INTENT( IN ) :: nsr, zsrCount, nrc, zrcCount
    REAL      (KIND=8), INTENT( IN ) :: zsr( * ), zrc( * )
    REAL                 :: zMin, zMax
    INTEGER              :: CopyCount, IAllocStat, I

    zMin = REAL( SSP%Depth( 1 ), KIND = KIND( zMin ) )
    zMax = REAL( SSP%Depth( SSP%NMedia + 1 ), KIND = KIND( zMax ) )

    IF ( nsr <= 0 .OR. nrc <= 0 ) CALL ERROUT( 'InitKrakenMex', 'nsr and nrc must be positive' )
    IF ( zsrCount <= 0 .OR. zrcCount <= 0 ) CALL ERROUT( 'InitKrakenMex', 'Depth vectors must contain at least one value' )

    ALLOCATE( Pos%Sz( MAX( 3, nsr ) ), Pos%ws( nsr ), Pos%iSz( nsr ), Stat = IAllocStat )
    IF ( IAllocStat /= 0 ) CALL ERROUT( 'InitKrakenMex', 'Too many source depths' )

    ALLOCATE( Pos%Rz( MAX( 3, nrc ) ), Pos%wr( nrc ), Pos%iRz( nrc ), Stat = IAllocStat )
    IF ( IAllocStat /= 0 ) CALL ERROUT( 'InitKrakenMex', 'Too many receiver depths' )

    Pos%NSz = nsr
    Pos%NRz = nrc

    Pos%Sz = 0.0
    Pos%Rz = 0.0

    IF ( nsr > zsrCount ) THEN
       IF ( zsrCount < 2 ) CALL ERROUT( 'InitKrakenMex', 'Auto-interpolated source depths require at least two values' )
       Pos%Sz( 1 ) = REAL( zsr( 1 ) )
       Pos%Sz( 2 ) = REAL( zsr( zsrCount ) )
       Pos%Sz( 3 ) = -999.9
    ELSE
       CopyCount = MIN( nsr, zsrCount )
       DO I = 1, CopyCount
          Pos%Sz( I ) = REAL( zsr( I ) )
       END DO
       IF ( nsr >= 3 .AND. CopyCount < 3 ) Pos%Sz( 3 ) = -999.9
    END IF

    IF ( nrc > zrcCount ) THEN
       IF ( zrcCount < 2 ) CALL ERROUT( 'InitKrakenMex', 'Auto-interpolated receiver depths require at least two values' )
       Pos%Rz( 1 ) = REAL( zrc( 1 ) )
       Pos%Rz( 2 ) = REAL( zrc( zrcCount ) )
       Pos%Rz( 3 ) = -999.9
    ELSE
       CopyCount = MIN( nrc, zrcCount )
       DO I = 1, CopyCount
          Pos%Rz( I ) = REAL( zrc( I ) )
       END DO
       IF ( nrc >= 3 .AND. CopyCount < 3 ) Pos%Rz( 3 ) = -999.9
    END IF

    CALL SubTab( Pos%Sz, Pos%NSz )
    CALL SubTab( Pos%Rz, Pos%NRz )
    CALL Sort(   Pos%Sz, Pos%NSz )
    CALL Sort(   Pos%Rz, Pos%NRz )

    IF ( ANY( Pos%Sz( 1 : Pos%NSz ) < zMin ) ) WHERE ( Pos%Sz( 1 : Pos%NSz ) < zMin ) Pos%Sz( 1 : Pos%NSz ) = zMin
    IF ( ANY( Pos%Sz( 1 : Pos%NSz ) > zMax ) ) WHERE ( Pos%Sz( 1 : Pos%NSz ) > zMax ) Pos%Sz( 1 : Pos%NSz ) = zMax
    IF ( ANY( Pos%Rz( 1 : Pos%NRz ) < zMin ) ) WHERE ( Pos%Rz( 1 : Pos%NRz ) < zMin ) Pos%Rz( 1 : Pos%NRz ) = zMin
    IF ( ANY( Pos%Rz( 1 : Pos%NRz ) > zMax ) ) WHERE ( Pos%Rz( 1 : Pos%NRz ) > zMax ) Pos%Rz( 1 : Pos%NRz ) = zMax

    ALLOCATE( Pos%Sx( 1 ), Pos%Sy( 1 ), Pos%Rr( 1 ), Pos%theta( 1 ), Stat = IAllocStat )
    IF ( IAllocStat /= 0 ) CALL ERROUT( 'InitKrakenMex', 'Unable to allocate default position vectors' )

    Pos%Sx( 1 )    = 0.0D0
    Pos%Sy( 1 )    = 0.0D0
    Pos%Rr( 1 )    = 0.0D0
    Pos%theta( 1 ) = 0.0D0

  END SUBROUTINE InitDepthVectors

  SUBROUTINE InitFrequencyVector( frq, frqCount )

    REAL (KIND=8), INTENT( IN ) :: frq( * )
    INTEGER,       INTENT( IN ) :: frqCount
    INTEGER                     :: IAllocStat

    Nfreq = frqCount
    ALLOCATE( freqVec( MAX( 3, Nfreq ) ), Stat = IAllocStat )
    IF ( IAllocStat /= 0 ) CALL ERROUT( 'InitKrakenMex', 'Unable to allocate the frequency vector' )
    freqVec = 0.0D0
    freqVec( 1 : Nfreq ) = frq( 1 : Nfreq )
    CALL SubTab( freqVec, Nfreq )

  END SUBROUTINE InitFrequencyVector

END MODULE KrakenMexInputMod
