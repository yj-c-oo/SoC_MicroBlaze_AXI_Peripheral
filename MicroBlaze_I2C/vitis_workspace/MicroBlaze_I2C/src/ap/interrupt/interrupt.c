#include "interrupt.h"

XIntc IntrController;

void TMR1_ISR(void *CallbackRef)
{
    FND_DispDigit(); 
}

void TMR0_Init()
{
    TMR_SetPSC(TMR0, 100-1);
    TMR_SetARR(TMR0, 0xffffffff);
    TMR_StartIntr(TMR0);
    TMR_StartTimer(TMR0);
}

void TMR1_Init()
{
    // 10khz -> 0.1ms
    TMR_SetPSC(TMR1, 100-1);
    TMR_SetARR(TMR1, 1000-1);
    TMR_StartIntr(TMR1);
    TMR_StartTimer(TMR1);
}

int SetupInterruptSystem()
{
    int status;

    // 1. initialize interrupt controller
    status = XIntc_Initialize(&IntrController, INTC_DEV_ID);
    if(status != XST_SUCCESS){
        return XST_FAILURE;
    }

    // 2. connect TMR1_ISR function with Intc
    status = XIntc_Connect(&IntrController, TMR1_VEC_ID, (XInterruptHandler)TMR1_ISR, (void *)0);
    if(status != XST_SUCCESS){
        return XST_FAILURE;
    }

    // 3. start interrupt controller (HW MODE)
    status = XIntc_Start(&IntrController, XIN_REAL_MODE);
    if(status != XST_SUCCESS){
        return XST_FAILURE;
    }

    // 4. activate each interrupt channel
    XIntc_Enable(&IntrController, TMR1_VEC_ID);

    // 5. Initialize and activate Exception of MicroBlaze
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XIntc_InterruptHandler, &IntrController);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
