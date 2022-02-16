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


DefineComponentArrayStructure_Size hand, MAX_HAND_CARDS, sizeof_p2c     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final
hand_X_start:: .db 40
hand_selected:: .db 0

;;
;; Definition of model deck
;;
model_deck::
;;         _status,        _class  _sprite     _name              _rarity   _type   _energy  _description,                    _damage _block, _vulnerable _weak   _strengh    _exhaust    _add_card
DefineCard e_type_card_in_hand, 1, _s_cards_0, ^/HIT            /, 1,      1,      1,      ^/SINGLE ATTACK - 6DM           /,  3,      0,      0,          0,      0,          0,          0
DefineCard e_type_card_in_hand, 2, _s_cards_1, ^/DEFEND         /, 1,      1,      1,      ^/SIMPLE DEFENCE - 5BK          /,  0,      3,      0,          0,      0,          0,          0
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
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_deck_init::