
#ifndef DEFINES_H_
#define DEFINES_H_

//Change SPI used. Refer to TM SPI library to check which pins are for SPI
#define NRF24L01_SPI				SPI1
//#define NRF24L01_SPI_PINS			TM_SPI_PinsPack_2

//Change CSN pin. This is for SPI communication
#define NRF24L01_CSN_PORT			GPIOA
#define NRF24L01_CSN_PIN			GPIO_Pin_13

//Change CE pin. This pin is used to enable/disable transmitter/receiver functionality
#define NRF24L01_CE_PORT			GPIOA
#define NRF24L01_CE_PIN				GPIO_Pin_14

// GPIO_Pin_10 is IRQ

#endif /* DEFINES_H_ */
