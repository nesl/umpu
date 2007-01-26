
#include <sos.h>
/**
 * Must also include the header file that defines the 
 * blink_get_header()
 */

mod_header_ptr blink_get_header();

/**
 * application start
 * This function is called once at the end od SOS initialization
 */
void sos_start(void)
{
ker_register_module(blink_get_header());
}
