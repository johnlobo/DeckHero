;; Registros
H_CHARACTERS = 01
H_ADJUST     = 02
V_ADJUST     = 05
V_LINES      = 06
V_SYNC       = 07

CRTC_V_auto:
	ld bc, #0xBC00 + V_LINES
	out (c), c
	ld hl, #0xBD00
	add hl, de
	ld b, h
	ld c, l
	out (c), c
	ret

CRTC_H_auto:
	ld bc, #0xBC00 + H_ADJUST
	out (c), c
	ld hl, #0xBD00
	add hl, de
	ld b, h
	ld c, l
	out (c), c
	ret

fadeOut::
	ld de, #25
height_out:
    ld a, #12
	call delay
	call CRTC_V_auto
	dec e
	jp nz, height_out
	call CRTC_V_auto
	ret

fadeIn::
	ld de, #0
height_in:
    ld a, #12
	call delay 
	call CRTC_V_auto
	inc e
	ld a, e
	cp #26
	jp nz, height_in
	ret

temblor::
	ld de, #47
	call CRTC_H_auto
	ld de, #45
    ld a, #9
	call delay
	call CRTC_H_auto
	ld de, #46
    ld a, #9
	call delay 
	call CRTC_H_auto
	ret

delay:
	halt
	dec a
	jr nz, delay
	ret