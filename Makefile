# L - disable optimiziations
ASMFLAGS = -L

# v - equlivant to -f lhg that fixes some header values
# p - pad value
FIXFLAGS = -v -p 0

COLORONLY = --color-only
COLORCOMP = --color-compatible
NO_MBC = --mbc-type ROM

define create_target = 
	rgbasm $(ASMFLAGS) -i $(2) -i hardware.inc/ -o $(1).o $(2)/main.asm
	rgblink -o $(1).gbc $(1).o
	rgbfix $(FIXFLAGS) $(3) $(1).gbc
endef

all:
ifeq ($(OS), Windows_NT)
	if not exist build mkdir build
else 
	mkdir -p build
endif 
	$(call create_target, build/bg_oam_priority, src/color_bg_oam_priority, $(COLORONLY) $(NO_MBC))
	$(call create_target, build/oam_internal_priority, src/oam_internal_priority, $(COLORONLY) $(NO_MBC))
	$(call create_target, build/hblank_vram_dma, src/hblank_vram_dma, $(COLORONLY) $(NO_MBC))
	$(call create_target, build/key0_lock_after_boot, src/key0_lock_after_boot, $(COLORONLY) $(NO_MBC))
	$(call create_target, build/ppu_disabled_state, src/ppu_disabled_state, $(COLORCOMP) $(NO_MBC))
	$(call create_target, build/mbc_oob_sram_mbc1, src/mbc_oob_sram, $(COLORCOMP) --mbc-type MBC1+RAM --ram-size 2)
	$(call create_target, build/mbc_oob_sram_mbc3, src/mbc_oob_sram, $(COLORCOMP) --mbc-type MBC3+RAM --ram-size 2)
	$(call create_target, build/mbc_oob_sram_mbc5, src/mbc_oob_sram, $(COLORCOMP) --mbc-type MBC5+RAM --ram-size 2)