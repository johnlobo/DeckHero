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

.module animation_system

.include "sys/animation.h.s"
.include "common.h.s"
.include "cpctelera.h.s"

anim_player::
    .dw _s_player_0
    .dw _s_player_1
    .dw null_ptr
    .dw anim_player
    
anim_explotion::
    .dw _s_explotion_0
    .dw _s_explotion_1
    .dw _s_explotion_2
    .dw _s_explotion_3
    .dw null_ptr
    .dw null_ptr

anim_effect::
    .dw _s_effect_00
    .dw _s_effect_01
    .dw _s_effect_02
    .dw _s_effect_03
    .dw null_ptr

anim_hit::
    .dw _s_effect_04
    .dw _s_effect_05
    .dw _s_effect_06
    .dw _s_effect_07
    .dw null_ptr

anim_shield::
    .dw _s_effect_08
    .dw _s_effect_09
    .dw _s_effect_10
    .dw _s_effect_11
    .dw null_ptr
    


;;-----------------------------------------------------------------
;; Animation system is inspired in animtor from the great 
;; "The abduction of Oscar Z"
;;-----------------------------------------------------------------

;;-----------------------------------------------------------------
;;
;; sys_animation_create
;;
;;  creates an element in the array of animations
;;  Input: ix: 
;;  Output: 
;;
;;  Modified: af, bc, hl
;;

;;-----------------------------------------------------------------
;;
;; sys_animation_step
;;
;;  Excutes one step of the animation
;;  Input: ix: 
;;  Output: 
;;
;;  Modified: af, bc, hl
;;
;;sys_animation_step::
;;  push ix
;;  ld hl, #sys_animation_update
;;  call entities_each
;;  pop ix
;;  ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; sys_animation_update
;;;;
;;;;  Excutes one step of the animation
;;;;  Input: ix: 
;;;;  Output: 
;;;;
;;;;  Modified: af, bc, hl
;;;;
;;; IN:
;;;   IX <- Entity pointer
;;sys_animation_update::
;;  dec ENTITY_ANIMATION_COUNTER (ix)
;;  ret nz
;;
;;  ; get next animation step
;;  ld l, ENTITY_ANIMATION_STEP_LO (ix)
;;  ld h, ENTITY_ANIMATION_STEP_HI (ix)
;;  ld a, #STEP_SIZE
;;  add_hl_a        ; HL <- animation.step + 1
;;
;;  ld a, (hl)
;;  inc hl
;;  or (hl)
;;  dec hl
;;  jr nz, continue
;;
;;  ; if we reached the end of the animation, just get first step
;;  ld l, ENTITY_ANIMATION_FIRST_LO (ix)
;;  ld h, ENTITY_ANIMATION_FIRST_HI (ix)
;;
;;continue:
;;  ; set new step
;;  ld ENTITY_ANIMATION_STEP_LO (ix), l
;;  ld ENTITY_ANIMATION_STEP_HI (ix), h
;;
;;  ; set step counter as animation counter
;;  .rept STEP_TIME
;;  inc hl
;;  .endm
;;  ld a, (hl)      ; A <- step->time
;;  ld ENTITY_ANIMATION_COUNTER (ix), a
;;
;;  ret
;;
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; sys_animation_setAnimation
;;;;
;;;; IN:
;;;;   IX <- entity address
;;;;   DE <- animation address
;;;; DESTROYS:
;;;;   AF, HL
;;sys_animation_setAnimation::
;;;   entity->animation.first = entity->animation.step = step;
;;  ld ENTITY_ANIMATION_FIRST_LO (ix), e
;;  ld ENTITY_ANIMATION_FIRST_HI (ix), d
;;  ld ENTITY_ANIMATION_STEP_LO (ix), e
;;  ld ENTITY_ANIMATION_STEP_HI (ix), d
;;
;;;   entity->animation.counter = step->time;
;;  ld hl, #STEP_TIME
;;  add hl, de
;;  ld a, (hl)
;;  ld ENTITY_ANIMATION_COUNTER (ix), a
;; ;; ret