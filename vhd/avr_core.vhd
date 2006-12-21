--************************************************************************************************
--  Top entity for AVR core
--  Version 1.11
--  Designed by Ruslan Lepetenok 
--  Modified 03.11.2002
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

entity avr_core
is port
     (
       -- panic signal
       panic : out std_logic;

       cp2     : in std_logic;
       ireset  : in std_logic;
       cpuwait : in std_logic;

-- PROGRAM MEMORY PORTS
       pc   : out std_logic_vector (15 downto 0);  -- CORE OUTPUT    !CHECKED!
       inst : in  std_logic_vector (15 downto 0);  -- CORE INPUT     !CHECKED!

-- I/O REGISTERS PORTS
       adr  : out std_logic_vector (5 downto 0);  -- CORE OUTPUT  ????
       iore : out std_logic;                      -- CORE OUTPUT  !CHECKED!
       iowe : out std_logic;                      -- CORE OUTPUT  !CHECKED!

-- DATA MEMORY PORTS
       ramadr : out std_logic_vector (15 downto 0);
       ramre  : out std_logic;
       ramwe  : out std_logic;

       dbusin  : in  std_logic_vector (7 downto 0);
       dbusout : out std_logic_vector (7 downto 0);

-- INTERRUPTS PORT
       irqlines : in  std_logic_vector (22 downto 0);
       irqack   : out std_logic;
       irqackad : out std_logic_vector(4 downto 0)

       );

end avr_core;

architecture struct of avr_core is

  component safe_stack
    port (
      -- General signals
      ireset : in std_logic;
      clock  : in std_logic;

      -- Bus signals
      adr     : in std_logic_vector(5 downto 0);
      reg_bus : in std_logic_vector(7 downto 0);
      ram_bus : in std_logic_vector(7 downto 0);
      iowe    : in std_logic;

      -- Output the local register
      ssph_out : out std_logic_vector(7 downto 0);
      sspl_out : out std_logic_vector(7 downto 0);

      -- Signals from mmc
      mmc_status_reg : in std_logic_vector(7 downto 0);

      -- signals for the ram_busArbiter
      ss_addr     : out std_logic_vector(15 downto 0);
      ss_addr_sel : out std_logic;
      ss_dbusout     : out  std_logic_vector(7 downto 0);
      ss_dbusout_sel : out  std_logic;

      -- Signals from pm_fetch_decoder
      fet_dec_pc : in std_logic_vector(15 downto 0);
      fet_dec_ssp_retL_wr       : in  std_logic;
      fet_dec_ssp_retH_wr       : in  std_logic;
      fet_dec_ssp_retL_rd       : in  std_logic;
      fet_dec_ssp_retH_rd       : in  std_logic;
      fet_dec_call_dom_change   : in  std_logic_vector(4 downto 0);
      fet_dec_ret_dom_change    : in  std_logic_vector(4 downto 0);
      fet_dec_write_ram_data    : in  std_logic_vector(7 downto 0);
      fet_dec_ssp_ret_dom_start : out std_logic;

      -- Signals from Domain Tracker
      dt_update_dom_id : in std_logic;

      -- ssp-MMC to update the dom id and send the stack_bound
      ssp_new_dom_id    : out std_logic_vector(2 downto 0);
      ssp_update_dom_id : out std_logic;
      ssp_stack_bound : out std_logic_vector(15 downto 0);

      -- Signal from io_reg_file
      stack_pointer_low : in std_logic_vector(7 downto 0);
      stack_pointer_high : in std_logic_vector(7 downto 0)
      );

  end component;

  component domain_tracker
    port (
      -- General signals
      ireset : in std_logic;
      clock  : in std_logic;

      -- Bus signals
      adr     : in std_logic_vector(5 downto 0);
      reg_bus : in std_logic_vector(7 downto 0);
      iowe    : in std_logic;

      -- pc from pm_fetch_decoder
      fet_dec_pc         : in std_logic_vector(15 downto 0);
      -- indication of call insrt from pm_fetch_decoder
      fet_dec_call_instr : in std_logic;

      -- send the local registers to io_adr_dec so SW can read
      jmp_table_high_out : out std_logic_vector(7 downto 0);
      jmp_table_low_out  : out std_logic_vector(7 downto 0);

      -- calculated domain id to mmc
      mmc_new_dom_id     : out std_logic_vector(2 downto 0);
      -- signal to update domain id to mmc
      mmc_update_dom_id  : out std_logic;
      --Trusted domain signal from MMC
      mmc_trusted_domain : in  std_logic
      );

  end component;

  component ram_busArbiter
    port (
      -- Output to the ram
      ram_wr_en       : out std_logic;
      ram_rd_en       : out std_logic;
      ram_addr        : out std_logic_vector(15 downto 0);
      ram_dbusout     : out std_logic_vector(7 downto 0);
      -- Input from the pm_fetch_module for ram
      fet_dec_rd_en   : in  std_logic;
      fet_dec_wr_en   : in  std_logic;
      fet_dec_addr    : in  std_logic_vector(15 downto 0);
      fet_dec_dbusout : in  std_logic_vector(7 downto 0);
      -- Input from the mmc for ram
      mmc_rd_en       : in  std_logic;
      mmc_wr_en       : in  std_logic;
      mmc_addr        : in  std_logic_vector(15 downto 0);
      mmc_dbusout     : in  std_logic_vector(7 downto 0);
      -- Input from mmc for read and write cycles
      mmc_read_cycle  : in  std_logic;
      mmc_write_cycle : in  std_logic;
      -- Input from safe stack
      ss_addr         : in  std_logic_vector(15 downto 0);
      ss_addr_sel     : in  std_logic;
      ss_dbusout      : in  std_logic_vector(7 downto 0);
      ss_dbusout_sel  : in  std_logic
      );

  end component;

  component mmc
    port (
      -- General Signals
      ireset : in std_logic;
      clock  : in std_logic;

      -- MMC-Bus arbiter interface
      mmc_addr        : out std_logic_vector(15 downto 0);  -- R/W addr
      mmc_wr_en       : out std_logic;                      -- Write enable
      mmc_rd_en       : out std_logic;                      -- Read enable
      mmc_dbusout     : out std_logic_vector(7 downto 0);
      mmc_read_cycle  : out std_logic;
      mmc_write_cycle : out std_logic;

      -- MMC-pm_fetch_decoder interface
      fet_dec_pc_stop    : out std_logic;  -- Stop increment of pc
      fet_dec_nop_insert : out std_logic;  -- Insert nop in the processor     
      fet_dec_str_addr   : in  std_logic_vector(15 downto 0);  -- str addr
      fet_dec_run_mmc    : in  std_logic;
      fet_dec_data       : in  std_logic_vector(7 downto 0);

      -- MMC-io_adr_dec interface to allow local registers to be read in SW
      mem_map_pointer_low_out  : out std_logic_vector(7 downto 0);
      mem_map_pointer_high_out : out std_logic_vector(7 downto 0);
      mem_prot_bottom_low_out  : out std_logic_vector(7 downto 0);
      mem_prot_bottom_high_out : out std_logic_vector(7 downto 0);
      mem_prot_top_low_out     : out std_logic_vector(7 downto 0);
      mem_prot_top_high_out    : out std_logic_vector(7 downto 0);
      mmc_status_reg_out       : out std_logic_vector(7 downto 0);

      -- MMC-io_reg_file interface to get the stack pointer
      stack_pointer_low  : in std_logic_vector(7 downto 0);
      stack_pointer_high : in std_logic_vector(7 downto 0);

      -- MMC-domain_tracker interface to update the domain id
      dt_new_dom_id     : in  std_logic_vector(2 downto 0);
      dt_update_dom_id  : in  std_logic;
      dt_trusted_domain : out std_logic;

      -- MMC-avr_core interface to allow local registers to be written in SW and
      -- receive the data when performing a ram read
      adr     : in std_logic_vector(5 downto 0);
      reg_bus : in std_logic_vector(7 downto 0);
      ram_bus : in std_logic_vector(7 downto 0);
      iowe    : in std_logic;

      -- MMC-ssp interface to update the dom id on a ret and receive the stack
      -- bound
      ssp_new_dom_id : in std_logic_vector(2 downto 0);
      ssp_update_dom_id : in std_logic;
      ssp_stack_bound : in std_logic_vector(15 downto 0);

      -- Debug signals
      dbg_mmc_panic : out std_logic     -- panic signal
      );
  end component;

-- *****************************************************************************************
  component pm_fetch_dec
    is port (
      -- MMC specific signals
      fet_dec_pc_stop    : in  std_logic;
      fet_dec_nop_insert : in  std_logic;
      fet_dec_str_addr   : out std_logic_vector(15 downto 0);
      fet_dec_run_mmc    : out std_logic;
      fet_dec_data       : out std_logic_vector(7 downto 0);

      -- domain_tracker specific signals
      dt_pc         : out std_logic_vector(15 downto 0);
      dt_call_instr : out std_logic;

       -- safe stack specific signals
      fet_dec_pc : out std_logic_vector(15 downto 0);
      fet_dec_ssp_retL_wr : out std_logic;
      fet_dec_ssp_retH_wr : out std_logic;
      fet_dec_ssp_retH_rd : out std_logic;
      fet_dec_ssp_retL_rd : out std_logic;
      fet_dec_ssp_ret_dom_start : in std_logic;
      fet_dec_call_dom_change : out std_logic_vector(4 downto 0);
      fet_dec_ret_dom_change : out std_logic_vector(4 downto 0);

       -- Signal from Domain Tracker (Pause Fet Dec Unit)
       dt_update_dom_id     : in  std_logic;       

-- EXTERNAL INTERFACES OF THE CORE
      clk     : in std_logic;
      nrst    : in std_logic;
      cpuwait : in std_logic;

-- PROGRAM MEMORY PORTS
      pc   : out std_logic_vector (15 downto 0);  -- CORE OUTPUT       !CHECKED!
      inst : in  std_logic_vector (15 downto 0);  -- CORE INPUT     !CHECKED!

-- I/O REGISTERS PORTS
      adr  : out std_logic_vector (5 downto 0);  -- CORE OUTPUT  ????
      iore : out std_logic;                      -- CORE OUTPUT  !CHECKED!
      iowe : out std_logic;                      -- CORE OUTPUT  !CHECKED!

-- DATA MEMORY PORTS
      ramadr : out std_logic_vector (15 downto 0);
      ramre  : out std_logic;
      ramwe  : out std_logic;

      dbusin  : in  std_logic_vector (7 downto 0);
      dbusout : out std_logic_vector (7 downto 0);

-- INTERRUPTS PORT
      irqlines : in  std_logic_vector (22 downto 0);
      irqack   : out std_logic;
      irqackad : out std_logic_vector(4 downto 0);

-- END OF THE CORE INTERFACES


-- *********************************************************************************************
-- ******************** INTERFACES TO THE OTHER BLOCKS *****************************************
-- *********************************************************************************************


-- *********************************************************************************************
-- ******************** INTERFACES TO THE ALU *************************************************
-- *********************************************************************************************
      alu_data_r_in : out std_logic_vector(7 downto 0);
      alu_data_d_in : out std_logic_vector(7 downto 0);

-- OPERATION SIGNALS INPUTS
      idc_add_out  : out std_logic;
      idc_adc_out  : out std_logic;
      idc_adiw_out : out std_logic;
      idc_sub_out  : out std_logic;
      idc_subi_out : out std_logic;
      idc_sbc_out  : out std_logic;
      idc_sbci_out : out std_logic;
      idc_sbiw_out : out std_logic;

      adiw_st_out : out std_logic;
      sbiw_st_out : out std_logic;

      idc_and_out  : out std_logic;
      idc_andi_out : out std_logic;
      idc_or_out   : out std_logic;
      idc_ori_out  : out std_logic;
      idc_eor_out  : out std_logic;
      idc_com_out  : out std_logic;
      idc_neg_out  : out std_logic;

      idc_inc_out : out std_logic;
      idc_dec_out : out std_logic;

      idc_cp_out   : out std_logic;
      idc_cpc_out  : out std_logic;
      idc_cpi_out  : out std_logic;
      idc_cpse_out : out std_logic;

      idc_lsr_out  : out std_logic;
      idc_ror_out  : out std_logic;
      idc_asr_out  : out std_logic;
      idc_swap_out : out std_logic;


-- DATA OUTPUT
      alu_data_out : in std_logic_vector(7 downto 0);

-- FLAGS OUTPUT
      alu_c_flag_out : in std_logic;
      alu_z_flag_out : in std_logic;
      alu_n_flag_out : in std_logic;
      alu_v_flag_out : in std_logic;
      alu_s_flag_out : in std_logic;
      alu_h_flag_out : in std_logic;

-- *********************************************************************************************
-- ******************** INTERFACES TO THE GENERAL PURPOSE REGISTER FILE ************************
-- *********************************************************************************************
      reg_rd_in  : out std_logic_vector (7 downto 0);
      reg_rd_out : in  std_logic_vector (7 downto 0);
      reg_rd_adr : out std_logic_vector (4 downto 0);
      reg_rr_out : in  std_logic_vector (7 downto 0);
      reg_rr_adr : out std_logic_vector (4 downto 0);
      reg_rd_wr  : out std_logic;

      post_inc  : out std_logic;        -- POST INCREMENT FOR LD/ST INSTRUCTIONS
      pre_dec   : out std_logic;        -- PRE DECREMENT FOR LD/ST INSTRUCTIONS
      reg_h_wr  : out std_logic;
      reg_h_out : in  std_logic_vector (15 downto 0);
      reg_h_adr : out std_logic_vector (2 downto 0);  -- x,y,z
      reg_z_out : in  std_logic_vector (15 downto 0);  -- OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS

-- *********************************************************************************************
-- ******************** INTERFACES TO THE INPUT/OUTPUT REGISTER FILE ***************************
-- *********************************************************************************************
-- adr : out std_logic_vector(5 downto 0);
-- iowe : out std_logic;

-- dbusout : out std_logic_vector(7 downto 0);  -- OUTPUT OF THE CORE

      sreg_fl_in : out std_logic_vector(7 downto 0);  -- ????        
      sreg_out   : in  std_logic_vector(7 downto 0);  -- ????       

      sreg_fl_wr_en : out std_logic_vector(7 downto 0);  --FLAGS WRITE ENABLE SIGNALS       

      spl_out     : in  std_logic_vector(7 downto 0);
      sph_out     : in  std_logic_vector(7 downto 0);
      sp_ndown_up : out std_logic;      -- DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
      sp_en       : out std_logic;      -- WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS

      rampz_out : in std_logic_vector(7 downto 0);

-- *********************************************************************************************
-- ******************** INTERFACES TO THE INPUT/OUTPUT ADDRESS DECODER ************************
-- *********************************************************************************************

-- ram_data_in : in std_logic_vector (7 downto 0);
-- adr : in std_logic_vector(5 downto 0);
-- iore : in std_logic;                 -- CORE SIGNAL         
--          ramre        : in std_logic;  -- CORE SIGNAL         
--          dbusin       : out std_logic_vector(7 downto 0));  -- CORE SIGNAL                           

-- *********************************************************************************************
-- ******************** INTERFACES TO THE BIT PROCESSOR **************************************
-- *********************************************************************************************

      bit_num_r_io : out std_logic_vector (2 downto 0);  -- BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
--              dbusin          : in  std_logic_vector(7 downto 0);  -- SBI/CBI/SBIS/SBIC  IN
      bitpr_io_out : in  std_logic_vector(7 downto 0);  -- SBI/CBI OUT        

      branch : out std_logic_vector (2 downto 0);  -- NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION

      bit_pr_sreg_out : in std_logic_vector(7 downto 0);  -- BCLR/BSET/BST(T-FLAG ONLY)             

      sreg_bit_num : out std_logic_vector(2 downto 0);  -- BIT NUMBER FOR BCLR/BSET INSTRUCTIONS

      bld_op_out : in std_logic_vector(7 downto 0);  -- BLD OUT (T FLAG)

      bit_test_op_out : in std_logic;   -- OUTPUT OF SBIC/SBIS/SBRS/SBRC


-- OPERATION SIGNALS INPUTS

      -- INSTRUCTUIONS AND STATES

      idc_sbi_out : out std_logic;
      sbi_st_out  : out std_logic;
      idc_cbi_out : out std_logic;
      cbi_st_out  : out std_logic;

      idc_bld_out  : out std_logic;
      idc_bst_out  : out std_logic;
      idc_bset_out : out std_logic;
      idc_bclr_out : out std_logic;

      idc_sbic_out : out std_logic;
      idc_sbis_out : out std_logic;

      idc_sbrs_out : out std_logic;
      idc_sbrc_out : out std_logic;

      idc_brbs_out : out std_logic;
      idc_brbc_out : out std_logic;

      idc_reti_out : out std_logic

-- *********************************************************************************************
-- ******************** END OF INTERFACES TO THE OTHER BLOCKS *********************************
-- *********************************************************************************************


      );

  end component;


  component alu_avr is port(

    alu_data_r_in : in std_logic_vector(7 downto 0);
    alu_data_d_in : in std_logic_vector(7 downto 0);

    alu_c_flag_in : in std_logic;
    alu_z_flag_in : in std_logic;


-- OPERATION SIGNALS INPUTS
    idc_add  : in std_logic;
    idc_adc  : in std_logic;
    idc_adiw : in std_logic;
    idc_sub  : in std_logic;
    idc_subi : in std_logic;
    idc_sbc  : in std_logic;
    idc_sbci : in std_logic;
    idc_sbiw : in std_logic;

    adiw_st : in std_logic;
    sbiw_st : in std_logic;

    idc_and  : in std_logic;
    idc_andi : in std_logic;
    idc_or   : in std_logic;
    idc_ori  : in std_logic;
    idc_eor  : in std_logic;
    idc_com  : in std_logic;
    idc_neg  : in std_logic;

    idc_inc : in std_logic;
    idc_dec : in std_logic;

    idc_cp   : in std_logic;
    idc_cpc  : in std_logic;
    idc_cpi  : in std_logic;
    idc_cpse : in std_logic;

    idc_lsr  : in std_logic;
    idc_ror  : in std_logic;
    idc_asr  : in std_logic;
    idc_swap : in std_logic;


-- DATA OUTPUT
    alu_data_out : out std_logic_vector(7 downto 0);

-- FLAGS OUTPUT
    alu_c_flag_out : out std_logic;
    alu_z_flag_out : out std_logic;
    alu_n_flag_out : out std_logic;
    alu_v_flag_out : out std_logic;
    alu_s_flag_out : out std_logic;
    alu_h_flag_out : out std_logic
    );

  end component;


  component reg_file
    is
      -- generic(ResetRegFile : boolean);
      port (
        reg_rd_in  : in  std_logic_vector (7 downto 0);
        reg_rd_out : out std_logic_vector (7 downto 0);
        reg_rd_adr : in  std_logic_vector (4 downto 0);
        reg_rr_out : out std_logic_vector (7 downto 0);
        reg_rr_adr : in  std_logic_vector (4 downto 0);
        reg_rd_wr  : in  std_logic;

        post_inc  : in  std_logic;      -- POST INCREMENT FOR LD/ST INSTRUCTIONS
        pre_dec   : in  std_logic;      -- PRE DECREMENT FOR LD/ST INSTRUCTIONS
        reg_h_wr  : in  std_logic;
        reg_h_out : out std_logic_vector (15 downto 0);
        reg_h_adr : in  std_logic_vector (2 downto 0);  -- x,y,z
        reg_z_out : out std_logic_vector (15 downto 0);  -- OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS


        clk  : in std_logic;
        nrst : in std_logic

        );
  end component;

  component io_reg_file is port (
    clk  : in std_logic;
    nrst : in std_logic;

    adr     : in std_logic_vector(5 downto 0);
    iowe    : in std_logic;
    dbusout : in std_logic_vector(7 downto 0);

    sreg_fl_in : in  std_logic_vector(7 downto 0);
    sreg_out   : out std_logic_vector(7 downto 0);

    sreg_fl_wr_en : in std_logic_vector (7 downto 0);  --FLAGS WRITE ENABLE SIGNALS       

    spl_out     : out std_logic_vector(7 downto 0);
    sph_out     : out std_logic_vector(7 downto 0);
    sp_ndown_up : in  std_logic;        -- DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
    sp_en       : in  std_logic;        -- WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS

    rampz_out : out std_logic_vector(7 downto 0)

    );
  end component;


  component bit_processor is port(

    clk  : in std_logic;
    nrst : in std_logic;

    bit_num_r_io : in  std_logic_vector (2 downto 0);  -- BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
    dbusin       : in  std_logic_vector(7 downto 0);  -- SBI/CBI/SBIS/SBIC  IN
    bitpr_io_out : out std_logic_vector(7 downto 0);  -- SBI/CBI OUT        

    sreg_out : in std_logic_vector(7 downto 0);  -- BRBS/BRBC/BLD IN 
    branch   : in std_logic_vector (2 downto 0);  -- NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION


    bit_pr_sreg_out : out std_logic_vector(7 downto 0);  -- BCLR/BSET/BST(T-FLAG ONLY)             

    sreg_bit_num : in std_logic_vector(2 downto 0);  -- BIT NUMBER FOR BCLR/BSET INSTRUCTIONS

    bld_op_out : out std_logic_vector(7 downto 0);  -- BLD OUT (T FLAG)
    reg_rd_out : in  std_logic_vector(7 downto 0);  -- BST/SBRS/SBRC IN    

    bit_test_op_out : out std_logic;    -- OUTPUT OF SBIC/SBIS/SBRS/SBRC


-- OPERATION SIGNALS INPUTS

    -- INSTRUCTUIONS AND STATES

    idc_sbi : in std_logic;
    sbi_st  : in std_logic;
    idc_cbi : in std_logic;
    cbi_st  : in std_logic;

    idc_bld  : in std_logic;
    idc_bst  : in std_logic;
    idc_bset : in std_logic;
    idc_bclr : in std_logic;

    idc_sbic : in std_logic;
    idc_sbis : in std_logic;

    idc_sbrs : in std_logic;
    idc_sbrc : in std_logic;

    idc_brbs : in std_logic;
    idc_brbc : in std_logic;

    idc_reti : in std_logic

    );

  end component;

  component io_adr_dec is port (
    adr        : in  std_logic_vector(5 downto 0);
    iore       : in  std_logic;
    dbusin_ext : in  std_logic_vector(7 downto 0);
    dbusin_int : out std_logic_vector(7 downto 0);

    -- Registers from mmc.vhd
    mem_map_pointer_low_out  : in std_logic_vector(7 downto 0);
    mem_map_pointer_high_out : in std_logic_vector(7 downto 0);
    mem_prot_bottom_low_out  : in std_logic_vector(7 downto 0);
    mem_prot_bottom_high_out : in std_logic_vector(7 downto 0);
    mem_prot_top_low_out     : in std_logic_vector(7 downto 0);
    mem_prot_top_high_out    : in std_logic_vector(7 downto 0);
    mmc_status_reg_out       : in std_logic_vector(7 downto 0);
    jmp_table_low_out        : in std_logic_vector(7 downto 0);
    jmp_table_high_out       : in std_logic_vector(7 downto 0);
    ssph_out : in std_logic_vector(7 downto 0);
    sspl_out : in std_logic_vector(7 downto 0);
    -- End registers from mmc.vhd

    spl_out   : in std_logic_vector(7 downto 0);
    sph_out   : in std_logic_vector(7 downto 0);
    sreg_out  : in std_logic_vector(7 downto 0);
    rampz_out : in std_logic_vector(7 downto 0)
    );
  end component;



-- *****************************************************************************************


  signal sg_dbusin, sg_dbusout : std_logic_vector (7 downto 0) := (others => '0');
  signal sg_adr                : std_logic_vector (5 downto 0) := (others => '0');
  signal sg_iowe, sg_iore      : std_logic                     := '0';

-- SIGNALS FOR INSTRUCTION AND STATES

  signal sg_idc_add, sg_idc_adc, sg_idc_adiw, sg_idc_sub, sg_idc_subi, sg_idc_sbc, sg_idc_sbci, sg_idc_sbiw,
    sg_adiw_st, sg_sbiw_st, sg_idc_and, sg_idc_andi, sg_idc_or, sg_idc_ori, sg_idc_eor, sg_idc_com,
    sg_idc_neg, sg_idc_inc, sg_idc_dec, sg_idc_cp, sg_idc_cpc, sg_idc_cpi, sg_idc_cpse,
    sg_idc_lsr, sg_idc_ror, sg_idc_asr, sg_idc_swap, sg_idc_sbi, sg_sbi_st, sg_idc_cbi, sg_cbi_st,
    sg_idc_bld, sg_idc_bst, sg_idc_bset, sg_idc_bclr, sg_idc_sbic, sg_idc_sbis, sg_idc_sbrs, sg_idc_sbrc,
    sg_idc_brbs, sg_idc_brbc, sg_idc_reti : std_logic := '0';

  signal sg_alu_data_r_in, sg_alu_data_d_in, sg_alu_data_out : std_logic_vector(7 downto 0) := (others => '0');

  signal sg_reg_rd_in, sg_reg_rd_out, sg_reg_rr_out : std_logic_vector (7 downto 0)  := (others => '0');
  signal sg_reg_rd_adr, sg_reg_rr_adr               : std_logic_vector (4 downto 0)  := (others => '0');
  signal sg_reg_h_out, sg_reg_z_out                 : std_logic_vector (15 downto 0) := (others => '0');
  signal sg_reg_h_adr                               : std_logic_vector (2 downto 0)  := (others => '0');
  signal sg_reg_rd_wr, sg_post_inc,
    sg_pre_dec, sg_reg_h_wr                         : std_logic                      := '0';

  signal sg_sreg_fl_in, sg_sreg_out, sg_sreg_fl_wr_en,
    sg_spl_out, sg_sph_out, sg_rampz_out : std_logic_vector(7 downto 0) := (others => '0');

  signal sg_sp_ndown_up, sg_sp_en : std_logic := '0';


  signal sg_bit_num_r_io, sg_branch, sg_sreg_bit_num : std_logic_vector (2 downto 0) := (others => '0');
  signal sg_bitpr_io_out, sg_bit_pr_sreg_out, sg_sreg_flags,
    sg_bld_op_out, sg_reg_file_rd_in                 : std_logic_vector(7 downto 0)  := (others => '0');


  signal sg_bit_test_op_out : std_logic := '0';

  signal sg_alu_c_flag_out, sg_alu_z_flag_out, sg_alu_n_flag_out, sg_alu_v_flag_out,
    sg_alu_s_flag_out, sg_alu_h_flag_out : std_logic := '0';

  -- signals between pm_fetch_dec and ram_busArbiter
  signal sg_fet_dec_wr_en   : std_logic;
  signal sg_fet_dec_addr    : std_logic_vector(15 downto 0);
  signal sg_fet_dec_rd_en   : std_logic;
  signal sg_fet_dec_dbusout : std_logic_vector(7 downto 0);

  -- signals between mmc and ram_busArbiter
  signal sg_mmc_wr_en       : std_logic;
  signal sg_mmc_rd_en       : std_logic;
  signal sg_mmc_addr        : std_logic_vector(15 downto 0);
  signal sg_mmc_dbusout     : std_logic_vector(7 downto 0);
  signal sg_mmc_read_cycle  : std_logic;
  signal sg_mmc_write_cycle : std_logic;

  -- signals between mmc and io_adr_dec
  signal sg_mem_map_pointer_low_out  : std_logic_vector(7 downto 0);
  signal sg_mem_map_pointer_high_out : std_logic_vector(7 downto 0);
  signal sg_mem_prot_bottom_low_out  : std_logic_vector(7 downto 0);
  signal sg_mem_prot_bottom_high_out : std_logic_vector(7 downto 0);
  signal sg_mem_prot_top_low_out     : std_logic_vector(7 downto 0);
  signal sg_mem_prot_top_high_out    : std_logic_vector(7 downto 0);
  signal sg_mmc_status_reg_out       : std_logic_vector(7 downto 0);

  -- signals between mmc and pm_fetch_dec
  signal sg_fet_dec_str_addr   : std_logic_vector(15 downto 0);
  signal sg_fet_dec_run_mmc    : std_logic;
  signal sg_fet_dec_data       : std_logic_vector(7 downto 0);
  signal sg_fet_dec_pc_stop    : std_logic;
  signal sg_fet_dec_nop_insert : std_logic;

  -- signals between domain_tracker and pm_fetch_dec
  signal sg_dt_pc         : std_logic_vector(15 downto 0);
  signal sg_dt_call_instr : std_logic;

  -- signals between domain_tracker and mmc
  signal sg_new_dom_id     : std_logic_vector(2 downto 0);
  signal sg_update_dom_id  : std_logic;
  signal sg_trusted_domain : std_logic;

  -- signals between the domain_tracker and io_adr_dec
  signal sg_jmp_table_high_out : std_logic_vector(7 downto 0);
  signal sg_jmp_table_low_out  : std_logic_vector(7 downto 0);

  -- signals between safe_stack and ram_busArbiter
  signal sg_ss_addr : std_logic_vector(15 downto 0);
  signal sg_ss_addr_sel : std_logic;
  signal sg_ss_dbusout : std_logic_vector(7 downto 0);
  signal sg_ss_dbusout_sel : std_logic;

  -- signals between safe stack and pm_fetch_dec
  signal sg_fet_dec_pc : std_logic_vector(15 downto 0);
  signal sg_fet_dec_ssp_retL_wr : std_logic;
  signal sg_fet_dec_ssp_retH_wr : std_logic;
  signal sg_fet_dec_ssp_retL_rd : std_logic;
  signal sg_fet_dec_ssp_retH_rd : std_logic;
  signal sg_fet_dec_call_dom_change : std_logic_vector(4 downto 0);
  signal sg_fet_dec_ret_dom_change : std_logic_vector(4 downto 0);
  signal sg_fet_dec_ssp_ret_dom_start : std_logic;
  
  -- signals between safe stack and io_adr_dec
  signal sg_sspl_out : std_logic_vector(7 downto 0);
  signal sg_ssph_out : std_logic_vector(7 downto 0);

  -- signals between safe stack and MMC
  signal sg_ssp_new_dom_id : std_logic_vector(2 downto 0);
  signal sg_ssp_update_dom_id : std_logic;
  signal sg_ssp_stack_bound : std_logic_vector(15 downto 0);

begin

  SAFE_STK : component safe_stack port map(
    ireset => ireset,
    clock => cp2,

    adr => sg_adr,
    reg_bus => sg_dbusout,
    ram_bus => sg_dbusin,
    iowe => sg_iowe,

    ssph_out => sg_ssph_out,
    sspl_out => sg_sspl_out,

    mmc_status_reg => sg_mmc_status_reg_out,

    ss_addr => sg_ss_addr,
    ss_addr_sel => sg_ss_addr_sel,
    ss_dbusout => sg_ss_dbusout,
    ss_dbusout_sel => sg_ss_dbusout_sel,

    fet_dec_pc => sg_fet_dec_pc,
    fet_dec_ssp_retL_wr => sg_fet_dec_ssp_retL_wr,
    fet_dec_ssp_retH_wr =>  sg_fet_dec_ssp_retH_wr,  
    fet_dec_ssp_retL_rd   => sg_fet_dec_ssp_retL_rd,   
    fet_dec_ssp_retH_rd     => sg_fet_dec_ssp_retH_rd,  
    fet_dec_call_dom_change   => sg_fet_dec_call_dom_change,
    fet_dec_ret_dom_change    => sg_fet_dec_ret_dom_change,
    fet_dec_write_ram_data    => sg_fet_dec_data,
    fet_dec_ssp_ret_dom_start => sg_fet_dec_ssp_ret_dom_start,

    dt_update_dom_id => sg_update_dom_id,
    
    ssp_new_dom_id => sg_ssp_new_dom_id,
    ssp_update_dom_id => sg_ssp_update_dom_id,
    ssp_stack_bound => sg_ssp_stack_bound,

    stack_pointer_low => sg_spl_out,
    stack_pointer_high => sg_sph_out
    );
    

  DOMAIN_UPDATE : component domain_tracker port map(
    ireset => ireset,
    clock  => cp2,

    adr     => sg_adr,
    reg_bus => sg_dbusout,
    iowe    => sg_iowe,

    fet_dec_pc         => sg_dt_pc,
    fet_dec_call_instr => sg_dt_call_instr,

    jmp_table_low_out  => sg_jmp_table_low_out,
    jmp_table_high_out => sg_jmp_table_high_out,

    mmc_new_dom_id     => sg_new_dom_id,
    mmc_update_dom_id  => sg_update_dom_id,
    mmc_trusted_domain => sg_trusted_domain
    );

  ARBITER : component ram_busArbiter port map (
    ram_wr_en   => ramwe,
    ram_addr    => ramadr,
    ram_rd_en   => ramre,
    ram_dbusout => sg_dbusout,

    fet_dec_wr_en   => sg_fet_dec_wr_en,
    fet_dec_rd_en   => sg_fet_dec_rd_en,
    fet_dec_addr    => sg_fet_dec_addr,
    fet_dec_dbusout => sg_fet_dec_dbusout,

    mmc_wr_en       => sg_mmc_wr_en,
    mmc_rd_en       => sg_mmc_rd_en,
    mmc_addr        => sg_mmc_addr,
    mmc_dbusout     => sg_mmc_dbusout,
    mmc_write_cycle => sg_mmc_write_cycle,
    mmc_read_cycle  => sg_mmc_read_cycle,

    ss_addr => sg_ss_addr,
    ss_addr_sel => sg_ss_addr_sel,
    ss_dbusout => sg_ss_dbusout,
    ss_dbusout_sel => sg_ss_dbusout_sel
    );

  MEM_MAP_CHECK : component mmc port map(
    ireset => ireset,
    clock  => cp2,

    mmc_read_cycle  => sg_mmc_read_cycle,
    mmc_write_cycle => sg_mmc_write_cycle,
    mmc_addr        => sg_mmc_addr,
    mmc_wr_en       => sg_mmc_wr_en,
    mmc_rd_en       => sg_mmc_rd_en,
    mmc_dbusout     => sg_mmc_dbusout,

    fet_dec_pc_stop    => sg_fet_dec_pc_stop,
    fet_dec_nop_insert => sg_fet_dec_nop_insert,
    fet_dec_str_addr   => sg_fet_dec_str_addr,
    fet_dec_run_mmc    => sg_fet_dec_run_mmc,
    fet_dec_data       => sg_fet_dec_data,

    mem_map_pointer_low_out  => sg_mem_map_pointer_low_out,
    mem_map_pointer_high_out => sg_mem_map_pointer_high_out,
    mem_prot_bottom_low_out  => sg_mem_prot_bottom_low_out,
    mem_prot_bottom_high_out => sg_mem_prot_bottom_high_out,
    mem_prot_top_low_out     => sg_mem_prot_top_low_out,
    mem_prot_top_high_out    => sg_mem_prot_top_high_out,
    mmc_status_reg_out       => sg_mmc_status_reg_out,

    stack_pointer_low  => sg_spl_out,
    stack_pointer_high => sg_sph_out,

    dt_new_dom_id     => sg_new_dom_id,
    dt_update_dom_id  => sg_update_dom_id,
    dt_trusted_domain => sg_trusted_domain,

    adr     => sg_adr,
    reg_bus => sg_dbusout,
    ram_bus => sg_dbusin,
    iowe    => sg_iowe,

    ssp_new_dom_id => sg_ssp_new_dom_id,
    ssp_update_dom_id => sg_ssp_update_dom_id,
    ssp_stack_bound => sg_ssp_stack_bound,

    dbg_mmc_panic => panic
    );

  main : component pm_fetch_dec port map
    (
      -- MMC specific signals
      fet_dec_pc_stop    => sg_fet_dec_pc_stop,
      fet_dec_nop_insert => sg_fet_dec_nop_insert,
      fet_dec_str_addr   => sg_fet_dec_str_addr,
      fet_dec_run_mmc    => sg_fet_dec_run_mmc,
      fet_dec_data       => sg_fet_dec_data,

      -- domain_tracker specific signals
      dt_pc         => sg_dt_pc,
      dt_call_instr => sg_dt_call_instr,
      dt_update_dom_id => sg_update_dom_id,

      -- safe_stack specific signals
      fet_dec_pc => sg_fet_dec_pc,
       fet_dec_ssp_retL_wr => sg_fet_dec_ssp_retL_wr,
       fet_dec_ssp_retH_wr => sg_fet_dec_ssp_retH_wr,
       fet_dec_ssp_retH_rd => sg_fet_dec_ssp_retH_rd,
       fet_dec_ssp_retL_rd => sg_fet_dec_ssp_retL_rd,
       fet_dec_ssp_ret_dom_start => sg_fet_dec_ssp_ret_dom_start,
       fet_dec_call_dom_change => sg_fet_dec_call_dom_change,
       fet_dec_ret_dom_change => sg_fet_dec_ret_dom_change,


-- EXTERNAL INTERFACES OF THE CORE
      clk     => cp2,
      nrst    => ireset,
      cpuwait => cpuwait,

-- PROGRAM MEMORY PORTS
      pc   => pc,
      inst => inst,

-- I/O REGISTERS PORTS
      adr  => sg_adr,
      iore => sg_iore,
      iowe => sg_iowe,

-- DATA MEMORY PORTS
      -- THIS HAS BEEN EDITED TO COMMUNICATE THROUGH THE ARBITER
      ramadr => sg_fet_dec_addr,
      ramre  => sg_fet_dec_rd_en,
      ramwe  => sg_fet_dec_wr_en,

      dbusin  => sg_dbusin,
      dbusout => sg_fet_dec_dbusout,

-- INTERRUPTS PORT
      irqlines => irqlines,
      irqack   => irqack,
      irqackad => irqackad,

-- END OF THE CORE INTERFACES


-- *********************************************************************************************
-- ******************** INTERFACES TO THE OTHER BLOCKS *****************************************
-- *********************************************************************************************


-- *********************************************************************************************
-- ******************** INTERFACES TO THE ALU *************************************************
-- *********************************************************************************************
      alu_data_r_in => sg_alu_data_r_in,
      alu_data_d_in => sg_alu_data_d_in,

-- OPERATION SIGNALS INPUTS

      idc_add_out  => sg_idc_add,
      idc_adc_out  => sg_idc_adc,
      idc_adiw_out => sg_idc_adiw,
      idc_sub_out  => sg_idc_sub,
      idc_subi_out => sg_idc_subi,
      idc_sbc_out  => sg_idc_sbc,
      idc_sbci_out => sg_idc_sbci,
      idc_sbiw_out => sg_idc_sbiw,

      adiw_st_out => sg_adiw_st,
      sbiw_st_out => sg_sbiw_st,

      idc_and_out  => sg_idc_and,
      idc_andi_out => sg_idc_andi,
      idc_or_out   => sg_idc_or,
      idc_ori_out  => sg_idc_ori,
      idc_eor_out  => sg_idc_eor,
      idc_com_out  => sg_idc_com,
      idc_neg_out  => sg_idc_neg,

      idc_inc_out => sg_idc_inc,
      idc_dec_out => sg_idc_dec,

      idc_cp_out   => sg_idc_cp,
      idc_cpc_out  => sg_idc_cpc,
      idc_cpi_out  => sg_idc_cpi,
      idc_cpse_out => sg_idc_cpse,

      idc_lsr_out  => sg_idc_lsr,
      idc_ror_out  => sg_idc_ror,
      idc_asr_out  => sg_idc_asr,
      idc_swap_out => sg_idc_swap,


-- DATA OUTPUT
      alu_data_out => sg_alu_data_out,

-- FLAGS OUTPUT
      alu_c_flag_out => sg_alu_c_flag_out,
      alu_z_flag_out => sg_alu_z_flag_out,
      alu_n_flag_out => sg_alu_n_flag_out,
      alu_v_flag_out => sg_alu_v_flag_out,
      alu_s_flag_out => sg_alu_s_flag_out,
      alu_h_flag_out => sg_alu_h_flag_out,

-- *********************************************************************************************
-- ******************** INTERFACES TO THE GENERAL PURPOSE REGISTER FILE ************************
-- *********************************************************************************************
      reg_rd_in  => sg_reg_rd_in,
      reg_rd_out => sg_reg_rd_out,
      reg_rd_adr => sg_reg_rd_adr,
      reg_rr_out => sg_reg_rr_out,
      reg_rr_adr => sg_reg_rr_adr,
      reg_rd_wr  => sg_reg_rd_wr,

      post_inc  => sg_post_inc,
      pre_dec   => sg_pre_dec,
      reg_h_wr  => sg_reg_h_wr,
      reg_h_out => sg_reg_h_out,
      reg_h_adr => sg_reg_h_adr,
      reg_z_out => sg_reg_z_out,

-- *********************************************************************************************
-- ******************** INTERFACES TO THE INPUT/OUTPUT REGISTER FILE ***************************
-- *********************************************************************************************

      sreg_fl_in => sg_sreg_fl_in,      --??   
      sreg_out   => sg_sreg_out,

      sreg_fl_wr_en => sg_sreg_fl_wr_en,

      spl_out     => sg_spl_out,
      sph_out     => sg_sph_out,
      sp_ndown_up => sg_sp_ndown_up,
      sp_en       => sg_sp_en,

      rampz_out => sg_rampz_out,

-- *********************************************************************************************
-- ******************** INTERFACES TO THE INPUT/OUTPUT ADDRESS DECODER ************************
-- *********************************************************************************************

-- ram_data_in : in std_logic_vector (7 downto 0);
-- adr : in std_logic_vector(5 downto 0);
-- iore : in std_logic;                 -- CORE SIGNAL         
--          ramre        : in std_logic;  -- CORE SIGNAL         
--          dbusin       : out std_logic_vector(7 downto 0));  -- CORE SIGNAL                           

-- *********************************************************************************************
-- ******************** INTERFACES TO THE BIT PROCESSOR **************************************
-- *********************************************************************************************

      bit_num_r_io => sg_bit_num_r_io,
      bitpr_io_out => sg_bitpr_io_out,

      branch => sg_branch,

      bit_pr_sreg_out => sg_bit_pr_sreg_out,

      sreg_bit_num => sg_sreg_bit_num,

      bld_op_out => sg_bld_op_out,

      bit_test_op_out => sg_bit_test_op_out,


-- OPERATION SIGNALS INPUTS

      -- INSTRUCTUIONS AND STATES

      idc_sbi_out => sg_idc_sbi,
      sbi_st_out  => sg_sbi_st,
      idc_cbi_out => sg_idc_cbi,
      cbi_st_out  => sg_cbi_st,

      idc_bld_out  => sg_idc_bld,
      idc_bst_out  => sg_idc_bst,
      idc_bset_out => sg_idc_bset,
      idc_bclr_out => sg_idc_bclr,

      idc_sbic_out => sg_idc_sbic,
      idc_sbis_out => sg_idc_sbis,

      idc_sbrs_out => sg_idc_sbrs,
      idc_sbrc_out => sg_idc_sbrc,

      idc_brbs_out => sg_idc_brbs,
      idc_brbc_out => sg_idc_brbc,

      idc_reti_out => sg_idc_reti

      );




  general_purpose_register_file : component reg_file
    -- generic map(ResetRegFile => TRUE)
    port map (
      reg_rd_in  => sg_reg_rd_in,
      reg_rd_out => sg_reg_rd_out,
      reg_rd_adr => sg_reg_rd_adr,
      reg_rr_out => sg_reg_rr_out,
      reg_rr_adr => sg_reg_rr_adr,
      reg_rd_wr  => sg_reg_rd_wr,

      post_inc  => sg_post_inc,
      pre_dec   => sg_pre_dec,
      reg_h_wr  => sg_reg_h_wr,
      reg_h_out => sg_reg_h_out,
      reg_h_adr => sg_reg_h_adr,
      reg_z_out => sg_reg_z_out,

      clk  => cp2,
      nrst => ireset

      );


  bit_proc : component bit_processor port map(

    clk  => cp2,
    nrst => ireset,

    bit_num_r_io => sg_bit_num_r_io,
    dbusin       => sg_dbusin,
    bitpr_io_out => sg_bitpr_io_out,

    sreg_out => sg_sreg_out,
    branch   => sg_branch,

    bit_pr_sreg_out => sg_bit_pr_sreg_out,

    sreg_bit_num => sg_sreg_bit_num,

    bld_op_out => sg_bld_op_out,
    reg_rd_out => sg_reg_rd_out,

    bit_test_op_out => sg_bit_test_op_out,


-- OPERATION SIGNALS INPUTS

    -- INSTRUCTUIONS AND STATES

    idc_sbi => sg_idc_sbi,
    sbi_st  => sg_sbi_st,
    idc_cbi => sg_idc_cbi,
    cbi_st  => sg_cbi_st,

    idc_bld  => sg_idc_bld,
    idc_bst  => sg_idc_bst,
    idc_bset => sg_idc_bset,
    idc_bclr => sg_idc_bclr,

    idc_sbic => sg_idc_sbic,
    idc_sbis => sg_idc_sbis,

    idc_sbrs => sg_idc_sbrs,
    idc_sbrc => sg_idc_sbrc,

    idc_brbs => sg_idc_brbs,
    idc_brbc => sg_idc_brbc,

    idc_reti => sg_idc_reti
    );


  io_dec : component io_adr_dec port map (
    adr        => sg_adr,
    iore       => sg_iore,
    dbusin_int => sg_dbusin,            -- LOCAL DATA BUS OUTPUT
    dbusin_ext => dbusin,               -- EXTERNAL DATA BUS INPUT

    -- registers from mmc.vhd
    mem_map_pointer_low_out  => sg_mem_map_pointer_low_out,
    mem_map_pointer_high_out => sg_mem_map_pointer_high_out,
    mem_prot_bottom_low_out  => sg_mem_prot_bottom_low_out,
    mem_prot_bottom_high_out => sg_mem_prot_bottom_high_out,
    mem_prot_top_low_out     => sg_mem_prot_top_low_out,
    mem_prot_top_high_out    => sg_mem_prot_top_high_out,
    mmc_status_reg_out       => sg_mmc_status_reg_out,
    ssph_out => sg_ssph_out,
    sspl_out => sg_sspl_out,
    -- registers from domain_tracker
    jmp_table_low_out        => sg_jmp_table_low_out,
    jmp_table_high_out       => sg_jmp_table_high_out,

    spl_out   => sg_spl_out,
    sph_out   => sg_sph_out,
    sreg_out  => sg_sreg_out,
    rampz_out => sg_rampz_out
    );

  io_registers : component io_reg_file port map (
    clk  => cp2,
    nrst => ireset,

    adr     => sg_adr,
    iowe    => sg_iowe,
    dbusout => sg_dbusout,

    sreg_fl_in => sg_sreg_fl_in,
    sreg_out   => sg_sreg_out,

    sreg_fl_wr_en => sg_sreg_fl_wr_en,

    spl_out     => sg_spl_out,
    sph_out     => sg_sph_out,
    sp_ndown_up => sg_sp_ndown_up,
    sp_en       => sg_sp_en,

    rampz_out => sg_rampz_out
    );



  ALU : component alu_avr port map(

    alu_data_r_in => sg_alu_data_r_in,
    alu_data_d_in => sg_alu_data_d_in,

    alu_c_flag_in => sg_sreg_out(0),
    alu_z_flag_in => sg_sreg_out(1),


-- OPERATION SIGNALS INPUTS
    idc_add  => sg_idc_add,
    idc_adc  => sg_idc_adc,
    idc_adiw => sg_idc_adiw,
    idc_sub  => sg_idc_sub,
    idc_subi => sg_idc_subi,
    idc_sbc  => sg_idc_sbc,
    idc_sbci => sg_idc_sbci,
    idc_sbiw => sg_idc_sbiw,

    adiw_st => sg_adiw_st,
    sbiw_st => sg_sbiw_st,

    idc_and  => sg_idc_and,
    idc_andi => sg_idc_andi,
    idc_or   => sg_idc_or,
    idc_ori  => sg_idc_ori,
    idc_eor  => sg_idc_eor,
    idc_com  => sg_idc_com,
    idc_neg  => sg_idc_neg,

    idc_inc => sg_idc_inc,
    idc_dec => sg_idc_dec,

    idc_cp   => sg_idc_cp,
    idc_cpc  => sg_idc_cpc,
    idc_cpi  => sg_idc_cpi,
    idc_cpse => sg_idc_cpse,

    idc_lsr  => sg_idc_lsr,
    idc_ror  => sg_idc_ror,
    idc_asr  => sg_idc_asr,
    idc_swap => sg_idc_swap,


-- DATA OUTPUT
    alu_data_out => sg_alu_data_out,

-- FLAGS OUTPUT
    alu_c_flag_out => sg_alu_c_flag_out,
    alu_z_flag_out => sg_alu_z_flag_out,
    alu_n_flag_out => sg_alu_n_flag_out,
    alu_v_flag_out => sg_alu_v_flag_out,
    alu_s_flag_out => sg_alu_s_flag_out,
    alu_h_flag_out => sg_alu_h_flag_out
    );



  adr     <= sg_adr;
  iowe    <= sg_iowe;
  iore    <= sg_iore;
  dbusout <= sg_dbusout;

end struct;
