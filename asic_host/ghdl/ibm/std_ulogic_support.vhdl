-- *!***************************************************************************
-- *! Copyright 2019 International Business Machines
-- *!
-- *! Licensed under the Apache License, Version 2.0 (the "License");
-- *! you may not use this file except in compliance with the License.
-- *! You may obtain a copy of the License at
-- *! http://www.apache.org/licenses/LICENSE-2.0
-- *!
-- *! The patent license granted to you in Section 3 of the License, as applied
-- *! to the "Work," hereby includes implementations of the Work in physical form.
-- *!
-- *! Unless required by applicable law or agreed to in writing, the reference design
-- *! distributed under the License is distributed on an "AS IS" BASIS,
-- *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- *! See the License for the specific language governing permissions and
-- *! limitations under the License.
-- *!
-- *! The background Specification upon which this is based is managed by and available from
-- *! the OpenCAPI Consortium.  More information can be found at https://opencapi.org.
-- *!***************************************************************************





library ieee, ibm ;
use ieee.std_logic_1164.all ;
use ibm.synthesis_support.all ;

package std_ulogic_support is

  ATTRIBUTE synthesis_return : string ;

  type base_t is ( BIN, OCT, DEC, HEX );

  function "="    ( l,r : integer ) return std_ulogic;
  function "/="   ( l,r : integer ) return std_ulogic;
  function ">"    ( l,r : integer ) return std_ulogic;
  function ">="   ( l,r : integer ) return std_ulogic;
  function "<"    ( l,r : integer ) return std_ulogic;
  function "<="   ( l,r : integer ) return std_ulogic;

  function "="    ( l,r : std_ulogic ) return std_ulogic;
  function "/="   ( l,r : std_ulogic ) return std_ulogic;
  function ">"    ( l,r : std_ulogic ) return std_ulogic;
  function ">="   ( l,r : std_ulogic ) return std_ulogic;
  function "<"    ( l,r : std_ulogic ) return std_ulogic;
  function "<="   ( l,r : std_ulogic ) return std_ulogic;

  function "="    ( l, r : std_ulogic_vector ) return std_ulogic;
  function "/="   ( l, r : std_ulogic_vector ) return std_ulogic;
  function ">"    ( l, r : std_ulogic_vector ) return std_ulogic;
  function ">="   ( l, r : std_ulogic_vector ) return std_ulogic;
  function "<"    ( l, r : std_ulogic_vector ) return std_ulogic;
  function "<="   ( l, r : std_ulogic_vector ) return std_ulogic;

  attribute like_builtin of "="  :function is true;
  attribute like_builtin of "/=" :function is true;
  attribute like_builtin of ">"  :function is true;
  attribute like_builtin of ">=" :function is true;
  attribute like_builtin of "<"  :function is true;
  attribute like_builtin of "<=" :function is true;

  function eq( l,r : std_ulogic ) return boolean;
  function ne( l,r : std_ulogic ) return boolean;
  function gt( l,r : std_ulogic ) return boolean;
  function ge( l,r : std_ulogic ) return boolean;
  function lt( l,r : std_ulogic ) return boolean;
  function le( l,r : std_ulogic ) return boolean;

  function eq( l,r : std_ulogic ) return std_ulogic;
  function ne( l,r : std_ulogic ) return std_ulogic;
  function gt( l,r : std_ulogic ) return std_ulogic;
  function ge( l,r : std_ulogic ) return std_ulogic;
  function lt( l,r : std_ulogic ) return std_ulogic;
  function le( l,r : std_ulogic ) return std_ulogic;

  function eq( l,r : std_ulogic_vector ) return boolean;
  function ne( l,r : std_ulogic_vector ) return boolean;
  function gt( l,r : std_ulogic_vector ) return boolean;
  function ge( l,r : std_ulogic_vector ) return boolean;
  function lt( l,r : std_ulogic_vector ) return boolean;
  function le( l,r : std_ulogic_vector ) return boolean;

  function eq( l,r : std_ulogic_vector ) return std_ulogic;
  function ne( l,r : std_ulogic_vector ) return std_ulogic;
  function gt( l,r : std_ulogic_vector ) return std_ulogic;
  function ge( l,r : std_ulogic_vector ) return std_ulogic;
  function lt( l,r : std_ulogic_vector ) return std_ulogic;
  function le( l,r : std_ulogic_vector ) return std_ulogic;

  attribute functionality of eq : function is "=";
  attribute functionality of ne : function is "/=";
  attribute functionality of gt : function is ">";
  attribute functionality of ge : function is ">=";
  attribute functionality of lt : function is "<";
  attribute functionality of le : function is "<=";

  attribute dc_allow of eq : function is true;
  attribute dc_allow of ne : function is true;


  function tconv( b : boolean          ) return  bit;
  function tconv( b : boolean          ) return  string;
  function tconv( b : boolean          ) return  std_ulogic;

  function tconv( b : bit        ) return  boolean;
  function tconv( b : bit        ) return  character;
  function tconv( b : bit        ) return  string;
  function tconv( b : bit        ) return  integer;
  function tconv( b : bit        ) return  std_ulogic;

  function tconv( b : bit_vector ) return  integer;
  function tconv( b : bit_vector ) return  string;
  function tconv( b : bit_vector; base : base_t  ) return  string;
  --function tconv( b : bit_vector ) return  std_ulogic_vector;
  function tconv( b : bit_vector ) return  std_logic_vector;

  function tconv( n : natural; w: positive ) return bit_vector ;
  function tconv( n : natural; w: positive ) return std_ulogic_vector ;
  function tconv( n : integer; w: positive ) return string  ;
  function tconv( n : integer              ) return string  ;

  function tconv( s : string                ) return integer ;
  function tconv( s : string; base : base_t ) return integer ;
  function tconv( s : string                ) return bit ;
  function tconv( s : string                ) return bit_vector ;
  function tconv( s : string; base : base_t ) return bit_vector ;
  function tconv( s : string                ) return std_ulogic ;
  function tconv( s : string                ) return std_ulogic_vector ;
  function tconv( s : string; base : base_t ) return std_ulogic_vector ;

  function tconv( s : std_ulogic       ) return  boolean;
  function tconv( s : std_ulogic       ) return  bit;
  function tconv( s : std_ulogic       ) return  character;
  function tconv( s : std_ulogic       ) return  string;
  function tconv( s : std_ulogic       ) return  integer;
  function tconv( s : std_ulogic       ) return  std_ulogic_vector;

  --function tconv( s : std_ulogic_vector ) return  bit_vector;
  --function tconv( s : std_ulogic_vector ) return  std_logic_vector;
  --function tconv( s : std_ulogic_vector ) return  integer;
  --function tconv( s : std_ulogic_vector ) return  string;
  --function tconv( s : std_ulogic_vector; base : base_t ) return  string;
  --function tconv( s : std_ulogic_vector ) return  std_ulogic;

  function tconv( s : std_logic_vector ) return  bit_vector;
  function tconv( s : std_logic_vector ) return  std_ulogic_vector;
  function tconv( s : std_logic_vector ) return  integer;
  function tconv( s : std_logic_vector ) return  string;
  function tconv( s : std_logic_vector; base : base_t ) return  string;

  function hexstring( d : std_ulogic_vector ) return string ;
  function octstring( d : std_ulogic_vector ) return string ;
  function bitstring( d : std_ulogic_vector ) return string ;

  attribute type_convert of tconv : function is true;


  attribute btr_name         of tconv  : function is "PASS";
  attribute pin_bit_information of tconv : function is
           (1 => ("   ","A0      ","INCR","PIN_BIT_SCALAR"),
            2 => ("   ","10      ","INCR","PIN_BIT_SCALAR"));


  function std_match (l, r: std_ulogic) return std_ulogic;
  function std_match (l, r: std_ulogic_vector) return std_ulogic;

  attribute functionality of std_match : function is "=";
  attribute dc_allow of std_match : function is true;


  function shift_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  attribute functionality of shift_left : function is "SLL";

  function shift_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  attribute functionality of shift_right : function is "SRL";



  function rotate_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  attribute functionality of rotate_left : function is "ROL";

  function rotate_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector;
  attribute functionality of rotate_right : function is "ROR";


  function "sll" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;


  function "srl" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;



  function "rol" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;


  function "ror" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector;
END std_ulogic_support ;

package body std_ulogic_support is


  type std_ulogic_to_character_type is array( std_ulogic ) of character;

  constant std_ulogic_to_character : std_ulogic_to_character_type :=
    ( 'U','X','0','1','Z','W','L','H','-');

  type stdlogic_1d is array ( std_ulogic ) of std_ulogic;
  type b_stdlogic_1d is array ( std_ulogic ) of boolean;

  type stdlogic_2d is array ( std_ulogic, std_ulogic ) of std_ulogic;
  type b_stdlogic_2d is array ( std_ulogic, std_ulogic ) of boolean;


  constant not_table : stdlogic_1d := (
                  'U'=>'U',
                  'X'=>'X',
                  '0'=>'1',
                  '1'=>'0',
                  'Z'=>'X',
                  'W'=>'X',
                  'L'=>'1',
                  'H'=>'0',
                  '-'=>'-',
                  others=>'-'
  );

  constant b_not_table : b_stdlogic_1d := (
                  'U'=>false,
                  'X'=>false,
                  '0'=>true ,
                  '1'=>false,
                  'Z'=>false,
                  'W'=>false,
                  'L'=>true ,
                  'H'=>false,
                  '-'=>true,
                  others=>false
  );


  constant and_table : stdlogic_2d := (
         ( 'U', 'U', '0', 'U', 'U', 'U', '0', 'U', 'U' ),
         ( 'U', 'X', '0', 'X', 'X', 'X', '0', 'X', 'X' ),
         ( '0', '0', '0', '0', '0', '0', '0', '0', '0' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '1' ),
         ( 'U', 'X', '0', 'X', 'X', 'X', '0', 'X', 'X' ),
         ( 'U', 'X', '0', 'X', 'X', 'X', '0', 'X', 'X' ),
         ( '0', '0', '0', '0', '0', '0', '0', '0', '0' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '1' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '-' ),
         others=>(others=>'-')
  );


  constant nand_table : stdlogic_2d := (
         ( 'U', 'U', '1', 'U', 'U', 'U', '1', 'U', 'U' ),
         ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' ),
         ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '0' ),
         ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' ),
         ( 'U', 'X', '1', 'X', 'X', 'X', '1', 'X', 'X' ),
         ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '0' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '-' ),
         others=>(others=>'-')
  );


  constant or_table : stdlogic_2d := (
         ( 'U', 'U', 'U', '1', 'U', 'U', 'U', '1', 'U' ),
         ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '0' ),
         ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),
         ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' ),
         ( 'U', 'X', 'X', '1', 'X', 'X', 'X', '1', 'X' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '0' ),
         ( '1', '1', '1', '1', '1', '1', '1', '1', '1' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '-' ),
         others=>(others=>'-')
  );


  constant nor_table : stdlogic_2d := (
         ( 'U', 'U', 'U', '0', 'U', 'U', 'U', '0', 'U' ),
         ( 'U', 'X', 'X', '0', 'X', 'X', 'X', '0', 'X' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),
         ( '0', '0', '0', '0', '0', '0', '0', '0', '0' ),
         ( 'U', 'X', 'X', '0', 'X', 'X', 'X', '0', 'X' ),
         ( 'U', 'X', 'X', '0', 'X', 'X', 'X', '0', 'X' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),
         ( '0', '0', '0', '0', '0', '0', '0', '0', '0' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '-' ),
         others=>(others=>'-')
  );


  constant xor_table : stdlogic_2d := (
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '0' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '0' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '-' ),
         others=>(others=>'-')
  );


  constant match_table : stdlogic_2d := (
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '0', '0', '1' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '1', '1', '1' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '1' ),
         ( 'U', '1', '1', '1', '1', '1', '1', '1', '-' )
  );

  constant b_match_table : b_stdlogic_2d := (
    'U'=>( '-'=>true, others=>false ),
    'X'=>( '-'=>true, others=>false ),
    '0'=>( '-'=>true, '0'=>true, 'L'=>true, others=>false ),
    '1'=>( '-'=>true, '1'=>true, 'H'=>true, others=>false ),
    'Z'=>( '-'=>true, others=>false ),
    'W'=>( '-'=>true, others=>false ),
    'L'=>( '-'=>true, '0'=>true, 'L'=>true, others=>false ),
    'H'=>( '-'=>true, '1'=>true, 'H'=>true, others=>false ),
    '-'=>( '-'=>true, others=>true ),
     others=>(others=>false)
  );


  constant equal_table : stdlogic_2d := (
         ( '1', '0', '0', '0', '0', '0', '0', '0', '0' ),
         ( '0', '1', '0', '0', '0', '0', '0', '0', '0' ),
         ( '0', '0', '1', '0', '0', '0', '0', '0', '0' ),
         ( '0', '0', '0', '1', '0', '0', '0', '0', '0' ),
         ( '0', '0', '0', '0', '1', '0', '0', '0', '0' ),
         ( '0', '0', '0', '0', '0', '1', '0', '0', '0' ),
         ( '0', '0', '0', '0', '0', '0', '1', '0', '0' ),
         ( '0', '0', '0', '0', '0', '0', '0', '1', '0' ),
         ( '0', '0', '0', '0', '0', '0', '0', '0', '1' )
  );

  constant b_equal_table : b_stdlogic_2d := (
    'U'=>( 'U'=>true, others=>false ),
    'X'=>( 'X'=>true, others=>false ),
    '0'=>( '0'=>true, others=>false ),
    '1'=>( '1'=>true, others=>false ),
    'Z'=>( 'Z'=>true, others=>false ),
    'W'=>( 'W'=>true, others=>false ),
    'L'=>( 'L'=>true, others=>false ),
    'H'=>( 'H'=>true, others=>false ),
    '-'=>( '-'=>true, others=>false ),
     others=>(others=>false)
  );


  constant lt_table : stdlogic_2d := (
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ),
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', 'X' ),
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         others=>(others=>'-')
  );

  constant b_lt_table : b_stdlogic_2d := (
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( '1'=>true, 'H'=>true, others=>false ),
     '1'=>( others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( '1'=>true, 'H'=>true, others=>false ),
     'H'=>( others=>false ),
     '-'=>( others=>false ),
     others=>( others=>false )
  );


  constant le_table : stdlogic_2d := (
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '1', '1', 'X', 'X', '1', '1', 'X' ),
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '1', '1', 'X', 'X', '0', '1', 'X' ),
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
        others=>(others=>'-')
  );

  constant b_le_table : b_stdlogic_2d := (
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     '1'=>( '1'=>true, 'H'=>true, others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     'H'=>( '1'=>true, 'H'=>true, others=>false ),
     '-'=>( others=>false ),
     others=>( others=>false )
  );


  constant gt_table : stdlogic_2d := (
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '0', '0', 'X', 'X', '0', '0', 'X' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         others=>(others=>'-')
  );

  constant b_gt_table : b_stdlogic_2d := (
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( others=>false ),
     '1'=>( '0'=>true, 'L'=>true, others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( others=>false ),
     'H'=>( '0'=>true, 'L'=>true, others=>false ),
     '-'=>( others=>false ),
  others=>(others=>false));


  constant ge_table : stdlogic_2d := (
         ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),
         ( 'U', 'X', '1', '1', 'X', 'X', '1', '1', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', 'X' ),
         ( 'U', 'X', '1', '1', 'X', 'X', '1', '1', 'X' ),
         ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X' ),
         others=>(others=>'-')
  );

  constant b_ge_table : b_stdlogic_2d := (
     'U'=>( others=>false ),
     'X'=>( others=>false ),
     '0'=>( '0'=>true, 'L'=>true, others=>false ),
     '1'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     'Z'=>( others=>false ),
     'W'=>( others=>false ),
     'L'=>( '0'=>true, 'L'=>true,  others=>false ),
     'H'=>( '0'=>true, '1'=>true, 'L'=>true, 'H'=>true, others=>false ),
     '-'=>( others=>false ),
     others=>( others=>false )
  );


  function eq( l,r : std_ulogic ) return boolean is
  begin
    return b_match_table( l, r );
  end eq;

  function ne( l,r : std_ulogic ) return boolean is
  begin
    return not( b_match_table( l, r ) );
  end ne;

  function gt( l,r : std_ulogic ) return boolean is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return b_gt_table( l, r );
  end gt;

  function ge( l,r : std_ulogic ) return boolean is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return b_ge_table( l, r );
  end ge;

  function lt( l,r : std_ulogic ) return boolean is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return b_lt_table( l, r );
  end lt;

  function le( l,r : std_ulogic ) return boolean is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return b_le_table( l, r );
  end le;


  function eq( l,r : std_ulogic ) return std_ulogic is
  begin
    return match_table( l, r );
  end eq;

  function ne( l,r : std_ulogic ) return std_ulogic is
  begin
    return not_table( match_table( l, r ) );
  end ne;

  function gt( l,r : std_ulogic ) return std_ulogic is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return gt_table( l, r );
  end gt;

  function ge( l,r : std_ulogic ) return std_ulogic is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return ge_table( l, r );
  end ge;

  function lt( l,r : std_ulogic ) return std_ulogic is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return lt_table( l, r );
  end lt;

  function le( l,r : std_ulogic ) return std_ulogic is
  begin
    assert ( l /= '-' ) and ( r /= '-' )
      report "Invalid dont_care in relational function"
      severity error;
    return le_table( l, r );
  end le;

  function to_x01d( d : std_ulogic ) return std_ulogic is
    variable result : std_ulogic;
  begin
    case d is
      when '0' | 'L' => result := '0';
      when '1' | 'H' => result := '1';
      when '-'      => result := '-';
      when others   => result := 'X';
    end case;
    return result;
  end to_x01d;

  function eq( l,r : std_ulogic_vector)  return boolean  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : boolean := true ;
    variable result        : boolean := true ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the eq " &
        "function are unequal. "
        severity error ;
      result := false ;
    else
      for i in lv'left downto lv'right loop
        vs1_result := vs1_result and b_match_table(lv(i),rv(i));
      end loop;
      result := vs1_result ;
    end if ;
    return result;
  end eq;

  function ne( l,r : std_ulogic_vector)  return boolean  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : boolean := true ;
    variable result        : boolean := true ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the ne " &
        "function are unequal. "
        severity error;
      result := false ;
    else
      for i in lv'left downto lv'right loop
        vs1_result := vs1_result and b_match_table(lv(i),rv(i));
      end loop;
      result := not vs1_result ;
    end if;
    return result;
  end ne;

  function gt( l,r : std_ulogic_vector)  return boolean  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : boolean := true ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to a gt " &
        "function are unequal. "
        severity error;
      result:= false ;
    else
      result := false ;
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "10"   =>
            result := true ;
            exit;
          when "01"   =>
            result := false ;
            exit;
          when "11" | "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := false ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end gt;

  function ge( l,r : std_ulogic_vector)  return boolean  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : boolean := true ;
  begin
    if l'length /= r'length then
      assert false
        report "The bit lengths of the two inputs to the ge " &
        "function are unequal. "
        severity error;
      result := false ;
    else
      result := true;
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "10"   =>
            result := true ;
            exit;
          when "01"   =>
            result := false ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := false ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end ge;

  function lt( l,r : std_ulogic_vector)  return boolean  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : boolean := true ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the lt " &
        "function are unequal. "
        severity error;
      result := false ;
    else
      result := false;
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "01"   =>
            result := true ;
            exit;
          when "10"   =>
            result := false ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := false ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end lt;

  function le( l,r : std_ulogic_vector)  return boolean  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : boolean := true ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the le " &
        "function are unequal. "
        severity error;
      result := false ;
    else
      result := true;
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "01"   =>
            result := true ;
            exit;
          when "10"   =>
            result := false ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := false ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end le;

  function eq( l,r : std_ulogic_vector)  return std_ulogic  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic := '1';
    variable result        : std_ulogic := '0' ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the eq " &
        "function are unequal. "
        severity error;
      result := '0' ;
    else
      for i in lv'left downto lv'right loop
        vs1_result := and_table( vs1_result,
                                 match_table( lv(i), rv(i) ) );
      end loop;
      result := vs1_result ;
    end if ;
    return result;
  end eq;
  function ne( l,r : std_ulogic_vector)  return std_ulogic  is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic := '1';
    variable result        : std_ulogic := '0' ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the ne " &
        "function are unequal. "
        severity error;
      result := '0' ;
    else
      for i in lv'left downto lv'right loop
        vs1_result := and_table( vs1_result,
                                 match_table( lv(i), rv(i) ) );
      end loop;
      result := not vs1_result ;
    end if ;
    return result;
  end ne;

  function gt( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : std_ulogic := '0' ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the gt " &
        "function are unequal. "
        severity error;
      result := '0' ;
    else
      result := '0';
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "10"   =>
            result := '1' ;
            exit;
          when "01"   =>
            result := '0' ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := 'X' ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end gt;

  function ge( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : std_ulogic := '0' ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the ge " &
        "function are unequal. "
        severity error;
      result := '0' ;
    else
      result := '1';
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "10"   =>
            result := '1' ;
            exit;
          when "01"   =>
            result := '0' ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := 'X' ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end ge;

  function lt( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : std_ulogic := '0' ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the lt " &
        "function are unequal. "
        severity error;
      result := '0' ;
    else
      result := '0';
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "01"   =>
            result := '1' ;
            exit;
          when "10"   =>
            result := '0' ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := 'X' ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end lt;

  function le( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
    variable result        : std_ulogic := '0' ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the le " &
        "function are unequal. "
        severity error;
      result := '0' ;
    else
      result := '1';
      for i in lv'left downto lv'right loop
        vs1_result := to_x01d( lv(i) ) & to_x01d( rv(i) );
        case vs1_result is
          when "01"   =>
            result := '1' ;
            exit;
          when "10"   =>
            result := '0' ;
            exit;
          when "11" |
            "00" =>
            null ;
          when others =>
            assert ( vs1_result(0) /= '-' ) and
              ( vs1_result(1) /= '-' )
              report "Invalid dont_care in relational function"
              severity error;
            result := 'X' ;
            exit;
        end case ;
      end loop;
    end if ;
    return result;
  end le;

  function tconv  ( b : boolean ) return bit is
    variable result : bit;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case b is
      when false  => result := '0';
      when true   => result := '1';
    end case;
    return result;
  end tconv ;

  function tconv  ( b : boolean ) return string is
  begin
    case b is
      when false  => return("FALSE");
      when true   => return("TRUE");
    end case;
  end tconv ;

  function tconv  ( b : boolean ) return std_ulogic is
    variable result : std_ulogic;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case b is
      when false  => result := '0';
      when true   => result := '1';
    end case;
    return result;
  end tconv ;

  function tconv  ( b : bit ) return boolean is
    variable result : boolean;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case b is
      when '0' => result := false;
      when '1' => result := true;
    end case;
    return result;
  end tconv ;

  function tconv  ( b : bit ) return character is
  begin
    case b is
      when '0' => return('0');
      when '1' => return('1');
    end case;
  end tconv ;

  function tconv  ( b : bit ) return string is
  begin
    case b is
      when '0' => return("0");
      when '1' => return("1");
    end case;
  end tconv ;

  function tconv  ( b : bit ) return integer is
  begin
    case b is
      when '0' => return(0);
      when '1' => return(1);
    end case;
  end tconv ;

  function tconv  ( b : bit ) return std_ulogic is
    variable result : std_ulogic;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case b is
      when '0' => result := '0';
      when '1' => result := '1';
    end case;
    return result;
  end tconv ;

  function tconv  ( b : bit_vector ) return integer is
    variable int_result : integer := 0;
    ATTRIBUTE synthesis_return OF int_result:VARIABLE IS "FEED_THROUGH" ;
    variable int_exp    : integer := 0;
    alias    new_value  : bit_vector(1 to b'length) is b ;
  begin
    for i in new_value'length downto 1 loop
      if new_value(i)='1' then
        int_result := int_result + (2**int_exp);
      end if;
      int_exp := int_exp + 1;
    end loop;
    return int_result;
  end tconv ;

  function tconv  ( b : bit_vector ) return string is
    alias sv : bit_vector ( 1 to b'length ) is b;
    variable result : string ( 1 to b'length ) := (others => '0');
  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
      end case;
    end loop;
    return result;
  end tconv ;

  function tconv  ( b : bit_vector; base : base_t ) return string is
    alias sv : bit_vector ( 1 to b'length ) is b;
    variable result : string ( 1 to b'length );
    variable start : positive;
    variable extra : natural;
    variable resultlength : positive;
    subtype bv is bit_vector( 1 to 1 );
    subtype qv is bit_vector( 1 to 2 );
    subtype ov is bit_vector( 1 to 3 );
    subtype hv is bit_vector( 1 to 4 );
  begin
    case base is
      when bin =>
        resultlength := sv'length;
        start := 1;
        for i in start to resultlength loop
          case sv( i ) is
            when '0' => result( i ) := '0';
            when '1' => result( i ) := '1';
          end case;
        end loop;

      when oct =>
        extra := sv'length rem ov'length;
        case extra is
          when 0 =>
            resultlength := b'length/ov'length;
            start := 1;
          when 1 =>
            resultlength := ( b'length/ov'length ) + 1;
            start := 2;
            case sv( 1 ) is
              when '0' => result( 1 ) := '0';
              when '1' => result( 1 ) := '1';
            end case;
          when 2 =>
            resultlength := ( b'length/ov'length ) + 1;
            start := 2;
            case qv'( sv( 1 to 2 ) ) is
              when "00" => result( 1 ) := '0';
              when "01" => result( 1 ) := '1';
              when "10" => result( 1 ) := '2';
              when "11" => result( 1 ) := '3';
            end case;
          when others =>
            assert false report "TCONV fatal condition" severity failure;
        end case;

        for i in 0 to resultlength - start loop
          case ov'( sv( (ov'length*i)+(extra+1) to (ov'length*i)+(extra+3) ) ) is
            when "000" => result( i+start ) := '0';
            when "001" => result( i+start ) := '1';
            when "010" => result( i+start ) := '2';
            when "011" => result( i+start ) := '3';
            when "100" => result( i+start ) := '4';
            when "101" => result( i+start ) := '5';
            when "110" => result( i+start ) := '6';
            when "111" => result( i+start ) := '7';
            when others => result( i+start ) := '.';
          end case;
        end loop;

      when hex =>
        extra := b'length rem hv'length;
        case extra is
          when 0 =>
            resultlength := b'length/hv'length;
            start := 1;
          when 1 =>
            resultlength := ( b'length/hv'length ) + 1;
            start := 2;
            case sv( 1 ) is
              when '0' => result( 1 ) := '0';
              when '1' => result( 1 ) := '1';
            end case;
          when 2 =>
            resultlength := ( b'length/hv'length ) + 1;
            start := 2;
            case qv'( sv( 1 to 2 ) ) is
              when "00" => result( 1 ) := '0';
              when "01" => result( 1 ) := '1';
              when "10" => result( 1 ) := '2';
              when "11" => result( 1 ) := '3';
            end case;
          when 3 =>
            resultlength := ( b'length/hv'length ) + 1;
            start := 2;
            case ov'( sv( 1 to 3 ) ) is
              when o"0" => result( 1 ) := '0';
              when o"1" => result( 1 ) := '1';
              when o"2" => result( 1 ) := '2';
              when o"3" => result( 1 ) := '3';
              when o"4" => result( 1 ) := '4';
              when o"5" => result( 1 ) := '5';
              when o"6" => result( 1 ) := '6';
              when o"7" => result( 1 ) := '7';
            end case;
          when others =>
            assert false report "TCONV fatal condition" severity failure;
        end case;

        for i in 0 to resultlength - start loop
          case hv'( sv( (hv'length*i)+(extra+1) to (hv'length*i)+(extra+4) ) ) is
            when "0000" => result( i+start ) := '0';
            when "0001" => result( i+start ) := '1';
            when "0010" => result( i+start ) := '2';
            when "0011" => result( i+start ) := '3';
            when "0100" => result( i+start ) := '4';
            when "0101" => result( i+start ) := '5';
            when "0110" => result( i+start ) := '6';
            when "0111" => result( i+start ) := '7';
            when "1000" => result( i+start ) := '8';
            when "1001" => result( i+start ) := '9';
            when "1010" => result( i+start ) := 'A';
            when "1011" => result( i+start ) := 'B';
            when "1100" => result( i+start ) := 'C';
            when "1101" => result( i+start ) := 'D';
            when "1110" => result( i+start ) := 'E';
            when "1111" => result( i+start ) := 'F';
            when others => result( i+start ) := '.';
          end case;
        end loop;

      when others =>
        assert false report "Unsupported base passed." severity warning;

    end case;

    return result( 1 to resultLength );
  end tconv ;

  function tconv  ( b : bit_vector ) return std_logic_vector is
    alias sv : bit_vector ( 1 to b'length ) is b;
    variable result : std_logic_vector ( 1 to b'length ) := (others => 'X');
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
      end case;
    end loop;
    return result;
  end tconv ;

  function tconv  ( n  : natural;w  : positive) return bit_vector is
    variable result : bit_vector(w-1 downto 0) := ( others => '0' );
    variable ib     : integer;
    variable test   : integer;
  begin
    ib := n;
    for i in result'reverse_range loop
      exit when ib = 0;
      test := ib rem 2;
      if test = 1 then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
      ib := ib / 2;
    end loop;

    assert ib = 0
      report "tconv: integer overflows requested result width"
      severity warning;

    return result;
  end tconv;

  function tconv  ( n  : natural; w  : positive) return std_ulogic_vector is
    variable result : std_ulogic_vector(w-1 downto 0) := ( others => '0' );
    variable ib     : integer;
    variable test   : integer;
  begin
    ib := n;
    for i in result'reverse_range loop
      exit when ib = 0;
      test := ib rem 2;
      if test = 1 then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
      ib := ib / 2;
    end loop;

    assert ib = 0
      report "tconv: integer overflows requested result width"
      severity warning;

    return result;
  end tconv;

  function tconv  ( n : integer; w : positive ) return string is
    subtype digit is integer range 0 to 9;
    variable result : string( 1 to w ) := ( others => ' ' );
    variable ib     : integer;
    variable msd    : integer;
    variable sign   : character := '-';
    variable test   : digit;
  begin
    ib := abs n;
    for i in result'reverse_range loop
      test := ib rem 10;

      case test is
        when 0 => result(i) := '0';
        when 1 => result(i) := '1';
        when 2 => result(i) := '2';
        when 3 => result(i) := '3';
        when 4 => result(i) := '4';
        when 5 => result(i) := '5';
        when 6 => result(i) := '6';
        when 7 => result(i) := '7';
        when 8 => result(i) := '8';
        when 9 => result(i) := '9';
      end case;

      ib := ib / 10;

      exit when ib = 0;
    end loop;

    if ib < 0 then
      result(1) := sign;
    end if;

    assert
      not( ( ( ib < 0 ) and ( ( abs ib ) > ( 10**(w-1) - 1 ) ) ) or
           ( ( ib >= 0 ) and ( ib       > ( 10**w     - 1 ) ) ) )
      report "tconv: integer overflows requested result width"
      severity warning;

    return result;
  end tconv;

  function tconv  ( n : integer) return string is
    subtype digit is integer range 0 to 9;
    variable result : string( 1 to 10 ) := ( others => ' ' );
    variable ib     : integer;
    variable msd    : integer;
    variable sign   : character := '-';
    variable test   : digit;
  begin
    ib := abs n ;
    for i in result'reverse_range loop
      test := ib rem 10;
      case test is
        when 0 => result(i) := '0';
        when 1 => result(i) := '1';
        when 2 => result(i) := '2';
        when 3 => result(i) := '3';
        when 4 => result(i) := '4';
        when 5 => result(i) := '5';
        when 6 => result(i) := '6';
        when 7 => result(i) := '7';
        when 8 => result(i) := '8';
        when 9 => result(i) := '9';
      end case;
      ib := ib / 10;
      if ib = 0 then
        msd := i;
        exit;
      end if;
    end loop;
    if ib < 0 then
      return sign & result(msd to 10);
    else
      return result(msd to 10);
    end if;
  end tconv;

  function tconv  ( s : string ) return integer is
    variable result : integer := 0;
    alias si : string( s'length downto 1 ) is s;
    variable invalid : boolean := false;
  begin
    for i in si'range loop
      case si( i ) is
        when '0'    => null;
        when '1'    => result := result + 10 ** ( i - 1 ) ;
        when '2'    => result := result + 2 * 10 ** ( i - 1 ) ;
        when '3'    => result := result + 3 * 10 ** ( i - 1 ) ;
        when '4'    => result := result + 4 * 10 ** ( i - 1 ) ;
        when '5'    => result := result + 5 * 10 ** ( i - 1 ) ;
        when '6'    => result := result + 6 * 10 ** ( i - 1 ) ;
        when '7'    => result := result + 7 * 10 ** ( i - 1 ) ;
        when '8'    => result := result + 8 * 10 ** ( i - 1 ) ;
        when '9'    => result := result + 9 * 10 ** ( i - 1 ) ;
        when others => invalid := true;
      end case;
    end loop;
    assert not invalid
      report "String contained characters other than 0 thru 9" &
      "; treating invalid characters as 0's"
      severity warning;
    return result;
  end tconv;

  function tconv  ( s : string; base : base_t ) return integer is
    alias sv : string ( s'length downto 1 ) is s;
    variable result : integer := 0;
    variable invalid : boolean := false;
    variable vc_len : integer := 20;
    variable validchars : string(1 to 20) := "0 thru 9 or A thru F";
  begin
    case base is
      when bin =>
        vc_len := 6;
        validchars(1 to 6) := "0 or 1";
        for i in sv'range loop
          case sv( i ) is
            when '0'    => null;
            when '1'    => result := result + 2 ** ( i - 1 ) ;
            when others => invalid := true;
          end case;
        end loop;

      when oct =>
        vc_len := 8;
        validchars(1 to 8) := "0 thru 7";
        for i in sv'range loop
          case sv( i ) is
            when '0'    => null;
            when '1'    => result := result + 8 ** ( i - 1 ) ;
            when '2'    => result := result + 2 * 8 ** ( i - 1 ) ;
            when '3'    => result := result + 3 * 8 ** ( i - 1 ) ;
            when '4'    => result := result + 4 * 8 ** ( i - 1 ) ;
            when '5'    => result := result + 5 * 8 ** ( i - 1 ) ;
            when '6'    => result := result + 6 * 8 ** ( i - 1 ) ;
            when '7'    => result := result + 7 * 8 ** ( i - 1 ) ;
            when others => invalid := true;
          end case;
        end loop;

      when dec =>
        vc_len := 8;
        validchars(1 to 8) := "0 thru 9";
        for i in sv'range loop
          case sv( i ) is
            when '0'    => null;
            when '1'    => result := result + 10 ** ( i - 1 ) ;
            when '2'    => result := result + 2 * 10 ** ( i - 1 ) ;
            when '3'    => result := result + 3 * 10 ** ( i - 1 ) ;
            when '4'    => result := result + 4 * 10 ** ( i - 1 ) ;
            when '5'    => result := result + 5 * 10 ** ( i - 1 ) ;
            when '6'    => result := result + 6 * 10 ** ( i - 1 ) ;
            when '7'    => result := result + 7 * 10 ** ( i - 1 ) ;
            when '8'    => result := result + 8 * 10 ** ( i - 1 ) ;
            when '9'    => result := result + 9 * 10 ** ( i - 1 ) ;
            when others => invalid := true;
          end case;
        end loop;

      when hex =>
        for i in sv'range loop
          case sv( i ) is
            when '0'    => null;
            when '1'    => result := result + 16 ** ( i - 1 ) ;
            when '2'    => result := result + 2 * 16 ** ( i - 1 ) ;
            when '3'    => result := result + 3 * 16 ** ( i - 1 ) ;
            when '4'    => result := result + 4 * 16 ** ( i - 1 ) ;
            when '5'    => result := result + 5 * 16 ** ( i - 1 ) ;
            when '6'    => result := result + 6 * 16 ** ( i - 1 ) ;
            when '7'    => result := result + 7 * 16 ** ( i - 1 ) ;
            when '8'    => result := result + 8 * 16 ** ( i - 1 ) ;
            when '9'    => result := result + 9 * 16 ** ( i - 1 ) ;
            when 'A' | 'a'   => result := result + 10 * 16 ** ( i - 1 ) ;
            when 'B' | 'b'   => result := result + 11 * 16 ** ( i - 1 ) ;
            when 'C' | 'c'   => result := result + 12 * 16 ** ( i - 1 ) ;
            when 'D' | 'd'   => result := result + 13 * 16 ** ( i - 1 ) ;
            when 'E' | 'e'   => result := result + 14 * 16 ** ( i - 1 ) ;
            when 'F' | 'f'   => result := result + 15 * 16 ** ( i - 1 ) ;
            when others => invalid := true;
          end case;
        end loop;

      when others =>
        assert false report "Unsupported base passed." severity warning;

    end case;

    assert not invalid
      report "String contained characters other than " &
      validchars(1 to vc_len) & "; treating invalid characters as 0's"
      severity warning;

    return result;
  end;

  function tconv  ( s : string ) return bit is
    variable result : bit ;
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    assert s'length = 1
      report "String conversion to bit longer that 1 character"
      severity warning;
    case si(1) is
      when '0' => result := '0';
      when '1' => result := '1';
      when others =>
        invalid := true;
        result := '0';
    end case;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
             "treating invalid characters as 0's"
      severity warning;
    return result;
  end tconv;

  function tconv  ( s : string ) return bit_vector is
    variable result : bit_vector( 1 to s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    for i in si'range loop
      case si(i) is
        when '0' => result( i ) := '0';
        when '1' => result( i ) := '1';
        when others =>
          invalid := true;
          result( i ) := '0';
      end case;
    end loop;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
      "treating invalid characters as 0's"
      severity warning;
    return result( 1 to result'length );
  end tconv;

  function tconv  ( s : string; base : base_t ) return bit_vector is
    variable result : bit_vector( 1 to 4*s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    case base is
      when bin =>
        for i in si'range loop
          case si(i) is
            when '0' => result( i ) := '0';
            when '1' => result( i ) := '1';
            when others =>
              invalid := true;
              result( i ) := '0';
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 or 1; " &
          "treated invalid characters as 0's"
          severity warning;
        return result(1 to s'length) ;

      when oct =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (3*i)-2 to 3*i ) := o"0";
            when '1' => result( (3*i)-2 to 3*i ) := o"1";
            when '2' => result( (3*i)-2 to 3*i ) := o"2";
            when '3' => result( (3*i)-2 to 3*i ) := o"3";
            when '4' => result( (3*i)-2 to 3*i ) := o"4";
            when '5' => result( (3*i)-2 to 3*i ) := o"5";
            when '6' => result( (3*i)-2 to 3*i ) := o"6";
            when '7' => result( (3*i)-2 to 3*i ) := o"7";
            when others =>
              invalid := true;
              result( (3*i)-2 to 3*i ) := o"0";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 7; " &
          "treated invalid characters as 0's"
          severity warning;
        return result( 1 to 3*s'length );

      when hex =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (4*i)-3 to 4*i ) := x"0";
            when '1' => result( (4*i)-3 to 4*i ) := x"1";
            when '2' => result( (4*i)-3 to 4*i ) := x"2";
            when '3' => result( (4*i)-3 to 4*i ) := x"3";
            when '4' => result( (4*i)-3 to 4*i ) := x"4";
            when '5' => result( (4*i)-3 to 4*i ) := x"5";
            when '6' => result( (4*i)-3 to 4*i ) := x"6";
            when '7' => result( (4*i)-3 to 4*i ) := x"7";
            when '8' => result( (4*i)-3 to 4*i ) := x"8";
            when '9' => result( (4*i)-3 to 4*i ) := x"9";
            when 'A' | 'a' => result( (4*i)-3 to 4*i ) := x"A";
            when 'B' | 'b' => result( (4*i)-3 to 4*i ) := x"B";
            when 'C' | 'c' => result( (4*i)-3 to 4*i ) := x"C";
            when 'D' | 'd' => result( (4*i)-3 to 4*i ) := x"D";
            when 'E' | 'e' => result( (4*i)-3 to 4*i ) := x"E";
            when 'F' | 'f' => result( (4*i)-3 to 4*i ) := x"F";
            when others =>
              invalid := true;
              result( (4*i)-3 to 4*i ) := x"0";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 9 or " &
          "A through F; " &
          "treated invalid characters as 0's"
          severity warning;
        return result( 1 to 4*s'length );

      when others =>
        assert false report "Unsupported base passed." severity warning;
        return result ;

    end case;
  end tconv;

  function tconv  ( s : string ) return std_ulogic is
    variable result : std_ulogic ;
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    assert s'length = 1
      report "String conversion to bit longer that 1 character"
      severity warning;
    case si(1) is
      when '0' => result := '0';
      when '1' => result := '1';
      when others =>
        invalid := true;
        result := 'X';
    end case;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
             "treating invalid characters as X's"
      severity warning;
    return result;
  end tconv;

  function tconv  ( s : string ) return std_ulogic_vector is
    variable result : std_ulogic_vector( 1 to s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    for i in si'range loop
      case si(i) is
        when '0' => result( i ) := '0';
        when '1' => result( i ) := '1';
        when others =>
          invalid := true;
          result( i ) := 'X';
      end case;
    end loop;
    assert not invalid
      report "String contained characters other than 0 or 1; " &
      "treating invalid characters as X's"
      severity warning;
    return result( 1 to result'length );
  end tconv;

  function TConv  ( s : string; base : base_t ) return std_ulogic_vector is
    variable result : std_ulogic_vector( 1 to 4*s'length );
    alias si : string( 1 to s'length ) is s;
    variable invalid : boolean := false;
  begin
    case base is
      when bin =>
        for i in si'range loop
          case si(i) is
            when '0' => result( i ) := '0';
            when '1' => result( i ) := '1';
            when others =>
              invalid := true;
              result( i ) := '0';
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 or 1; " &
          "treated invalid characters as 0's"
          severity warning;
        return result(1 to s'length) ;

      when oct =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (3*i)-2 to 3*i ) := "000";
            when '1' => result( (3*i)-2 to 3*i ) := "001";
            when '2' => result( (3*i)-2 to 3*i ) := "010";
            when '3' => result( (3*i)-2 to 3*i ) := "011";
            when '4' => result( (3*i)-2 to 3*i ) := "100";
            when '5' => result( (3*i)-2 to 3*i ) := "101";
            when '6' => result( (3*i)-2 to 3*i ) := "110";
            when '7' => result( (3*i)-2 to 3*i ) := "111";
            when others =>
              invalid := true;
              result( (3*i)-2 to 3*i ) := "XXX";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 7; " &
          "treated invalid characters as X's"
          severity warning;
        return result( 1 to 3*s'length );

      when hex =>
        for i in si'range loop
          case si(i) is
            when '0' => result( (4*i)-3 to 4*i ) := "0000";
            when '1' => result( (4*i)-3 to 4*i ) := "0001";
            when '2' => result( (4*i)-3 to 4*i ) := "0010";
            when '3' => result( (4*i)-3 to 4*i ) := "0011";
            when '4' => result( (4*i)-3 to 4*i ) := "0100";
            when '5' => result( (4*i)-3 to 4*i ) := "0101";
            when '6' => result( (4*i)-3 to 4*i ) := "0110";
            when '7' => result( (4*i)-3 to 4*i ) := "0111";
            when '8' => result( (4*i)-3 to 4*i ) := "1000";
            when '9' => result( (4*i)-3 to 4*i ) := "1001";
            when 'A' | 'a' => result( (4*i)-3 to 4*i ) := "1010";
            when 'B' | 'b' => result( (4*i)-3 to 4*i ) := "1011";
            when 'C' | 'c' => result( (4*i)-3 to 4*i ) := "1100";
            when 'D' | 'd' => result( (4*i)-3 to 4*i ) := "1101";
            when 'E' | 'e' => result( (4*i)-3 to 4*i ) := "1110";
            when 'F' | 'f' => result( (4*i)-3 to 4*i ) := "1111";
            when others =>
              invalid := true;
              result( (4*i)-3 to 4*i ) := "XXXX";
          end case;
        end loop;
        assert not invalid
          report "String contained characters other than 0 through 9 or " &
          "A through F; " &
          "treated invalid characters as X's"
          severity warning;
        return result( 1 to 4*s'length );

      when others =>
        assert false report "Unsupported base passed." severity warning;
        return result ;

    end case;
  end tconv;

  function tconv  ( s : std_ulogic ) return boolean is
    variable result: boolean;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case s is
      when '0' => result := false;
      when '1' => result := true;
      when 'L' => result := false;
      when 'H' => result := true;
      when others => result := false;
    end case;
    return result;
  end;

  function tconv  ( s : std_ulogic ) return bit is
    variable result: bit;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case s is
      when '0' => return('0');
      when '1' => return('1');
      when 'L' => return('0');
      when 'H' => return('1');
      when others => return('0');
    end case;
    return result;
  end;

  function tconv  ( s : std_ulogic ) return character is
  begin
    case s is
      when '0' => return('0');
      when 'L' => return('L');
      when '1' => return('1');
      when 'H' => return('H');
      when 'U' => return('U');
      when 'W' => return('W');
      when '-' => return('-');
      when 'Z' => return('Z');
      when others => return('X');
    end case;
  end;

  function tconv  ( s : std_ulogic ) return string is
  begin
    case s is
      when '0' => return("0");
      when 'L' => return("L");
      when '1' => return("1");
      when 'H' => return("H");
      when 'U' => return("U");
      when 'W' => return("W");
      when '-' => return("-");
      when 'Z' => return("Z");
      when others => return("X");
    end case;
  end;

  function tconv  ( s : std_ulogic ) return integer is
  begin
    case s is
      when '0' => return(0);
      when 'L' => return(0);
      when '1' => return(1);
      when 'H' => return(1);
      when 'U' => return(0);
      when 'W' => return(0);
      when '-' => return(0);
      when 'Z' => return(0);
      when others => return(0);
    end case;
  end;

  function tconv  ( s : std_ulogic ) return std_ulogic_vector is
    variable result : std_ulogic_vector(0 to 0);
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case s is
      when '0' => result := "0";
      when '1' => result := "1";
      when 'L' => result := "0";
      when 'H' => result := "1";
      when 'W' => result := "W";
      when '-' => result := "-";
      when 'U' => result := "U";
      when 'X' => result := "X";
      when 'Z' => result := "Z";
    end case;
    return result;
  end;




  function tconv  ( s : std_ulogic_vector ) return std_ulogic is
    alias sv : std_ulogic_vector ( 1 to s'length ) is s;
    variable result : std_ulogic;
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    case sv(s'length) is
      when '0' => result := '0';
      when '1' => result := '1';
      when 'L' => result := '0';
      when 'H' => result := '1';
      when 'W' => result := 'W';
      when '-' => result := '-';
      when 'U' => result := 'U';
      when 'X' => result := 'X';
      when 'Z' => result := 'Z';
    end case;
    return result;
  end;

  function tconv  ( s : std_logic_vector ) return bit_vector is
    alias sv : std_logic_vector ( 1 to s'length ) is s;
    variable result : bit_vector ( 1 to s'length ) := (others => '0');
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;
  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
        when 'L' => result(i) := '0';
        when 'H' => result(i) := '1';
        when others => result(i) := '0';
      end case;
    end loop;
    return result;
  end;

  function tconv  ( s : std_logic_vector ) return std_ulogic_vector is
    alias sv : std_logic_vector ( 1 to s'length ) is s;
    variable result : std_ulogic_vector ( 1 to s'length ) := (others => 'X');
    ATTRIBUTE synthesis_return OF result:VARIABLE IS "FEED_THROUGH" ;

  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
        when 'L' => result(i) := '0';
        when 'H' => result(i) := '1';
        when 'W' => result(i) := 'W';
        when '-' => result(i) := '-';
        when 'U' => result(i) := 'U';
        when 'X' => result(i) := 'X';
        when 'Z' => result(i) := 'Z';
      end case;
    end loop;
    return result;
  end;

  function tconv  ( s : std_logic_vector ) return integer is
    variable int_result : integer := 0;
    ATTRIBUTE synthesis_return OF int_result:VARIABLE IS "FEED_THROUGH" ;
    variable int_exp    : integer := 0;
    alias    new_value  : std_logic_vector(1 to s'length) is s ;
    variable invalid : boolean := false;
  begin
    for i in new_value'length downto 1 loop
      case new_value(i) is
        when '1' => int_result := int_result + (2**int_exp);
        when '0' => null;
        when others =>
          invalid := true;
      end case;
      int_exp := int_exp + 1;
    end loop;
    assert not invalid
      report "The std_logic_Vector input contained values " &
      "other than '0' and '1'.  They were treated as zeroes."
      severity warning;
    return int_result;
  end tconv ;

  function tconv  ( s : std_logic_vector ) return string is
    alias sv : std_logic_vector ( 1 to s'length ) is s;
    variable result : string ( 1 to s'length ) := (others => 'X');
  begin
    for i in result'range loop
      case sv(i) is
        when '0' => result(i) := '0';
        when 'L' => result(i) := 'L';
        when '1' => result(i) := '1';
        when 'H' => result(i) := 'H';
        when 'U' => result(i) := 'U';
        when '-' => result(i) := '-';
        when 'W' => result(i) := 'W';
        when 'Z' => result(i) := 'Z';
        when others => result(i) := 'X';
      end case;
    end loop;
    return result;
  end;

  function tconv  ( s : std_logic_vector; base : base_t ) return string is
    alias sv : std_logic_vector ( 1 to s'length ) is s;
    variable result : string ( 1 to s'length );
    variable start : positive;
    variable extra : natural;
    variable resultlength : positive;
    subtype bv is std_logic_vector( 1 to 1 );
    subtype qv is std_logic_vector( 1 to 2 );
    subtype ov is std_logic_vector( 1 to 3 );
    subtype hv is std_logic_vector( 1 to 4 );
  begin
    case base is
      when bin =>
        resultLength := sv'length;
        start := 1;
        for i in start to resultLength loop
          case sv( i ) is
            when '0' => result( i ) := '0';
            when '1' => result( i ) := '1';
            when 'X' => result( i ) := 'X';
            when 'L' => result( i ) := 'L';
            when 'H' => result( i ) := 'H';
            when 'W' => result( i ) := 'W';
            when '-' => result( i ) := '-';
            when 'U' => result( i ) := 'U';
            when 'Z' => result( i ) := 'Z';
          end case;
        end loop;

      when oct =>
        extra := sv'length rem ov'length;
        case extra is
          when 0 =>
            resultLength := s'length/ov'length;
            start := 1;
          when 1 =>
            resultLength := ( s'length/ov'length ) + 1;
            start := 2;
            case sv( 1 ) is
              when '0' => result( 1 ) := '0';
              when '1' => result( 1 ) := '1';
              when '-' => result( 1 ) := '-';
              when 'X' => result( 1 ) := 'X';
              when 'U' => result( 1 ) := 'U';
              when 'Z' => result( 1 ) := 'Z';
              when others => result( 1 ) := '.';
            end case;
          when 2 =>
            resultLength := ( s'length/ov'length ) + 1;
            start := 2;
            case qv'( sv( 1 to 2 ) ) is
              when "00" => result( 1 ) := '0';
              when "01" => result( 1 ) := '1';
              when "10" => result( 1 ) := '2';
              when "11" => result( 1 ) := '3';
              when "--" => result( 1 ) := '-';
              when "XX" => result( 1 ) := 'X';
              when "UU" => result( 1 ) := 'U';
              when "ZZ" => result( 1 ) := 'Z';
              when others => result( 1 ) := '.';
            end case;
          when others =>
            assert false report "TCONV fatal condition" severity failure;
        end case;

        for i in 0 to resultLength - start loop
          case ov'( sv( (ov'length*i)+(extra+1) to (ov'length*i)+(extra+3) ) ) is
            when "000" => result( i+start ) := '0';
            when "001" => result( i+start ) := '1';
            when "010" => result( i+start ) := '2';
            when "011" => result( i+start ) := '3';
            when "100" => result( i+start ) := '4';
            when "101" => result( i+start ) := '5';
            when "110" => result( i+start ) := '6';
            when "111" => result( i+start ) := '7';
            when "---" => result( i+start ) := '-';
            when "XXX" => result( i+start ) := 'X';
            when "UUU" => result( i+start ) := 'U';
            when "ZZZ" => result( i+start ) := 'Z';
            when others => result( i+start ) := '.';
          end case;
        end loop;

      when hex =>
        extra := s'length rem hv'length;
        case extra is
          when 0 =>
            resultLength := s'length/hv'length;
            start := 1;
          when 1 =>
            resultLength := ( s'length/hv'length ) + 1;
            start := 2;
            case sv( 1 ) is
              when '0' => result( 1 ) := '0';
              when '1' => result( 1 ) := '1';
              when '-' => result( 1 ) := '-';
              when 'X' => result( 1 ) := 'X';
              when 'U' => result( 1 ) := 'U';
              when 'Z' => result( 1 ) := 'Z';
              when others => result( 1 ) := '.';
            end case;
          when 2 =>
            resultLength := ( s'length/hv'length ) + 1;
            start := 2;
            case qv'( sv( 1 to 2 ) ) is
              when "00" => result( 1 ) := '0';
              when "01" => result( 1 ) := '1';
              when "10" => result( 1 ) := '2';
              when "11" => result( 1 ) := '3';
              when "--" => result( 1 ) := '-';
              when "XX" => result( 1 ) := 'X';
              when "UU" => result( 1 ) := 'U';
              when "ZZ" => result( 1 ) := 'Z';
              when others => result( 1 ) := '.';
            end case;
          when 3 =>
            resultLength := ( s'length/hv'length ) + 1;
            start := 2;
            case ov'( sv( 1 to 3 ) ) is
              when "000" => result( 1 ) := '0';
              when "001" => result( 1 ) := '1';
              when "010" => result( 1 ) := '2';
              when "011" => result( 1 ) := '3';
              when "100" => result( 1 ) := '4';
              when "101" => result( 1 ) := '5';
              when "110" => result( 1 ) := '6';
              when "111" => result( 1 ) := '7';
              when "---" => result( 1 ) := '-';
              when "XXX" => result( 1 ) := 'X';
              when "UUU" => result( 1 ) := 'U';
              when "ZZZ" => result( 1 ) := 'Z';
              when others => result( 1 ) := '.';
            end case;
          when others =>
            assert false report "TCONV fatal condition" severity failure;
        end case;

        for i in 0 to resultLength - start loop
          case hv'( SV( (hv'length*i)+(extra+1) to (hv'length*i)+(extra+4) ) ) is
            when "0000" => result( i+start ) := '0';
            when "0001" => result( i+start ) := '1';
            when "0010" => result( i+start ) := '2';
            when "0011" => result( i+start ) := '3';
            when "0100" => result( i+start ) := '4';
            when "0101" => result( i+start ) := '5';
            when "0110" => result( i+start ) := '6';
            when "0111" => result( i+start ) := '7';
            when "1000" => result( i+start ) := '8';
            when "1001" => result( i+start ) := '9';
            when "1010" => result( i+start ) := 'A';
            when "1011" => result( i+start ) := 'B';
            when "1100" => result( i+start ) := 'C';
            when "1101" => result( i+start ) := 'D';
            when "1110" => result( i+start ) := 'E';
            when "1111" => result( i+start ) := 'F';
            when "----" => result( i+start ) := '-';
            when "XXXX" => result( i+start ) := 'X';
            when "UUUU" => result( i+start ) := 'U';
            when "ZZZZ" => result( i+start ) := 'Z';
            when others => result( i+start ) := '.';
          end case;
        end loop;

      when others =>
        assert false report "Unsupported base passed." severity warning;
    end case;
    return result( 1 to resultLength );
  end;

  function hexstring( d : std_ulogic_vector ) return string is
    variable nd :
      std_ulogic_vector( 0 to ((d'length + (4 - (d'length mod 4))) - 1) ) := ( others => '0' );
    variable r : string(1 to (nd'length/4));
    variable hexsize   : integer;
    variable offset    : integer;
    subtype iv4 is std_ulogic_vector(1 to 4);
  begin

    offset := d'length mod 4;

    if offset = 0 then
      hexsize := d'length / 4;
      nd( 0 to d'length - 1 ) := d;
    else
      hexsize := nd'length / 4;
      nd( ( nd'left + (4 - offset) ) to nd'right ) := d;
    end if;

    for i in 0 to hexsize - 1 loop

      case iv4( nd( ( i * 4 ) to ( ( i * 4 ) + 3 ) ) ) IS
        when "0000"    => r(i + 1) := '0';
        when "0001"    => r(i + 1) := '1';
        when "0010"    => r(i + 1) := '2';
        when "0011"    => r(i + 1) := '3';
        when "0100"    => r(i + 1) := '4';
        when "0101"    => r(i + 1) := '5';
        when "0110"    => r(i + 1) := '6';
        when "0111"    => r(i + 1) := '7';
        when "1000"    => r(i + 1) := '8';
        when "1001"    => r(i + 1) := '9';
        when "1010"    => r(i + 1) := 'A';
        when "1011"    => r(i + 1) := 'B';
        when "1100"    => r(i + 1) := 'C';
        when "1101"    => r(i + 1) := 'D';
        when "1110"    => r(i + 1) := 'E';
        when "1111"    => r(i + 1) := 'F';
        when "----"    => r(i + 1) := '-';
        when "XXXX"    => r(i + 1) := 'X';
        when "UUUU"    => r(i + 1) := 'U';
        when "ZZZZ"    => r(i + 1) := 'Z';
        when others    => r(i + 1) := '.';
      end case;

    end loop;

    return r(1 to hexsize);
  end hexstring;

  function octstring( d : std_ulogic_vector ) return string is
    variable nd :
      std_ulogic_vector( 0 to ((d'length + (3 - (d'length mod 3))) - 1) ) := ( others => '0' );
    variable offset    : integer;
    variable r : string(1 to (nd'length/3));
    variable octsize   : integer;
    subtype iv3 is std_ulogic_vector(1 to 3);
  begin

    offset := d'length mod 3;

    if offset = 0 then
      octsize := d'length / 3;
      nd( 0 to d'length - 1 ) := d;
    else
      octsize := nd'length / 3;
      nd( ( nd'left + (3 - offset) ) to nd'right ) := d;
    end if;

    for i in 0 to octsize - 1 loop

      case iv3( nd( ( i * 3 ) to ( ( i * 3 ) + 2 ) ) ) is
        when "000"    => r(i + 1) := '0';
        when "001"    => r(i + 1) := '1';
        when "010"    => r(i + 1) := '2';
        when "011"    => r(i + 1) := '3';
        when "100"    => r(i + 1) := '4';
        when "101"    => r(i + 1) := '5';
        when "110"    => r(i + 1) := '6';
        when "111"    => r(i + 1) := '7';
        when "---"    => r(i + 1) := '-';
        when "XXX"    => r(i + 1) := 'X';
        when "UUU"    => r(i + 1) := 'U';
        when "ZZZ"    => r(i + 1) := 'Z';
        when others    => r(i + 1) := '.';
      end case;

    end loop;

    return r;
  end octstring;

  function bitstring( d : std_ulogic_vector ) return string is
    variable nd :
      std_ulogic_vector(0 to ( d'length - 1 ) ) := ( others => '0' );
    variable r : string(1 to (nd'length));
  begin
    nd := d;
    for i in nd'range loop
      r(i + 1) := std_ulogic_to_character( nd(i) );
    end loop;
    return r;
  end bitstring;


  constant no_warning: boolean := false;

  function std_match (l, r: std_ulogic) return std_ulogic is
    variable value: std_ulogic;
  begin
    if (b_match_table(l,r) = true) then
      return '1' ;
    else
      return '0' ;
    end if ;
  end std_match;

  function std_match (l, r: std_ulogic_vector) return std_ulogic is
    alias lv: std_ulogic_vector(1 to l'length) is l;
    alias rv: std_ulogic_vector(1 to r'length) is r;
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert no_warning
        report "NUMERIC_IBM.STD_MATCH: null detected, returning FALSE"
        severity warning;
      return 'X' ;
    end if;
    if lv'length /= rv'length then
      assert no_warning
        report "NUMERIC_IBM.STD_MATCH: L'LENGTH /= R'LENGTH, returning FALSE"
        severity warning;
      return 'X' ;
    else
      for i in lv'low to lv'high loop
        if not (b_match_table(lv(i), rv(i))) then
          return '0' ;
        end if;
      end loop;
      return '1' ;
    end if;
  end std_match;

  function "="  ( l,r : integer ) return std_ulogic is
  begin
    if (l - r) = 0 then
      return ('1');
    else
      return ('0');
    end if ;
  end "=";

  function "/=" ( l,r : integer ) return std_ulogic is
  begin
    if (l - r) = 0 then
      return ('0');
    else
      return ('1');
    end if ;
  end "/=";

  function ">"  ( l,r : integer ) return std_ulogic is
  begin
    if (l - r) > 0 then
      return ('1');
    else
      return ('0');
    end if ;
  end ">";

  function ">="  ( l,r : integer ) return std_ulogic is
  begin
    if (l - r) >= 0 then
      return ('1');
    else
      return ('0');
    end if ;
  end ">=";

  function "<"  ( l,r : integer ) return std_ulogic is
  begin
    if (r - l) > 0 then
      return ('1');
    else
      return ('0');
    end if ;
  end "<";

  function "<=" ( l,r : integer ) return std_ulogic is
  begin
    if (r - l) >= 0 then
      return ('1');
    else
      return ('0');
    end if ;
  end "<=";

  function "="  ( l,r : std_ulogic ) return std_ulogic is
  begin
    return ( tconv( l = r ) );
  end "=";

  function "/=" ( l,r : std_ulogic ) return std_ulogic is
  begin
    return ( tconv( l /= r ) );
  end "/=";

  function ">"  ( l,r : std_ulogic ) return std_ulogic is
  begin
    return ( tconv( l > r ) );
  end ">";

  function ">="  ( l,r : std_ulogic ) return std_ulogic is
  begin
    return ( tconv( l >= r ) );
  end ">=";

  function "<"  ( l,r : std_ulogic ) return std_ulogic is
  begin
    return ( tconv( l < r ) );
  end "<";

  function "<=" ( l,r : std_ulogic ) return std_ulogic is
  begin
    return ( tconv( l <= r ) );
  end "<=";


  function "=" ( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic := '1';
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the = " &
               "operator are unequal. "
        severity error;
        return '0' ;
    end if ;

    return ( tconv( l = r ) );
  end "=";

  function "/=" ( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic := '1';
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the /= " &
        "operator are unequal. "
        severity error;
      return '0' ;
    end if ;

    return ( tconv( l /= r ) );
  end "/=";

  function ">" ( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the > " &
        "operator are unequal. "
        severity error;
      return '0' ;
    end if ;

    return ( tconv( l > r ) );
  end ">";

  function ">=" ( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the >= " &
        "operator are unequal. "
        severity error;
      return '0' ;
    end if ;

    return ( tconv( l >= r ) );
  end ">=";

  function "<" ( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the < " &
        "operator are unequal. "
        severity error;
      return '0' ;
    end if ;

    return ( tconv( l < r ) );
  end "<";

  function "<=" ( l,r : std_ulogic_vector)  return std_ulogic is
    alias lv : std_ulogic_vector (l'length downto 1) is l;
    alias rv : std_ulogic_vector (r'length downto 1) is r;
    variable vs1_result    : std_ulogic_vector(0 to 1) := "00" ;
  begin
    if lv'length /= rv'length then
      assert false
        report "The bit lengths of the two inputs to the <= " &
        "operator are unequal. "
        severity error;
      return '0' ;
    end if ;

    return ( tconv( l <= r ) );
  end "<=";

  constant nau: std_ulogic_vector(0 downto 1) := (others => '0');

  function xsll (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
  is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) := (others => '0');
    attribute SYNTHESIS_RETURN of RESULT:variable is "SLL" ;
  begin
    if count <= arg_l then
      result(arg_l downto count) := xarg(arg_l-count downto 0);
    end if;
    return result;
  end xsll;

  function xsrl (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
  is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) := (others => '0');
    attribute SYNTHESIS_RETURN of RESULT:variable is "SRL" ;
  begin
    if count <= arg_l then
      result(arg_l-count downto 0) := xarg(arg_l downto count);
    end if;
    return result;
  end xsrl;

  function xsra (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
  is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0);
    variable xcount: natural := count;
    attribute SYNTHESIS_RETURN of RESULT:variable is "SRA" ;
  begin
    if ((arg'length <= 1) or (xcount = 0)) then return arg;
    else
      if (xcount > arg_l) then xcount := arg_l;
      end if;
      result(arg_l-xcount downto 0) := xarg(arg_l downto xcount);
      result(arg_l downto (arg_l - xcount + 1)) := (others => xarg(arg_l));
    end if;
    return result;
  end xsra;

  function xrol (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
  is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) := xarg;
    attribute SYNTHESIS_RETURN of RESULT:variable is "ROL" ;
    variable countm: integer;
  begin
    countm := count mod (arg_l + 1);
    if countm /= 0 then
      result(arg_l downto countm) := xarg(arg_l-countm downto 0);
      result(countm-1 downto 0) := xarg(arg_l downto arg_l-countm+1);
    end if;
    return result;
  end xrol;

  function xror (arg: std_ulogic_vector; count: natural) return std_ulogic_vector
  is
    constant arg_l: integer := arg'length-1;
    alias xarg: std_ulogic_vector(arg_l downto 0) is arg;
    variable result: std_ulogic_vector(arg_l downto 0) := xarg;
    attribute SYNTHESIS_RETURN of RESULT:variable is "ROR" ;
    variable countm: integer;
  begin
    countm := count mod (arg_l + 1);
    if countm /= 0 then
      result(arg_l-countm downto 0) := xarg(arg_l downto countm);
      result(arg_l downto arg_l-countm+1) := xarg(countm-1 downto 0);
    end if;
    return result;
  end xror;


  function shift_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
  begin
    if (arg'length < 1) then return nau;
    end if;
    return std_ulogic_vector(xsll(std_ulogic_vector(arg), count));
  end shift_left;

  function shift_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
  begin
    if (arg'length < 1) then return nau;
    end if;
    return std_ulogic_vector(xsrl(std_ulogic_vector(arg), count));
  end shift_right;


  function rotate_left (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
  begin
    if (arg'length < 1) then return nau;
    end if;
    return std_ulogic_vector(xrol(std_ulogic_vector(arg), count));
  end rotate_left;

  function rotate_right (arg: std_ulogic_vector; count: natural) return std_ulogic_vector is
  begin
    if (arg'length < 1) then return nau;
    end if;
    return std_ulogic_vector(xror(std_ulogic_vector(arg), count));
  end rotate_right;

  function "sll" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
  begin
    if (count >= 0) then
      return shift_left(arg, count);
    else
      return shift_right(arg, -count);
    end if;
  end "sll";

  function "srl" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
  begin
    if (count >= 0) then
      return shift_right(arg, count);
    else
      return shift_left(arg, -count);
    end if;
  end "srl";

  function "rol" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
  begin
    if (count >= 0) then
      return rotate_left(arg, count);
    else
      return rotate_right(arg, -count);
    end if;
  end "rol";

  function "ror" (arg: std_ulogic_vector; count: integer) return std_ulogic_vector is
  begin
    if (count >= 0) then
      return rotate_right(arg, count);
    else
      return rotate_left(arg, -count);
    end if;
  end "ror";


END std_ulogic_support ;

