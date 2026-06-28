#include "I2CApp.h"

hBtn_t hBtnStart;

void I2CApp_Init(void) {
    FND_Init();
    Button_Init(&hBtnStart, GPIOA, GPIO_PIN_4);
    GPIO_SetMode(GPIOA, GPIO_PIN_5 | GPIO_PIN_6, OUTPUT);
    GPIO_SetMode(GPIOC, 0xFF, INPUT);
    FND_SetNum(0); 
}

void I2CApp_Execute(void) {
    if (Button_GetState(&hBtnStart) == ACT_PUSHED) {

        uint8_t tx_data = GPIO_ReadPort(GPIOC);
        uint8_t slave_addr = 0x50;
        uint8_t write_addr = slave_addr << 1;       // 0xA0
        uint8_t read_addr  = (slave_addr << 1) | 1; // 0xA1

        GPIO_WritePin(GPIOA, GPIO_PIN_6, SET); // Busy LED ON
        GPIO_WritePin(GPIOA, GPIO_PIN_5, RESET);

        I2C_Start();
        I2C_Write(write_addr);

        if (I2C_GetAck() == 1) {
            I2C_Stop();
            GPIO_WritePin(GPIOA, GPIO_PIN_6, RESET); 
            return; 
        }

        I2C_Write(tx_data);
        I2C_Stop();

        delay_ms(5); 

        I2C_Start();
        I2C_Write(read_addr);

        if (I2C_GetAck() == 1) {
            I2C_Stop();
            GPIO_WritePin(GPIOA, GPIO_PIN_6, RESET);
            return;
        }

        uint8_t rx_data = I2C_Read(1);
        I2C_Stop();

        FND_SetNum(rx_data);

        GPIO_WritePin(GPIOA, GPIO_PIN_6, RESET); // Busy OFF
        GPIO_WritePin(GPIOA, GPIO_PIN_5, SET);   // Done ON
    }
}
