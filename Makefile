RM_F =
ifeq ($(OS), Windows_NT)
	RM_F = Del
else
	RM_F = rm -f
endif

# L - disable optimiziations
ASMFLAGS = -L

# v - equlivant to -f lhg that fixes some header values
# m - cartrigde type, p - pad value
FIXFLAGS = -v -m 0 -p 0

# C - for CGB only
COLORONLY = -C
# c - for CGB compatible roms
COLORCOMP = -c	

define create_target = 
	rgbasm $(ASMFLAGS) -i $(2) -i hardware.inc/ -o $(1).o $(2)/main.asm
	rgblink -o $(1).gbc $(1).o
	rgbfix $(FIXFLAGS) $(3) $(1).gbc
endef

all:
	mkdir -p build
	$(call create_target, build/bg_oam_priority, src/color_bg_oam_priority, $(COLORONLY))
	$(call create_target, build/oam_internal_priority, src/oam_internal_priority, $(COLORONLY))
	$(call create_target, build/hblank_vram_dma, src/hblank_vram_dma, $(COLORONLY))
	$(call create_target, build/key0_lock_after_boot, src/key0_lock_after_boot, $(COLORONLY))
	$(call create_target, build/ppu_disabled_state, src/ppu_disabled_state, $(COLORCOMP))