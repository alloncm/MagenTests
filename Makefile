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

SRC_DIR = src
SRC_FILE = $(SRC_DIR)/color_bg_oam_priority.asm
TARGET =  bg_oam_priority

$(TARGET).gbc: $(TARGET).o
	$(RGBLINK) -o $@ $^
	$(RGBFIX) $(FIXFLAGS) $@

$(TARGET).o: $(SRC_FILE)
	$(RGBASM) -i $(SRC_DIR) -i $(HARDWAREINC_PATH) -o $@ $^

.PHONY: clean
clean:
	$(RM_F) *.o