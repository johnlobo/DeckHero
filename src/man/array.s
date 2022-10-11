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
.module array_manager

.include "man/array.h.s"
.include "cpctelera.h.s"
.include "common.h.s"
.include "man/deck.h.s"
.include "sys/util.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA



;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_array_init
;;
;;  Initilizes an array
;;  Input: ix points to the array
;;  Output: 
;;  Modified: AF, HL
;;
man_array_init::
    xor a
    ld a_count(ix), a           ;; Initialize the number of elements in the array

    ld__hl_ix                   ;; point hl to the start of the array 
    ld a, #a_array
    add_hl_a
    
    ld a_pend(ix), l            ;; load pointer to the end in hl
    ld a_pend+1(ix), h

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
    ret


;;-----------------------------------------------------------------
;;
;; man_array_create_element
;;
;;  Create a card from the model pointed by HL
;;  Input:  ix: pointer to the array 
;;          hl: pointer to the entity to add to the array
;;  Output: hl: points to the new created entity
;;  Modified: AF, BC, DE, HL
;;
man_array_create_element::
    ld b, #0                        ;; bc = component size
    ld a, a_component_size(ix)      ;;
    ld c, a                         ;;    
    ld (_create_size), a            ;; self modifying code to move the size of the entity to bc
    xor a                           ;; ld a, #0
    ld (_create_size+1), a          ;;
    
    ld e, a_pend(ix)                ;; Load the address of the next element in de
    ld d, a_pend+1(ix)              ;;
    push de                         ;; Store the address of the next element to return it at the end
    ldir                            ;; de=pend, bc=component_size, hl=pointer to the entity to be added

    inc a_count(ix)                 ;; increase the number of entities

    ld l, a_pend(ix)                ;; load in hl the pointer to the next entity
    ld h, a_pend+1(ix)
_create_size = .+1
    ld   bc, #00
    add  hl, bc

    ld   a_pend(ix), l              ;; update the pointer to the next entity
    ld   a_pend+1(ix), h            ;;

    pop hl                          ;; restore the new element address in hl
ret




;;-----------------------------------------------------------------
;;
;; man_array_remove_element
;;
;;  Remove a card pointed by a from the hand
;;  Input: a: number of card to remove
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_array_remove_element::

    ld b, a                     ;; copy card to erase to b
    ld a, a_count(ix)           ;; check if we have to erase the last card
    dec a                       ;;
    cp b                        ;;
    jr z, _last_card            ;;  jump if we have to erase the last card

    push ix                     ;; hl to the start of the array    
    pop hl                      ;;
    ld de, #a_array             ;;
    add hl, de                  ;;

    ld a, b                     ;; restore a value from b
    or a                        ;; if we have to erase the first card we are don with hl
    jp z, _calc_end_of_card     ;; 

    ld de, #sizeof_e            ;; copy the size of a card in de
_start_loop:                    ;;
    add hl, de                  ;; hl advance a card
    djnz _start_loop            ;; hl points to the start of the card to remove

_calc_end_of_card:
    ld d, h                     ;; copy hl in de-> de=start of the card to remove
    ld e, l                     ;;

    ld bc, #sizeof_e            ;; add size of card to hl
    add hl,bc                   ;; hl= end of the card to remove

    push de                     ;; save de
    push hl                     ;; save hl
    ex de, hl                   ;; we have in de the end of the card to remove

    ld l, a_pend(ix)            ;; calculate the amount of data to move
    ld h, a_pend+1(ix)          ;; 
    sbc hl, de                  ;;
    ld b, h                     ;; move hl to bc
    ld c, l                     ;; bc = size of data to move

    pop hl                      ;; restore hl
    pop de                      ;; restore de

    ldir
    jr _move_pend

_last_card:
    dec a_selected(ix)
    
_move_pend:
    ld l, a_pend(ix)            ;; calculate the amount of data to move
    ld h, a_pend+1(ix)          ;; 
    ld   bc, #sizeof_e          ;;
    sbc  hl, bc                 ;;
    ld a_pend(ix), l            ;; store hl in pend
    ld a_pend+1(ix), h          ;; 

    dec a_count(ix) 

ret

;;-----------------------------------------------------------------
;;
;; man_array_get_element
;;
;;  Retrieves in hl the element in position a
;;  Input:  a: number of element to return
;;          ix: array structure
;;  Output: hl: pointer to the element
;;  Modified: AF, BC, DE, HL
;;
man_array_get_element::
    push ix                     ;; load in hl the beginning of the array
    pop hl                      ;;
    ld de, #a_array
    add hl, de

    or a                        ;; check if we have to retrieve the first card
    ret z                       ;; retrurn if we want to get the first card

    ld b, a
    ld d, #0                    ;; copy the size of an entity in de
    ld e, a_component_size(ix)  ;; 
_g_e_sum_loop:                  ;;
    add hl, de                  ;;  add de to hl until we reach the card
    djnz _g_e_sum_loop          ;;

    ret


;;-----------------------------------------------------------------
;;
;; man_array_get_random_element
;;
;;  Retrieves in hl the element in a random position and in a the position
;;  Input:  ix: array structure
;;          a: offset
;;  Output: hl: element
;;          a : number of element.
;;  Modified: AF, BC, DE, HL
;;
man_array_get_random_element::
    ld (SUB_OFFSET), a
    ld (ADD_OFFSET), a
    push ix                         ;; load in hl the beginning of the array
    pop hl                          ;;
    ld de, #a_array 
    add hl, de                      ;; move hl to the beginning of the array
    push hl                         ;; save hl (array address)

    ld a, a_count(ix)               ;; load max number in a
    SUB_OFFSET = . +1
    sub #0x00
    call sys_util_get_random_number
    ADD_OFFSET = . +1
    add #0x00
    ld (_r_e_output), a             ;; store the random number in the output variable
    pop hl                          ;; restore hl (array address)
    or a                            ;; check if we have to retrieve the first card
    jp z, _g_r_e_return             ;; jump if we wnat to get the first card

    ld b, a
    ;;ld de, #sizeof_e                ;; copy the size of a card in de
    ld e, a_component_size(ix)
    ld d, #0
_g_r_e_sum_loop:                    ;;
    add hl, de                      ;;  add de to hl until we reach the card
    djnz _g_r_e_sum_loop            ;;

_g_r_e_return:
_r_e_output = .+1   
    ld a, #00
    ret




;;-----------------------------------------------------------------
;;
;; man_array_move_all_elements
;;
;;  moves all the elements form one array to the other
;;  Input:  hl: array from
;;          de: array to
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_array_move_all_elements::
    ld (FIRST_ARRAY), hl
    ld (THIRD_ARRAY), hl
    ex de, hl
    ld (SECOND_ARRAY), hl
_move_loop:
FIRST_ARRAY = .+2
    ld ix, #0000
    xor a
    call man_array_get_element

SECOND_ARRAY = .+2
    ld ix, #0000
    call man_array_create_element

THIRD_ARRAY = .+2    
    ld ix, #0000
    xor a
    call man_array_remove_element
    
    ld a, a_count(ix)
    or a
    jr nz, _move_loop
    ret