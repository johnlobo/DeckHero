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

;;===============================================================================
;; CARD DEFINITION MACRO
;;===============================================================================
.mdelete DefineHand
.macro DefineHand _status, _class, _sprite, _name, _rarity, _type, _energy, _description, _damage, _block, _vulnerable, _weak, _strengh, _exhaust, _add_card
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
.endm

;;===============================================================================
;; CARD SCTRUCTURE CREATION
;;===============================================================================
BeginStruct c
Field c, status , 1
Field c, class , 1
Field c, sprite , 2
Field c, name , 16
Field c, rarity , 1
Field c, type , 1
Field c, energy , 1
Field c, description , 31
Field c, damage , 1
Field c, block , 1
Field c, vulnerable , 1
Field c, weak , 1
Field c, strengh , 1
Field c, exhaust , 1
Field c, add_card , 1
EndStruct c

;;===============================================================================
;; PUBLIC VARIABLES
;;===============================================================================
.globl hand_num
.globl hand_pend
.globl hand_array
.globl hand_X_start
.globl hand_selected


;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_hand_init
.globl man_hand_create_card
.globl man_hand_remove_card