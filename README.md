# MagenTests
Collection of test roms to check and verify the behavior of the Gameboy Color during the development of my emulator - [MagenBoy](https://github.com/alloncm/MagenBoy)

## Why only Gameboy Color?
Well during the development of MagenBoy (My gameboy emulator) I found plenty of test roms and information about the original Gameboy (DMG).\
Unfortuntly, now when adding support for the Gameboy Color (CGB) I had a hard time finding all the information online so I decided to try and test it myself
 
## ColorBgOamPriority

The gameboy color has 3 different places where the priority between the Background layer and the OAM a layer can be declared.

This test verifies the reltions between those flags and the behavior when they colide.

Checkout the [PanDocs](https://gbdev.io/pandocs/Tile_Maps.html#bg-to-obj-priority-in-cgb-mode) for background on the CGB behavior.

### Test result

You should see 5 green squares and 3 half grren and half blue squares with no red lines

#### Expected results:

Screnshoot from Orignal CGB hardware

![image](images/hardware_screenshot.jpg)

#### Original hardware

Special thanks to [ISSOtm](https://github.com/ISSOtm) for running this test rom on original hardware, verifying it actually works and screenshoting the result.

## ColorOamInternalPriority

The gameboy color changes the way the PPU manages its internal OAM objects priority.

For more info checks the [PanDocs](https://gbdev.io/pandocs/OAM.html#drawing-priority).

### Test result

You should see 2 pairs of rectangles connected or touching each other.

#### Expected result

![image](images/oam_internal_priority_expected_sameboy.png)