#include "stm32f0xx.h"
#include "stm32f0xx_gpio.h"
#include "stm32f0xx_rcc.h"
#include "stm32f0xx_spi.h"
#include "stm32f0xx_usart.h"
#include "stm32f0xx_misc.h"
#include "stm32f0xx_syscfg.h"
#include "stm32f0xx_tim.h"
#include "printf.h"
#include "led.h"
#include "defines.h"
//#include "stm32_nrf24l01.h"
#include "FreeRTOS.h"
#include "task.h"
#include "jlx12864oled.h"
#include "u8g.h"
#include "u8g_arm.h"

#define DEBUG


#define NRF24L01_REG_CONFIG			0x00	//Configuration Register
#define NRF24L01_REG_EN_AA			0x01	//Enable �Auto Acknowledgment� Function
#define NRF24L01_REG_EN_RXADDR		0x02	//Enabled RX Addresses
#define NRF24L01_REG_SETUP_AW		0x03	//Setup of Address Widths (common for all data pipes)
#define NRF24L01_REG_SETUP_RETR		0x04	//Setup of Automatic Retransmission
#define NRF24L01_REG_RF_CH			0x05	//RF Channel

extern uint8_t NRF24L01_ReadRegister(uint8_t reg);

u8g_t u8g;


/* RCC_Configuration */
void RCC_Configuration(void)
{
#ifdef DEBUG
	/* Enable USART1 for debug output */
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);
#endif
	/* Enable GPIOC, GPIOA, SPI */
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOC | RCC_AHBPeriph_GPIOA | RCC_AHBPeriph_GPIOB, ENABLE);
	//RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_SPI1, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_SPI2, ENABLE);
}

void init_GPIO(void)
{
  GPIO_InitTypeDef GPIO_InitStructure;
  GPIO_StructInit(&GPIO_InitStructure);

// инициализация светодиодов и прочего вырезана
	/* Configure USART2 Tx (PA.02) as alternate function push-pull */
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_1);
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource3, GPIO_AF_1);

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3 | GPIO_Pin_2;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);

    /* Configure LEDs (PC.8, PC.9) */
    GPIO_InitStructure.GPIO_Pin = LED1_PIN | LED2_PIN;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
    GPIO_Init(LED_PORT, &GPIO_InitStructure);

   // init SPI1-NRF24L01+
#if 0
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource5, GPIO_AF_0);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource6, GPIO_AF_0);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource7, GPIO_AF_0);

   GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
   GPIO_InitStructure.GPIO_Pin = SPI_SCK_PIN | SPI_MOSI_PIN;
   GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
   GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
   GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
   GPIO_Init(GPIOA, &GPIO_InitStructure);

   GPIO_InitStructure.GPIO_Pin = SPI_CS_PIN;
   GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
   GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
   GPIO_Init(SPI_GPIO_PORT,&GPIO_InitStructure);

   GPIO_InitStructure.GPIO_Pin = (NRF24L01_CE_PIN);
   GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
   GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
   GPIO_Init(NRF24L01_CE_PORT, &GPIO_InitStructure);
/*
   GPIO_InitStructure.GPIO_Pin = NRF24L01_IRQ_PIN;
   GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
   GPIO_Init(NRF24L01_IRQ_PORT,&GPIO_InitStructure);
*/
   GPIO_InitStructure.GPIO_Pin = SPI_MISO_PIN;
   //GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
   GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
   GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
   GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
   GPIO_Init(SPI_GPIO_PORT, &GPIO_InitStructure);
#endif

   /* LCD */
   GPIO_PinAFConfig(GPIOB, GPIO_PinSource13, GPIO_AF_0);
   GPIO_PinAFConfig(GPIOB, GPIO_PinSource14, GPIO_AF_0);
   GPIO_PinAFConfig(GPIOB, GPIO_PinSource15, GPIO_AF_0);

  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_15;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOB, &GPIO_InitStructure);

  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_14;
  //GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOB, &GPIO_InitStructure);

  GPIO_InitStructure.GPIO_Pin = LCD_RS_PIN;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_Init(LCD_RS_PORT,&GPIO_InitStructure);

  GPIO_InitStructure.GPIO_Pin = (LCD_RES_PIN);
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_Init(LCD_RES_PORT, &GPIO_InitStructure);

  GPIO_InitStructure.GPIO_Pin = LCD_CS_PIN;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_Init(LCD_CS_PORT, &GPIO_InitStructure);

}

void init_SPI(void)
{
   SPI_InitTypeDef SPI_InitStructure;
   SPI_StructInit(&SPI_InitStructure);

#if 0
   /* NRF */
   SPI_InitStructure.SPI_Mode = SPI_Mode_Master;
   SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_256;
   SPI_InitStructure.SPI_Direction = SPI_Direction_2Lines_FullDuplex;
   SPI_InitStructure.SPI_CPOL = SPI_CPOL_Low;
   SPI_InitStructure.SPI_CPHA = SPI_CPHA_1Edge;
   SPI_InitStructure.SPI_CRCPolynomial = 7;
   SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;
   SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;
   SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;
   SPI_Init(NRF24L01_SPI,&SPI_InitStructure);
   // NSS must be set to '1' due to NSS_Soft settings (otherwise it will be Multimaster mode).

   NRF24L01_CSN_HIGH;
   NRF24L01_CE_LOW;
   SPI_Cmd(NRF24L01_SPI,ENABLE);
   SPI_NSSInternalSoftwareConfig(NRF24L01_SPI,SPI_NSSInternalSoft_Set);
#endif

   /*LCD */
   SPI_InitStructure.SPI_Mode = SPI_Mode_Master;
   SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_256;
   SPI_InitStructure.SPI_Direction = SPI_Direction_1Line_Tx;
   SPI_InitStructure.SPI_CPOL = SPI_CPOL_Low;
   SPI_InitStructure.SPI_CPHA = SPI_CPHA_1Edge;
   SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;
   SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;
   SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;
   SPI_Init(OLED_SPI,&SPI_InitStructure);
   SPI_Cmd(OLED_SPI,ENABLE);

   SPI_RxFIFOThresholdConfig(OLED_SPI, SPI_RxFIFOThreshold_QF);
}

void delay_(uint32_t dl)
{
volatile uint32_t delaycount;
   delaycount = dl;
   while(delaycount)
   {
      delaycount--;
   }
}

#if 0
void retranslate(void)
{
/* Receiver address */
uint8_t TxAddress[] = {
   0xE7,
   0xE7,
   0xE7,
   0xE7,
   0xE7
};
/* My address */
uint8_t MyAddress[] = {
   0x7E,
   0x7E,
   0x7E,
   0x7E,
   0x7E
};

uint8_t dataIn[32];
NRF24L01_Transmit_Status_t transmissionStatus;
   /* Initialize NRF24L01+ on channel 15 and 32bytes of payload */
   /* By default 2Mbps data rate and 0dBm output power */
   /* NRF24L01 goes to RX mode by default */
   NRF24L01_Init(15, 32);

   /* Set RF settings, Data rate to 2Mbps, Output power to -18dBm */
   NRF24L01_SetRF(NRF24L01_DataRate_2M, NRF24L01_OutputPower_M18dBm);

   /* Set my address, 5 bytes */
   //NRF24L01_SetMyAddress(MyAddress);
   /* Set TX address, 5 bytes */
   //NRF24L01_SetTxAddress(TxAddress);

   LED1_ON;
   delay_(3600000);
   LED1_OFF;

   printf("retranslate\r\n");

   uint8_t reg;

	reg = NRF24L01_ReadRegister(NRF24L01_REG_CONFIG);
	printf("NRF24L01_REG_CONFIG: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_EN_RXADDR);
	printf("NRF24L01_REG_EN_RXADDR: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_RF_CH);
	printf("NRF24L01_REG_RF_CH: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_CONFIG);
	printf("NRF24L01_REG_CONFIG: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_RF_CH);
		printf("NRF24L01_REG_RF_CH: 0x%X\r\n", reg);

		reg = NRF24L01_ReadRegister(NRF24L01_REG_CONFIG);
			printf("NRF24L01_REG_CONFIG: 0x%X\r\n", reg);

      while (1)
      {
      /* If data is ready on NRF24L01+ */
      if (NRF24L01_DataReady())
         {
            /* Get data from NRF24L01+ */
            NRF24L01_GetData(dataIn);

            delay_(36000);
            printf("dataIn: %s\r\n", dataIn);

            /* Send it back, automatically goes to TX mode */
            NRF24L01_Transmit(dataIn);

            /* Start send */
            LED1_ON;
            delay_(360000);
            /* Wait for data to be sent */
            do {
               transmissionStatus = NRF24L01_GetTransmissionStatus();
            } while (transmissionStatus == NRF24L01_Transmit_Status_Sending);
            /* Send done */
            LED1_OFF;

            /* Go back to RX Mode */
            NRF24L01_PowerUpRx();
         }
      }

}

void transmitter(void)
{
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
uint8_t dataOut[32], dataIn[32], i;
uint32_t tr_count;
NRF24L01_Transmit_Status_t transmissionStatus;

   /* Initialize NRF24L01+ on channel 15 and 32bytes of payload */
   /* By default 2Mbps data rate and 0dBm output power */
   /* NRF24L01 goes to RX mode by default */
   NRF24L01_Init(15, 32);

   /* Set RF settings, Data rate to 2Mbps, Output power to -18dBm */
   NRF24L01_SetRF(NRF24L01_DataRate_2M, NRF24L01_OutputPower_M18dBm);

   /* Set my address, 5 bytes */
   NRF24L01_SetMyAddress(MyAddress);
   /* Set TX address, 5 bytes */
   NRF24L01_SetTxAddress(TxAddress);

   uint8_t reg;

   delay_(720000);

/*
	reg = NRF24L01_ReadRegister(NRF24L01_REG_CONFIG);
	printf("NRF24L01_REG_CONFIG: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_EN_RXADDR);
	printf("NRF24L01_REG_EN_RXADDR: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_RF_CH);
	printf("NRF24L01_REG_RF_CH: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_CONFIG);
	printf("NRF24L01_REG_CONFIG: 0x%X\r\n", reg);

	reg = NRF24L01_ReadRegister(NRF24L01_REG_RF_CH);
		printf("NRF24L01_REG_RF_CH: 0x%X\r\n", reg);

		reg = NRF24L01_ReadRegister(NRF24L01_REG_CONFIG);
			printf("NRF24L01_REG_CONFIG: 0x%X\r\n", reg);
*/
	delay_(720000);

   for (i = 0; i < 32; i++)
   {
      dataOut[i] = i + 30;
      dataIn[i] = 0;
   }
while (1) {
         /* Transmit data, goes automatically to TX mode */
         NRF24L01_Transmit(dataOut);
         /* Turn on led to indicate sending */
         LED2_ON;
         /* Wait for data to be sent */
         do {
            transmissionStatus = NRF24L01_GetTransmissionStatus();

            printf("transmissionStatus: %d\r\n", transmissionStatus);
            delay_(720000);

         } while (transmissionStatus == NRF24L01_Transmit_Status_Sending);
         /* Turn off led */
         LED2_OFF;

         /* Go back to RX mode */
         NRF24L01_PowerUpRx();
         i = 0;

         /* Wait received data, wait max 100ms, if time is larger, then data were probably lost */
         while (!NRF24L01_DataReady())
         {
            delay_(720000);
            i++;
            printf("TM_NRF24L01_DataReady\r\n");
            if( i > 100) break;
         }

         /* Get data from NRF2L01+ */
         NRF24L01_GetData(dataIn);

         printf("dataIn: %s\r\n", dataIn);

         /* Check transmit status */
         if (transmissionStatus == NRF24L01_Transmit_Status_Ok)
         {
            tr_count++;
            printf("tr_count: %s\r\n", tr_count);
         }
      }
}
#endif


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
	//USART_ITConfig(USART2, USART_IT_RXNE, ENABLE);
}


void putc( void* p, char c)
{
	while(USART_GetFlagStatus(USART2, USART_FLAG_TXE) == RESET) {
			}
	USART_SendData(USART2, c);
}

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

void init(void)
{
  //init_RCC();
  /* RCC_Configuration */
  RCC_Configuration();
  init_GPIO();
  init_SPI();
  //NVIC_Configuration();
  USART_Configuration();
  init_printf(0,putc);
}

/* Demo row3 banner task */
void task3(void *pvParameters) {
	unsigned char column = 0;

	for (;;) {
		if (column > 130) {
			column = 0;
		}
		else {
			column++;
		}
		LCD_PrintStr(3, column, " Task 3");
		vTaskDelay(25);
	}
}

/* Demo LED1 flashing task */
void task1(void *pvParameters) {

        for (;;) {
                GPIO_SetBits(GPIOC, GPIO_Pin_9);
                vTaskDelay(1000);
                GPIO_ResetBits(GPIOC, GPIO_Pin_9);
                vTaskDelay(1000);
        }
}



void task2(void *pvParameters)
{
    uint8_t pos = 0;

    u8g_SetDefaultForegroundColor(&u8g);
    u8g_SetFont(&u8g, u8g_font_helvR12);

    for(;;)
    {
      /* picture loop */
      u8g_FirstPage(&u8g);
      do
      {
          u8g_SetFont(&u8g, u8g_font_helvR18);
          u8g_DrawStr(&u8g,  0, 31+pos, "Hello");
          u8g_SetFont(&u8g, u8g_font_gdr25r);
          u8g_DrawStr(&u8g, pos, 31, "World!");
      } while ( u8g_NextPage(&u8g) );

      /* refresh screen after some delay */
      vTaskDelay(10);

      /* update position */
      pos++;
      pos &= 63;
    }
}

void main()
{
	init();
	printf("Hello!\r\n");
	//printf("Check: %d", NRF24_Check());
	//transmitter();
	//retranslate();

	/* IO pins initial state */
	CS_ON;
	RS_OFF;
	RES_OFF;

	/* Queue of data to LCD */
	LCDDataQueue = xQueueCreate( 5, sizeof( LCDMessage ) );
	/* Queue of commands to LCD */
	LCDCmdQueue = xQueueCreate( 5, sizeof( char ) );

	u8g_InitComFn(&u8g, &u8g_dev_ssd1306_128x64_hw_spi, u8g_com_hw_spi_fn);

	/* 4 tasks which print moving text banners on LCD */
	//xTaskCreate( task3, ( char * ) "Row3", configMINIMAL_STACK_SIZE, NULL, 1,
	//							( xTaskHandle * ) NULL);
	xTaskCreate( task1, ( char * ) "Led1", configMINIMAL_STACK_SIZE, NULL, 1,
							( xTaskHandle * ) NULL);
	xTaskCreate( task2, ( char * ) "glib", configMINIMAL_STACK_SIZE, NULL, 1,
	                        ( xTaskHandle * ) NULL);

	/* Start LCD gatekeeper */
	//xTaskCreate( LCD_Task, ( char * ) "LCD", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY, ( xTaskHandle * ) NULL );



	vTaskStartScheduler();

	while(1)
	{
	}
}

