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
.module deck_manager

.include "man/deck.h.s"
.include "cpctelera.h.s"
.include "common.h.s"
.include "man/card.h.s"
.include "comp/component.h.s"
.include "sys/util.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA


DefineComponentArrayStructure_Size deck, MAX_CARDS, sizeof_c     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final
deck_X_start:: .db 40

;;
;; Definition of model deck
;;
model_deck::
;;         _status,             _class  _sprite     _name          _rarity _type   _energy _description,       _damage _block, _vulnerable _weak   _strengh    _exhaust    _add_card
model_deck_01::
DefineCard e_type_card_in_hand, 1,      _s_cards_0, ^/STRIKE    /, 1,      1,      3,      ^/SINGLE ATTACK       /,   3,      0,      0,          0,      0,          0,          0
model_deck_02::
DefineCard e_type_card_in_hand, 2,      _s_cards_1, ^/DEFEND    /, 1,      1,      2,      ^/SIMPLE DEFENCE      /,  0,      3,      0,          0,      0,          0,          0


;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_deck_init
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_init::
    xor a
    ld  (deck_num), a

    ld  hl, #deck_array      ;;ponemos el puntero de la ultima entidad a la primera posicion del array
    ld  (deck_pend), hl

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
ret


;;-----------------------------------------------------------------
;;
;; man_deck_getArrayHL
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_getArrayHL::
    ld  hl, #deck_array
ret

;;-----------------------------------------------------------------
;;
;; man_deck_get_random_card
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_get_random_card::
    
    call cpct_getRandom_mxor_u8_asm
    ld a, 0b0000001
    and l
    ld b, a
    or a
    jp z, 
    ld de, #sizeof_c
    ld hl, #model_deck
_loop_sum:
    add hl, de

    ld  hl, #deck_array
ret

;;-----------------------------------------------------------------
;;
;; man_deck_update_X_start
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_update_X_start:
    ;; Calculate x start coord
    ld a, (deck_num)
    sla a                       ;; Multiply num cards by 8
    sla a                       ;;
    sla a                       ;;
    srl a                       ;; Divide (num cards*8) by 2
    ld c,a                      ;; move ((num cards*8)/2) to c
    ld a, #40                   ;; a = 40
    sub c                       ;; a = 40 - ((num cards*8)/2)
    ld (deck_X_start), a        ;; 
    ret

;;-----------------------------------------------------------------
;;
;; man_deck_create_card
;;
;;  Create a card from the model pointed by HL
;;  Input: HL: puntero al array con los datos de inicializacion
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_create_card::

    ld  de, (deck_pend)
    ld  bc, #sizeof_c
    ldir

    ;;PASAMOS A LA SIGUIENTE ENTIDAD
    ld hl, #deck_num    ;;aumentamos el numero de entidades
    inc (hl)

    ld   hl, (deck_pend) ;;pasamos el puntero a la siguiente entidad
    ld   bc, #sizeof_c
    add  hl, bc
    ld   (deck_pend), hl

    call man_deck_update_X_start    ;; update the X coord of the deck
ret

;;-----------------------------------------------------------------
;;
;; man_deck_remove_card
;;
;;  Remove a card pointed by a from the deck
;;  Input: a: number of card to remove
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_remove_card::

    ;;ld h, a                     ;; position de at the begining of the card to remove
    ;;ld e, #sizeof_c                    ;;
    ;;call sys_util_h_times_e     ;;    
    ;;ld a, l                     ;;
    ;;ld de,  #deck_array         ;;    
    ;;add_de_a                    ;;

    ld b, a                     ;; copy card to erase to b
    ld hl, #deck_array          ;; mode de at the start of the deck
    ld de, #sizeof_c            ;; copy the size of a card in hl
_sum_loop:                      ;;
    add hl, de                  ;;
    djnz _sum_loop              ;;

    ld d, h                     ;; copy hl in de
    ld e, l                     ;;

    ld bc, #sizeof_c            ;; add size of card to hl
    add hl,bc                   ;;

    push de                     ;; save de
    push hl                     ;; save hl
    ex de, hl                   ;; we have in de the end of the card to remove

    ld hl, (deck_pend)          ;; calculate the amount of data to move
    sbc hl, de                  ;;
    ld b, h                     ;; move hl to bc
    ld c, l                     ;; bc = size of data to move

    pop hl                      ;; restore hl
    pop de                      ;; restore de

    ldir

    ld   hl, (deck_pend)        ;; move deck end back one card
    ld   bc, #sizeof_c          ;;
    sbc  hl, bc                 ;;
    ld   (deck_pend), hl        ;;

    ld hl, #deck_num            ;; Decrment the number of cards
    dec (hl)

    call man_deck_update_X_start        ;; Update X coord for teh deck
ret

