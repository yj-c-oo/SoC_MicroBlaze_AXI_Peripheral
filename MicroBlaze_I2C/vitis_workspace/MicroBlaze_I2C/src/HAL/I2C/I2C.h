#ifndef SRC_HAL_I2C_I2C_H_
#define SRC_HAL_I2C_I2C_H_

#include "xparameters.h"
#include <stdint.h>
#include "xil_io.h"

#define I2C_BASE_ADDR  XPAR_I2C_0_S00_AXI_BASEADDR

#define I2C_REG_CTRL   0x00
#define I2C_REG_TX     0x04
#define I2C_REG_RX     0x08
#define I2C_REG_STATUS 0x0C

void I2C_Start(void);
void I2C_Stop(void);
void I2C_Write(uint8_t data);
uint8_t I2C_Read(uint8_t ack_nack);
uint8_t I2C_IsBusy(void);
uint8_t I2C_IsDone(void);
uint8_t I2C_GetAck(void);
#endif /* SRC_HAL_I2C_I2C_H_ */
