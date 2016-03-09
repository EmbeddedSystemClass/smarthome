
#ifndef DEFINES_H_
#define DEFINES_H_


//Change SPI used. Refer to TM SPI library to check which pins are for SPI
#define NRF24L01_SPI				SPI1
//#define NRF24L01_SPI_PINS			TM_SPI_PinsPack_2

//Change CSN pin. This is for SPI communication
//#define NRF24L01_CSN_PORT			GPIOC
//#define NRF24L01_CSN_PIN			GPIO_Pin_1

//Change CE pin. This pin is used to enable/disable transmitter/receiver functionality
//#define NRF24L01_CE_PORT			GPIOC
//#define NRF24L01_CE_PIN		    GPIO_Pin_2

// GPIO_Pin_10 is IRQ

//Change TIM1 pins. This pins are used to PWM output channels
#define TIM1_PORT					GPIOA
//#define TIM1_CH1_PIN				GPIO_Pin_8
#define TIM1_CH2_PIN				GPIO_Pin_9
#define TIM1_CH3_PIN				GPIO_Pin_10


//Change LEDs pins. This pins are used to control LEDs
#define LED_PORT					GPIOC
#define LED1_PIN					GPIO_Pin_8
#define LED2_PIN					GPIO_Pin_9

#endif /* DEFINES_H_ */
