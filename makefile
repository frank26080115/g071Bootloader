CC = $(ARM_SDK_PREFIX)gcc
CP = $(ARM_SDK_PREFIX)objcopy
MCU := -mcpu=cortex-m4 -mthumb
LDSCRIPT := STM32G071GBUX_FLASH.ld
LIBS := -lc -lm -lnosys -static
LDFLAGS := -specs=nano.specs -T$(LDSCRIPT) $(LIBS) -Wl,--gc-sections -Wl,--print-memory-usage
MAIN_SRC_DIR := Src
SRC_DIR := Core/Startup \
	Core/Src \
	Drivers/STM32F3xx_HAL_Driver/Src
SRC := $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.[cs]))
OBJ := $(SRC:%.[cs]=%.o)

INCLUDES :=  \
	-ICore/Inc \
	-IDrivers/STM32F3xx_HAL_Driver/Inc \
	-IDrivers/CMSIS/Include \
	-IDrivers/CMSIS/Device/ST/STM32F3xx/Include 

VALUES :=  \
	-DUSE_MAKE \
	-DHSE_VALUE=8000000 \
	-DSTM32F302xC \
	-DHSE_STARTUP_TIMEOUT=100 \
	-DLSE_STARTUP_TIMEOUT=5000 \
	-DLSE_VALUE=32768 \
	-DVDD_VALUE=3300 \
	-DLSI_VALUE=32000 \
	-DHSI_VALUE=8000000 \
	-DUSE_FULL_LL_DRIVER \
	-DPREFETCH_ENABLE=1

VERSION := 8
CFLAGS = $(MCU) $(VALUES) $(INCLUDES) -Os -Wall -fdata-sections -ffunction-sections -mno-unaligned-access -Wall -Wcast-align -ffunction-sections -fdata-sections -fno-exceptions -ffreestanding -flto
CFLAGS += -DUSE_$(TARGET) -DBOOTLOADER_VERSION=$(VERSION)
CFLAGS += -MMD -MP -MF $(@:%.bin=%.d)

ARM_SDK_PREFIX ?= arm-none-eabi-

TARGETS := PA2 PB4
TARGET_PREFIX := AM32_GD32F350_BOOTLOADER_

.PHONY : clean all
all : $(TARGETS)
clean :
	rm -f Src/*.o

$(TARGETS) :
	$(MAKE) TARGET=$@ $(TARGET_PREFIX)$@.bin

$(TARGETS:%=$(TARGET_PREFIX)%.bin) : clean $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET_PREFIX)$(TARGET)_V$(VERSION).elf $(OBJ)
	$(CP) -O binary $(TARGET_PREFIX)$(TARGET)_V$(VERSION).elf $(TARGET_PREFIX)$(TARGET)_V$(VERSION).bin
	$(CP) $(TARGET_PREFIX)$(TARGET)_V$(VERSION).elf -O ihex  $(TARGET_PREFIX)$(TARGET)_V$(VERSION).hex
