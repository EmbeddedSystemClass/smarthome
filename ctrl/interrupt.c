/*
 * interrupt.c
 *
 *  Created on: 04.11.2015
 *      Author: jesstr
 */

#include "stm32f10x.h"
#include "stm32f10x_usart.h"
#include "fifo.h"
#include "led.h"


/*  USART1 global interrupt handler  */
void USART2_IRQHandler(void)
{
	uint16_t buf;

	LED1_ON;

	 /* RXNE is automaticaly cleared by DMA read */
	//if ((USART3->SR & USART_FLAG_RXNE) != (u16)RESET)

	// check if the USART1 receive interrupt flag was set
	if( USART_GetITStatus(USART2, USART_IT_RXNE) ){

		buf = USART_ReceiveData(USART2);

	}

	WriteBuf(&buf, 2);
}
