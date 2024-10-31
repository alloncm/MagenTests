TileData:
    ; bad bg tile, default one
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111

    ; good bg tile, on success should be visible 
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222
    dw `22222222

    ; bad bg tile, tests failed transfer, shouldnt be visible
    dw `33333333
    dw `33333333
    dw `33333333
    dw `33333333
    dw `33333333
    dw `33333333
    dw `33333333
    dw `33333333
.end

; Map set to tile 1
NewTileMap:
    DS $400, 1 
.end

; Map set to tile 2
NewBadTileMap:
    DS $400, 2
.end