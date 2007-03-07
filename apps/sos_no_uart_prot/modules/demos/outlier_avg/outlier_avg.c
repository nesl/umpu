/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4 shiftwidth=4 softtabstop=4 cindent: */
/**
 * \file outlier_avg.c
 * \brief Compute the average after removing outliers
 */

#include <sys_module.h>
#include <led.h>
//#include <sensordrivers/mts310/include/mts3xxsb.h>
//#include <sensordrivers/mts310/include/mts310sb.h>

#include "outlier_avg.h"
#define MAX_SIZE 4
#define FLOAT_PRECISION 100L
#define TIMER_ID 1
#define TIMER_PERIOD 512L




typedef struct{
  sos_pid_t pid;
  uint8_t size, index;
  int32_t param_fraction;
  int32_t param_threshold;
  int32_t *readings;
  int32_t *ratings;
  uint16_t photo_data[MAX_SIZE];
} app_state_t;

int8_t outlier_detection_module(void *state, Message *msg);
static inline uint8_t distance(uint8_t size, int32_t* readings, int32_t* ratings, int32_t number_thresh, int32_t param_thresh);
static inline int32_t calc_avg(int32_t* readings, int32_t *ratings, uint8_t size);

static mod_header_t mod_header SOS_MODULE_HEADER = {
  .mod_id         = OUTLIER_DETECTION_PID,
  .state_size     = sizeof(app_state_t),
  .num_sub_func   = 0,
  .num_prov_func  = 0,
  .platform_type  = HW_TYPE,
  .processor_type = MCU_TYPE,  
  .code_id		  = ehtons(OUTLIER_DETECTION_PID),
  .module_handler = outlier_detection_module,
};

int8_t outlier_detection_module(void *state, Message *msg)
{
  app_state_t *s = (app_state_t*) state;
  
  switch (msg->type){
  case MSG_INIT:
	{
	  uint8_t i;
	  int32_t number_threshold, average;

	  s->pid = msg->did;
	  s->size = MAX_SIZE;
	  s->index = 0;
	  s->param_fraction = 40;
	  s->param_threshold = 100 * FLOAT_PRECISION;
	  s->readings = (int32_t*)sys_malloc(s->size*sizeof(int32_t));
	  s->ratings = (int32_t*)sys_malloc(s->size*sizeof(int32_t));
	  //	  sys_timer_start(TIMER_ID, TIMER_PERIOD, TIMER_REPEAT);
	  DEBUG("SOS OUTLIER: init.\n");


	  //	  MsgParam* param = (MsgParam*) (msg->data);
	  //	  uint16_t photo_data = param->word;
	  s->photo_data[0] = 1000;
	  s->photo_data[1] = 1001;
	  s->photo_data[2] =  200;
	  s->photo_data[3] = 1003;

	  for (i = 0; i < MAX_SIZE; i++)
		s->readings[s->index++] = s->photo_data[i] * FLOAT_PRECISION;

	  // Begin Evaluation
	  sys_led(LED_RED_TOGGLE);			
	  if (s->index == s->size) {
		number_threshold = s->size * ((1 * FLOAT_PRECISION) - s->param_fraction);
		DEBUG("SOS OUTLIER: Outlier called with args s:%d n:%d p:%d \n",
			  s->size, number_threshold, s->param_threshold);
		distance(s->size, s->readings, s->ratings, number_threshold, s->param_threshold);
		average = calc_avg(s->readings, s->ratings, s->size);
		s->index = 0;
		sys_led(LED_RED_TOGGLE);
		DEBUG("SOS OUTLIER: Finished a round.\n");
	  }
	  // End Evaluation


	  break;
	}

	/*
	  case MSG_TIMER_TIMEOUT:
	  {
	  sys_led(LED_GREEN_TOGGLE);
	  MsgParam *p = (MsgParam *)msg->data;
	  if (p->byte == TIMER_ID) {
	  if (sys_sensor_get_data(MTS310_PHOTO_SID) != SOS_OK) {
	  DEBUG("SOS OUTLIER: sensor busy.\n");
	  } 
	  }
	  return SOS_OK;
	  }
	  case MSG_DATA_READY:
	  {
	  
	  MsgParam* param = (MsgParam*) (msg->data);
	  uint16_t photo_data = param->word;
	  int32_t number_threshold, average;
	  s->readings[s->index++] = photo_data * FLOAT_PRECISION;
	  
	  if (s->index == s->size) {
	  number_threshold = s->size * ((1 * FLOAT_PRECISION) - s->param_fraction);
	  DEBUG("SOS OUTLIER: Outlier called with args s:%d n:%d p:%d \n",
	  s->size, number_threshold, s->param_threshold);
	  distance(s->size, s->readings, s->ratings, number_threshold, s->param_threshold);
	  average = calc_avg(s->readings, s->ratings, s->size);
	  s->index = 0;
	  sys_led(LED_RED_TOGGLE);
	  DEBUG("SOS OUTLIER: Finished a round.\n");
	  }
	  return SOS_OK;
	  }
	*/
	
  case MSG_FINAL:
	{
	  break;
	}

  default:
	return -EINVAL;
  }
  return SOS_OK;
}

//-------------------------------------------------------------
static inline uint8_t distance(uint8_t size, int32_t* readings, int32_t* ratings, int32_t number_thresh, int32_t param_thresh)
{
  int32_t count;
  int32_t distance[MAX_SIZE][MAX_SIZE];
  uint8_t i,j,terminate_flag;

  for (i=0;i<size;i++){
	ratings[i] = 0;
  }
	
  /* Calculates the Eucledian distance between measurements */
  for (i=0;i<size;i++){
	for (j=0;j<size;j++){
	  if (readings[i] > readings[j]) {
		distance[i][j] = readings[i] - readings[j];
	  } else {
		distance[i][j] = readings[j] - readings[i];
	  }
	}
  }
	
  /* Runs the algorithm */
  for (i=0;i<size;i++){
	j = 0;
	count = 0;
	terminate_flag = 1;
	
	while ((terminate_flag) & (j < size)){
	  if (distance[i][j] < param_thresh){
		count = count + 100;
	  }
	  j++;
	  if (count >= number_thresh){
		ratings[i] = 1 * FLOAT_PRECISION;
		terminate_flag = 0;
	  }
	}
  }

#ifdef PC_PLATFORM
  printf("outliers: ");
  for (i = 0; i < size; i++){
    printf("%d ", ratings[i]);
  }
  printf("\n");
#endif
  
  return 0;
}
//-------------------------------------------------------------
static int32_t calc_avg(int32_t* readings, int32_t *ratings, uint8_t size) 
{
  uint8_t i = 0, num = 0;
  int32_t sum = 0;
  int32_t avg = 0;
  
  for (; i < size; i++) {
	if (ratings[i] == (1*FLOAT_PRECISION)) {
	  sum += readings[i];
	  num++;
	}
  }
	
  if (num > 0) 
	avg = sum/num;

  DEBUG("Average: %d\n", (int)(avg/FLOAT_PRECISION));

  return avg;
}
//-------------------------------------------------------------
#ifndef _MODULE_
mod_header_ptr outlier_detection_get_header()
{
   return sos_get_header_address(mod_header);
}
#endif

