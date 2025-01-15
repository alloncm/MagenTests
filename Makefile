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
# C - for CGB only
FIXFLAGS = -C -v -m 0 -p 0

define create_target = 
	rgbasm $(ASMFLAGS) -i $(2) -i hardware.inc/ -o $(1).o $(2)/main.asm
	rgblink -o $(1).gbc $(1).o
	rgbfix $(FIXFLAGS) $(1).gbc
endef

all:
	$(call create_target, bg_oam_priority, src/color_bg_oam_priority)
	$(call create_target, oam_internal_priority, src/oam_internal_priority)
	$(call create_target, hblank_vram_dma, src/hblank_vram_dma)
	$(call create_target, key0_lock_after_boot, src/key0_lock_after_boot)
	$(call create_target, ppu_disabled_state, src/ppu_disabled_state)

.PHONY: clean
clean:
	$(RM_F) *.o