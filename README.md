# MagenTests
Collection of test roms to check and verify the behavior of the Gameboy Color during the development of my emulator - [MagenBoy](https://github.com/alloncm/MagenBoy)

## Why only Gameboy Color?
Well during the development of MagenBoy (My gameboy emulator) I found plenty of test roms and information about the original Gameboy (DMG).\
Unfortuntly, now when adding support for the Gameboy Color (CGB) I had a hard time finding all the information online so I decided to try and test it myself
 
## ColorBgOamPriority
The gameboy color has 3 different places where the priority between the Background layer and the OAM a layer is declared:

1. OAM Attributes bit 7 - Those attributes exists in the gameboy too - if set pixels 1-3 of the BG layer will get priority over OAM pixels (OAM will still be prioritize over BG pixel 0) - [source](https://gbdev.io/pandocs/OAM.html#byte-3---attributesflags)

2. LCDC bit 0 - in Gameboy Color this bit changes its purpose and defines the priority of the background - according to the pandocs this supposed to be master priority mode but this is not always the case - [source](https://gbdev.io/pandocs/LCDC.html#lcdc0---bg-and-window-enablepriority)

3. BG Map Attribute bit 7 - in color we got Tile attributes for the BG too, according to The pandocs setting this bit should ignore the OAM priority bit, which not always the case - [source](https://gbdev.io/pandocs/Tile_Maps.html#bg-map-attributes-cgb-mode-only)

After trying to implement this behavior I noticed that this is not the whole picture and there are a few edge cases not covered.

### Expected behavior
Colors:
* Green - visible OAM objects
* Blue - BG tiles that mask OAM objects
* Red - hidden OAM objects (you shouldn't see them)

| OAM priority bit | Background priority bit  | Background master enable bit | Result | Description |
| ---------------- | ------------------------ | ---------------------------- | ------ | ----------- |
| [X] | [X] | [X] |![image](images/expceted_green_blue.png)| depends on the color number of the BG pixel - BG color 0 the OAM have priority otherwise the BG have priority |
| [X] | [X] | [_] |![image](images/expceted_green.png)| OAM have priority |
| [_] | [_] | [X] |![image](images/expceted_green_blue.png)| depends on the color number of the BG pixel - BG color 0 the OAM have priority otherwise the BG have priority |
| [_] | [X] | [X] |![image](images/expceted_green_blue.png)| depends on the color number of the BG pixel - BG color 0 the OAM have priority otherwise the BG have priority |
| [X] | [_] | [X] |![image](images/expceted_green.png)| OAM have priority |
| [X] | [_] | [_] |![image](images/expceted_green.png)| OAM have priority |
| [_] | [X] | [_] |![image](images/expceted_green.png)| OAM have priority |
| [_] | [_] | [_] |![image](images/expceted_green.png)| OAM have priority |

*Notice that when BG color is 0 the oam will always have priority*

### Test result
You should see 5 green squares and 3 half grren and half blue squares with no red lines

#### Example:
![image](images/hardware_screenshot.jpg)

#### Original hardware

Special thanks to [ISSOtm](https://github.com/ISSOtm) for running this test rom on original hardware, verifying it actually works and screenshoting the result.