TARGET = ctrl

CSRC = $(wildcard *.c )

# CMSIS
STM_CMSIS = ../libs/STM32F1xx
INCLUDES = -I./cmsis -I./cmsis_boot
INCLUDES += -I../libs/printf
INCLUDES += -I../libs/fifo
INCLUDES += -I../libs/nrf24l01/stm32f1
CSRC += $(wildcard ./cmsis_boot/*.c ./cmsis/*.c)
CSRC += $(wildcard ../libs/printf/*.c)
CSRC += $(wildcard ../libs/fifo/*.c)
CSRC += $(wildcard ../libs/nrf24l01/stm32f1/*.c)
CSRC += $(wildcard ./cmsis_boot/startup/*.c)
#ASMSRC = $(wildcard ./cmsis_boot/startup/*.s)

 
# Stm32 standart periferal library
STM_SPL = ../libs/STM32F1xx/STM32F1xx_StdPeriph_Lib
STM_SPL_INC = $(STM_SPL)/inc
STM_SPL_SRC = $(STM_SPL)/src
INCLUDES += -I$(STM_SPL_INC)
# Here should be added used parts of SPL 
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f10x_gpio.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f10x_rcc.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f10x_spi.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f10x_misc.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f10x_usart.c)
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f10x_tim.c)
CSRC += $(wildcard $(STM_SPL_SRC)/misc.c)


# FreeRTOS
#INCLUDES +=  -I../libs/FreeRTOS/Source/include -I../libs/FreeRTOS/Source/portable/GCC/ARM_CM3
#CSRC += $(wildcard ../libs/FreeRTOS/Source/*.c ../libs/FreeRTOS/Source/portable/GCC/ARM_CM3/*.c ../libs/FreeRTOS/Source/portable/GCC/MemMang/*.c)

CFLAGS = -DUSE_STDPERIPH_DRIVER

# MCU family setup
LDSCRIPT = ./cmsis_boot/stm32l152rb.ld
CFLAGS += -DSTM32F10X_MD_VL
COMMONFLAGS = -mcpu=cortex-m3 -mthumb


BUILDDIR = ../build/$(TARGET)

-include ../Makefile.inc.stm32

prebuild:
	#@echo "Hardware version: $(HARDWARE)"
	#@./getver.sh
	#@echo "SVN version: `cat inc/version.h|sed s'/#define VERSION //'`"
