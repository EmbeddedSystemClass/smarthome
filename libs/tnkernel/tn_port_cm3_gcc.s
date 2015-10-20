/* ------------------------------------------------------------------------------
;
; TNKernel RTOS port for ARM(c) Cortex-M3(c) core
;
; Copyright © 2004,2008 Yuri Tiomkin
; All rights reserved.
;
;
; Assembler:   GCC
;
;
; Permission to use, copy, modify, and distribute this software in source
; and binary forms and its documentation for any purpose and without fee
; is hereby granted, provided that the above copyright notice appear
; in all copies and that both that copyright notice and this permission
; notice appear in supporting documentation.
;
; THIS SOFTWARE IS PROVIDED BY THE YURI TIOMKIN AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL YURI TIOMKIN OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
; SUCH DAMAGE.
----------------------------------------------------------------------------- */

   .cpu cortex-m3
/* .code 16
 .fpu softvfp
 .syntax unified
 .thumb
 .text
*/
    .section .text
    .code 16
    .syntax unified


  /* External references */

  .extern   tn_curr_run_task
  .extern   tn_next_task_to_run
  .extern   tn_int_counter
  .extern   tn_context_switch_request
  .extern   tn_system_state


  /* Public functions declared in this file */

  .global  tn_switch_context_exit
  .global  tn_switch_context
  .global  tn_cpu_save_sr
  .global  tn_cpu_restore_sr
  .global  tn_start_exe
  .global  tn_chk_irq_disabled
  .global  PendSV_Handler
  .global  tn_int_exit
  .global  ffs_asm

 /*  Interrupt Control State Register Address */

  .equ ICSR_ADDR,   0xE000ED04

 /*  pendSV bit in the Interrupt Control State Register */

  .equ PENDSVSET,   0x10000000

 /*  System Handlers 12-15 Priority Register Address */

  .equ PR_12_15_ADDR,  0xE000ED20

 /*  PRI_14 (PendSV) priority in the System Handlers 12-15 Priority Register Address
     PendSV priority is minimal (0xFF)
 */

  .equ PENDS_VPRIORITY,  0x00FF0000

/*----------------------------------------------------------------------------*
/* Interrups not yet enabled*/
/*--------------------------------------------------------------------------- */
 .thumb_func

tn_start_exe:
       ldr    r1, =PR_12_15_ADDR        /* Load the System 12-15 Priority Register */
       ldr    r0, [r1]
       orr    r0, r0, #PENDS_VPRIORITY  /*  set PRI_14 (PendSV) to 0xFF - minimal */
       str    r0, [r1]

       ldr    r1,=tn_system_state       /*  Indicate that system has started */
       mov    r0,#1                     /*  1 -> TN_SYS_STATE_RUNNING */
       strb   r0,[r1]

  /*---------------*/

       ldr    r0, =tn_context_switch_request  /* set the context switch */
       mov    r1, #1
       str    r1, [r0]

       ldr    r1, =tn_curr_run_task     /*  =tn_next_task_to_run */
       ldr    r2, [r1]
       ldr    r0, [r2]                  /*  in r0 - new task SP */

       ldmia  r0!, {r4-r11}
       msr    psp, r0
       orr    lr, lr, #0x04             /*  Force to new process PSP */

/* tn_switch_context_exit: */

       ldr    r1, =ICSR_ADDR            /*  Trigger PendSV exception */
       ldr    r0, =PENDSVSET
       str    r0, [r1]

       cpsie  I                         /*  Enable core interrupts */

  /* - Never reach this  */

       b  .
    /*  bx lr */


/* ------------------------------------------------------------------------ */
  .thumb_func

tn_switch_context_exit:

       ldr    r1, =ICSR_ADDR            /*  Trigger PendSV exception */
       ldr    r0, =PENDSVSET
       str    r0, [r1]

       cpsie  I                         /*  Enable core interrupts */

  /* - Never reach this  */

       b  .

/* ------------------------------------------------------------------------ */

    .thumb_func

PendSV_Handler:
       cpsid  I                         /*  Disable core int */

  /* - The context switching - to do or not */

       ldr    r0, =tn_context_switch_request
       ldr    r1, [r0]
       cmp    r1, #0                    /*  if there is no context */
       beq    exit_context_switch       /*  switching - return */
       mov    r1, #0
       str    r1, [r0]

  /* -------------------------------------- */

       mrs    r0, psp                   /*  in PSP - process(task) stack pointer */
       stmdb  r0!, {r4-r11}

       ldr    r3, =tn_curr_run_task
       mov    r1,  r3
       ldr    r1, [r1]
       str    r0, [r1]                  /*  save own SP in TCB */

       ldr    r1, =tn_next_task_to_run
       ldr    r2, [r1]
       str    r2, [r3]                  /*  in r3 - =tn_curr_run_task */

       ldr    r0, [r2]                  /*  in r0 - new task SP */

       ldmia  r0!, {r4-r11}
       msr    psp, r0
       orr    lr, lr, #0x04             /*  Force to new process PSP */

  /* -------------------------------------- */

exit_context_switch:

       cpsie  I                         /*  enable core int */

       bx     lr

/* ------------------------------------------------------------------------ */
  .thumb_func

tn_switch_context:

     /* - set the context switch request  */

       ldr    r0, =tn_context_switch_request
       mov    r1, #1
       str    r1, [r0]

     /* -  Just Invoke PendSV exception   */

       ldr    r1, =ICSR_ADDR
       ldr    r0, =PENDSVSET
       str    r0, [r1]

       bx     lr

/* ------------------------------------------------------------------------ */
  .thumb_func

tn_int_exit:

       ldr    r1, =ICSR_ADDR            /*  Invoke PendSV exception  */
       ldr    r0, =PENDSVSET
       str    r0, [r1]

       bx     lr

/* ------------------------------------------------------------------------ */
  .thumb_func

tn_cpu_save_sr:

       mrs    r0, primask
       cpsid  I
       bx     lr

/* ------------------------------------------------------------------------ */
  .thumb_func

tn_cpu_restore_sr:

       msr    primask, r0
       bx     lr

/* ------------------------------------------------------------------------ */
  .thumb_func

tn_chk_irq_disabled:

       mrs    r0, primask
       bx     lr

/* ------------------------------------------------------------------------ */
  .thumb_func

ffs_asm:

       mov    r1, r0                    /*  tmp = in  */
       rsbs   r0, r1, #0                /*  in = -in  */
       ands   r0, r0, r1                /*  in = in & tmp  */
       CLZ.W  r0, r0
       rsb    r0, r0, #0x20             /*  32 - in */
       bx     lr

/* ------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------ */


  .end
