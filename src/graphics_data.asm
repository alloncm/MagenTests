DEF OBJ0_Y EQU $10
DEF OBJ1_Y EQU $20
DEF OBJ2_Y EQU $30
DEF OBJ3_Y EQU $40
DEF OBJ4_Y EQU $50
DEF OBJ5_Y EQU $60
DEF OBJ6_Y EQU $70
DEF OBJ7_Y EQU $80

TileData:
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
    
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
.end

OAMData:
    ; OAM - on | BG - on | BGM - on
    db OBJ0_Y, 40, 1, 0   ; object 0 - OAM color 2/1 on bg color 0/1 with all the priorities set - bg color 1 is visible
    ; OAM - on | BG - on | BGM - off
    db OBJ1_Y, 40, 2, 0   ; object 1 - OAM color 1 on bg color 0/1 with the bg priority and the oam priority (bg master priority is off) - oam is visible
    ; OAM - off| BG - off| BGM - on
    db OBJ2_Y, 40, 1, $80 ; object 2 - OAM color 1/2 on bg color 0/1 with the oam priority off and the bg priority off (bg master priority is on)
    ; OAM - off| BG - on | BGM - on
    db OBJ3_Y, 40, 1, $80 ; object 3 - OAM color 2/1 on bg color 0/1 with the oam priority off and the bg priorities on (master and regualr)
    ; OAM - on | BG - off| BGM - on
    db OBJ4_Y, 40, 2, 0   ; object 4
    ; OAM - on | BG - off| BGM - off
    db OBJ5_Y, 40, 2, 0   ; object 5
    ; OAM - off| BG - on | BGM - off
    db OBJ6_Y, 40, 2, $80 ; object 6
    ; OAM - off| BG - off| BGM - off
    db OBJ7_Y, 40, 2, $80 ; object 7
.end