; Colors definition
DEF WHITE   EQU $FFFF
DEF RED     EQU $001F
DEF GREEN   EQU $03E0

TileData:
    ; bg tile
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111

    ; oam tiles
    dw `00000000
    dw `00000010
    dw `00000110
    dw `00001110
    dw `00011110
    dw `00111110
    dw `01111110
    dw `00000000
    
    dw `00000000
    dw `00000020
    dw `00000220
    dw `00002220
    dw `00022220
    dw `00222220
    dw `02222220
    dw `00000000
.end

OAMData:
    ; Y, X, Tile, attr
    db 40, 46, 2, 0
    db 40, 40, 1, 0
.end