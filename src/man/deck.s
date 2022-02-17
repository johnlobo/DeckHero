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


DefineComponentArrayStructure_Size deck, MAX_DECK_CARDS, sizeof_c     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final
deck_X_start:: .db 40
deck_selected:: .db 0

;;
;; Definition of model deck
;;
model_deck::
;;         _status,        _class  _sprite     _name              _rarity   _type   _energy  _description,                    _damage _block, _vulnerable _weak   _strengh    _exhaust    _add_card
model_hit:
DefineCard e_type_card_in_hand, 1, _s_cards_0, ^/HIT            /, 1,      1,      1,      ^/SINGLE ATTACK - 6DM           /,  3,      0,      0,          0,      0,          0,          0
model_defend:
DefineCard e_type_card_in_hand, 2, _s_cards_1, ^/DEFEND         /, 1,      1,      1,      ^/SIMPLE DEFENCE - 5BK          /,  0,      3,      0,          0,      0,          0,          0
model_bash:
DefineCard e_type_card_in_hand, 2, _s_cards_2, ^/BASH           /, 1,      1,      2,      ^/STRONG HIT - 8DM+2VN          /,  0,      3,      0,          0,      0,          0,          0
DefineCard e_type_card_in_hand, 2, _s_cards_3, ^/UNBREAKABLE    /, 1,      1,      1,      ^/GREAT DEFENCE - 30BK (E)      /,  0,      3,      0,          0,      0,          0,          0
DefineCard e_type_card_in_hand, 2, _s_cards_4, ^/IGNORE         /, 1,      1,      1,      ^/GOOD BLOCK - 8BK+1C           /,  0,      3,      0,          0,      0,          0,          0


;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_deck_init
;;
;;  Initializaes a deck of cards
;;  Input: 
;;  Output:
;;  Modified: AF, HL
;;
man_deck_init::
    xor a
    ld  (deck_num), a

    ld  hl, #deck_array      ;;ponemos el puntero de la ultima entidad a la primera posicion del array
    ld  (deck_pend), hl

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
    
    ;; Load default cards in deck
    ld hl, #model_hit
    call man_deck_create_card
    ;;ld hl, #model_defend
    ;;call man_deck_create_card
    ld hl, #model_bash
    call man_deck_create_card
ret


;;-----------------------------------------------------------------
;;
;; man_deck_get_random_card
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: hl pointing to the start of the random card
;;  Modified: AF, BC, DE, HL
;;
man_deck_get_random_card::

    call cpct_getRandom_mxor_u8_asm
    ld a, l                             ;; Calculates a pseudo modulus of max number
    ld h,#0                             ;; Load hl with the random number
    
    ld a, (deck_num)                    ;; load in bc the max number
    ld c, a
    ld b, #0
_deck_mod_loop:
    or a                                ;; ??
    sbc hl,bc                           ;; hl = hl - bc
    jp p, _deck_mod_loop                      ;; Jump back if hl > 0
    add hl,bc                           ;; Adds MAX_MODEL_CARD to hl back to get back to positive values
    ld a,l                              ;; loads the normalized random number in a

    ld hl, #deck_array                  ;; point hl to the start of the model cards
    or a                                ;; If the random card is the first (0) return 
    ret z                               ;; 

    ld b, a
    ld de, #sizeof_c
_deck_loop_sum:
    add hl, de
    djnz _deck_loop_sum	

ret

;;-----------------------------------------------------------------
;;
;; man_deck_model_get_random_card
;;
;;  Gets a random number between 0 and 18
;;  Input: 
;;  Output: hl pointing to the start of the random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_model_get_random_card::
    call cpct_getRandom_mxor_u8_asm

    ld a, l                             ;; Calculates a pseudo modulus of MAX_MODEL_CARD
    ld h,#0                             ;; Load hl with the random number
    ld bc,#MAX_MODEL_CARD               ;; Load bc with the max value
_model_mod_loop:
    or a                                ;; ??
    sbc hl,bc                           ;; hl = hl - bc
    jp p, _model_mod_loop                      ;; Jump back if hl > 0
    add hl,bc                           ;; Adds MAX_MODEL_CARD to hl back to get back to positive values
    ld a,l                              ;; loads the normalized random number in a

    ld hl, #model_deck                  ;; point hl to the start of the model cards
    or a                                ;; If the random card is the first (0) return 
    ret z

    ld b, a
    ld de, #sizeof_c
_model_loop_sum:
    add hl, de
    djnz _model_loop_sum	
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
    ;;sla a                       ;; Multiply num cards by 8
    ;;sla a                       ;;
    ;;sla a                       ;;
    ld c, a                     ;; Multiply num cards by 6
    sla a                       ;;
    sla a                       ;; Multyply by 4
    add c                       ;;
    add c                       ;; Multiplies by 6

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
;; man_deck_create_card
;;
;;  Create a card from the model pointed by HL
;;  Input: HL: pointer to the card to add to the hand
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
;;man_deck_create_card::
;;
;;    ex de, hl                           ;; save the pointer to the card in de
;;
;;    ld  hl, (deck_pend)                 ;; load in hl the address of the next card
;;    ld (hl), #e_type_card_in_hand       ;; stores in the firs byt the status of the card
;;    inc hl                              ;; move to the next position
;;    ld (hl), e                          ;; store in the following 2 bytes the address to the card to add
;;    inc hl                              ;; move to the next position
;;    ld (hl), d                          ;;
;;    
;;    ld hl, #deck_num                    ;; increase the number of cards in hand
;;    inc (hl)                            ;; 
;;
;;    ld   hl, (deck_pend)                ;; update the pointer to the next card
;;    ld   bc, #sizeof_p2c                ;; load the size of the pointer to card
;;    add  hl, bc                         ;; move hl the the next card
;;    ld   (deck_pend), hl                ;; store the new pointer to the next card
;;
;;    ;;call man_hand_update_X_start        ;; update the X coord of the deck
;;ret





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

    or a                        ;; check if we have to erase the first card
    jp z, _not_last_card        ;; jump if 0

    ld b, a                     ;; copy card to erase to b
    ld a, (deck_num)            ;; check if we have to erase the last card
    dec a                       ;;
    cp b                        ;;
    jr z, _last_card            ;;  jump if we have to erase the last card

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
    jr _not_last_card

_last_card:
    ld hl, #deck_selected
    dec (hl)
    
_not_last_card:
    ld   hl, (deck_pend)        ;; move deck end back one card
    ld   bc, #sizeof_c          ;;
    sbc  hl, bc                 ;;
    ld   (deck_pend), hl        ;;

    ld hl, #deck_num            ;; Decrment the number of cards
    dec (hl)

    call man_deck_update_X_start        ;; Update X coord for teh deck
ret

