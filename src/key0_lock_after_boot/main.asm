INCLUDE "hardware.inc"

SECTION "graphics_data", ROM0
INCLUDE "graphics_data.asm"

SECTION "std", ROM0
INCLUDE "../common.asm"

SECTION "boot", ROM0[$100]
    nop 
    jp Main

SECTION "main", ROM0[$150]
Main::
    di                                                ; no need for interrupts for now
    ld sp, $FFFE                                      ; setup the stack
    
    ; Copy tiles to VRAM
    ld hl, _VRAM 
    ld bc, TileData
    ld de, TileData.end - TileData
    call Memcpy

    ; Set screen 0 to use tile 0
    ld hl, _SCRN0
    ld bc, $400 
    ld a, 0
    call Memset

    ; set vram bank to 1 in order to set the BG attributes
    ld a, 1 
    ld [rVBK], a

    ld hl, _SCRN0
    ld bc, $400
    ld a, 0                                             ; bg priority off, bg pallete 0
    call Memset                                         ; loading the first screen attributes with 0

    ld a, 0
    ld [rVBK], a

    ; Load palettes
    ld bc, GREEN
    ld d, 2                                             ; palette 0 color 1
    ld e, 1                                             ; BG
    call LoadPallete

    ; Turn lcd on, with the correct flags
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BGON|LCDCF_BG9800
    ld [rLCDC], a  

    ; Set to DMG mode, it souldn't have effect at all since writes to this register are locked after the bootrom ends
    ld a, $04  
    ld [$FF4C], a

.loop
    halt
    jp .loop