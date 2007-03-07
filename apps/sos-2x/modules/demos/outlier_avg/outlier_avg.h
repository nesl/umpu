/**
 * \file outlier_avg.h
 * \brief Constants for outlier average module
 * \author Ram Kumar {ram@ee.ucla.edu}
 */

#ifndef _OUTLIER_AVG_H_
#define _OUTLIER_AVG_H_

#define OUTLIER_DETECTION_PID APP_MOD_MIN_PID

#define OUTLIER_EWMA_MSG_START (MOD_MSG_START)

enum {
  MSG_AVERAGE = OUTLIER_EWMA_MSG_START,
  MSG_SENSOR_VALUE,
  MSG_OUTLIER_RATINGS,
};


#endif//_OUTLIER_AVG_H_
