# Download data to WD and unzip

  dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(dataset_url, "data.zip")
  unzip("data.zip")

# Load test data of 9 subjects into dataframes

  testY<- read.table("./UCI HAR Dataset/test/y_test.txt") # labels of activity
  testX<- read.table("./UCI HAR Dataset/test/X_test.txt") # measurements of each feature
  test_sub<- read.table("./UCI HAR Dataset/test/subject_test.txt")
  
# Load train data of 21 subjects into dataframe

  trainY<- read.table("./UCI HAR Dataset/train/y_train.txt")
  trainX<- read.table("./UCI HAR Dataset/train/X_train.txt")
  train_sub<- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Combine datasets to create one with 30 subjects. 
    
  test_df <- cbind(test_sub, testY, testX) # bind all three test datasets
  train_df <- cbind(train_sub, trainY, trainX) # bind all three train datasets
  
  
  df <- rbind(train_df,test_df) # append train & test datasets vertically
  library(plyr); df_order <- arrange(df, df[,1])  # order all rows by subject ID
  
# 2. Extract measurements on the mean and std for each measurement.
  
# if error occurs naming df, then make sure the object storing the variable
# labels is `chr` and not `factor`

# First the variables need to have descriptive names. Import the names as
# a `chr vector`. 
  
  label <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = F)
  label <- label$V2
  names(df_order) [3:563] <- label
  names(df_order) [1:2] <- c("ID", "Activity")
  
# Extract columns with STD or mean. 
  
# Now that we have descriptive names we can partial match strings with 
# the words `mean` and `std` using `grep`. `grep` gives the colindex
# of partially matched strings. The dataframe is then subsetted by the
# resulting colindex object into a new df (df_extract). 
  
  condition <- grep("mean|std", colnames(df_order))
  df_extract <- df_order[,c(1:2, condition)] #col 1:2 are ID and Activity.

# 3. Use descriptive activity names to name the activities in the data set
  
  act <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors = F)
    
  df_extract <- within(df_extract, Activity <- factor(Activity, labels = act$V2))
  
# 5. From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable 
# for each activity and each subject.
  
  df_ag <- aggregate(. ~ID+Activity, df_extract, function(x) c(mean = mean(x)))

# Output of tidy averaged data as txt file and read back in.
  
  df_grade <- write.table(df_ag, file= "tidy_data.txt", row.name=FALSE)
  data <- read.table("tidy_data.txt", header = TRUE)