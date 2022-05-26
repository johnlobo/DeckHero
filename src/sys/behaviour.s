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

.module behaviour_system

.include "sys/behaviour.h.s"
.include "cpctelera.h.s"
.include "man/oponent.h.s"


;;-----------------------------------------------------------------
;;
;; sys_behaviour_update_one_entity
;;
;;  Excutes the beahviour of an entity
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
sys_behaviour_update_one_entity::

    ret
;;-----------------------------------------------------------------
;;
;; sys_behaviour_update_one_entity
;;
;;  Excutes the beahviour of an entity
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
sys_behaviour_update::

    ret

;;-----------------------------------------------------------------
;;
;; sys_behaviour_get_behaviour
;;
;;  Excutes the beahviour of an entity
;;  Input: hl: beahviour array
;;          a: step
;;  Output: b: behaviour id
;;          c: behaviour amount
;;  Modified: af, bc, hl
;;
sys_behaviour_get_behaviour::
    sla a
    add_hl_a
    ld a, (hl)
    ld b, a
    inc hl
    ld a, (hl)
    ld c, a
    ret

;;-----------------------------------------------------------------
;;
;; sys_behaviour_blob
;;
sys_behaviour_blob::
    .db damage, 6
    .db shield, 5
    .db damage, 6
    .db shield, 5
    .db damage, 6
    .db shield, 5
    .db damage, 6
    .db eof_behaviour, 0


