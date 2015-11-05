#include "stm32f0xx.h"
#include "stm32f0xx_gpio.h"
#include "stm32f0xx_rcc.h"
#include "stm32f0xx_spi.h"
#include "stm32f0xx_usart.h"
#include "stm32f0xx_misc.h"
#include "stm32f0xx_syscfg.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "tm_stm32f4_nrf24l01.h"
#include "led.h"
#include "printf.h"



#define DEBUG

#define APPLICATION_ADDRESS     (uint32_t)0x8001C00

/* My address */
uint8_t MyAddress[] = {
    0xE7,
    0xE7,
    0xE7,
    0xE7,
    0xE7
};
/* Receiver address */
uint8_t TxAddress[] = {
    0x7E,
    0x7E,
    0x7E,
    0x7E,
    0x7E
};

uint8_t dataOut[32] = "abcdefghijklmnoszxABCDEFCBDA", dataIn[32];


/* GPIO_Configuration */
void GPIO_Configuration(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;

	GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_1);
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource3, GPIO_AF_1);

    /* Configure SPI CLK (PA.05), SPI MOSI (PA.07)
     * as alternate function push-pull */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3 | GPIO_Pin_2;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Configure SPI CLK (PA.05), SPI MOSI (PA.07)
     * as alternate function push-pull */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_7 | GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Configure SPI MISO (PA.06)
     * as alternate function push-pull */
    /*
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
	*/

    /* Configure LEDs (PA.4) */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4 | NRF24L01_CSN_PIN | NRF24L01_CE_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Try to config SWD port */
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource13, GPIO_AF_0);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource14, GPIO_AF_0);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_14;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_DOWN;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);


}


/* RCC_Configuration */
void RCC_Configuration(void)
{
#ifdef DEBUG
	/* Enable USART1 for debug output */
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
#endif
	/* Enable SPI */
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_SPI1, ENABLE);

	/* Enable GPIOA */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE);

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_DBGMCU, ENABLE);
/*
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOB, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOC, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOD, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOF, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_TS, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_CRC, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_FLITF, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_SRAM, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_SPI1, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM15, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM16, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM17, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_DBGMCU, ENABLE);

	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM6, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM14, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_WWDG, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_SPI2, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C1, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C2, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_PWR, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_DAC, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_CEC, ENABLE);
	*/
}


/* SPI configuration */
void SPI_Configuration(void)
{
	SPI_InitTypeDef SPI_InitStructure;

	/* OLED_SPI configuration */
	SPI_InitStructure.SPI_Direction = SPI_Direction_1Line_Tx;
	SPI_InitStructure.SPI_Mode = SPI_Mode_Master;
	SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;

	SPI_InitStructure.SPI_CPOL = SPI_CPOL_Low;
	SPI_InitStructure.SPI_CPHA = SPI_CPHA_1Edge;
	SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;

	SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_2;
	SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;

	SPI_Init(NRF24L01_SPI, &SPI_InitStructure);

	SPI_Cmd(NRF24L01_SPI, ENABLE);
}


/* NVIC_Configuration */
void NVIC_Configuration(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;

  /* Enable the USART1 Interrupt */
#ifdef DEBUG
  NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
#endif
  //NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  //NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
}


#ifdef DEBUG
/* USART_Configuration */
void USART_Configuration(void)
{
	USART_InitTypeDef USART_InitStructure;

	/* Fill USART_InitStructure with default values
	* (9600, 8 bit, 1 stop bit, no flow control) */
	USART_StructInit(&USART_InitStructure);
	/* Set baudrate to 115200 */
	USART_InitStructure.USART_BaudRate = 115200;

	/* Init USART1 */
	USART_Init(USART1, &USART_InitStructure);

	/* Enable USART1 */
	USART_Cmd(USART1, ENABLE);

	/* Enable USART1 Rx interrupt */
	USART_ITConfig(USART1, USART_IT_RXNE, ENABLE);
}

/* Print string over UART */
void UART_PrintStr(char *str) {
	while (*str) {
		while(USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET) {
		}
		USART_SendData(USART1, *str++);
	}
}

/* Print data over UART */
void UART_PrintData(unsigned char *data, unsigned int n)
{
	char str[16];

	UART_PrintStr("[ ");
	while (n--) {
		sprintf(str, "%d ", *data++);
		UART_PrintStr(str);
	}
	UART_PrintStr("]\r\n");
}
#endif


void delay(uint32_t time)
{
	volatile uint32_t i = time * 1000;

	while (i) {
		i--;
	}
}


void SysTick_Handler(void) {
  static uint16_t tick = 0;

  switch (tick++) {
  	case 100:
  		tick = 0;
  		//GPIOA->ODR ^= (1 << 4);
  		break;
  }
}



__IO uint32_t VectorTable[48] __attribute__((section(".RAMVectorTable")));


/* Main routine */
int main(void)
{
	int i, d, nbytes = 0;
	char data[16] = {'\0'};


	/* Relocate by software the vector table to the internal SRAM at 0x20000000 ***/

	/* Copy the vector table from the Flash (mapped at the base of the application
	 load address 0x08003000) to the base address of the SRAM at 0x20000000. */
	for(i = 0; i < 48; i++)
	{
	VectorTable[i] = *(__IO uint32_t*)(APPLICATION_ADDRESS + (i<<2));
	}

	/* Enable the SYSCFG peripheral clock*/
	RCC_APB2PeriphResetCmd(RCC_APB2Periph_SYSCFG, ENABLE);
	/* Remap SRAM at 0x00000000 */
	SYSCFG_MemoryRemapConfig(SYSCFG_MemoryRemap_SRAM);

	//SysTick_Config(SystemCoreClock/100);

	/* Hardware initialization */
	RCC_Configuration();
	GPIO_Configuration();
	SPI_Configuration();
	NVIC_Configuration();

#ifdef DEBUG
	USART_Configuration();
	UART_PrintStr("Hello\n");
#endif

	//LED2_ON;

	TM_NRF24L01_Transmit_Status_t transmissionStatus;

	/* Initialize NRF24L01+ on channel 15 and 32bytes of payload */
	/* By default 2Mbps data rate and 0dBm output power */
	/* NRF24L01 goes to RX mode by default */
	TM_NRF24L01_Init(15, 32);

	/* Set 2MBps data rate and -18dBm output power */
	TM_NRF24L01_SetRF(TM_NRF24L01_DataRate_2M, TM_NRF24L01_OutputPower_M18dBm);

	/* Set my address, 5 bytes */
	TM_NRF24L01_SetMyAddress(MyAddress);
	/* Set TX address, 5 bytes */
	TM_NRF24L01_SetTxAddress(TxAddress);

    __enable_irq();

    while(1)
    {

    	UART_PrintStr("!");

    	if ((nbytes = GetBufDataCount()) > 0) {
    		ReadBuf(data, nbytes);

    		if (strncmp(data, "r", 1) == 0) {
    			NVIC_SystemReset();
    		}

    		UART_PrintStr(data);
    	}

    	delay(1000);
    	LED1_OFF;

//#if 0
		/* Fill data with something */
		//sprintf((char *)dataOut, "abcdefghijklmnoszxABCDEFCBDA");

		/* Transmit data, goes automatically to TX mode */
		TM_NRF24L01_Transmit(dataOut);

		/* Turn on led to indicate sending */
		LED1_ON;

		/* Wait for data to be sent */

		do {
			transmissionStatus = TM_NRF24L01_GetTransmissionStatus();
			uint8_t status = TM_NRF24L01_GetStatus();

			UART_PrintData(&status, 1);
			UART_PrintData(&transmissionStatus, 1);
		} while (transmissionStatus == TM_NRF24L01_Transmit_Status_Sending);

		//UART_PrintStr(transmissionStatus);

		UART_PrintData((unsigned char)transmissionStatus, 1);

		/* Turn off led */
		LED1_OFF;
#if 0
		/* Go back to RX mode */
		TM_NRF24L01_PowerUpRx();

		/* Wait received data, wait max 100ms, if time is larger, then data were probably lost */
		while (!TM_NRF24L01_DataReady() && (d < 10)) {
			delay(100);
			d++;
		}
		d = 0;

		/* Get data from NRF2L01+ */
		TM_NRF24L01_GetData(dataIn);

		/* Check transmit status */
		if (transmissionStatus == TM_NRF24L01_Transmit_Status_Ok) {

		} else if (transmissionStatus == TM_NRF24L01_Transmit_Status_Lost) {

		} else {

		}
#endif
	}
}
