/*
  The following delay procedures must be implemented for u8glib. This is done in this file:

  void u8g_Delay(uint16_t val)		Delay by "val" milliseconds
  void u8g_MicroDelay(void)		Delay be one microsecond
  void u8g_10MicroDelay(void)	Delay by 10 microseconds
  
  Additional requirements:
  
      SysTick must be enabled, but SysTick IRQ is not required. Any LOAD values are fine,
      it is prefered to have at least 1ms
      Example:
        SysTick->LOAD = (SystemCoreClock/1000UL*(unsigned long)SYS_TICK_PERIOD_IN_MS) - 1;
	SysTick->VAL = 0;
	SysTick->CTRL = 7;   // enable, generate interrupt (SysTick_Handler), do not divide by 2
*/

#include "u8g_arm.h"
#include "jlx12864oled.h"



void u8g_Delay(uint16_t val)
{
    
}

void u8g_MicroDelay(void)
{

}

void u8g_10MicroDelay(void)
{

}


/*========================================================================*/
/* u8glib com procedure */

uint8_t u8g_com_hw_spi_fn(u8g_t *u8g, uint8_t msg, uint8_t arg_val, void *arg_ptr)
{
  
  switch(msg)
  {
    case U8G_COM_MSG_STOP:
      break;
    
    case U8G_COM_MSG_INIT:
      break;
    
    case U8G_COM_MSG_ADDRESS:                     /* define cmd (arg_val = 0) or data mode (arg_val = 1) */
      if (arg_val == 0) {
          RS_OFF;
      }
      else {
          RS_ON;
      }
     break;

    case U8G_COM_MSG_CHIP_SELECT:
      if ( arg_val == 0 )
      {
          CS_OFF;
      }
      else
      {
          CS_ON;
      }
      break;
      
    case U8G_COM_MSG_RESET:
        if (arg_val == 0) {
             RES_OFF;
         }
         else {
             RES_ON;
         }
      break;
      
    case U8G_COM_MSG_WRITE_BYTE:
      LCD_SPISend(arg_val);
      break;
    
    case U8G_COM_MSG_WRITE_SEQ:
    case U8G_COM_MSG_WRITE_SEQ_P:
      {
        register uint8_t *ptr = arg_ptr;
        while( arg_val > 0 )
        {
          LCD_SPISend(*ptr++);
          arg_val--;
        }
      }
      break;
  }
  return 1;
}

