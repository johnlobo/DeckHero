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

.include "common.h.s"

.module animation_system

;;===============================================================================
;; PUBLIC CONSTANTS
;;===============================================================================
.globl anim_hero
.globl anim_explotion

;;===============================================================================
;; PUBLIC VARIABLES
;;===============================================================================

;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================

;;===============================================================================
;; ANIMATION DEFINITION MACRO
;;===============================================================================
.macro DefineAnim _status, _class, _sprite, _name, _rarity, _type, _energy, _description, _damage, _block, _vulnerable, _weak, _strengh, _exhaust, _add_card, _execute_routine
    .db _status
    .db _class
    .dw _sprite
    .asciz "_name"
    .db _rarity
    .db _type
    .db _energy
    .asciz "_description"
    .db _damage
    .db _block
    .db _vulnerable
    .db _weak
    .db _strengh
    .db _exhaust
    .db _add_card
    .dw _execute_routine
.endm

;;===============================================================================
;; ANIMATION SCTRUCTURE CREATION
;;===============================================================================
BeginStruct anim
Field anim, status , 1
Field anim, class , 1
Field anim, sprite , 2
Field anim, name , 16
Field anim, rarity , 1
Field anim, type , 1
Field anim, energy , 1
Field anim, description , 31
Field anim, damage , 1
Field anim, block , 1
Field anim, vulnerable , 1
Field anim, weak , 1
Field anim, strengh , 1
Field anim, exhaust , 1
Field anim, add_card , 1
Field anim, execute_routine, 2
EndStruct anim