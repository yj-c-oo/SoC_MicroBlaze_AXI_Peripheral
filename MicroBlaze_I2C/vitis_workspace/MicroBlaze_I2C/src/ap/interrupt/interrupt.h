#ifndef SRC_AP_INTERRUPT_INTERRUPT_H_
#define SRC_AP_INTERRUPT_INTERRUPT_H_

#include "xparameters.h"
#include "xintc.h"
#include "xil_exception.h"
#include "../../common/common.h"
#include "../../driver/FND/FND.h"
#include "../../HAL/TMR/TMR.h"

#define INTC_DEV_ID XPAR_INTC_0_DEVICE_ID
#define TMR1_VEC_ID XPAR_INTC_0_TMR_1_VEC_ID

void TMR1_ISR(void *CallbackRef);
int SetupInterruptSystem(void);
void TMR0_Init(void);
void TMR1_Init(void);

#endif /* SRC_AP_INTERRUPT_INTERRUPT_H_ */
