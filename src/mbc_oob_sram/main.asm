INCLUDE "hardware.inc"

SECTION "graphics_data", ROM0
INCLUDE "graphics_data.asm"

SECTION "std", ROM0
INCLUDE "../common.asm"

DEF RND_VAL EQU 6                                   ; Chosen by a fair random cube
DEF EXPECTED_SRAM_BANKS EQU 2

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

    ; Enable external ram
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a

    ld a, [$149]                                        ; read cart ram size
    cp a, EXPECTED_SRAM_BANKS
    jr nz, .fail                                        ; if sram banks are not the expected amount

    ; Series of checks to see if the SRAM behaves correctly
    ; Sanity check
    ld hl, _SRAM                                        ; hl stores the current address we are working with
    call TestRamWriteAndRead
    jr nz, .fail                                        ; If the values are not the same it is an error

    ld a, 1
    ld [rRAMB], a                                       ; Loading bank 1
    inc hl                                              ; Using different offset just in case
    call TestRamWriteAndRead
    jr nz, .fail                                        ; If the values are not the same it is an error

    ld a, 2
    ld [rRAMB], a                                       ; Loading bank 2, it does not exists
    inc hl                                              ; Using different offset just in case
    call TestRamWriteAndRead
    jr nz, .fail                                        ; If the values are not the same it is an error
    ; In case the values are the same check it we have access with this non existing bank to the other values
    ld hl, _SRAM
    ld a, [hl]
    cp a, RND_VAL
    jr nz, .fail

    ld bc, GREEN                                        ; Else setting bc to green to indicate success
    ld a, 0                                             ; And setting a to white (for DMG machines)
    jr .set_output
.fail
    ld bc, RED                                          ; Setting bc to red indicating failure
    ld a, 3                                             ; And setting a to black (for DMG machines)
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

;------------------------------------------
; Test RAM by writing a value to it
; and reading it
; const hl - address within the ram region 
; will garbage af
;------------------------------------------
TestRamWriteAndRead:
    ld a, RND_VAL
    ld [hl], a
    ld a, [hl]
    cp a, RND_VAL
    ret