RGBASM = rgbasm
RGBLINK = rgblink
RGBFIX = rgbfix

RM_F =
ifeq ($(OS), Windows_NT)
	RM_F = Del
else
	RM_F = rm -f
endif

ASMFLAGS = -L				# L - disable optimiziations
FIXFLAGS = -C -v -m 0 -p 0  # v - equlivant to -f lhg that fixes some header values \
							  m - cartrigde type, p - pad value \
							  C - for CGB only
HARDWAREINC_PATH = hardware.inc/

define create_target = 
	$(RGBASM) -i $(2) -i $(HARDWAREINC_PATH) -o $(1).o $(2)/main.asm
	$(RGBLINK) -o $(1).gbc $(1).o
	$(RGBFIX) $(FIXFLAGS) $(1).gbc
endef

all:
	$(call create_target,bg_oam_priority,src/color_bg_oam_priority)
	$(call create_target,oam_internal_priority,src/oam_internal_priority)

.PHONY: clean
clean:
	$(RM_F) *.o