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
.include "man/foe.h.s"
.include "man/fight.h.s"
.include "man/effects.h.s"
.include "sys/animation.h.s"


;;-----------------------------------------------------------------
;;
;; sys_behaviour_update_one_entity
;;
;;  Excutes the beahviour of an entity
;;  Input: 
;;  Output: 
;;  Modified: 
;;
sys_behaviour_update_one_entity::

    ret


;;-----------------------------------------------------------------
;;
;; sys_behaviour_get_behaviour
;;
;;  Excutes the beahviour of an entity
;;  Input: hl: beahviour array
;;          a: step
;;  Output: a: oponent (self, oponent)
;;          b: behaviour id
;;          c: behaviour amount
;;  Modified: af, bc, hl
;;
sys_behaviour_get_behaviour::
    ld c, a             ;; save a to make 3
    sla a               ;; multiply a by 2
    add c               ;; add a to make 3
    add_hl_a            ;; add ax3 to the start of the behaviour array
    ld a, (hl)          ;; store id in b
    ld b, a             ;;
    inc hl              ;;
    ld a, (hl)          ;; store amount in c
    ld c, a             ;;
    inc hl              ;;
    ld a, (hl)          ;; store oponent in a
    ret

;;-----------------------------------------------------------------
;;
;;  sys_behaviour_execute
;;
;;  Excutes the current beahviour of an entity
;;  Input: ix: Oponent entity
;;  Output: 
;;  Modified: af, bc, hl
;;
sys_behaviour_execute_one::
    ;; Draw behaviour sprite
    ld l, o_behaviour_func(ix)          ;; obtain current behaviour
    ld h, o_behaviour_func + 1(ix)      ;;
    ld a, o_behaviour_step(ix)          ;;
    call sys_behaviour_get_behaviour    ;; get b=behaviour id, c=behaviour amount   

    ld (EFFECT_OPONENT), a              ;; self modifying code to set effect oponent

    ld a, b                             ;; load behaviour id in a
                                    
    cp #10                              ;; check if behaviour id addable 
    jp m, sbe_add_effect                ;;

    ;;cp #10                            ;; already compared to 10
    jr z, sbe_damage_oponent            ;; if id = 10 -> damage oponent

    jr sbe_exit
sbe_damage_oponent:         
    push ix                             ;; damage oponent always damage player
    ld ix, #player                      ;;
    call sys_behaviour_damage_oponent   ;;
    pop ix                              ;;
    m_updated_player_effects            ;; update player effects flag
    jr sbe_exit                         ;;

sbe_add_effect:
EFFECT_OPONENT = . +1
    ld a, #00                           ;; self modifying code to test the oponent
    or a                                ;; 
    jr z, sbe_effect_to_self            ;; if oponent = self jump
    push ix                             ;; else set oponent = player
    ld ix, #player                      ;;
    call sys_behaviour_add2Effect       ;;
    pop ix
    m_updated_player_effects            ;; update player effects flag
    jr sbe_exit

sbe_effect_to_self:
    call sys_behaviour_add2Effect       ;;
    m_updated_foe_effects               ;; update foe effects flag

    
sbe_exit:
    inc o_behaviour_step(ix)            ;; Increment behaviour step
    ld a, o_behaviour_step(ix)          ;; check if behaviour step should be restarted.
    cp #beh_eof_behaviour               ;;
    ret nz                              ;;
    
    xor a                               ;; retart behaviour step
    ld o_behaviour_step(ix), a          ;;
    ret

    ret

;;-----------------------------------------------------------------
;;
;;  sys_behaviour_add2Effect
;;
;;  Excutes the current beahviour of an entity
;;  Input: ix: Oponent entity
;;          b: effect
;;          c: amount to add
;;  Output: 
;;  Modified: af, de, hl, 
;;
sys_behaviour_add2Effect::
    ld d, #0                    ;; move the offset to the effect to de
    ld e, b                     ;;
    push ix                     ;; move the start of the struct to hl
    pop hl                      ;;
    add hl, de                  ;; hl points to the effect
    ld a, (hl)                  ;; a contains the value of the effect
    add c                       ;; add amount
    ld (hl), a                  ;; stores the updated effect value again
    ret

;;-----------------------------------------------------------------
;;
;;  sys_behaviour_damage_player
;;
;;  Excutes the current beahviour of an entity
;;  Input: ix: Oponent entity
;;          c: of damage to add
;;  Output: 
;;  Modified: af, bc
;;
sys_behaviour_damage_oponent::
    ;; Create hit effect
    push bc
    ld hl, #anim_hit            ;;  
    call man_effects_animate    ;;
    pop bc
    
    ;; Substract damage
    ld a, o_shield(ix)          ;; check if shield is enought to get the damage
    sub c                       ;;
    jp p, sbdp_shield_enough

    neg                         ;; positives the difference to obtain remaining damage
    ld c, a                     ;; load remaining damage in c
    xor a                       ;; update shield to 0
    ld o_shield(ix), a          ;;
    ld a, o_life(ix)            ;; load life in a
    sub c                       ;; substract remainign damge
    jp p, sbdp_exit             ;; jump if the player is alive
    xor a                       ;; set life to 0
sbdp_exit:
    ld o_life(ix), a            ;; updates players life
    ret                         

sbdp_shield_enough:
    ld o_shield(ix), a          ;; updates players shield
    ret


;;-----------------------------------------------------------------
;;
;; sys_behaviour_blob
;;
sys_behaviour_blob::
    .db beh_damage, 6, beh_oponent
    .db beh_shield, 5, beh_self
    .db beh_damage, 6, beh_oponent
    .db beh_shield, 5, beh_self
    .db beh_damage, 6, beh_oponent
    .db beh_shield, 5, beh_self
    .db beh_damage, 6, beh_oponent
    .db beh_eof_behaviour, 0, 0

;;-----------------------------------------------------------------
;;
;; sys_behaviour_update_one_entity
;;
;;  Excutes the beahviour of an entity
;;  Input: 
;;  Output: 
;;  Modified: 
;;
sys_behaviour_update::
    ld a, (#foes_count)         ;;
    or a                        ;;
    ret z                       ;; return if no foes

    ld b, a
    ld ix, #foes_array
sbu_loop:
    push bc
    call sys_behaviour_execute_one
    ld de, #sizeof_o
    add ix, de
    pop bc
    djnz sbu_loop

    ret
