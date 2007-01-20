/* -*- Mode: C; tab-width:2 -*- */
/* ex: set ts=2 shiftwidth=2 softtabstop=2 cindent: */
#ifndef _PIN_MAP_H
#define _PIN_MAP_H

#include <pin_defs.h>
#include <pin_alt_func.h>


// LED assignments
ALIAS_IO_PIN( RED_LED, PINA2);
ALIAS_IO_PIN( GREEN_LED, PINA1);
ALIAS_IO_PIN( YELLOW_LED, PINA0);

void init_IO(void);

#endif //_PIN_MAP_H

