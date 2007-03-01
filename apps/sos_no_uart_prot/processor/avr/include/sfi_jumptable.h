/**
 * \file sfi_jumptable.h
 * \brief Jump table implementation for SOS kernel in SFI mode
 * \author Ram Kumar {ram@ee.ucla.edu}
 */
#include <inttypes.h>
#include <sos_module_types.h>
#include <sos_linker_conf.h>

#ifndef _SFI_JUMPTABLE_H_
#define _SFI_JUMPTABLE_H_



/**
 * Configuration for SFI Jumptable
 */

enum sfi_jumptable_config_t
  {
    SFI_JUMP_TABLE_START = 1,   //! First page of SFI Table
    SFI_JUMP_TABLE_END   = 8,  //! Last page of SFI Table
    SFI_DOM0_TABLE = SFI_JUMP_TABLE_START, 
    SFI_DOM1_TABLE,
    SFI_DOM2_TABLE,
    SFI_DOM3_TABLE,
    SFI_DOM4_TABLE,
    SFI_DOM5_TABLE,
    SFI_DOM6_TABLE,
    SFI_SYS_TABLE,      
  };

/**
 * Number of protection domains supported
 */
#define SFI_MOD_DOMAINS 7 // There are 7 module protection domains and a kernel protection domain


/**
 * Domain Identities
 */
enum sfi_domain_id_t
  {
    SFI_DOM0 = 0, //! Domain 0
    SFI_DOM1,     //! Domain 1
    SFI_DOM2,     //! Domain 2
    SFI_DOM3,     //! Domain 3
    SFI_DOM4,     //! Domain 4
    SFI_DOM5,     //! Domain 5
    SFI_DOM6,     //! Domain 6
  };

#define WORDS_PER_PAGE 128L
#define SIZE_OF_JMP_INSTR 2 // 2 word instruction

#define CONV_DOMAINID_TO_PAGENUM(x) (uint16_t)(SFI_DOM0_TABLE + (uint16_t)x)
#define CONV_DOMAINID_TO_ADDRESS(x) (uint32_t)((SFI_DOM0_TABLE + (uint32_t)x) * 256)
// x is domain id
#define SFI_MOD_TABLE_ENTRY_LOC(x, fnidx) (((uint16_t)(SFI_DOM0_TABLE + (uint16_t)x) * WORDS_PER_PAGE) + (SIZE_OF_JMP_INSTR * fnidx))


#ifndef _MODULE_
/**
 * Initialize the module jump table
 */
void sfi_modtable_init();

/**
 * Get the domain ID for a given module ID
 * \param pid Module ID
 * \return -1 if Module ID is not assigned domain
 */
int8_t sfi_get_domain_id(sos_pid_t pid);


/**
 * \brief Exception routine for SFI Jumptable violations
 */
void sfi_jmptbl_exception();


/**
 * \brief Exception routine displays error code of exception and halts system
 * \param errcode Error code indicates type of SFI exception
 */
void sfi_exception(uint8_t errcode);
#endif//_MODULE_


#endif// _SFI_JUMPTABLE_H_
