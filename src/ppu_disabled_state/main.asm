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
    
    call TurnOffLcd                                   ; To prevent failed writes to the vram when it gets locked

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

    ; Lcd turned off at vblank mode (mode 1) and now suposed to be at hblank (mode 0)
    ld a, [rSTAT]
    and a, %11      ; Read only the ppu mode
    jr nz, .fail    ; If ppu mode is not hblank (mode 0) set error
    ld bc, GREEN    ; Else setting bc to green to indicate success
    ld a, 0         ; And setting a to white (for DMG machines)
    jr .set_output
.fail
    ld bc, RED      ; Setting bc to red indicating failure
    ld a, 3         ; And setting a to black (for DMG machines)
.set_output
    ; bc contains the palette color we would use
    ld d, 2                                             ; palette 0 color 1
    ld e, 1                                             ; BG
    call LoadPallete
    ; a contains DMG compatible color, setting color 1
    ; a << 2 in order to set color 1 with the value
    sla a
    sla a
    ld [rBGP], a

    ; Turn lcd on, with the correct flags to see the result
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BGON|LCDCF_BG9800
    ld [rLCDC], a
.loop
    ; halt
    jp .loop