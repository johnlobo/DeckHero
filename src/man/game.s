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

.module game_manager
.include "common.h.s"
.include "man/fight.h.s"
.include "man/player.h.s"
.include "man/oponent.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA


blob_template::
DefineOponent 1, ^/BLOB           /, _s_blob_0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

foe::
DefineOponent 1, ^/FOE   1        /, _s_blob_0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_game_init
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_game_init::
    call man_player_init    ;; Initialize player
    call man_fight_init     ;; Initialize fight
    ret

;;-----------------------------------------------------------------
;;
;; man_game_update
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_game_update::
    call man_fight_update
    ret