;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

.module sys_util

.include "../common.h.s"
;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA


string_buffer:: .asciz "          "


;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------;; 
;;  sys_util_h_times_e
;;
;; Inputs:
;;   H and E
;; Outputs:
;;   HL is the product
;;   D is 0
;;   A,E,B,C are preserved
;; 36 bytes
;; min: 190cc
;; max: 242cc
;; avg: 216cc
;; Credits:
;;  Z80Heaven (http://z80-heaven.wikidot.com/advanced-math#toc9)

sys_util_h_times_e::
  ld d,#0
  ld l,d
  sla h 
  jr nc,.+3 
  ld l,e
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  jr nc,.+3 
  add hl,de
  add hl,hl 
  ret nc 
  add hl,de
  ret

;;-----------------------------------------------------------------;; 
;;  sys_util_h_times_e
;;
;;Inputs:
;;     HL is the numerator
;;     C is the denominator
;;Outputs:
;;     A is the remainder
;;     B is 0
;;     C is not changed
;;     DE is not changed
;;     HL is the quotient
;;
sys_util_hl_div_c::
       ld b,#16
       xor a
         add hl,hl
         rla
         cp c
         jr c,.+4
           inc l
           sub c
         djnz .-7
       ret

;;-----------------------------------------------------------------
;;
;; sys_util_BCD_GetEnd
;;
;;  
;;  Input:  b: number of bytes of the bcd number
;;          de: source for the first bcd bnumber
;;          hl: source for the second bcd number
;;  Output: 
;;  Destroyed: af, bc,de, hl
;;
;;  Chibi Akumas BCD code (https://www.chibiakumas.com/z80/advanced.php#LessonA1)
;;
sys_util_BCD_GetEnd::
;Some of our commands need to start from the most significant byte
;This will shift HL and DE along b bytes
	push bc
	ld c,b	;We want to add BC, but we need to add one less than the number of bytes
	dec c
	ld b,#0
	add hl,bc
	ex de, hl	;We've done HL, but we also want to do DE
	add hl,bc
	ex de, hl
	pop bc
	ret

;;-----------------------------------------------------------------
;;
;; BCD_Add
;;
;;   Add two BCD numbers
;;  Input:  hl: Number to add to de
;;          de: Number to store the sum 
;;  Output: 
;;  Destroyed: af, bc,de, hl
;;
;;  Chibi Akumas BCD code (https://www.chibiakumas.com/z80/advanced.php#LessonA1)
;;
sys_util_BCD_Add::
    or a
BCD_Add_Again:
    ld a, (de)
    adc (hl)
    daa
    ld (de), a
    inc de
    inc hl
    djnz BCD_Add_Again
    ret
  
;;-----------------------------------------------------------------
;;
;; sys_util_BCD_Compare
;;
;;  Compare two BCD numbers
;;  Input:  hl: BCD Number 1
;;          de: BCD Number 2
;;  Output: 
;;  Destroyed: af, bc,de, hl
;;
;;  Chibi Akumas BCD code (https://www.chibiakumas.com/z80/advanced.php#LessonA1)
;;
sys_util_BCD_Compare::
  ld b, #SCORE_NUM_BYTES
  call sys_util_BCD_GetEnd
BCD_cp_direct:
  ld a, (de)
  cp (hl)
  ret c
  ret nz
  dec de
  dec hl
  djnz BCD_cp_direct
  or a                    ;; Clear carry
  ret

;;-----------------------------------------------------------------
;;
;; sys_util_get_random_number
;;
;;  Returns a random number between 0 and <end>
;;  Input:  a: <end>
;;  Output: a: random number
;;  Destroyed: af, bc,de, hl

sys_util_get_random_number::
  ld (#random_max_number), a
  call cpct_getRandom_mxor_u8_asm
  ld a, l                             ;; Calculates a pseudo modulus of max number
  ld h,#0                             ;; Load hl with the random number
random_max_number = .+1
  ld c, #0                            ;; Load c with the max number
  ld b, #0
_random_mod_loop:
  or a                                ;; ??
  sbc hl,bc                           ;; hl = hl - bc
  jp p, _random_mod_loop              ;; Jump back if hl > 0
  add hl,bc                           ;; Adds MAX_MODEL_CARD to hl back to get back to positive values
  ld a,l                              ;; loads the normalized random number in a
ret

;;-----------------------------------------------------------------
;;
;; sys_util_delay
;;
;;  Waits a determined number of frames 
;;  Input:  b: number of frames
;;  Output: 
;;  Destroyed: af, bc
;;
sys_util_delay::
  push bc
  call cpct_waitVSYNCStart_asm
  pop bc
  djnz sys_util_delay
  ret