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

.module oponent_manager

.include "common.h.s"

;;===============================================================================
;; OPONENT DEFINITION MACRO
;;===============================================================================
.mdelete DefineOponent
.macro DefineOponent _status, _name, _sprite, _life, _money, _shield, _force, _dexterity, _buffer, _blessing, _thorns, _regen, _draw_card, _confuse, _poison
    .db _status
    .asciz "_name"
    .dw _sprite
    .db _life
    .db _shield
    .db _money
    .db _force
    .db _dexterity
    .db _buffer
    .db _blessing
    .db _thorns
    .db _regen
    .db _draw_card
    .db _confuse
    .db _poison
.endm

;;===============================================================================
;; OPONENT SCTRUCTURE CREATION
;;===============================================================================
BeginStruct o
Field o, status , 1
Field o, name , 16    
Field o, sprite , 2
Field o, life , 1
Field o, shield , 1
Field o, money , 1
Field o, force , 1
Field o, dexterity , 1
Field o, buffer , 1
Field o, blessing , 1
Field o, thorns , 1
Field o, regen , 1
Field o, draw_card , 1
Field o, confuse , 1
Field o, poison , 1
EndStruct o


;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_oponent_init
.globl man_oponent_create
.globl man_oponent_update