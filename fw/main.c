#include "stm32f0xx.h"
#include "stm32f0xx_gpio.h"
#include "stm32f0xx_rcc.h"
#include "stm32f0xx_spi.h"
//#include <stdint.h>
#include "tm_stm32f4_nrf24l01.h"

#define 	LED1_ON 	GPIO_SetBits(GPIOA, GPIO_Pin_4)
#define 	LED1_OFF 	GPIO_ResetBits(GPIOA, GPIO_Pin_4)
#define 	LED2_ON 	GPIO_SetBits(GPIOA, GPIO_Pin_3)
#define 	LED2_OFF 	GPIO_ResetBits(GPIOA, GPIO_Pin_3)


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

    /* Configure LEDs (PA.4, PA.3) */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4 | GPIO_Pin_3 | NRF24L01_CSN_PIN | NRF24L01_CE_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
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

	/* Enable GPIOC */
	RCC_APB2PeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);
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


void delay(uint32_t time)
{
	volatile uint32_t i = time * 1000;

	while (i) {
		i--;
	}
}


/* Main routine */
int main(void)
{
	int d = 0;

	/* Hardware initialization */
	RCC_Configuration();
	GPIO_Configuration();
	SPI_Configuration();

	LED2_ON;

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


    while(1)
    {
    	LED1_ON;
    	delay(1000);
    	LED1_OFF;
    	delay(1000);

			/* Fill data with something */
			//sprintf((char *)dataOut, "abcdefghijklmnoszxABCDEFCBDA");

			/* Transmit data, goes automatically to TX mode */
			TM_NRF24L01_Transmit(dataOut);

			/* Turn on led to indicate sending */
			LED1_ON;

			/* Wait for data to be sent */
			do {
				transmissionStatus = TM_NRF24L01_GetTransmissionStatus();
			} while (transmissionStatus == TM_NRF24L01_Transmit_Status_Sending);

			/* Turn off led */
			LED1_OFF;

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
    	}
}
