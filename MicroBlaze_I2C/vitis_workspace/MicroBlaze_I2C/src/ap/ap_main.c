#include "ap_main.h"
#include "interrupt/interrupt.h"
#include "I2CApp/I2CApp.h"

void ap_Init(void) {
    SetupInterruptSystem();

    TMR0_Init();
    TMR1_Init();

    I2CApp_Init();
}

void ap_Execute(void) {
    while(1) {
        I2CApp_Execute();
    }
}
