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

.module player_manager

.include "man/player.h.s"
.include "common.h.s"
.include "man/deck.h.s"
.include "man/hand.h.s"
.include "man/oponent.h.s"
.include "sys/input.h.s"
.include "sys/render.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

;; Character templates
player_template::
;;_status, _name, _sprite, _life, _money, _shield, _force, _dexterity, _buffer, _blessing, _thorns, _regen, _draw_card, _confuse, _poison
DefineOponent 1, ^/PLAYER1        /, _s_player_0, 60, 60, S_PLAYER_WIDTH, S_PLAYER_HEIGHT,123, 1, 5, 1, 0, 0, 0, 0, 0, 0, 0, 0
;; Characters
player::
DefineOponent 1, ^/PLAYER1        /, _s_player_0, 60, 60, S_PLAYER_WIDTH, S_PLAYER_HEIGHT,100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_fight_init
;;
;;  Initializes a fight
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
man_player_init::
    ;; Initialization of the player
    ld de, #player
    ld hl, #player_template
    ld bc, #sizeof_o
    ldir
    ret


