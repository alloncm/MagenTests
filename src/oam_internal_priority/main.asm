SECTION "graphics_data", ROM0
INCLUDE "graphics_data.asm"
INCLUDE "hardware.inc"

SECTION "std", ROM0
INCLUDE "../common.asm"

SECTION "boot", ROM0[$100]
    nop 
    jp Main

SECTION "main", ROM0[$150]
Main::
    di                                                ; no need for interrupts for now
    ld sp, $0FFFE                                     ; setup the stack

    call TurnOffLcd

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

    ; load the oam attributes to the oam ram
    ld hl, _OAMRAM
    ld bc, OAMData
    ld de, OAMData.end - OAMData
    call Memcpy

    ; set up palletes
    ld d, 2                                             ; color index
    ld e, 1                                             ; BG
    ld bc, WHITE
    call LoadPallete                                    ; BG pallete - set color 1 of pallete 0 
    
    ld d, 2                                             ; color index
    ld e, 0                                             ; OAM
    ld bc, GREEN
    call LoadPallete                                    ; OAM pallete - set color 1 of pallete 0
    
    ld d, 4                                             ; color index
    ld e, 0                                             ; OAM
    ld bc, RED
    call LoadPallete                                    ; OAM pallete - set color 2 of pallete 0
    
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
    ld [rLCDC], a                                       ; turn lcd on, with the correct flags

.loop
    jp .loop                                            ; wait forever