;;-----------------------------LICENSE NOTICE------------------------------------

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

;;===============================================================================
;; PUBLIC VARIABLES
;;===============================================================================
.globl add_card_action
.globl add_card_selected
.globl add_card_previous
.globl add_card_max
.globl add_card_moved

.globl game_room_x
.globl game_room_y

.globl game_room_path

;;===============================================================================
;; PUBLIC METHODS
;;===============================================================================
.globl man_game_add_room_to_path
.globl man_game_init
.globl man_game_update