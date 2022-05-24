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
;; TYPES
;;===============================================================================

updated_none            = 0b00000000
updated_topbar          = 0b00000001
updated_player_sprite   = 0b00000010
updated_player_effect   = 0b00000100
updated_foe_sprite      = 0b00001000
updated_foe_effect      = 0b00010000
updated_hand            = 0b00100000
updated_icon_numbers    = 0b01000000
updated_zone_messages   = 0b10000000



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

.globl player_updates


;;===============================================================================
;; PUBLIC MACROS
;;===============================================================================
.mdelete m_updated_topbar
.macro m_updated_hand
    ld a, (player_updates)
    or #updated_topbar    
    ld (player_updates), a
.endm

.mdelete m_updated_player_sprite
.macro m_updated_player_sprite
    ld a, (player_updates)
    or #updated_player_sprite    
    ld (player_updates), a
.endm

.mdelete m_updated_player_effects
.macro m_updated_player_effects
    ld a, (player_updates)
    or #updated_player_effect    
    ld (player_updates), a
.endm

.mdelete m_updated_foe_sprite
.macro m_updated_foe_sprite
    ld a, (player_updates)
    or #updated_foe_sprite    
    ld (player_updates), a
.endm

.mdelete m_updated_foe_effects
.macro m_updated_foe_effects
    ld a, (player_updates)
    or #updated_foe_effect
    ld (player_updates), a
.endm

.mdelete m_updated_hand
.macro m_updated_hand
    ld a, (player_updates)
    or #updated_hand    
    ld (player_updates), a
.endm

.mdelete m_updated_icon_numbers
.macro m_updated_icon_numbers
    ld a, (player_updates)
    or #updated_icon_numbers    
    ld (player_updates), a
.endm

.mdelete m_updated_zone_messages
.macro m_updated_zone_messages
    ld a, (player_updates)
    or #updated_zone_messages
    ld (player_updates), a
.endm


;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_fight_init
.globl man_fight_update
.globl man_fight_execute_card
