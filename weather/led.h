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
#include "defines.h"

#define 	LED1_ON 	GPIO_SetBits(LED_PORT, LED1_PIN)
#define 	LED1_OFF 	GPIO_ResetBits(LED_PORT, LED1_PIN)
#define 	LED2_ON 	GPIO_SetBits(LED_PORT, LED2_PIN)
#define 	LED2_OFF 	GPIO_ResetBits(LED_PORT, LED2_PIN)

#endif /* LED_H_ */
