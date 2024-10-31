INCLUDE "hardware.inc"

SECTION "graphics_data", ROM0
INCLUDE "graphics_data.asm"

SECTION "std", ROM0
INCLUDE "../common.asm"

DEF REQUIRED_HBLANK_DMA_CYCLES EQU ($400 / $10)

SECTION "boot", ROM0[$100]
    nop 
    jp Main

SECTION "main", ROM0[$150]
Main::
    di                                                ; no need for interrupts for now
    ld sp, $FFFE                                      ; setup the stack

    call TurnOffLcd

    ; Set BG view to the bottom right corner
    ld a, SCRN_VX - SCRN_X
    ld [rSCX], a
    ld a, SCRN_VY - SCRN_Y
    ld [rSCY], a

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
    ld bc, RED
    ld d, 2                                             ; palette 0 color 1
    ld e, 1                                             ; BG
    call LoadPallete

    ld bc, GREEN
    ld d, 4                                             ; palette 0 color 2
    ld e, 1                                             ; BG
    call LoadPallete

    ld bc, BLUE
    ld d, 6                                             ; palette 0 color 3
    ld e, 1                                             ; BG
    call LoadPallete

    ; Turn lcd on, with the correct flags
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BGON|LCDCF_BG9800
    ld [rLCDC], a                          

    call WaitForLy0

    ; HDMA HBlank transfer to set the tile map to green tiles
    ; Should finish succesfully 
    ld a, NewTileMap >> 8
    ld [rHDMA1], a
    ld a, NewTileMap & $FF
    ld [rHDMA2], a
    ld a, _SCRN0 >> 8
    ld [rHDMA3], a
    ld a, _SCRN0 & $FF
    ld [rHDMA4], a
    ld a, HDMA5F_MODE_HBL | (REQUIRED_HBLANK_DMA_CYCLES - 1)
    ld [rHDMA5], a

    ; Wait for the transfer to end (and then forever), 
    ; since the HDMA HBlank wont be activated in halt 
    ; we wait until the transfer is completed until entering halt mode
    ld c, HDMA5F_BUSY
.wait_for_transfer
    ld a, [rHDMA5]
    and a, c
    jr z, .wait_for_transfer

    call WaitForLy0

    ; HDMA HBlank transfer to set the tile map to blue tile
    ; Should not finish succesfully cause of the halt
    ld a, NewBadTileMap >> 8
    ld [rHDMA1], a
    ld a, NewBadTileMap & $FF
    ld [rHDMA2], a
    ld a, _SCRN0 >> 8
    ld [rHDMA3], a
    ld a, _SCRN0 & $FF
    ld [rHDMA4], a
    ld a, HDMA5F_MODE_HBL | (REQUIRED_HBLANK_DMA_CYCLES - 1)
    ld [rHDMA5], a

.loop
    ; Should prevent the HDMA transfer from happening at all,
    ; since it starts at mode 2 (oam search) until the transfer 
    ; is activated at mode 0 (hblank) the CPU is already halted
    halt
    jp .loop

; Wait for LY = 0
; mut a
WaitForLy0:
    ld a, [rLY]
    xor a
    jr nz, WaitForLy0
    ret