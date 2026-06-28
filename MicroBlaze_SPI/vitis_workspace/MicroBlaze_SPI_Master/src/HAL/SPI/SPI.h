/*
 * SPI.h
 *
 *  Created on: 2026. 5. 6.
 *      Author: kccistc
 */

// --- HAL/SPI/SPI.h ---
#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_

#include "xparameters.h"
#include <stdint.h>
#include "xil_io.h"

#define SPI_BASE_ADDR  XPAR_SPI_0_S00_AXI_BASEADDR
#define XPAR_SPI_0_S00_AXI_BASEADDR 0x44A00000

#define SPI_REG_CTRL   0x00
#define SPI_REG_TX     0x04
#define SPI_REG_RX     0x08
#define SPI_REG_STATUS 0x0C

void SPI_Init(uint8_t clk_div, uint8_t cpol, uint8_t cpha);
void SPI_Send(uint8_t data);
uint8_t SPI_ReadRx(void);
uint8_t SPI_IsBusy(void);
uint8_t SPI_IsDone(void);

#endif
