DEF VRAM_TILE_DATA_START_ADDRESS EQU $8000
DEF VRAM_TILE_MAP0_START_ADDRESS EQU $9800
DEF VRAM_TILE_MAP1_START_ADDRESS EQU $9C00
DEF VRAM_TILE_MAP_SIZE EQU $400
DEF OAM_START_ADDRESS EQU $FE00
DEF LY EQU $FF44
DEF LYC EQU $FF45
DEF VBK EQU $FF4F
DEF BGPI EQU $FF68
DEF BGPD EQU $FF69
DEF OBPI EQU $FF6A
DEF OBPD EQU $FF6B
DEF LCDC EQU $FF40
DEF STAT EQU $FF41
DEF INTE EQU $FFFF
DEF INTF EQU $FF0F

SECTION "stat interrupt", ROM0[$48]
    jp hl

SECTION "boot", ROM0[$100]
Start::
    nop 
    jp Main

SECTION "main", ROM0[$150]
Main::
    di ; no need for interrupts for now

    ; turn lcd off - must be done during vblank mode
    .wait_for_vbalnk
        ld a, [STAT]
        and a, %11  ; get only the mode flag
        cp a, 1     ; 1 is the vblank status
        jr nz, .wait_for_vbalnk
    ld a, 0
    ld [LCDC], a

    ld hl, VRAM_TILE_DATA_START_ADDRESS ; VRAM tile data
    ld bc, BackgroundTileData
    ld de, BackgroundTileData.end - BackgroundTileData
    call Memcpy

    ld hl, VRAM_TILE_MAP0_START_ADDRESS
    ld bc, VRAM_TILE_MAP_SIZE
    ld a, 0 ; tile number to use
    call Memset
    
    ld hl, VRAM_TILE_MAP1_START_ADDRESS
    ld bc, VRAM_TILE_MAP_SIZE
    ld a, 1 ; tile number to use
    call Memset

    ; set vram bank to 1
    ld a, 1 
    ld [VBK], a
    ; set data
    ld hl, VRAM_TILE_MAP0_START_ADDRESS
    ld bc, VRAM_TILE_MAP_SIZE
    ld a, %10000000 ; bg priority, bg pallete 0
    call Memset
    
    ld hl, VRAM_TILE_MAP1_START_ADDRESS
    ld bc, VRAM_TILE_MAP_SIZE
    ld a, %10000000 ; bg priority, bg pallete 0
    call Memset
    ; set vram bank to 0
    ld a, 0
    ld [VBK], a

    ld hl, OAM_START_ADDRESS
    ld bc, OAMData
    ld de, OAMData.end - OAMData
    call Memcpy

    ; palletes
    ; BG pallete - set color 1 of pallete 0 to black
    ld d, 2 ; color index
    ld e, 1 ; BG
    ld bc, $0000 ; black
    call LoadPallete
    ; BG pallete - set color 0 of pallete 0 to black
    ld d, 0 ; color index
    ld e, 1 ; BG
    ld bc, $FFFF ; black
    call LoadPallete

    ld d, 2 ; color index
    ld e, 0 ; OAM
    ld bc, $03E0 ; green
    call LoadPallete
    
    ld d, 4 ; color index
    ld e, 0 ; OAM
    ld bc, $001F ; red
    call LoadPallete

    ld a, %10010011 ; turn lcd on, with the correct flags
    ld [LCDC], a

    ld a, [OAM_LYC_PIPELINE]
    ld [LYC], a
    ld a, $40
    ld [STAT], a  ; enable lyc source for stat
    ld hl, StatInterruptHandlerObj1Start
    ld c, 0


    ; enable stat interrupt
    ei
    ld a, 0
    ld [INTF], a ; clear if register
    ld a, %00010
    ld [INTE], a ; enable stat interrupt

    ; block
    .loop
    jp .loop

; mut d - color index
; const e - oam or bg (0 for oam, 1 for bg)
; const bc - color
LoadPallete:
    ld a, d
    set 7, a ; in order for the pallete pointer to auto increment
    bit 0, e ; check if 0 (oam) or 1 (bg)
    jr z, .oam_pallete
    .bg_pallete
        ld [BGPI], a
        ld a, c
        ld [BGPD], a
        ld a, b
        ld [BGPD], a
    .oam_pallete
        ld [OBPI], a
        ld a, c
        ld [OBPD], a
        ld a, b
        ld [OBPD], a
    ret

StatInterruptHandlerInit:
    ld a, %10010011
    ld [LCDC], a    ; switch bg master priority on and switch to tile map 0 where bg uses color 0
    call IncCounter
    ld [LYC], a
    reti

StatInterruptHandlerObj1Start:
    ld a, %10011011
    ld [LCDC], a    ; switch to tile map 1 where bg uses color 1
    call IncCounter
    ld [LYC], a
    reti

StatInterruptHandlerObj1End:
    ld a, %10010011
    ld [LCDC], a    ; switch to tile map 0 where bg uses color 0
    call IncCounter
    ld [LYC], a
    reti 

StatInterruptHandlerObj2Start:
    ld a, %10011010
    ld [LCDC], a    ; switch bg master priority off and switch to tile map 1 where bg uses color 1
    call IncCounter
    ld [LYC], a
    reti 

StatInterruptHandlerObj2End:
    ld a, %10010011
    ld [LCDC], a    ; switch bg master priority on and switch to tile map 0 where bg uses color 0
    call IncCounter
    ld [LYC], a
    reti

; mut hl - dst (address to set)
; mut bc - len (non zero length)
; const a - val (value to set)
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

; mut hl - dst (address to copy to)
; mut bc - src (adress to copy from)
; mut de - len (length of src to copy to dst)
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

BackgroundTileData:
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
.end

DEF OBJ0_Y EQU 20
DEF OBJ1_Y EQU 40
DEF OBJ2_Y EQU 60
DEF OBJ3_Y EQU 80

OAM_LYC_PIPELINE:
    db 0
    db OBJ1_Y - 16
    db OBJ1_Y - 8
    db OBJ2_Y - 16
    ; db OBJ2_Y - 8
.end

STAT_INTERRUPT_PIPELINE:
    dw StatInterruptHandlerInit
    dw StatInterruptHandlerObj1Start
    dw StatInterruptHandlerObj1End
    dw StatInterruptHandlerObj2Start    
    ; dw StatInterruptHandlerObj2End

IncCounter:
    inc c
    ld a, OAM_LYC_PIPELINE.end - OAM_LYC_PIPELINE
    cp a, c
    jr nz, .exit
        ld c, 0
    .exit
    push bc
    ld a, c
    add a, a
    ld c, a
    ld b, 0
    ld hl, STAT_INTERRUPT_PIPELINE
    add hl, bc ; set hl for the next callback
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop bc
    ld hl, OAM_LYC_PIPELINE
    add hl, bc
    ld a, [hl]
    ld h, d
    ld l, e
    ret

OAMData:
    db OBJ0_Y, 20, 1, 0   ; object 0 - OAM color 1 on bg color 0 with all the priorities set
    db OBJ1_Y, 20, 2, 0   ; object 1 - OAM color 2 on bg color 1 with all the priorities set
    db OBJ2_Y, 20, 1, 0   ; object 2 - OAM color 1 on bg color 1 with the bg priority and the oam priority (bg master priority is off)
    db OBJ3_Y, 20, 2, $80 ; object 3 - OAM color 2 on bg color 0 with the oam priority off
.end