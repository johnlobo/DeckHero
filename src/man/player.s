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
DefineOponent 
    1,                      ;; _status    
    ^/PLAYER1        /,     ;; _name 
    _s_player_0,            ;; _sprite
    PLAYER_SPRITE_X,        ;; _sprite_x    
    PLAYER_SPRITE_Y,        ;; _sprite_y     
    S_PLAYER_WIDTH,         ;; _sprite_w
    S_PLAYER_HEIGHT,        ;; _sprite_h
    99,                     ;; _max_life   
    1,                      ;; _money  
    3,                      ;; _effects_count
    80,                     ;; _life
    5,                      ;; _shield
    1,                      ;; _force
    0,                      ;; _dexterity
    0,                      ;; _buffer
    0,                      ;; _blessing
    0,                      ;; _thorns
    0,                      ;; _regen
    0,                      ;; _draw_card
    0,                      ;; confuse
    0,                      ;; _poison
    0,                      ;; _vulnerable
    #null_ptr,              ;; _behaviour_func
    0                       ;; _behaviour_step
;; Characters
player::
player::
DefineOponent 
    1,                      ;; _status    
    ^/PLAYER1        /,     ;; _name 
    _s_player_0,            ;; _sprite
    PLAYER_SPRITE_X,        ;; _sprite_x    
    PLAYER_SPRITE_Y,        ;; _sprite_y     
    S_PLAYER_WIDTH,         ;; _sprite_w
    S_PLAYER_HEIGHT,        ;; _sprite_h
    80,                     ;; _max_life   
    0,                      ;; _money  
    3,                      ;; _effects_count
    80,                     ;; _life
    5,                      ;; _shield
    1,                      ;; _force
    0,                      ;; _dexterity
    0,                      ;; _buffer
    0,                      ;; _blessing
    0,                      ;; _thorns
    0,                      ;; _regen
    0,                      ;; _draw_card
    0,                      ;; confuse
    0,                      ;; _poison
    0,                      ;; _vulnerable
    #null_ptr,              ;; _behaviour_func
    0                       ;; _behaviour_step

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
;;  Output: 
;;  Modified: 
;;
man_player_init::
    ;; Initialization of the player
    ld de, #player
    ld hl, #player_template
    ld bc, #sizeof_o
    ldir
    ret

;;-----------------------------------------------------------------
;;
;; man_player_get_life
;;
;;  Returns the life of the player
;;  Input: 
;;  Output: a: life of the player
;;  Modified: 
;;
man_player_get_life::
    push ix
    ld ix, #player
    ld a, o_life(ix)
    pop ix
    ret

