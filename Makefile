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

SRC_FILE = src/color_bg_oam_priority.asm
TARGET = testcolor

$(TARGET).gbc: $(TARGET).o
	$(RGBLINK) -o $@ $^
	$(RGBFIX) $(FIXFLAGS) $@

$(TARGET).o: $(SRC_FILE)
	$(RGBASM) -o $@ $^

.PHONY: clean
clean:
	$(RM_F) *.o