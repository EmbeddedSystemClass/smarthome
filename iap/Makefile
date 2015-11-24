TARGET = iap

CSRC = $(wildcard src/*.c )
INCLUDES = -I./inc

# CMSIS
STM_CMSIS = ../libs/STM32F0xx
INCLUDES += -I./cmsis -I./cmsis_boot
CSRC += $(wildcard ./cmsis_boot/*.c ./cmsis/*.c)
CSRC += $(wildcard ./cmsis_boot/startup/*.c)
#ASMSRC = 

 
# Stm32 standart periferal library
STM_SPL = ../libs/STM32F0xx/STM32F0xx_StdPeriph_Lib
STM_SPL_INC = $(STM_SPL)/inc
STM_SPL_SRC = $(STM_SPL)/src
INCLUDES += -I$(STM_SPL_INC)
# Here should be added used parts of SPL 
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_gpio.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_rcc.c)
#CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_spi.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_misc.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_usart.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_flash.c)


CFLAGS = -DUSE_STDPERIPH_DRIVER

# MCU family setup
LDSCRIPT = ./cmsis_boot/stm32f030.ld
CFLAGS += -DSTM32F030
COMMONFLAGS = -mcpu=cortex-m0 -mthumb


BUILDDIR = ../build/$(TARGET)

-include ../Makefile.inc.stm32

prebuild:
	#@echo "Hardware version: $(HARDWARE)"
	#@./getver.sh
	#@echo "SVN version: `cat inc/version.h|sed s'/#define VERSION //'`"
