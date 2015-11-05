TARGET = fw

CSRC = $(wildcard *.c )

# CMSIS
STM_CMSIS = ../libs/STM32F0xx
INCLUDES = -I./cmsis -I./cmsis_boot
INCLUDES += -I../libs/printf
CSRC += $(wildcard ./cmsis_boot/*.c ./cmsis/*.c)
CSRC += $(wildcard ../libs/printf/*.c)
#CSRC += $(wildcard ./cmsis_boot/startup/*.c)
ASMSRC = $(wildcard ./cmsis_boot/startup/*.s)

 
# Stm32 standart periferal library
STM_SPL = ../libs/STM32F0xx/STM32F0xx_StdPeriph_Lib
STM_SPL_INC = $(STM_SPL)/inc
STM_SPL_SRC = $(STM_SPL)/src
INCLUDES += -I$(STM_SPL_INC)
# Here should be added used parts of SPL 
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_gpio.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_rcc.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_spi.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_misc.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_usart.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_syscfg.c)


# FreeRTOS
#INCLUDES +=  -I../libs/FreeRTOS/Source/include -I../libs/FreeRTOS/Source/portable/GCC/ARM_CM3
#CSRC += $(wildcard ../libs/FreeRTOS/Source/*.c ../libs/FreeRTOS/Source/portable/GCC/ARM_CM3/*.c ../libs/FreeRTOS/Source/portable/GCC/MemMang/*.c)

CFLAGS = -DUSE_STDPERIPH_DRIVER

# MCU family setup
LDSCRIPT = ./cmsis_boot/stm32f030.ld
CFLAGS += -DSTM32F030


BUILDDIR = ../build/$(TARGET)

-include ../Makefile.inc.stm32

prebuild:
	#@echo "Hardware version: $(HARDWARE)"
	#@./getver.sh
	#@echo "SVN version: `cat inc/version.h|sed s'/#define VERSION //'`"
