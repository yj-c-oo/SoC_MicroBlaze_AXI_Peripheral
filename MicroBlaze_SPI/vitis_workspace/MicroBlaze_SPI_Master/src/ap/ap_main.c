// --- ap/ap_main.c ---
#include "ap_main.h"
#include "interrupt.h"      
#include "SpiApp/SpiApp.h"  

void ap_init() {
    SetupInterruptSystem();

    TMR0_Init(); 
    TMR1_Init(); 

    SpiApp_Init();
}

void ap_execute() {
    while (1) {
        SpiApp_Execute();
    }
}
