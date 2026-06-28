#include "I2C.h"
#include "../../common/common.h"

uint8_t I2C_IsBusy(void) {
    return (uint8_t)(Xil_In32(I2C_BASE_ADDR + I2C_REG_STATUS) & 0x01);
}

uint8_t I2C_IsDone(void) {
    return (uint8_t)((Xil_In32(I2C_BASE_ADDR + I2C_REG_STATUS) >> 1) & 0x01);
}

uint8_t I2C_GetAck(void) {
    return (uint8_t)((Xil_In32(I2C_BASE_ADDR + I2C_REG_STATUS) >> 2) & 0x01);
}

void I2C_Start(void) {
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x01);
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x00);
    delay_us(50); 
}

void I2C_Stop(void) {
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x08);
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x00);
    delay_us(50); 
}

void I2C_Write(uint8_t data) {
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_TX, data);
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x02);
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x00);
    delay_us(300); 
}

uint8_t I2C_Read(uint8_t ack_nack) {
    uint32_t ctrl_val = 0x04 | ((ack_nack & 0x01) << 4);
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, ctrl_val);
    Xil_Out32(I2C_BASE_ADDR + I2C_REG_CTRL, 0x00);
    delay_us(300); 

    return (uint8_t)(Xil_In32(I2C_BASE_ADDR + I2C_REG_RX) & 0xFF);
}
