TARGET = weather

CSRC = $(wildcard *.c )

INCLUDES = -I./lcd/
CSRC += $(wildcard ./lcd/*.c)


# CMSIS
STM_CMSIS = ../libs/STM32F0xx
INCLUDES += -I./cmsis -I./cmsis_boot
INCLUDES += -I.
INCLUDES += -I../libs/printf
INCLUDES += -I../libs/fifo
INCLUDES += -I../libs/nrf24l01/stmf0-nrf
INCLUDES += -I../libs/u8glib_arm_v1.14/stm32f0
INCLUDES += -I../libs/u8glib_arm_v1.14/src
CSRC += $(wildcard ./cmsis_boot/*.c ./cmsis/*.c)
CSRC += $(wildcard ../libs/printf/*.c)
CSRC += $(wildcard ../libs/fifo/*.c)
CSRC += $(wildcard ../libs/nrf24l01/stmf0-nrf/*.c)
CSRC += $(wildcard ../libs/u8glib_arm_v1.14/stm32f0/*.c)
CSRC += $(wildcard ../libs/u8glib_arm_v1.14/src/*.c)
CSRC += $(wildcard ./cmsis_boot/startup/*.c)
#ASMSRC = $(wildcard ./cmsis_boot/startup/*.s)

 
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
CSRC += $(wildcard $(STM_SPL_SRC)/stm32f0xx_tim.c)


# FreeRTOS
INCLUDES +=  -I../libs/FreeRTOSV9.0.0rc1/FreeRTOS/Source/include -I../libs/FreeRTOSV9.0.0rc1/FreeRTOS/Source/portable/GCC/ARM_CM0
CSRC += $(wildcard ../libs/FreeRTOSV9.0.0rc1/FreeRTOS/Source/*.c ../libs/FreeRTOSV9.0.0rc1/FreeRTOS/Source/portable/GCC/ARM_CM0/*.c ../libs/FreeRTOSV9.0.0rc1/FreeRTOS/Source/portable/MemMang/heap_4.c)


CFLAGS = -DUSE_STDPERIPH_DRIVER

# MCU family setup
LDSCRIPT = ./cmsis_boot/stm32f051.ld
CFLAGS += -DSTM32F051
COMMONFLAGS = -mcpu=cortex-m0 -mthumb


BUILDDIR = ../build/$(TARGET)

-include ../Makefile.inc.stm32

prebuild:
	#@echo "Hardware version: $(HARDWARE)"
	#@./getver.sh
	#@echo "SVN version: `cat inc/version.h|sed s'/#define VERSION //'`"
