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

.module render_system


;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl sys_render_init
.globl sys_render_update
.globl sys_render_erase_hand
.globl sys_render_hand
.globl sys_render_show_deck
.globl sys_render_show_array
.globl sys_render_fight_screen
.globl sys_render_energy
.globl sys_render_sacrifice
.globl sys_render_deck
.globl sys_render_cemetery
.globl sys_render_effects
