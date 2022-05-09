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

.module fight_manager


;;===============================================================================
;; PUBLIC VARIABLES
;;===============================================================================
.globl fight_deck

.globl hand
.globl hand_count
.globl hand_pend
.globl hand_array
.globl hand_selected

.globl cemetery
.globl cemetery_count
.globl cemetery_pend
.globl cemetery_array
.globl cemetery_selected

.globl sacrifice
.globl sacrifice_count
.globl sacrifice_pend
.globl sacrifice_array
.globl sacrifice_selected

.globl player_energy

;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_fight_init
.globl man_fight_update
.globl man_fight_execute_card
