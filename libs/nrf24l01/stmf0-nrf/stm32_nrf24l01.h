#ifndef NRF24L01_H
#define NRF24L01_H 1

#include "stm32f0xx.h"
#include "stm32f0xx_gpio.h"

#ifdef __cplusplus
extern C {
#endif

/* IRQ */
#define NRF24L01_IRQ_PORT    		GPIOB    				// PORT A
#define NRF24L01_IRQ_LINE    		EXTI_Line2    	// Line2
#define NRF24L01_IRQ_PIN    		GPIO_Pin_2    	// Pin2
#define NRF24L01_PINSOURCE   		GPIO_PinSource2	// Pin2
/* CE */
#define NRF24L01_CE_PORT			GPIOC
#define NRF24L01_CE_PIN				GPIO_Pin_2

/* SPI */
#define NRF24L01_SPI_PORT 			1
#if NRF24L01_SPI_PORT == 1
	#define NRF24L01_SPI  SPI1
	#define SPI_SCK_PIN   GPIO_Pin_5     // PA5
	#define SPI_MISO_PIN  GPIO_Pin_6     // PA6
	#define SPI_MOSI_PIN  GPIO_Pin_7     // PA7
	#define SPI_CS_PIN    GPIO_Pin_4     // PA4
	#define SPI_GPIO_PORT GPIOA
#elif NRF24L01_SPI_PORT == 2
	#define SPI_PORT      SPI2
	#define SPI_SCK_PIN   GPIO_Pin_13    // PB13
	#define SPI_MISO_PIN  GPIO_Pin_14    // PB14
	#define SPI_MOSI_PIN  GPIO_Pin_15    // PB15
	#define SPI_CS_PIN    GPIO_Pin_12    // PB12
	#define SPI_GPIO_PORT GPIOB
#elif NRF24L01_SPI_PORT == 3
	#define SPI_PORT      SPI3
	#define SPI_SCK_PIN   GPIO_Pin_3     // PB3  (JTDO)
	#define SPI_MISO_PIN  GPIO_Pin_4     // PB4  (NJTRST)
	#define SPI_MOSI_PIN  GPIO_Pin_5     // PB5
	#define SPI_CS_PIN    GPIO_Pin_6     // PB6
	#define SPI_GPIO_PORT GPIOB
#endif
/* Pins operations */
#define NRF24L01_CE_LOW				GPIO_ResetBits(NRF24L01_CE_PORT,NRF24L01_CE_PIN)
#define NRF24L01_CE_HIGH			GPIO_SetBits(NRF24L01_CE_PORT,NRF24L01_CE_PIN)
#define NRF24L01_CSN_LOW			GPIO_ResetBits(SPI_GPIO_PORT,SPI_CS_PIN)
#define NRF24L01_CSN_HIGH			GPIO_SetBits(SPI_GPIO_PORT,SPI_CS_PIN)


typedef enum {
	NRF24L01_Transmit_Status_Lost = 0x00,   /*!< Message is lost, reached maximum number of retransmissions */
	NRF24L01_Transmit_Status_Ok = 0x01,     /*!< Message sent successfully */
	NRF24L01_Transmit_Status_Sending = 0xFF /*!< Message is still sending */
} NRF24L01_Transmit_Status_t;

typedef enum {
	NRF24L01_DataRate_2M,  /*!< Data rate set to 2Mbps */
	NRF24L01_DataRate_1M,  /*!< Data rate set to 1Mbps */
	NRF24L01_DataRate_250k /*!< Data rate set to 250kbps */
} NRF24L01_DataRate_t;

typedef enum {
	NRF24L01_OutputPower_M18dBm,	/*!< Output power set to -18dBm */
	NRF24L01_OutputPower_M12dBm, /*!< Output power set to -12dBm */
	NRF24L01_OutputPower_M6dBm,  /*!< Output power set to -6dBm */
	NRF24L01_OutputPower_0dBm    /*!< Output power set to 0dBm */
} NRF24L01_OutputPower_t;

uint8_t NRF24L01_Init(uint8_t channel, uint8_t payload_size);
void NRF24L01_SetMyAddress(uint8_t* adr);
void NRF24L01_SetTxAddress(uint8_t* adr);
uint8_t NRF24L01_GetRetransmissionsCount(void);
void NRF24L01_PowerUpTx(void);
void NRF24L01_PowerUpRx(void);
void NRF24L01_PowerDown(void);
NRF24L01_Transmit_Status_t NRF24L01_GetTransmissionStatus(void);
void NRF24L01_Transmit(uint8_t *data);
uint8_t NRF24L01_DataReady(void);
void NRF24L01_GetData(uint8_t *data);
void NRF24L01_SetChannel(uint8_t channel);
void NRF24L01_SetRF(NRF24L01_DataRate_t DataRate, NRF24L01_OutputPower_t OutPwr);
uint8_t NRF24L01_GetStatus(void);

uint8_t NRF24_Check(void);
void NRF24_init(void);

#ifdef __cplusplus
}
#endif

#endif

