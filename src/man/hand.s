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
.module hand_manager

.include "man/hand.h.s"
.include "cpctelera.h.s"
.include "common.h.s"
.include "man/card.h.s"
.include "comp/component.h.s"


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
;; man_hand_init
;;
;;  Initilizes a hand of cards
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, HL
;;
man_hand_init::
    xor a
    ld  (hand_num), a

    ld  hl, #hand_array      ;;ponemos el puntero de la ultima entidad a la primera posicion del array
    ld  (hand_pend), hl

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
    ret

;;-----------------------------------------------------------------
;;
;; man_hand_update_X_start
;;
;;  Updates the starting x coord for rendering the hand
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, C
;;
man_hand_update_X_start:
    ;; Calculate x start coord
    ld a, (hand_num)
    ld c, a                     ;; Multiply num cards by 6
    sla a                       ;;
    sla a                       ;; Multyply by 4
    add c                       ;;
    add c                       ;; Multiplies by 6

    srl a                       ;; Divide (num cards*8) by 2
    ld c,a                      ;; move ((num cards*8)/2) to c
    ld a, #40                   ;; a = 40
    sub c                       ;; a = 40 - ((num cards*8)/2)
    ld (hand_X_start), a        ;; 
    ret

;;-----------------------------------------------------------------
;;
;; man_hand_create_card
;;
;;  Create a card from the model pointed by HL
;;  Input: HL: pointer to the card to add to the hand
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_hand_create_card::

    ex de, hl                           ;; save the pointer to the card in de

    ld  hl, (hand_pend)                 ;; load in hl the address of the next card
    ld (hl), #e_type_card_in_hand       ;; stores in the firs byt the status of the card
    inc hl                              ;; move to the next position
    ld (hl), e                          ;; store in the following 2 bytes the address to the card to add
    inc hl                              ;; move to the next position
    ld (hl), d                          ;;
    
    ld hl, #hand_num                    ;; increase the number of cards in hand
    inc (hl)                            ;; 

    ld   hl, (hand_pend)                ;; update the pointer to the next card
    ld   bc, #sizeof_p2c                ;; load the size of the pointer to card
    add  hl, bc                         ;; move hl the the next card
    ld   (hand_pend), hl                ;; store the new pointer to the next card

    call man_hand_update_X_start        ;; update the X coord of the deck
ret


;;-----------------------------------------------------------------
;;
;; man_hand_remove_card
;;
;;  Remove a card pointed by a from the hand
;;  Input: a: number of card to remove
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_hand_remove_card::

    or a                        ;; check if we have to erase the first card
    jp z, _not_last_card        ;; jump if 0

    ld b, a                     ;; copy card to erase to b
    ld a, (hand_num)            ;; check if we have to erase the last card
    dec a                       ;;
    cp b                        ;;
    jr z, _last_card            ;;  jump if we have to erase the last card

    ld hl, #hand_array          ;; mode de at the start of the deck
    ld de, #sizeof_p2c            ;; copy the size of a card in hl
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

    ld hl, (hand_pend)          ;; calculate the amount of data to move
    sbc hl, de                  ;;
    ld b, h                     ;; move hl to bc
    ld c, l                     ;; bc = size of data to move

    pop hl                      ;; restore hl
    pop de                      ;; restore de

    ldir
    jr _not_last_card

_last_card:
    ld hl, #hand_selected
    dec (hl)
    
_not_last_card:
    ld   hl, (hand_pend)        ;; move deck end back one card
    ld   bc, #sizeof_p2c        ;;
    sbc  hl, bc                 ;;
    ld   (hand_pend), hl        ;;

    ld hl, #hand_num            ;; Decrment the number of cards
    dec (hl)

    call man_hand_update_X_start        ;; Update X coord for teh deck
ret