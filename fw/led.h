/*
 * led.h
 *
 *  Created on: 04.11.2015
 *      Author: jesstr
 */

#ifndef LED_H_
#define LED_H_

#include "stm32f0xx.h"
#include "stm32f0xx_gpio.h"

#define 	LED1_ON 	GPIO_SetBits(GPIOA, GPIO_Pin_4)
#define 	LED1_OFF 	GPIO_ResetBits(GPIOA, GPIO_Pin_4)
//#define 	LED2_ON 	GPIO_SetBits(GPIOA, GPIO_Pin_3)
//#define 	LED2_OFF 	GPIO_ResetBits(GPIOA, GPIO_Pin_3)

#endif /* LED_H_ */
