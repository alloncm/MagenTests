SECTION "graphics_data", ROM0
INCLUDE "graphics_data.asm"
INCLUDE "hardware.inc"

SECTION "std", ROM0
INCLUDE "common.asm"

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
    ld a, [rSTAT]
    and a, %11  ; get only the mode flag
    cp a, 1     ; 1 is the vblank status
    jr nz, .wait_for_vbalnk
    ld a, 0
    ld [rLCDC], a

    ld hl, _VRAM ; VRAM tile data
    ld bc, TileData
    ld de, TileData.end - TileData
    call Memcpy

    ld hl, _SCRN0
    ld bc, $400 ; tile map size
    ld a, 0 ; tile number to use
    call Memset

    ; Copy screen 0 to 1
    ld hl, _SCRN1
    ld bc, _SCRN0
    ld de, $400 
    call Memcpy

    ; set vram bank to 1
    ld a, 1 
    ld [rVBK], a
    ; set data
    ld hl, _SCRN0
    ld bc, $400
    ld a, 0 ; bg priority off, bg pallete 0
    call Memset
    
    ; INDEX - (Y * 32) + X
    ld b, (BG_MAP_TILES_INDEX.end - BG_MAP_TILES_INDEX)
    ld c, 0
.set_screen_map
    push bc
    ld b, 0
    ld hl, BG_MAP_TILES_INDEX
    add hl, bc
    ld l, [hl]
    ld h, 0
    ld a, 32
    call Mulu8
    ld de, ((OBJ_X_OFFSET - 1) / 8) + _SCRN0
    add hl, de
    ld [hl], 1 ; set the screen map
    pop bc
    inc c
    ld a, b
    cp a, c
    jr nz, .set_screen_map

    ld hl, _SCRN1
    ld bc, _SCRN0
    ld de, $400
    call Memcpy
 
    ld hl, _SCRN1
    ld bc, 0
.set_screen_map_priority   
    set 7, [hl]
    inc hl
    inc bc
    ld a, b
    cp a, 4 ; second byte of $400
    jr nz, .set_screen_map_priority

    ; set vram bank to 0
    ld a, 0
    ld [rVBK], a

    ld hl, _OAMRAM
    ld bc, OAMData
    ld de, OAMData.end - OAMData
    call Memcpy

    ; palletes
    ; BG pallete - set color 0 of pallete 0 to black
    ld d, 0 ; color index
    ld e, 1 ; BG
    ld bc, BLACK
    call LoadPallete
    ; BG pallete - set color 1 of pallete 0 to black
    ld d, 2 ; color index
    ld e, 1 ; BG
    ld bc, BLACK
    call LoadPallete
    ; BG pallete - set color 0 of pallete 1 to black
    ld d, 8 ; color index
    ld e, 1 ; BG
    ld bc, BLUE
    call LoadPallete
    ; BG pallete - set color 1 of pallete 1 to black
    ld d, 10 ; color index
    ld e, 1 ; BG
    ld bc, BLUE
    call LoadPallete

    ld d, 2 ; color index
    ld e, 0 ; OAM
    ld bc, GREEN
    call LoadPallete
    
    ld d, 4 ; color index
    ld e, 0 ; OAM
    ld bc, RED
    call LoadPallete

    ld a, %10010011 ; turn lcd on, with the correct flags
    ld [rLCDC], a

    ld a, [OAM_LYC_PIPELINE]
    ld [rLYC], a
    ld a, $40
    ld [rSTAT], a  ; enable lyc source for stat
    ld hl, StatInterruptHandlerObj0Start
    ld c, 0


    ; enable stat interrupt
    ei
    ld a, 0
    ld [rIF], a ; clear if register
    ld a, %00010
    ld [rIE], a ; enable stat interrupt

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



StatInterruptHandlerObj0Start:
; OAM - on | BG - on | BGM - on
    ld a, %10011011
    ld [rLCDC], a 
    call AdvancePipeline
    reti

StatInterruptHandlerObj1Start:
; OAM - on | BG - on | BGM - off
    ld a, %10011010
    ld [rLCDC], a
    call AdvancePipeline
    reti 

StatInterruptHandlerObj2Start:
; OAM - off| BG - off| BGM - on
    ld a, %10010011
    ld [rLCDC], a
    call AdvancePipeline
    reti
    
StatInterruptHandlerObj3Start:
; OAM - off| BG - off| BGM - on
    ld a, %10011011
    ld [rLCDC], a
    call AdvancePipeline
    reti

StatInterruptHandlerObj4Start:
; OAM - on | BG - off| BGM - on
    ld a, %10010011
    ld [rLCDC], a
    call AdvancePipeline
    reti

StatInterruptHandlerObj5Start:
; OAM - on | BG - off| BGM - off
    ld a, %10010010
    ld [rLCDC], a
    call AdvancePipeline
    reti

StatInterruptHandlerObj6Start:
; OAM - off| BG - on | BGM - off
    ld a, %10011010
    ld [rLCDC], a
    call AdvancePipeline
    reti

StatInterruptHandlerObj7Start:
; OAM - off| BG - off| BGM - off
    ld a, %10010010
    ld [rLCDC], a    ; switch bg master priority off and switch to tile map 0 where bg uses color 0
    call AdvancePipeline
    reti

AdvancePipeline:
    ; increment and check for overflow
    inc c
    ld a, OAM_LYC_PIPELINE.end - OAM_LYC_PIPELINE
    cp a, c
    jr nz, .exit
        ld c, 0     ; reset the counter in case of overflow
    
    ; update hl register with the next callback address and LYC with the next LYC value
    .exit
    ld b, 0
    push bc     ; save the counter (c) in order to use bc in next statements
    ; multiply c by 2
    ld a, c
    add a, a
    ld c, a

    ld hl, STAT_INTERRUPT_PIPELINE
    add hl, bc ; set hl for the next callback (base address + the offset in bc)
    ; copy hl to de
    ld e, [hl]
    inc hl
    ld d, [hl]

    pop bc ; reload original counter (c)

    ld hl, OAM_LYC_PIPELINE
    add hl, bc ; hl points to the next value (base address + offest in counter (bc))
    ld a, [hl]
    ld [rLYC], a ; load lyc with the next value
    ; copy de to hl
    ld h, d
    ld l, e
    ret

BG_MAP_TILES_INDEX:
    db (OBJ0_Y - 16) / 8
    db (OBJ1_Y - 16) / 8
    db (OBJ2_Y - 16) / 8
    db (OBJ3_Y - 16) / 8
    db (OBJ4_Y - 16) / 8
    db (OBJ5_Y - 16) / 8
    db (OBJ6_Y - 16) / 8
    db (OBJ7_Y - 16) / 8
.end

OAM_LYC_PIPELINE:
    db OBJ0_Y - 16
    db OBJ1_Y - 16
    db OBJ2_Y - 16
    db OBJ3_Y - 16
    db OBJ4_Y - 16
    db OBJ5_Y - 16
    db OBJ6_Y - 16
    db OBJ7_Y - 16
.end

STAT_INTERRUPT_PIPELINE:
    dw StatInterruptHandlerObj0Start
    dw StatInterruptHandlerObj1Start
    dw StatInterruptHandlerObj2Start
    dw StatInterruptHandlerObj3Start
    dw StatInterruptHandlerObj4Start
    dw StatInterruptHandlerObj5Start
    dw StatInterruptHandlerObj6Start
    dw StatInterruptHandlerObj7Start
.end

; Asserting that the pipelines are the same length
STATIC_ASSERT (STAT_INTERRUPT_PIPELINE.end - STAT_INTERRUPT_PIPELINE) / 2 == OAM_LYC_PIPELINE.end - OAM_LYC_PIPELINE, "STAT_INTERRUPT pipeline is not compatible with the OAM_LYC pipeline"