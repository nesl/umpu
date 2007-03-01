analysis = function(fileName,bitNumber){

  # Constants for detecting the initial pattern 
  STEP1 = 255
  STEP2 = 0
  EVENT = 1
  
  # Read the data from the file
  file_data = read.table(fileName,sep = "\t",header = TRUE)

  # List of variables used in this function
  time_stamp = 0
  value = 0
  monitor = 0
  start_point = 0
  nevents = 0
  events_list = 0
  avg = 0

  # Assigning values to the variables
  time_stamp = file_data[,1]
  value = file_data[,2]
  # Selecting the bit from the value
  monitor = (value %/% (2 ^ bitNumber)) %% 2

  # Detecting the initial pattern
  for(i in 2:length(value)) {
    if(value[i - 1] == STEP1 & value[i] == STEP2) {
      start_point = i + 1
      break;
    }
  }
  
  # Constructing events_list
  # events_list contains the time period that an event stays high
  for(i in start_point:(length(monitor) - 1)) {
    if(monitor[i] == EVENT) {
      events_list[nevents + 1] = time_stamp[i+1] - time_stamp[i]
      nevents = nevents + 1
    }
  }

  # returning the events_list
  events_list
}
