/*
 * SpiApp.c
 *
 *  Created on: 2026. 5. 6.
 *      Author: kccistc
 */
// --- ap/SpiApp/SpiApp.c ---
#include "SpiApp.h"

hBtn_t hBtnStart;

void SpiApp_Init(void) {
    FND_Init();

    Button_Init(&hBtnStart, GPIOA, GPIO_PIN_4);

    GPIO_SetMode(GPIOA, GPIO_PIN_5 | GPIO_PIN_6, OUTPUT);

    GPIO_SetMode(GPIOC, 0xFF, INPUT);

    SPI_Init(200, 0, 0);

    FND_SetNum(0);
}

void SpiApp_Execute(void) {

    if (Button_GetState(&hBtnStart) == ACT_PUSHED) {

        uint8_t tx_data = GPIO_ReadPort(GPIOC);

        GPIO_WritePin(GPIOA, GPIO_PIN_6, SET);
        GPIO_WritePin(GPIOA, GPIO_PIN_5, RESET);

        SPI_Send(tx_data);

        while(SPI_IsBusy());

        uint8_t rx_data = SPI_ReadRx();
        FND_SetNum(rx_data);

        GPIO_WritePin(GPIOA, GPIO_PIN_6, RESET);
        GPIO_WritePin(GPIOA, GPIO_PIN_5, SET);
    }
}
