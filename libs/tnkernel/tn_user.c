#include "stm32f10x.h"
#include "tn.h"

void tn_cpu_int_enable()
{
  tn_arm_enable_interrupts();
}

int tn_inside_int()
{
	return (SCB->ICSR & SCB_ICSR_VECTACTIVE_Msk) ? 1 : 0;
}

extern void rtos_init(void);        

void tn_app_init()
{
  tn_sys_tslice_ticks(28, 1);
  tn_sys_tslice_ticks(29, 1);
  tn_sys_tslice_ticks(30, 1);

  rtos_init();
}
