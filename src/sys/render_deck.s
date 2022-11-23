.module render_system

.include "sys/render.h.s"
.include "man/deck.h.s"
.include "man/fight.h.s"
.include "sys/text.h.s"
.include "sys/util.h.s"
.include "sys/messages.h.s"
.include "cpctelera.h.s"
.include "common.h.s"
.include "man/array.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

_show_deck_string: .asciz "PLAYERS DECK"            ;;12 chars, 24 bytes


;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; sys_render_get_X_start
;;
;;  Updates the starting x coord for rendering the array
;;  Input: ix: array of cards
;;  Output: a: x cord to start rendering the array of cards
;;  Modified: AF, C
;;
sys_render_get_X_start::
    ;; Calculate x start coord
    ld a, (hand_count)
    ld c, a                     ;; Multiply num cards by 6
    sla a                       ;;
    sla a                       ;; Multyply by 4
    add c                       ;;
    add c                       ;; Multiplies by 6

    srl a                       ;; Divide (num cards*8) by 2
    ld c,a                      ;; move ((num cards*8)/2) to c
    ld a, #39                   ;; a = 40
    sub c                       ;; a = 40 - ((num cards*8)/2)
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_erase_hand
;;
;;  Erase the deck render area
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_erase_hand::
    
    call cpct_waitVSYNC_asm
    ;;m_screenPtr_backbuffer HAND_X, HAND_Y_2      ;; Calculates backbuffer address
    m_screenPtr_frontbuffer HAND_X, HAND_Y_2      ;; Calculates backbuffer address
    
    ld c, #64
    ld b, #(S_CARD_HEIGHT + 5)
    ld a, #0
    call cpct_drawSolidBox_asm

    ;; Erase description

    call cpct_waitVSYNC_asm
    ;;m_screenPtr_backbuffer DESC_X,DESC_Y_1      ;; Calculates backbuffer address
    m_screenPtr_frontbuffer DESC_X,DESC_Y_1      ;; Calculates backbuffer address
    ld c, #64
    ld b, #20    
    ld a, #0
    call cpct_drawSolidBox_asm

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_card
;;
;;  Renders a specific card
;;  Input:  b: y coord
;;          c: x coord
;;          de: screen buffer
;;          ix: points to card
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_card::
    ;; Get screen address of the card
       
    ;;ld_de_backbuffer
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL

    ex de, hl

    push de

    ld l, c_sprite(ix)
    ld h, c_sprite+1(ix)
    ld c, #S_CARD_WIDTH
    ld b, #S_CARD_HEIGHT
    call cpct_drawSprite_asm

    ld h, #(S_CARD_ENERGY_WIDTH * S_CARD_ENERGY_HEIGHT)
    ld e, c_energy(ix)
    call sys_util_h_times_e
    ld a, l
    ld hl,#_s_cards_energy_0
    add_hl_a
    pop de
    ld c, #S_CARD_ENERGY_WIDTH
    ld b, #S_CARD_ENERGY_HEIGHT
    call cpct_drawSprite_asm

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_hand
;;
;;  Renders a hand of cards 
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL, IX, IY
;;
sys_render_hand::
    ld ix, #hand
    ld a,(hand_count)                       ;; retrieve num cards in deck
    or a                                    ;; If no cards ret
    ret z                                   ;;

    push iy                                 ;; save iy in the pile
    ld ix, #hand_array          
    call sys_render_get_X_start             ;; retrieve X start position of the deck in a
    ld c, a                                 ;; c = x coordinate 
    ld b, #0
_s_r_h_loop0:
    push bc                                 ;; Save b 
    push ix                                 

    ld l, e_p(ix)                           ;; Load card pointer in hl
    ld h, e_p+1(ix)                         ;;

    ld__iy_hl

    ld a, (hand_selected)                                   ;; compare card selected with current card
    cp b                                                    ;;
    ld b, #HAND_Y                                           ;; c = y coordinate by default
    jr nz, _hand_render_not_selected                             ;; jump if current card not selected
    ld b, #HAND_Y - 5

    cpctm_push AF, BC, DE, HL                               ;; Save values              
    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    ld__hl_iy                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;m_screenPtr_backbuffer DESC_X, DESC_Y_1                     ;; Calculates backbuffer address
    m_screenPtr_frontbuffer DESC_X, DESC_Y_1                     ;; Calculates backbuffer address

    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    ;; Render Card Description
    ld de, #c_description                                       ;; load description address in hl
    ld__hl_iy                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;m_screenPtr_backbuffer DESC_X, DESC_Y_2           ;; Calculates backbuffer address
    m_screenPtr_frontbuffer DESC_X, DESC_Y_2           ;; Calculates backbuffer address

    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    cpctm_pop HL, DE, BC, AF                                    ;; Restore values    

_hand_render_not_selected:
    push iy                                                     ;; move iy to ix for render card
    pop ix                                                      ;;
    
    ;;ld_de_backbuffer
    ld_de_frontbuffer
    call  sys_render_card                                       ;; render card

    pop ix                      ;; Move ix to the next card
    ld de, #sizeof_e          ;;
    add ix, de                  ;;

    pop bc                      ;; retrive b value for the loop

    ld a, #(S_CARD_WIDTH-2)         ;; Calculate x coord in C
    add c                       ;;
    ld c, a                     ;;

    inc b                       ;; increment current card

    ld a, (hand_count)            ;; compare with num of cards in deck
    cp b                        ;;
    jr nz, _s_r_h_loop0         ;; return to loop if not lasta card reached

    pop iy

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_show_deck
;;
;;  Shows the current deck on screen
;;  Input: ix: points to the array to show
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_show_deck::

    cpctm_clearScreen_asm 0

    ;;m_screenPtr_backbuffer 5, 10           ;; Calculates backbuffer address
    m_screenPtr_frontbuffer 5, 10           ;; Calculates backbuffer address
    ld c, #70
    ld b, #180
    ld l, #0x00                             ;; empty box
    ld a, #0xff
    call sys_messages_draw_box

    ld hl, #_show_deck_string
    ;;m_screenPtr_backbuffer 27, 14                           ;; Calculates backbuffer address
    m_screenPtr_frontbuffer 27, 14                           ;; Calculates backbuffer address

    ld c, #0
    call sys_text_draw_string

    ld c, #DECK_X                                           ;; c = x coordinate 
    ld b, #0

    ld a, a_selected(ix)                                    ;; store selected card for later comparing
    ld (SELECTED_CARD), a                                   ;;

    ld a, a_count(ix)                                       ;; store number of elements in the array in array_count
    ld (ARRAY_COUNT), a                                     ;; store array count in array_count         

    push ix                                                 ;; hl points to the first element of the array
    pop hl                                                  ;;
    ld de, #a_array                                         ;; 
    add hl, de                                              ;; 

    inc hl                                                  ;; skip status, hl points to the first pointer to card

_s_r_s_a_loop0:

    ld a, (hl)                                              ;; move the contents of hl (card pointed) to ix
    ld__ixl_a                                               ;;
    inc hl                                                  ;;
    ld a, (hl)                                              ;;
    ld__ixh_a                                               ;; ix = first card in deck

    push bc                                                 ;; Save b and c values
    push hl                                                 ;; Save hl value

SELECTED_CARD = . +1
    ld a, #0
    cp b                                                        ;;
    ld b, #DECK_Y                                               ;; c = y coordinate by default
    jr nz, _a_render_not_selected_show                             ;; jump if current card not selected
    ld b, #DECK_Y - 5
    
    push HL                                           ;; Save values              
    push bc

    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;m_screenPtr_backbuffer DESC_SHOW_X, DESC_SHOW_Y_1           ;; Calculates backbuffer address
    m_screenPtr_frontbuffer DESC_SHOW_X, DESC_SHOW_Y_1           ;; Calculates backbuffer address
    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    ;; Render Card Description
    ld de, #c_description                                       ;; load description address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;m_screenPtr_backbuffer DESC_SHOW_X, DESC_SHOW_Y_2           ;; Calculates backbuffer address
    m_screenPtr_frontbuffer DESC_SHOW_X, DESC_SHOW_Y_2           ;; Calculates backbuffer address
    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    pop bc
    pop HL                                                      ;; Restore values    

    
_a_render_not_selected_show:
    ;;ld_de_backbuffer
    ld_de_frontbuffer
    call  sys_render_card
    pop hl                      ;; retrive hl value for the loop
    pop bc                      ;; retrive b value for the loop


    ld a, #(S_CARD_WIDTH)       ;; Calculate x coord in C
    add c                       ;;
    ld c, a                     ;;

    inc b                       ;; increment current card

    inc hl                      ;; move to next card
    inc hl                      ;; skip status byte of next element

ARRAY_COUNT = .+1
    ld a, #00                       ;; compare with num of cards in deck
    cp b                            ;;
    jr nz, _s_r_s_a_loop0           ;; return to loop if not lasta card reached

    ret