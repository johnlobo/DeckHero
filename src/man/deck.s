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
.include "sys/util.h.s"
.include "sys/render.h.s"
.include "sys/behaviour.h.s"
.include "sys/animation.h.s"
.include "man/array.h.s"
.include "man/fight.h.s"
.include "man/oponent.h.s"
.include "man/foe.h.s"
.include "man/effects.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

deck::
DefineComponentArrayStructure_Size deck, MAX_DECK_CARDS, sizeof_c     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

;;
;; Definition of model deck
;;
model_deck::
model_deck_count: .db #0x05
model_deck_delta: .db #0x00
model_deck_component_size: .db #(sizeof_c)
model_deck_pend: .dw #0x0000
model_deck_selected: .db #0x00
model_deck_pselected: .db #0x00
model_deck_array:
;;         _status,        _class  _sprite     _name              _rarity   _type   _energy  _description,                    _damage _block, _vulnerable _weak   _strengh    _exhaust    _add_card _execute_routine
model_hit:
DefineCard #00, e_type_card_in_hand, 1, _s_cards_0, ^/HIT            /, 1,      1,      1,      ^/SINGLE ATTACK - 6DM           /,  6,      0,      0,          0,      0,          0,          0,       #man_deck_execute_hit
model_defend:
DefineCard #00, e_type_card_in_hand, 2, _s_cards_1, ^/DEFEND         /, 1,      1,      1,      ^/SIMPLE DEFENCE - 5BK          /,  0,      5,      0,          0,      0,          0,          0,       #man_deck_execute_defend
model_bash:
DefineCard #00, e_type_card_in_hand, 2, _s_cards_2, ^/BASH           /, 1,      1,      2,      ^/STRONG HIT - 8DM+2VN          /,  0,      3,      0,          0,      0,          0,          0,       #man_deck_dummy_routine
model_unbreakeable:
DefineCard #00, e_type_card_in_hand, 2, _s_cards_3, ^/UNBREAKABLE    /, 1,      1,      1,      ^/GREAT DEFENCE - 30BK (E)      /,  0,      3,      0,          0,      0,          0,          0,       #man_deck_dummy_routine
model_ignore:
DefineCard #00, e_type_card_in_hand, 2, _s_cards_4, ^/IGNORE         /, 1,      1,      1,      ^/GOOD BLOCK - 8BK+1C           /,  0,      3,      0,          0,      0,          0,          0,       #man_deck_dummy_routine

pe_struct:
    pe_cpms: .db #00
    pe_status: .db #e_type_invalid
    pe_pointer: .dw #00

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_deck_dummy_routine
;;
;;  Dummy execute routine to initialize a ard
man_deck_dummy_routine::
    ret

;;-----------------------------------------------------------------
;;
;; man_deck_remove_card_from_hand
;;
;;  Initializaes a deck of cards
;;  Input: 
;;  Output:
;;  Modified: AF, HL
;;
man_deck_remove_card_from_hand::
    push ix
    ld ix, #hand

    ld a, a_selected(ix)
    push af                         ;; save a (card to move)
    call man_array_get_element      ;; obtain content of a
    ld ix, #cemetery                ;; operate on cemetery
    call man_array_create_element   ;; create card in cemetery
    pop af                          ;; retrieve card to erase
    ld ix, #hand
    call man_array_remove_element   ;; erase card from hand
    dec a_delta(ix)                 ;; decrease delta flag

    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_deck_execute_hit
;;
;;  Dummy execute routine to initialize a card
;;
;;  Input: ix: card 
;; 

man_deck_execute_hit::
    push ix                                 ;; store card address
    ld a, c_damage(ix)                      ;; get damage from card
    ld (mdeh_damage+1), a                   ;; smc for later use of damage

    ld ix, #foes_array                      ;;
    ;;ld c, a                                 ;; c = damage damage
    ;;ld hl, #anim_hit                        ;;
    ;;call man_effects_animate                ;;
mdeh_damage:
    ld c, #00                               ;; make damage
    call sys_behaviour_damage_oponent       ;;
    m_updated_foe_effects                   ;; update effects
    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_deck_execute_defend
;;
;;  Executes a shield increasement
;;
;;
man_deck_execute_defend::
    ld a, c_block(ix)                           ;; load the block to add
    ld (mded_add_block+1), a
    push ix
    ld ix, #player                              ;;
    ld hl, #anim_shield                         ;;
    ld c, a                                     ;; block to add
    call man_effects_animate                    ;;
mded_add_block:
    ld b, #00                                   ;; add block
    call man_oponent_add_block                  ;;
    pop ix
    ret




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
    ld ix, #deck
    xor a
    ld  a_count(ix), a

    ld hl, #deck_array
    
    ld a_pend(ix), l            ;; Update pointer to the next entity
    ld a_pend+1(ix), h          ;;

    ld  (hl), #e_type_invalid   ;;ponemos el primer elemento del array con tipo invalido
    
;; Load default cards in deck 4 hits + 2 defends
;; hit loop
    ld b, #4
_d_i_hit_loop:
    push bc
    ld hl, #model_hit
    call man_array_create_element
    pop bc
    djnz _d_i_hit_loop
;; defends
    ld hl, #model_defend
    call man_array_create_element
    ld hl, #model_defend
    call man_array_create_element

;;debug
;;    ld hl, #model_defend
;;    call man_array_create_element
;;    ld hl, #model_defend
;;    call man_array_create_element
;;    ld hl, #model_defend
;;    call man_array_create_element
;;    ld hl, #model_defend
;;    call man_array_create_element
;;    ld hl, #model_defend
;;    call man_array_create_element
;;    ld hl, #model_defend
;;    call man_array_create_element
;;debug
ret

;;-----------------------------------------------------------------
;;
;; man_deck_load_array_from_deck
;;
;;  Loads the array with all the cards in deck
;;  Input: ix: array structure
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_deck_load_array_from_deck::
    ld hl, #deck_array                  ;; hl points to the array of cards
    ld a, (#deck_count)                   ;; a holds the number of cards to copy
    ld b, a                             ;; b = number of cards to copy
_l_a_loop:
    cpctm_push bc, hl                   ;; save bc and hl
    ld (pe_pointer), hl
    ld hl, #pe_struct
    call man_array_create_element       ;; create a new element from hl
    
    ld a, (deck_component_size)         ;;
    ld e, a                             ;; de hold the size of a card
    ld d, #0                            ;;

    pop hl                              ;; restore hl
    add hl, de                          ;; hl points to the next card of deck
    pop bc                              ;; restore bc (index)
    djnz _l_a_loop                      ;; jump if b != 0
    
    ret

;;-----------------------------------------------------------------
;;
;; man_deck_get_random_element
;;
;;  Returns a random element form the deck
;;  Input:
;;  Output: HL: points to a random card of deck 
;;  Modified: 
;;
man_deck_get_random_element::
    ret