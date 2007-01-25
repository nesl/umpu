/**
 * \file sfi_jumptable.h
 * \brief Jump table implementation for SOS kernel in SFI mode
 * \author Ram Kumar {ram@ee.ucla.edu}
 */
#include <inttypes.h>
#include <codemem_conf.h> // For CODEMEM_END_PAGE
#include <sos_module_types.h>
#include <sos_linker_conf.h>
#ifdef MINIELF_LOADER
#include <codemem.h>
#endif
#ifndef _SFI_JUMPTABLE_H_
#define _SFI_JUMPTABLE_H_

/**
 * \addtogroup sfijumptable
 * <STRONG>SFI Jumptable Organization</STRONG> <BR>
 * Pages: (CODEMEM_END_PAGE + 1) - (CODEMEM_END_PAGE + 10) <BR>
 * Kernel: 2 pages <BR>
 * Modules: 7 pages <BR>
 * 1 extra page left at the end <BR>
 * SFI Jumptable contains instructions: jmp <addr> <BR>
 * Similar in design to the interrupt table <BR>
 * The SFI table for the kernel is created at compile time by a script <BR>
 * The SFI table for each module is created at load-time <BR>
 * @{
 */



/**
 * Configuration for SFI Jumptable
 */
// Ram - Modify the AVR Makerules to move .sfijmptbl to the page SFI_JUMP_TABLE_START
// Ram - Modify create_sfijumptable.py if the order of tables is shuffled
enum sfi_jumptable_config_t
  {
    SFI_JUMP_TABLE_START = (CODEMEM_END_PAGE + 1),   //! First page of SFI Table
    SFI_JUMP_TABLE_END   = (CODEMEM_END_PAGE + 10),  //! Last page of SFI Table
    SFI_KER_TABLE_0 = SFI_JUMP_TABLE_START,      
    SFI_KER_TABLE_1,
    SFI_DOM0_TABLE, 
    SFI_DOM1_TABLE,
    SFI_DOM2_TABLE,
    SFI_DOM3_TABLE,
    SFI_DOM4_TABLE,
    SFI_DOM5_TABLE,
    SFI_DOM6_TABLE,
    SFI_PAD_TABLE, //!< Page for padding: Makes SFI table end on an odd page
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


#endif// _SFI_JUMPTABLE_H_
