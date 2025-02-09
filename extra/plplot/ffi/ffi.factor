! Copyright (C) 2023 Raghu R.
! See https://factorcode.org/license.txt for BSD license.
USING: alien combinators ;
IN: plplot.ffi

<< "bzip3" {
  { [ os unix? ] [ "libplplot.so" ] }
} cond cdecl add-library

TYPEDEF: double PLFLT
TYPEDEF: int32_t PLINT
TYPEDEF: PLINT PLBOOL
TYPEDEF: uint32_t PLUNICODE
TYPEDEF: PLFLT* PLFLT_NC_SCALAR
TYPEDEF: PLINT* PLINT_NC_SCALAR
TYPEDEF: PLBOOL* PLBOOL_NC_SCALAR
TYPEDEF: PLUNICODE* PLUNICODE_NC_SCALAR
TYPEDEF: char* PLCHAR_NC_SCALAR
TYPEDEF: const PLFLT* PLFLT_VECTOR
TYPEDEF: const PLINT* PLINT_VECTOR
TYPEDEF: const PLBOOL* PLBOOL_VECTOR
TYPEDEF: const char* PLCHAR_VECTOR
TYPEDEF: PLFLT* PLFLT_NC_VECTOR
TYPEDEF: char* PLCHAR_NC_VECTOR
TYPEDEF: const PLFLT* const* PLFLT_MATRIX
TYPEDEF: const char* const* PLCHAR_MATRIX
TYPEDEF: PLFLT** PLFLT_NC_MATRIX
TYPEDEF: char** PLCHAR_NC_MATRIX
TYPEDEF: void* PLPointer
TYPEDEF: void* PLMAPFORM_callback( PLINT n, PLFLT_NC_VECTOR x, PLFLT_NC_VECTOR y )
