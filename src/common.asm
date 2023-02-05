;----------------------------------------------------
; Memory set:
; mut hl - dst (address to set)
; mut bc - len (non zero length)
; const a - val (value to set)
;----------------------------------------------------
Memset:
    ldi [hl], a
    dec bc
    ; detect if bc is zero and return if so
    ld d, a     ; saves a 
    xor a
    cp a, c
    jr nz, .continue
    cp a, b
    jr nz, .continue

    ld a, d     ; loads a
    ret
    .continue:
        ld a, d ; loads a
        jr Memset

;----------------------------------------------------
; Memory copy:
; mut hl - dst (address to copy to)
; mut bc - src (adress to copy from)
; mut de - len (length of src to copy to dst)
;----------------------------------------------------
Memcpy:
    ld a, [bc]
    inc bc
    ldi [hl], a
    dec de
    ; detect if de is zero
    xor a
    cp a, e
    jr nz, Memcpy
    cp a, d
    jr nz, Memcpy
    ret
;----------------------------------------------------
; Multiply unsined 8 bit int by unsigned 16 bit int
; mut hl - value to operate on
; mut a - value to multiply with
; hl = hl * a
;----------------------------------------------------
Mulu8:
    push de
    ld d, h
    ld e, l
    ld hl, 0
    cp a, 0
    jr z, .exit
.mulloop
    add hl, de 
    dec a
    jr nz, .mulloop
.exit
    pop de
    ret

;----------------------------------------------------
; Wait for Vblank
; Wait untill the STAT register shows vblank status
;----------------------------------------------------
WaitVblank:
    ld a, [rSTAT]
    and a, %11                                          ; get only the mode flag
    cp a, 1                                             ; check for 1 (the vblank status)
    jr nz, WaitVblank
    ret

;----------------------------------------------------
; Turn off the LCD display
;----------------------------------------------------
TurnOffLcd:
    ld a, [rLCDC]
    and a, %10000000                                    ; get LCDC bit 7 to check if lcd is off
    cp a, 0                                             ; check lcdc for lcd off
    ret z                                               ; if lcd already off return and dont wait for vblank (it will never return)
    call WaitVblank
    ld a, 0
    ld [rLCDC], a
    ret

;----------------------------------------------------
; Laod a pallete color with a color 
; mut d - color index
; const e - oam or bg (0 for oam, 1 for bg)
; const bc - color
;----------------------------------------------------
LoadPallete:
    ld a, d
    set 7, a                                            ; in order for the pallete pointer to auto increment
    bit 0, e                                            ; check if 0 (oam) or 1 (bg)
    jr z, .oam_pallete
.bg_pallete
    ld [rBCPS], a
    ld a, c
    ld [rBCPD], a
    ld a, b
    ld [rBCPD], a
.oam_pallete
    ld [rOCPS], a
    ld a, c
    ld [rOCPD], a
    ld a, b
    ld [rOCPD], a
    ret