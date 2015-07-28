# author : Sonali Rahagude (srahagud@eng.ucsd.edu)
# Description: This module processes the raw files for features and labels:  places consecutive readings at window size distance and aligns them to the day stat.


align_features = function(inputFile, outputDir, winSize= 15) {
}

align_labels = function(inputDir, outputDir, winSize =15, names = NULL) {
	extract_labels_dir(inputDir,outputDir, winSize)
}

# splits annotation files in a directory by days, lines in the output file are separated by window size distance in time and are aligned to the day start.
# column names should be identifier,StartDateTime,EndDateTime,PA1 (posture labels)  
extract_labels_dir = function(inputDir, outputDir, winSize, names = NULL) {
  files = list.files(inputDir)

  for (i in 1:length(files)) {
    # start reading record file
    print(inputDir)
    print(files[i])
    file_full_path = paste0(inputDir, "/",files[i])
    if(file.info(file_full_path)$isdir) {
      next
    }

    bouts = read.csv(file.path(inputDir, files[i]), header=TRUE, stringsAsFactors=FALSE)
    output_file = file.path(outputDir, file_path_sans_ext(files[i]))

    # extract data format from the header of the annotation files
    date_fmt = get_date_format(str_trim(bouts[1, ]$StartDateTime))
    
    r = 1
    label = "NULL"
    if(nrow(bouts) < 2)
      next
    boutstart = strptime(str_trim(bouts[r, ]$StartDateTime), date_fmt)
    boutstop = strptime(str_trim(bouts[r, ]$EndDateTime), date_fmt)
    timestamp = align_start(winSize, boutstart)
    
    day = timestamp$mday
    out = file.path(output_file, paste0(strftime(timestamp, "%Y-%m-%d"), ".csv"))
    #cat(strftime(timestamp, "%Y-%m-%d"), '\n')
    if (!file.exists(output_file)) {
      dir.create(output_file, recursive=TRUE)
    }
    if (file.exists(out)) {
      file.remove(out)
    }
    cat("timestamp,behavior\n", file=out, append=TRUE)
    
    while (TRUE) {
      if ((timestamp >= boutstart) & (timestamp + winSize < boutstop)) {
        # keep adding label until the window is within the bout
        label = sub(" ", "", str_trim(bouts[r, c("behavior")]))
      }
      # move on to the next bout
      else if (timestamp + winSize >= boutstop) {        
        if (r == nrow(bouts)) {
          break
        }
        # the next bout might be smaller than the window itself
        while (timestamp + winSize >= boutstop) {
          if (r == nrow(bouts)) {
            break
          }
          r = r + 1
          boutstart = strptime(str_trim(bouts[r, ]$StartDateTime), date_fmt)
          boutstop = strptime(str_trim(bouts[r, ]$EndDateTime), date_fmt)
        }
        if (timestamp >= boutstart) {
          # the window is within this bout - add the label
          label = sub(" ", "", str_trim(bouts[r, c("behavior")]))
        }
      }
      cat(strftime(timestamp, "%Y-%m-%d %H:%M:%S,"), file=out, append=TRUE)
      cat(label, file=out, append=TRUE)
      cat("\n", file=out, append=TRUE)
      
      label = "NULL"
      timestamp = as.POSIXlt(timestamp + winSize)     
      # if it is a new day, create a new file for that date and start appending in the new file
      if (timestamp$mday != day) {
        day = timestamp$mday
        out = file.path(output_file, paste0(strftime(timestamp, "%Y-%m-%d"), ".csv"))
        if (file.exists(out)) {
          file.remove(out)
        }
        cat("timestamp,behavior\n", file=out, append=TRUE)
      }
    }
  }
}


# Returns the date format of the date string passed 
get_date_format = function(input_string) {
  dF1 = "%Y-%m-%d %H:%M:%S"
  dF2 = "%m/%d/%Y %H:%M:%S"
  if (!is.na(strptime(str_trim(input_string), dF1))) {
    return(dF1)
    }
  if (!is.na(strptime(str_trim(input_string), dF2))) {
    return(dF2)
  }
  return(NULL)
}

# Returns a start time that is aligned to the start of the day, i.e. 00:00:00 with respect to the window size.
# so the function will return start times that are multiples of window size.
align_start = function(win_size, start) {
  d0 = trunc(start, "days")
  s = as.numeric(difftime(start, d0, units="secs"))
  w = ceiling(s / win_size)
  newStart = as.POSIXlt(d0 + w * win_size)
  return(newStart)
}


