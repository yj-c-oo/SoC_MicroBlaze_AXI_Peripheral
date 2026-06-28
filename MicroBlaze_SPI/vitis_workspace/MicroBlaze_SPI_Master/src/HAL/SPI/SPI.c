/*
 * SPI.c
 *
 *  Created on: 2026. 5. 6.
 *      Author: kccistc
 */

// --- HAL/SPI/SPI.c ---
#include "SPI.h"

void SPI_Init(uint8_t clk_div, uint8_t cpol, uint8_t cpha) {
    uint32_t ctrl_val = (clk_div << 8) | (cpha << 1) | cpol;
    Xil_Out32(SPI_BASE_ADDR + SPI_REG_CTRL, ctrl_val);
}

void SPI_Send(uint8_t data) {
    Xil_Out32(SPI_BASE_ADDR + SPI_REG_TX, (1 << 8) | data);
    Xil_Out32(SPI_BASE_ADDR + SPI_REG_TX, data);
}

uint8_t SPI_ReadRx(void) {
    return (uint8_t)(Xil_In32(SPI_BASE_ADDR + SPI_REG_RX) & 0xFF);
}

uint8_t SPI_IsBusy(void) {
    return (uint8_t)(Xil_In32(SPI_BASE_ADDR + SPI_REG_STATUS) & 0x01); 
}

uint8_t SPI_IsDone(void) {
    return (uint8_t)((Xil_In32(SPI_BASE_ADDR + SPI_REG_STATUS) >> 1) & 0x01); 
}
