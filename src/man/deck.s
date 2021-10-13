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
.include "cpctelera.h.s"
.include "common.h.s"
.include "man/deck.h.s"
.include "man/card.h.s"
.include "comp/component.h.s"

DefineComponentArrayStructure_Size _deck, MAX_CARDS, CARD_SIZE     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

;;
;; Definition of model deck
;;
model_deck:
;;         _status,             _class  _sprite     _name   _rarity _type   _energy _description,       _damage _block, _vulnerable _weak   _strengh    _exhaust    _add_card
DefineCard e_type_card_in_hand, 1,      _s_cards_0, STRIKE, 1,      1,      1,      ^/SINGLE ATTACK/,   3,      0,      0,          0,      0,          0,          0
DefineCard e_type_card_in_hand, 2,      _s_cards_1, DEFEND, 1,      1,      1,      ^/SIMPLE DEFENCE/,  0,      3,      0,          0,      0,          0,          0


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
    ld  (_deck_num), a

    ld  hl, #_deck_array      ;;ponemos el puntero de la ultima entidad a la primera posicion del array
    ld  (_deck_pend), hl

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
    ld  hl, #_deck_array
ret

;;-----------------------------------------------------------------
;;
;; man_deck_create_card
;;
;;   gets a random number between 0 and 18
;;  Input: HL: puntero al array con los datos de inicializacion
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_create_card::

    ld  de, (_deck_pend)
    ld  bc, #CARD_SIZE
    ldir

    ;;PASAMOS A LA SIGUIENTE ENTIDAD
    ld  a, (_deck_num)    ;;aumentamos el numero de entidades
    inc a
    ld  (_deck_num), a

    ld   hl, (_deck_pend) ;;pasamos el puntero a la siguiente entidad
    ld   bc, #CARD_SIZE
    add  hl, bc
    ld   (_deck_pend), hl
ret

