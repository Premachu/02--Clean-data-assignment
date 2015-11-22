Cleaning and tidying data demonstration: Samsung data
==========

Data collected from the *Human Activity Recognition Using Smartphones Data Set* to give a demonstration on cleaning, combining and outputting tidy datasets following the principles of Hadley Wickham's *Tidy Data Paper*

The data comprises of 30 subjects who have carried out six activities while wearing a Samsung Smart Phone on the waist. Measurements of accelerometers from the Samsung Galaxy S smartphone were recorded.
The participants was randomly split, where 30% generated the training dataset and 70% generated the test dataset. 

The point of this script is to:

1. Combine the the train and test datasets into a single dataset
2. Extract measurements from the `mean` and `std` set of features.
3. Average the extracted features for each activity of each subject
4. Descriptively label the dataset
5. Following the principles of Hadley Wickham's *Tidy data paper*, Output a single tidy dataset combining the results of the previous steps

This is public data from https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones. [1]


License:
========

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.

## Processing.


To download data.zip and extract it into the working directory.

    dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(dataset_url, "data.zip")
    unzip("data.zip")

The dataset contains two main folders of importance for this cleaning data demonstration. `train` and `test`, each of which contain variables on participants that have conducted six activities while wearing a Samsung Galaxy smartphone.  

Load the following txt files and combine them combine as two seperate datasets (`test_df` and `train_df`) using the `cbind()` function :

* train
    * train/X_train.txt': Training set.
    * train/y_train.txt': Training labels. 
    * train/subject_train.txt'
* test
    * test/X_test.txt': Test set.
    * test/y_test.txt': Test labels.
    * train/subject_test.txt'
    
  Load test data of 9 subjects into dataframes
  
    testY<- read.table("./UCI HAR Dataset/test/y_test.txt") # labels of activity
    testX<- read.table("./UCI HAR Dataset/test/X_test.txt") # measurements of each feature
    test_sub<- read.table("./UCI HAR Dataset/test/subject_test.txt")
    
  Load train data of 21 subjects into dataframe
  
    trainY<- read.table("./UCI HAR Dataset/train/y_train.txt")
    trainX<- read.table("./UCI HAR Dataset/train/X_train.txt")
    train_sub<- read.table("./UCI HAR Dataset/train/subject_train.txt")


    test_df <- cbind(test_sub, testY, testX) # bind all three test datasets
    train_df <- cbind(train_sub, trainY, trainX) # bind all three train datasets

Now both the train and test datasets will be combined into a single dataset of 30 participants. 
  
    df <- rbind(train_df,test_df) # append train & test datasets vertically
    library(plyr); df_order <- arrange(df, df[,1])  # order all rows by ID

Now there is a single dataset, it is time to extract `std` and `mean` features. 

First, the variables need to be descriptively labeled using the `features.txt` file and `names()` function.
  
    label <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = F)
    label <- label$V2
    names(df_order) [3:563] <- label
    names(df_order) [1:2] <- c("ID", "Activity")
    
Now that we have descriptive names we can partial match strings with 
the words `mean` and `std` using `grep`. `grep` gives the colindex
of partially matched strings. The dataframe is then subsetted by the
resulting colindex object into a new df (df_extract).

    condition <- grep("mean|std", colnames(df_order))
    df_extract <- df_order[,c(1:2, condition)] #col 1:2 are ID and Activity.
    
The data is looking a lot better, but it would be more useful if the activities had descriptive names rather than numbers. Read in the `activity_labels.txt` as factors and name the dataframe using the `within()` function.

    act <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors = F)
      
    df_extract <- within(df_extract, Activity <- factor(Activity, labels = act$V2))
  
Now that the data is clean and tidy, we will summarise it by taking the average of each feature for each activity of each subject.

      df_ag <- aggregate(. ~ID+Activity, df_extract, function(x) c(mean = mean(x)))

As a final step the final tidy data frame will be saved as txt.file (`tidy_data.txt`), so that it is in the same format as the original data from which it is derived
A code is also supplied to read back-in the text file. 

    df_grade <- write.table(df_ag, file= "tidy_data.txt", row.name=FALSE)
    data <- read.table("tidy_data.txt", header = TRUE)