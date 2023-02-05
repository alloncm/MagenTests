SECTION "graphics_data", ROM0
INCLUDE "graphics_data.asm"
INCLUDE "hardware.inc"

SECTION "std", ROM0
INCLUDE "../common.asm"

SECTION "stat interrupt", ROM0[$48]
    jp hl

SECTION "boot", ROM0[$100]
    nop 
    jp Main

SECTION "main", ROM0[$150]
Main::
    di                                                ; no need for interrupts for now
    ld sp, $0FFFE                                     ; setup the stack

    call TurnOffLcd

    ld hl, _VRAM 
    ld bc, TileData
    ld de, TileData.end - TileData
    call Memcpy                                       ; Copy tiles to VRAM

    ld hl, _SCRN0
    ld bc, $400 
    ld a, 0 
    call Memset                                       ; Set screen 0 to use tile 0

    ld hl, _SCRN1
    ld bc, _SCRN0
    ld de, $400 
    call Memcpy                                         ; Copy screen 0 to screen 1

    ld a, 1 
    ld [rVBK], a                                        ; set vram bank to 1 in order to set the BG attributes
    
    ld hl, _SCRN0
    ld bc, $400
    ld a, 0                                             ; bg priority off, bg pallete 0
    call Memset                                         ; loading the first screen attributes with 0
    
    ld b, BG_MAP_TILES_INDEX.end - BG_MAP_TILES_INDEX   ; counter limit
    ld c, 0                                             ; counter
.set_screen_map
    push bc                                             ; save the counter
    ld b, 0                                             ; zero b inorder to use c (as part of bc) in 16 bit arritmetic
    ld hl, BG_MAP_TILES_INDEX                           ; load base address of the lut
    add hl, bc                                          ; add the counter (c) as the offset into the lut
    ld l, [hl]                                          ; load the 8bit value into hl
    ld h, 0
    ld a, 32                                            
    call Mulu8                                          ; multiply the Y value with 32 to get the correct line (INDEX - (Y * 32) + X)
    ld de, ((OBJ_X_OFFSET - 1) / 8) + _SCRN0            ; load the map base address with the X offset 
    add hl, de
    ld [hl], 1                                          ; those index uses the pallete 1 (not 0)
    pop bc                                              ; load the counter
    inc c                                               ; inc the counter
    ld a, b                                             ; check if reached the limit
    cp a, c
    jr nz, .set_screen_map                              ; jump to the start if the counter hasnt reached the max 

    ld bc, _SCRN0
    ld hl, _SCRN1
    ld de, $400
    call Memcpy                                         ; Copy screen 0 attrbiutes to screen 1
 
    ld hl, _SCRN1                                       ; pointer for the screen 1 bg attributes
    ld bc, 0                                            ; counter for screen 1 countes untill $400
.set_screen_map_priority   
    set 7, [hl]                                         ; setting the bit 7 in order to turn on the priority attribute
    inc hl                                              ; increment the pointer
    inc bc                                              ; increment the counter
    ld a, b
    cp a, 4                                             ; since the size is $400 checking just the second byte for 4 (and not the whole 16 bit register)
    jr nz, .set_screen_map_priority                     ; if not finished the whole screen jump to the start

    ld a, 0
    ld [rVBK], a                                        ; set vram bank to 0

    ld hl, _OAMRAM
    ld bc, OAMData
    ld de, OAMData.end - OAMData
    call Memcpy                                         ; load the oam attributes to the oam ram


    ld d, 0                                             ; color index
    ld e, 1                                             ; BG
    ld bc, WHITE
    call LoadPallete                                    ; BG pallete - set color 0 of pallete 0 to white
    
    ld d, 2                                             ; color index
    ld e, 1                                             ; BG
    ld bc, WHITE
    call LoadPallete                                    ; BG pallete - set color 1 of pallete 0 to white

    ld d, 8                                             ; color index
    ld e, 1                                             ; BG
    ld bc, BLUE
    call LoadPallete                                    ; BG pallete - set color 0 of pallete 1 to white
    
    ld d, 10                                            ; color index
    ld e, 1                                             ; BG
    ld bc, BLUE
    call LoadPallete                                    ; BG pallete - set color 1 of pallete 1 to white

    ld d, 2                                             ; color index
    ld e, 0                                             ; OAM
    ld bc, GREEN
    call LoadPallete
    
    ld d, 4                                             ; color index
    ld e, 0                                             ; OAM
    ld bc, RED
    call LoadPallete

    ld a, %10010011                                     
    ld [rLCDC], a                                       ; turn lcd on, with the correct flags

    ld a, [OAM_LYC_PIPELINE]
    ld [rLYC], a                                        ; Set the first LYC value for the stat interrupt
    ld a, $40
    ld [rSTAT], a                                       ; enable lyc source for stat interrupt

    ld hl, StatInterruptHandlerObj0Start                ; load the first callback
    ld c, 0                                             ; initialize the lut counter


    ei                                                  ; from now on we want interrupts
    ld a, 0
    ld [rIF], a                                         ; clear if register
    ld a, %00010
    ld [rIE], a                                         ; enable stat interrupt

.loop
    jp .loop                                            ; wait for interrupts

;----------------------------------------------------
    ld a, [rLCDC]
; All the stat interrupt handlers - one for each 
; OAM object (pipeline)
;----------------------------------------------------
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
    ld [rLCDC], a
    call AdvancePipeline
    reti

;----------------------------------------------------
; Advance the look up tables indices by 1 step and
; setting up the enviorment for the next pipeline 
; after the last one ran
;----------------------------------------------------
AdvancePipeline:
    ; increment and check for overflow
    inc c
    ld a, OAM_LYC_PIPELINE.end - OAM_LYC_PIPELINE
    cp a, c
    jr nz, .exit
        ld c, 0                                                 ; reset the counter in case of overflow
    
    ; update hl register with the next callback address and LYC with the next LYC value
    .exit
    ld b, 0
    push bc                                                     ; save the counter (c) in order to use bc in next statements
    ; multiply c by 2
    ld a, c
    add a, a
    ld c, a

    ld hl, STAT_INTERRUPT_PIPELINE
    add hl, bc                                                  ; set hl for the next callback (base address + the offset in bc)
    ; copy hl to de
    ld e, [hl]
    inc hl
    ld d, [hl]

    pop bc                                                      ; reload original counter (c)

    ld hl, OAM_LYC_PIPELINE
    add hl, bc                                                  ; hl points to the next value (base address + offest in counter (bc))
    ld a, [hl]
    ld [rLYC], a                                                ; load lyc with the next value
    ; copy de to hl
    ld h, d
    ld l, e
    ret

;----------------------------------------------------
; Look up table for the map index of each OAM object
;----------------------------------------------------
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

;----------------------------------------------------
; Look up table for the Y value of each stat
; interrupt value Im waiting for
;----------------------------------------------------
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
;----------------------------------------------------
; Look up table for the callback handler of each 
; stat interrupt value Im waiting for
;----------------------------------------------------
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