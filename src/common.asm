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