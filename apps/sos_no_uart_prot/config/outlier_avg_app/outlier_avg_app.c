#include <sos.h>


//! forward declaration
mod_header_ptr outlier_detection_get_header();

void sos_start(void){
  ker_register_module(outlier_detection_get_header());
  return;
}

