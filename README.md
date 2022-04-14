# MagenTests

Collection of test roms to check edge cases in the Gameboy and Gameboy Color during the development of my emulator - [MagenBoy](https://github.com/alloncm/MagenBoy)
 
## ColorBgOamPriority

The gameboy color has 3 different places where the priority between the Background layer and the OAM a layer is declared:

1. OAM Attributes bit 7 - Those attributes exists in the gameboy too - if set pixels 1-3 of the BG layer will get priority over OAM pixels (OAM will still be prioritize over BG pixel 0) - [source](https://gbdev.io/pandocs/OAM.html#byte-3---attributesflags)

2. LCDC bit 0 - in Gameboy Color this bit changes its purpose and defines the priority of the background - according to the pandocs this supposed to be master priority mode but this is not always the case - [source](https://gbdev.io/pandocs/LCDC.html#lcdc0---bg-and-window-enablepriority)

3. BG Map Attribute bit 7 - in color we got Tile attributes for the BG too, according to The pandocs setting this bit should ignore the OAM priority bit, which not always the case - [source](https://gbdev.io/pandocs/Tile_Maps.html#bg-map-attributes-cgb-mode-only)

After trying to implement this behavior I noticed that this is not the whole picture and there are a few edge cases not convered.

### Expected behavior
OAM - OAM priority bit\
BG - Background priority bit\
BGM - Background master enable bit

* OAM - on | BG - on | BGM - on = depends on the color number of the BG pixel - BG color 0 the OAM has priority otherwise the BG has priority
* OAM - on | BG - on | BGM - off = OAM has priority
* OAM - on | BG - off| BGM - off = OAM has priority
* OAM - on | BG - off| BGM - on = OAM has priority
* OAM - off| BG - on | BGM - on = depends on the color number of the BG pixel - BG color 0 the OAM has priority otherwise the BG has priority
* OAM - off| BG - on | BGM - off = OAM has priority
* OAM - off| BG - off| BGM - on = depends on the color number of the BG pixel - BG color 0 the OAM has priority otherwise the BG has priority
* OAM - off| BG - off| BGM - off = OAM has priority

*When BG color is 0 the oam will always has priority*

### Test result
You should see 5 green squares and 3 green retangles with no red rectangles

## Test against original hardware
Unfortuntly I dont have access for original Gameboy Color so the tests have been done against the BGB emulator