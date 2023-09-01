! Copyright (C) 2023 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.

! Factor Command Line Argument parser
USING: command-line syntax accessors sequences fry ;
IN: command-line.options

TUPLE: option
  { long string }
  { short string } 
  { description string }
  { arg/f object }
  { action object } ;
  
: parse-args ( args options -- argvals )
  '[
     [ long>> "--" swap append _ = ]
     [ short>> "-" swap append _ = ] bi and
   ] find nip
   dup  arg/f>> [ ]
  ;
