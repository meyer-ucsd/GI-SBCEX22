MODULE FatalError

  USE iso_c_binding, ONLY : c_char, c_null_char

  IMPLICIT NONE

CONTAINS

  SUBROUTINE ERROUT( WHERE, ErrMsg )

    CHARACTER (LEN=*), INTENT( IN ) :: WHERE, ErrMsg
    CHARACTER (LEN=512)             :: Message
    CHARACTER (KIND=c_char), ALLOCATABLE :: CMessage( : )
    INTEGER                         :: I, N

    INTERFACE
       SUBROUTINE kraken_mex_fatal( Message ) BIND( C, NAME = 'kraken_mex_fatal' )
         USE iso_c_binding, ONLY : c_char
         CHARACTER (KIND=c_char), INTENT( IN ) :: Message( * )
       END SUBROUTINE kraken_mex_fatal
    END INTERFACE

    WRITE( Message, '( A, A, A, A )' ) 'Fatal Error in Kraken [', TRIM( WHERE ), ']: ', TRIM( ErrMsg )
    N = LEN_TRIM( Message )

    ALLOCATE( CMessage( N + 1 ) )
    DO I = 1, N
       CMessage( I ) = Message( I : I )
    END DO
    CMessage( N + 1 ) = c_null_char

    CALL kraken_mex_fatal( CMessage )

  END SUBROUTINE ERROUT

END MODULE FatalError
