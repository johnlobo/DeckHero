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
.include "man/card.h.s"
.include "comp/component.h.s"
.include "man/deck.h.s"


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
;;  Initilizes a hand of cards
;;  Input: ix points to the array
;;  Output: 
;;  Modified: AF, HL
;;
man_array_init::
    xor a
    ld a_count(ix), a

    ;;ld  hl, #hand_array      ;;ponemos el puntero de la ultima entidad a la primera posicion del array
    ;;ld hl #(a_array(ix))
    ld__hl_ix                  ;; point hl to the start of the array 
    ld a, #a_array
    add_hl_a
    ;;ld  (hand_pend), hl
    ld a_pend(ix), l
    ld a_pend+1(ix), h

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
    ret


;;-----------------------------------------------------------------
;;
;; man_hand_create_card
;;
;;  Create a card from the model pointed by HL
;;  Input:  ix: pointer to the array 
;;          hl: pointer to the card to add to the hand
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_array_create_card::

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
    ld   bc, #sizeof_p2c                ;; load the size of the pointer to card
    add  hl, bc                         ;; move hl the the next card
    ld   a_pend(ix), l                  ;; store the new pointer to the next card
    ld   a_pend+1(ix), h                 ;;
ret


;;-----------------------------------------------------------------
;;
;; man_array_remove_card
;;
;;  Remove a card pointed by a from the hand
;;  Input: a: number of card to remove
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_array_remove_card::

    or a                        ;; check if we have to erase the first card
    jp z, _not_last_card        ;; jump if 0

    ld b, a                     ;; copy card to erase to b
    ;;ld a, (hand_num)          ;; check if we have to erase the last card
    ld a, a_count(ix)           ;; check if we have to erase the last card
    dec a                       ;;
    cp b                        ;;
    jr z, _not_last_card            ;;  jump if we have to erase the last card

    ;;ld hl, #hand_array          ;; mode de at the start of the deck
    ld l, a_array(ix)          ;; mode de at the start of the deck
    ld h, a_array+1(ix)          ;; mode de at the start of the deck
    ld de, #sizeof_p2c          ;; copy the size of a card in hl
_sum_loop:                      ;;
    add hl, de                  ;;
    djnz _sum_loop              ;;

    ld d, h                     ;; copy hl in de
    ld e, l                     ;;

    ld bc, #sizeof_p2c          ;; add size of card to hl
    add hl,bc                   ;;

    push de                     ;; save de
    push hl                     ;; save hl
    ex de, hl                   ;; we have in de the end of the card to remove

    ;;ld hl, (hand_pend)          ;; calculate the amount of data to move
    ld l, a_pend(ix)           ;; calculate the amount of data to move
    ld h, a_pend+1(ix)           ;; calculate the amount of data to move
    sbc hl, de                  ;;
    ld b, h                     ;; move hl to bc
    ld c, l                     ;; bc = size of data to move

    pop hl                      ;; restore hl
    pop de                      ;; restore de

    ldir
   
_not_last_card:
    ;;ld   hl, (hand_pend)      ;; move deck end back one card
    ld   l, a_pend(ix)          ;; move deck end back one card
    ld   h, a_pend+1(ix)        ;; move deck end back one card
    ld   bc, #sizeof_p2c        ;;
    sbc  hl, bc                 ;;
    ;;ld   (hand_pend), hl      ;;
    ld   a_pend(ix), l         ;;
    ld   a_pend+1(ix), h         ;;

    ;;ld hl, #hand_num          ;; Decrment the number of cards
    ;;dec (hl)
    dec(ix)

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
    ld de, #a_array
    add hl, de

    or a                        ;; check if we have to erase the first card
    jp z, _g_e_read_card        ;; jump if we wnat to get the first card

    ld b, a
    ld de, #sizeof_p2c          ;; copy the size of a card in de
_g_e_sum_loop:                      ;;
    add hl, de                  ;;  add de to hl until we reach the card
    djnz _g_e_sum_loop          ;;

_g_e_read_card:
    inc hl                      ;; dicard the status byte
    ld e, (hl)                  ;; read the content of (hl) in de
    inc hl                      ;;
    ld d, (hl)                  ;;

    ex de, hl                   ;; move de to hl

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
    ld hl, #deck_array
    ld a, (#deck_num)
    ld b, a
_l_a_loop:
    cpctm_push bc, hl
    call man_array_create_card
    ld de, #sizeof_c
    pop hl
    add hl, de
    pop bc
    djnz _l_a_loop
    
    ret