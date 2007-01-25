/**
 * \file umpu.h
 * \brief Software library to support UMPU AVR extensions
 * \author Ram Kumar {ram@ee.ucla.edu}
 * \author Akhilesh Singhania {akhi3030@gmail.com}
 */

#ifndef _UMPU_H_
#define _UMPU_H_

//--------------------------------------------------
// SPECIAL REGISTERS ADDRESS MAP
//--------------------------------------------------
#define MMBL _SFR_IO8(0x08)
#define MMBH _SFR_IO8(0x07)
#define MMTL _SFR_IO8(0x06)
#define MMTH _SFR_IO8(0x05)
#define MMPL _SFR_IO8(0x1D)
#define MMPH _SFR_IO8(0x1E)
#define MSR _SFR_IO8(0x04)
#define JTL _SFR_IO8(0x1C)
#define JTH _SFR_IO8(0x1F)
#define SSPL _SFR_IO8(0x03)
#define SSPH _SFR_IO8(0x02)
#define DBCTL _SFR_IO8(0x15)
#define DBDATA _SFR_IO8(0x12)
#define UMPU_PANIC _SFR_IO8(0x11)


//---------------------------------------------------
// MEMORY MAP STATUS REGISTER
//---------------------------------------------------
// Block Size Setup
#define SET_MSR_BLK_SIZE(size) {MSR &= 0x1F; MSR |= ((0x7 & LOG2BASE(size)) << 5);}
// Set Number of Domains
#define SET_MSR_DOMS_2() {MSR |= 0x02;}
#define SET_MSR_DOMS_8() {MSR &= ~0x02;}
// Enable MSR
#define MSR_ENABLE() {MSR |= 0x01;}
#define MSR_DISABLE() {MSR &= ~0x01;}
// Get Current Domain ID
#define GET_MSR_DOM_ID() ((MSR & 0x1E) >> 2)

//---------------------------------------------------
// DOMAIN BOUND SETUP IN PROM
// |UNUSED|DOMAIN ID (2:0)|UPPER OR LOWER BOUND|HIGH OR LOW BYTE BIT|UPDATE BIT|
//---------------------------------------------------
#define SET_DOM_UPBND(dom_id, addr) { \
    DBDATA = (uint8_t)addr; \
    DBCTL = ((dom_id & 0x7) << 3) | (1 << 2) | 1; \
    DBDATA = (uint8_t)(addr >> 8); \
    DBCTL = ((dom_id & 0x7) << 3) | (1 << 2) | (1 << 1) | 1; \
}
#define SET_DOM_LWBND(dom_id, addr) { \
    DBDATA = (uint8_t)addr; \
    DBCTL = ((dom_id & 0x7) << 3) | 1; \
    DBDATA = (uint8_t)(addr >> 8); \
    DBCTL = ((dom_id & 0x7) << 3) | (1 << 1) | 1; \
}




#endif//_UMPU_H_
