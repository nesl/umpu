#include <sos.h>

//! forward declaration
mod_header_ptr buf_writer_get_header();

void sos_start(void){
  ker_register_module(buf_writer_get_header());
}

