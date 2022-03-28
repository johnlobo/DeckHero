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
.module array_of_e_manager

.include "man/array_of_e.h.s"
.include "cpctelera.h.s"
.include "common.h.s"


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
;; man_array_of_e_init
;;
;;  Initilizes a hand of entities
;;  Input: ix points to the array
;;  Output: 
;;  Modified: AF, HL
;;
man_array_of_e_init::
    xor a
    ld a_count(ix), a

    ld__hl_ix                  ;; point hl to the start of the array 
    ;; TODO No entiendo esto... 
    ld a, #a_array
    add_hl_a
    ;;ld  (hand_pend), hl
    ld a_pend(ix), l
    ld a_pend+1(ix), h

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
    ret


;;-----------------------------------------------------------------
;;
;; man_hand_create_element
;;
;;  Create a card from the model pointed by HL
;;  Input:  ix: pointer to the array 
;;          hl: pointer to the card to add to the hand
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_array_of_e_create_element::

    ex de, hl                           ;; save the pointer to the card in de

    ld  l, a_pend(ix)                  ;; load in hl the address of the next card
    ld  h, a_pend+1(ix)                  ;; 
    ld (hl), #e_type_card_in_hand       ;; stores in the firs byt the status of the card
    inc hl                              ;; move to the next position
    ld (hl), e                          ;; store in the following 2 bytes the address to the card to add
    inc hl                              ;; move to the next position
    ld (hl), d                          ;;
    
    inc (ix)                            ;; increase the number of cards in hand

    ;;ld   hl, (hand_pend)              ;; update the pointer to the next card
    ld   l, a_pend(ix)                  ;; update the pointer to the next card
    ld   h, a_pend+1(ix)                ;; update the pointer to the next card
    ld   bc, #sizeof_e                  ;; load the size of the pointer to card
    add  hl, bc                         ;; move hl the the next card
    ld   a_pend(ix), l                  ;; store the new pointer to the next card
    ld   a_pend+1(ix), h                ;;

    call man_array_update_X_start        ;; Update X coord for teh deck

ret

;;-----------------------------------------------------------------
;;
;; man_array_of_e_remove_element
;;
;;  Remove an entitiy from the array
;;  Input: a: number of card to remove
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_array_of_e_remove_element::

    ld b, a                     ;; copy card to erase to b
    ld a, a_count(ix)           ;; check if we have to erase the last card
    dec a                       ;;
    cp b                        ;;
    jr z, _last_entity          ;;  jump if we have to erase the last card

    push ix                     ;; hl to the start of the array    
    pop hl                      ;;


    ;; ld de, #a_array   ;;
    ld e, a_array(ix)
    ld d, a_array+1(ix)
    add hl, de                  ;;

    ld a, b                     ;; restore a value from b
    or a                        ;; if we have to erase the first card we are don with hl
    jp z, _calc_end_of_entity     ;; 

    ld de, #sizeof_e            ;; copy the size of a card in de
_start_loop:                    ;;
    add hl, de                  ;; hl advance a card
    djnz _start_loop            ;; hl points to the start of the card to remove

_calc_end_of_entity:
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

_last_entity:
    dec a_selected(ix)
    
_move_pend:
    ld l, a_pend(ix)            ;; calculate the amount of data to move
    ld h, a_pend+1(ix)          ;; 
    ld   bc, #sizeof_e          ;;
    sbc  hl, bc                 ;;
    ld a_pend(ix), l            ;; store hl in pend
    ld a_pend+1(ix), h          ;; 

    dec a_count(ix) 

    call man_array_update_X_start        ;; Update X coord for teh deck

ret

;;-----------------------------------------------------------------
;;
;; man_array_get_element
;;
;;  Retrieves in hl the element in position a
;;  Input: a: number of card to remove
;;          ix: array structure
;;  Output: hl: element
;;  Modified: AF, BC, DE, HL
;;
man_array_get_element::
    push ix                     ;; load in hl the beginning of the array
    pop hl                      ;;
    ld (_e_output), a           ;; store the random number in the output variable
    ;; ld de, #a_array          ;;
    ld e, a_array(ix)
    ld d, a_array+1(ix)
    add hl, de

    or a                        ;; check if we have to retrieve the first card
    jp z, _g_e_read_card        ;; jump if we wnat to get the first card

    ld b, a
    ld de, #sizeof_e            ;; copy the size of a card in de
_g_e_sum_loop:                      ;;
    add hl, de                  ;;  add de to hl until we reach the card
    djnz _g_e_sum_loop          ;;

_g_e_read_card:
    inc hl                      ;; dicard the status byte
    ld e, (hl)                  ;; read the content of (hl) in de
    inc hl                      ;;
    ld d, (hl)                  ;;

    ex de, hl                   ;; move de to hl
_e_output = .+1
    ld a, #00
    ret


;;-----------------------------------------------------------------
;;
;; man_array_get_random_element
;;
;;  Retrieves in hl the element in a random position and in a the position
;;  Input:  ix: array structure
;;  Output: hl: element
;;          a : number of element.
;;  Modified: AF, BC, DE, HL
;;
man_array_get_random_element::
    push ix                         ;; load in hl the beginning of the array
    pop hl                          ;;
    ;; ld de, #a_array   ;;
    ld e, a_array(ix)
    ld d, a_array+1(ix) 
    add hl, de                      ;; move hl to the beginning of the array
    push hl                         ;; save hl (array address)

    ld a, a_count(ix)
    call sys_util_get_random_number
    ld (_r_e_output), a             ;; store the random number in the output variable
    pop hl                          ;; restore hl (array address)
    or a                            ;; check if we have to retrieve the first card
    jp z, _g_r_e_read_card          ;; jump if we wnat to get the first card

    ld b, a
    ld de, #sizeof_e                ;; copy the size of a card in de
_g_r_e_sum_loop:                    ;;
    add hl, de                      ;;  add de to hl until we reach the card
    djnz _g_r_e_sum_loop            ;;

_g_r_e_read_card:   
    inc hl                          ;; dicard the status byte
    ld e, (hl)                      ;; read the content of (hl) in de
    inc hl                          ;;
    ld d, (hl)                      ;;

    ex de, hl                       ;; move de to hl
_r_e_output = .+1   
    ld a, #00
    ret


;;-----------------------------------------------------------------
;;
;; man_array_load_array_from_deck
;;
;;  Loads the array with all the cards in deck
;;  Input: ix: array structure
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_array_load_array_from_deck::
    ld hl, #deck_array                  ;; hl points to the array of cards
    ld a, (#deck_num)                   ;; a holds the number of cards to copy
    ld b, a                             ;; b = number of cards to copy
_l_a_loop:
    cpctm_push bc, hl                   ;; save bc and hl
    call man_array_create_element       ;; create a new element from hl
    
    ld de, #sizeof_c                    ;; de hold the size of a card
    pop hl                              ;; restore hl
    add hl, de                          ;; hl points to the next card of deck
    pop bc                              ;; restore bc (index)
    djnz _l_a_loop                      ;; jump if b != 0
    
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