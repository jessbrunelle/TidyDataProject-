## Course Project Instructions:  
##You should create one R script called run_analysis.R that does the following. 
## (1)Merges the training and the test sets to create one data set.
## (2) Extracts only the measurements on the mean and standard deviation for each measurement. 
#3 (3)Uses descriptive activity names to name the activities in the data set
## (4) Appropriately labels the data set with descriptive variable names. 
## (5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Preliminary Steps
#download the files
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "projectdata.zip" )

##set working directory to projectdata folder 


## read both the training and test sets 
training = read.csv("UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
training[,562] = read.csv("UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training[,563] = read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

testing = read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing[,562] = read.csv("UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing[,563] = read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

activityLabels = read.csv("UCI HAR Dataset/activity_labels.txt", sep="", header=FALSE)

# Read all features and make the feature names make sense for R with some substitutions
features = read.csv("UCI HAR Dataset/features.txt", sep="", header=FALSE)
features[,2] = gsub('-mean', 'Mean', features[,2])
features[,2] = gsub('-std', 'Std', features[,2])
features[,2] = gsub('[-()]', '', features[,2])


# Merge training and test sets together
allData = rbind(training, testing)


# Get only the data on mean and std. dev.
preferredCols <- grep(".*Mean.*|.*Std.*", features[,2])
# First reduce the features table to what we want
features <- features[preferredCols,]
# Now add the last two columns (subject and activity)
preferredCols <- c(preferredCols, 562, 563)
# And remove the unwanted columns from allData
allData <- allData[,preferredCols]
# Add the column names (features) to allData
colnames(allData) <- c(features$V2, "Activity", "Subject")
colnames(allData) <- tolower(colnames(allData))

currentActivity = 1
for (currentActivityLabel in activityLabels$V2) {
  allData$activity <- gsub(currentActivity, currentActivityLabel, allData$activity)
  currentActivity <- currentActivity + 1
}

allData$activity <- as.factor(allData$activity)
allData$subject <- as.factor(allData$subject)

tidy = aggregate(allData, by=list(activity = allData$activity, subject=allData$subject), mean)
# Remove the subject and activity column, since a mean of those has no use
tidy[,90] = NULL
tidy[,89] = NULL
write.table(tidy, "tidy.txt", sep="\t")

