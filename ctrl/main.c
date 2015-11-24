#include "stm32f10x.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"
#include "stm32f10x_spi.h"
#include "stm32f10x_usart.h"
#include "misc.h"
#include "printf.h"
#include "led.h"
#include "defines.h"
#include "tm_stm32f4_nrf24l01.h"

#define DEBUG


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

	/* Configure USART2 Tx (PA.02) as alternate function push-pull */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_2;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);

	/* Configure USART2 Rx (PA.03) as input floating */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
	GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Configure SPI CLK (PA.05), SPI MOSI (PA.07)
     * as alternate function push-pull */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_7 ;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Configure SPI MISO (PA.06)
     * as alternate function push-pull */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_OD;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Configure SCN (PC.1), CE (PC.2) */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1 | GPIO_Pin_2;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOC, &GPIO_InitStructure);

    /* Configure LEDs (PC.8, PC.9) */
    GPIO_InitStructure.GPIO_Pin = LED1_PIN | LED2_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(LED_PORT, &GPIO_InitStructure);
}


/* RCC_Configuration */
void RCC_Configuration(void)
{
#ifdef DEBUG
	/* Enable USART2 */
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);
#endif

	/* Enable GPIOC, GPIOA */
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC | RCC_APB2Periph_GPIOA | RCC_APB2Periph_SPI1, ENABLE);
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

	/* Init USART2 */
	USART_Init(USART2, &USART_InitStructure);

	/* Enable USART2 */
	USART_Cmd(USART2, ENABLE);

	/* Enable USART2 Rx interrupt */
	USART_ITConfig(USART2, USART_IT_RXNE, ENABLE);
}
#endif


/* NVIC_Configuration */
void NVIC_Configuration(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;

  /* Enable the USART2 Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = USART2_IRQn;
  //NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  //NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
}


/* SPI configuration */
void SPI_Configuration(void)
{
	SPI_InitTypeDef SPI_InitStructure;

	/* OLED_SPI configuration */
	SPI_InitStructure.SPI_Direction = SPI_Direction_2Lines_FullDuplex;
	SPI_InitStructure.SPI_Mode = SPI_Mode_Master;
	SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;

	SPI_InitStructure.SPI_CPOL = SPI_CPOL_Low;
	SPI_InitStructure.SPI_CPHA = SPI_CPHA_1Edge;
	SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;

	SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_256;
	SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;

	SPI_Init(NRF24L01_SPI, &SPI_InitStructure);

	SPI_Cmd(NRF24L01_SPI, ENABLE);
}


void putc( void* p, char c)
{
	while(USART_GetFlagStatus(USART2, USART_FLAG_TXE) == RESET) {
			}
	USART_SendData(USART2, c);
}


/* Print string over UART */
void UART_PrintStr(char *str)
{
	while (*str) {
		while(USART_GetFlagStatus(USART2, USART_FLAG_TXE) == RESET) {
		}
		USART_SendData(USART2, *str++);
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
	/* Hardware initialization */
	RCC_Configuration();
	GPIO_Configuration();
	NVIC_Configuration();
	SPI_Configuration();
	#ifdef DEBUG
	USART_Configuration();
	init_printf(0,putc);
	#endif


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
    	LED1_OFF;
    	LED2_ON;
    	delay(1000);
    	LED2_OFF;
    	delay(1000);


    	int d;
		/* Fill data with something */
		sprintf((char *)dataOut, "abcdefghijklmnoszxABCDEFCBDA");

		/* Transmit data, goes automatically to TX mode */
		TM_NRF24L01_Transmit(dataOut);

		/* Turn on led to indicate sending */
		LED1_ON;

		/* Wait for data to be sent */

		do {
			transmissionStatus = TM_NRF24L01_GetTransmissionStatus();
			uint8_t status = TM_NRF24L01_GetStatus();

			delay(5000);

			printf("status: %d\r\n", status);
			printf("transmissionStatus: %d\r\n", transmissionStatus);
			printf("TM_NRF24L01_GetRetransmissionsCount: %d\r\n", TM_NRF24L01_GetRetransmissionsCount());
		} while (transmissionStatus == TM_NRF24L01_Transmit_Status_Sending);

		printf("transmissionStatus 2: %d\r\n", transmissionStatus);

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
