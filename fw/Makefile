TARGET = fw

CSRC = $(wildcard *.c )

# CMSIS
STM_CMSIS = ../libs/STM32F0xx
INCLUDES = -I$(STM_CMSIS)/cmsis -I$(STM_CMSIS)/cmsis_boot
CSRC += $(wildcard $(STM_CMSIS)/cmsis_boot/*.c $(STM_CMSIS)/cmsis/*.c)
CSRC += $(wildcard $(STM_CMSIS)/cmsis_boot/startup/*.c)
#ASMSRC = $(STM_CMSIS)/cmsis_boot/startup/startup_stm32f030.s

 
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

# FreeRTOS
#INCLUDES +=  -I../libs/FreeRTOS/Source/include -I../libs/FreeRTOS/Source/portable/GCC/ARM_CM3
#CSRC += $(wildcard ../libs/FreeRTOS/Source/*.c ../libs/FreeRTOS/Source/portable/GCC/ARM_CM3/*.c ../libs/FreeRTOS/Source/portable/GCC/MemMang/*.c)

CFLAGS = -DUSE_STDPERIPH_DRIVER

# MCU family setup
LDSCRIPT = $(STM_CMSIS)/cmsis_boot/stm32f030.ld
CFLAGS += -DSTM32F030
#LDSCRIPT = $(STM_CMSIS)/cmsis_boot/stm32l152rb.ld
#CFLAGS += -DSTM32F10X_MD_VL


BUILDDIR = ../build/$(TARGET)

-include ../Makefile.inc.stm32

prebuild:
	#@echo "Hardware version: $(HARDWARE)"
	#@./getver.sh
	#@echo "SVN version: `cat inc/version.h|sed s'/#define VERSION //'`"
