#include <inttypes.h>
#include "hardware.h"

typedef struct {
    uint16_t shiftReg;
    uint16_t initSeed;
    uint16_t mask;
} RandomState;

static RandomState randomst;
extern uint16_t node_address;

void sp_rand_init()
{
    HAS_CRITICAL_SECTION;
    ENTER_CRITICAL_SECTION();
    randomst.shiftReg = (uint16_t)(119 * 119 * (node_address + 1));
    randomst.initSeed = randomst.shiftReg;
    randomst.mask = (uint16_t)(137 * 29 * (node_address + 1));
    LEAVE_CRITICAL_SECTION();
}

uint16_t sp_rand() 
{
    HAS_CRITICAL_SECTION;
    uint8_t endbit;
    uint16_t tmpShiftReg;

    ENTER_CRITICAL_SECTION();
    tmpShiftReg = randomst.shiftReg;
    LEAVE_CRITICAL_SECTION();
    endbit = ((tmpShiftReg & 0x8000) != 0)?1:0;
    tmpShiftReg <<= 1;
    if (endbit)
        tmpShiftReg ^= 0x100b;
    tmpShiftReg++;
    ENTER_CRITICAL_SECTION();
    randomst.shiftReg = tmpShiftReg;
    LEAVE_CRITICAL_SECTION();
    tmpShiftReg = tmpShiftReg ^ randomst.mask;
    return tmpShiftReg;
}
