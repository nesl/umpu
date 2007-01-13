# Script for compiling a safe version of AVR
# To use this script: Set current directory in Modelsim to memprothw/branch/mmc_v2/sim
# At Modelsim command prompt: source avrsafe.tcl
#
# Individual procedures can be called afterwards by simply typing out their name as commands to modelsim
#

echo ------------------------------------------------
echo CREATE WORK LIBRARY
echo ------------------------------------------------
vlib work


echo ------------------------------------------------
echo MAP WORK LIBRARY
echo ------------------------------------------------
vmap work ./work


echo ------------------------------------------------
echo COMPILING VHDL FILES OF DESIGN
echo ------------------------------------------------
vcom ../vhd/AVRuCPackage.vhd ../vhd/CPUWaitGenerator.vhd ../vhd/DataRAM.vhd ../vhd/PROM.vhd \
../vhd/RAM.vhd ../vhd/RAMDataReg.vhd ../vhd/Service_Module.vhd ../vhd/Timer_Counter.vhd \
../vhd/alu_avr.vhd ../vhd/avr_core.vhd ../vhd/bit_processor.vhd ../vhd/domain_tracker.vhd \
../vhd/external_mux.vhd ../vhd/io_adr_dec.vhd ../vhd/io_reg_file.vhd \
../vhd/mem_map_addr_calc.vhd ../vhd/mem_map_error_calc.vhd ../vhd/mmc.vhd \
../vhd/pm_fetch_dec.vhd ../vhd/porta.vhd ../vhd/portb.vhd ../vhd/programLoader.vhd \
../vhd/programToLoad.vhd ../vhd/ram_busArbiter.vhd ../vhd/reg_file.vhd \
../vhd/safe_stack.vhd ../vhd/shifter.vhd ../vhd/simple_timer.vhd \
../vhd/tb_programLoader.vhd ../vhd/top_avr_core_sim.vhd ../vhd/uart.vhd \
../vhd/dom_bnd_filler.vhd ../vhd/umpu_panic.vhd ../vhd/shifter_mux.vhd


echo -----------------------------------------------------
echo SIMULATIING DESIGN
echo -----------------------------------------------------
vsim tb_programLoader


echo -----------------------------------------------------
echo ADDING SIGNALS TO WAVE
echo -----------------------------------------------------
echo --- Adding Clock
add wave -hex -label clock sim:/tb_programloader/programloader1/TOP_AVR/cp2
echo --- Adding Panic Signal
add wave -hex -label PANIC sim:/tb_programloader/programloader1/TOP_AVR/panic

proc fet_dec_intr {} {
    echo -- Adding signals to wave
    add wave -label irqlines sim:/tb_programloader/programloader1/TOP_AVR/testing_core/main/irqlines
    add wave -label irqack sim:/tb_programloader/programloader1/TOP_AVR/testing_core/main/irqack
    add wave -label irqackad sim:/tb_programloader/programloader1/TOP_AVR/testing_core/main/irqackad
    add wave -label irq_start sim:/tb_programloader/programloader1/TOP_AVR/testing_core/main/irq_start
    add wave -label sreg_out sim:/tb_programloader/programloader1/TOP_AVR/testing_core/main/sreg_out
}

proc mmc_status_reg {} {
    add wave -divider MMC_STATUS_AND_RELATED
    add wave -hex -label mmc_status_reg sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_status_reg
    add wave -hex -label umpu_en sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_status_reg(0)
    add wave -hex -label record_size sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_status_reg(1)
    add wave -hex -label dom_id sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_status_reg(4:2)
    add wave -hex -label block_size sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_status_reg(7:5)
}    

proc stack_bound {} {
    add wave -divider STACK_BOUND
    add wave -hex -label stack_bound sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/stack_bound
    add wave -hex -label cross_dom_call_in_progress sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/cross_dom_call_in_progress
    add wave -hex -label fet_dec_retH_wr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_retH_wr
    add wave -hex -label ret_dom_change sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ret_dom_change
    add wave -hex -label ram_bus sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ram_bus
}    

proc ssp {} {
    add wave -divider SSP_AND_RELATED
    add wave -hex -label ssp sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ssp
    add wave -hex -label ssp_int sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ssp_int
    add wave -hex -label ssp_inc sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ssp_incremented
    add wave -hex -label ssp_dec sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ssp_decremented

    add wave -hex -label ss_addr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ss_addr
    add wave -hex -label ss_addr_sel sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ss_addr_sel
    add wave -hex -label ss_dbusout sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ss_dbusout
    add wave -hex -label ss_dbusout_sel sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ss_dbusout_sel
}

proc cross_dom_ret {} {
    echo -- Analyzing Cross Domain Return
    echo -- Adding ssp signals
    mmc_status_reg
    ssp
    stack_bound
    echo -- Adding signals to wave
    add wave -divider CROSS_DOMAIN_RETURN

    add wave -hex -label clock sim:/tb_programloader/programloader1/TOP_AVR/cp2
    add wave -hex -label Panic sim:/tb_programloader/tbpanic

    add wave -hex -label PC sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/pc

    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/nret_st0
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/idc_ret
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_st1
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_st2
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_dom_change_0
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_dom_change_1
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_dom_change_2
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_dom_change_3
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_dom_change_4
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ret_st3

    add wave -hex -label fet_dec_retL_rd sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_retL_rd
    add wave -hex -label fet_dec_retH_rd sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_retH_rd
    add wave -hex -label fet_dec_ret_dom_change sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_ret_dom_change
    add wave -hex -label fet_dec_ret_dom_start sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_ret_dom_start
    add wave -hex -label ret_addr_rd sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ret_addr_rd
    add wave -hex -label ret_dom_change sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ret_dom_change
    add wave -hex -label ret_cmp sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ret_cmp
    add wave -hex -label ret_cmp_result sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ret_cmp_result
    add wave -hex -label cross_dom_ret_addr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/cross_dom_ret_addr
}


proc cross_dom_call {} {
    echo -- Analyzing Cross Domain Call
    echo -- Adding ssp signals
    mmc_status_reg
    ssp
    stack_bound
    echo -- Adding signals to wave
    add wave -divider CROSS_DOMAIN_CALL
    add wave -hex -label clock sim:/tb_programloader/programloader1/TOP_AVR/cp2
    add wave -hex -label Panic sim:/tb_programloader/tbpanic

    add wave -hex -label PC sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/pc
    add wave -hex -label stack_pointer sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/stack_pointer

    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/ncall_st0
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/idc_call
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_st1
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_dom_change_0
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_dom_change_1
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_dom_change_2
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_dom_change_3
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_dom_change_4
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_st2
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/main/call_st3

    add wave -hex -label fet_dec_retL_wr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_retL_wr
    add wave -hex -label fet_dec_retH_wr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_retH_wr
    add wave -hex -label fet_dec_call_dom_change sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/fet_dec_call_dom_change
    add wave -hex -label call_dom_change sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/call_dom_change
    add wave -hex -label ret_addr_wr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/ret_addr_wr
    add wave -hex -label cross_dom_ret_addr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/SAFE_STK/cross_dom_ret_addr
}

proc mmc_complete {} {
    echo -- Analyzing MMC
    
    echo -- Adding mmc_arbiter_interface signals
    mmc_arbiter_interface

    echo -- Adding mmc_fet_dec_interface signals
    mmc_fet_dec_interface

    echo -- Adding mmc_io_adr_interface signals
    mmc_io_adr_interface

    echo -- Adding mmc_io_reg_file_interface signals
    mmc_io_reg_file_interface

    echo -- Adding mmc_domain_tracker_interface signals
    mmc_dom_track_interface

    echo -- Adding mmc_ssp_interface signals
    mmc_ssp_interface
}

proc mmc_error {} {
    add wave -divider MMC-ERROR
    add wave -hex -label mem_map_error sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/mem_map_error
    add wave -hex -label err_stack_write sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/err_stack_write
    add wave -hex -label err_mem_prot_top sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/err_mem_prot_top
    add wave -hex -label err_mem_prot_bottom sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/err_mem_prot_bottom
    add wave -hex -label err_dom_id sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/err_dom_id
    add wave -hex -label stack_write sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/stack_write
    add wave -hex -label stack_bound_err sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/stack_bound_err
    add wave -hex -label fet_dec_str_addr sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/fet_dec_str_addr
    add wave -hex -label ssp_stack_bound sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_error_calc/ssp_stack_bound
}

proc test_bench {} {
    echo -- Analyzing the test bench
    echo -- Adding the test bench signals

    add wave -label PORT_A -hex sim:/tb_programloader/tbPorta
    add wave -label Proc_Addr -hex sim:/tb_programloader/tbProcAddress
    add wave -label Proc_Data -hex sim:/tb_programloader/tbProcData
    add wave -label Ram_Addr -hex sim:/tb_programloader/tbRamAddress
    add wave -label Ram_Data_Out -hex sim:/tb_programloader/tbRamDataOut
    add wave -label Ram_Data_In -hex sim:/tb_programloader/tbRamDataIn
    add wave -label Ram_Wr_En -hex sim:/tb_programloader/tbRamWrEn
}

proc mmc_arbiter_interface {} {
    echo -- Analyzing MMC
    echo -- Adding signals to wave
    add wave -divider MMC-BUS-ARBITER-INTERFACE
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_addr
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_wr_en
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_rd_en
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_dbusout
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_read_cycle
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_write_cycle
}

proc mmc_fet_dec_interface {} {
    echo -- Analyzing MMC
    echo -- Adding signals to wave
    add wave -divider MMC-MAIN-INTERFACE
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/fet_dec_pc_stop
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/fet_dec_nop_insert
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/fet_dec_str_addr
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/fet_dec_run_mmc
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/fet_dec_data
}

proc mmc_io_adr_interface {} {
    echo -- Analyzing MMC
    echo -- Adding signals to wave
    add wave -divide MMC-IO-ADR-INTERFACE
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mem_map_pointer_low_out
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mem_map_pointer_high_out
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mem_prot_bottom_low_out
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mem_prot_bottom_high_out
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mem_prot_top_low_out
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mem_prot_top_high_out
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/mmc_status_reg_out
}

proc mmc_io_reg_file_interface {} {
    echo -- Analyzing MMC
    echo -- Adding signals to wave
    add wave -divide MMC-IO-REG_FILE-INTERFACE
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/stack_pointer_low
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/stack_pointer_high
}

proc mmc_dom_track_interface {} {
    echo -- Analyzing MMC
    echo -- Adding signals to wave
    add wave -divide MMC-DOM-TRACKER-INTERFACE
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/dt_new_dom_id    
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/dt_update_dom_id
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/dt_trusted_domain 
}

proc mmc_ssp_interface {} {
    echo -- Analyzing MMC
    echo -- Adding signals to wave
    add wave -divide MMC-SSP-INTERFACE
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/ssp_new_dom_id
    add wave -hex sim:/tb_programloader/programloader1/TOP_AVR/TESTING_CORE/MEM_MAP_CHECK/ssp_update_dom_id
}

