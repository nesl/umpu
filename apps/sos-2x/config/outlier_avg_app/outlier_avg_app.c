#include <sos.h>


//! forward declaration
//mod_header_ptr loader_get_header();
mod_header_ptr outlier_detection_get_header();
//mod_header_ptr phototemp_sensor_get_header();

void sos_start(void){
  //  ker_register_module(loader_get_header());
  //  ker_register_module(phototemp_sensor_get_header());
  ker_register_module(outlier_detection_get_header());
  return;
}

