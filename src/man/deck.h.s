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


;;===============================================================================
;; PUBLIC CONSTANTS
;;===============================================================================
CARD_SIZE = 22
MAX_CARDS = 10

;;===============================================================================
;; PUBLIC VARIABLES
;;===============================================================================
.globl deck_num
.globl deck_pend
.globl deck_array
.globl deck_X_start

.globl model_deck
.globl model_deck_01
.globl model_deck_02

;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_deck_init
.globl man_deck_create_card
.globl man_deck_remove_card