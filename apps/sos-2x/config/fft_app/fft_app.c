#include <sos.h>

//! forward declaration
mod_header_ptr fft_module_get_header();
mod_header_ptr test_fft_module_get_header();

void sos_start(void){
  ker_register_module(test_fft_module_get_header());
  ker_register_module(fft_module_get_header());

}

