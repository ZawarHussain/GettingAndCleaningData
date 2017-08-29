library(reshape2)

filename <- "UCI_data.zip"

# Downloading the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  

#unzip the dataset
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


# getting features from features.txt file
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# getting labels from activity_labels file
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])


# Extract only the data on mean and standard deviation
stdAmean <- grep(".*mean.*|.*std.*", features[,2])
stdAmean.names <- features[stdAmean,2]

#replacing all '-mean' with Mean
stdAmean.names = gsub('-mean', 'Mean', stdAmean.names)

#replacing all '-std' with Std
stdAmean.names = gsub('-std', 'Std', stdAmean.names)

#removing all () at the end
stdAmean.names <- gsub('[-()]', '', stdAmean.names)


# Loading the training and testing sets for std and mean only
trainingD <- read.table("UCI HAR Dataset/train/X_train.txt")[stdAmean]

trainingActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainingD <- cbind(trainingSubjects, trainingActivities, trainingD)

testingD <- read.table("UCI HAR Dataset/test/X_test.txt")[stdAmean]
testingActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testingSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testingD <- cbind(testingSubjects, testingActivities, testingD)

# merging datasets 
fullData <- rbind(trainingD, testingD)
#adding labels
colnames(fullData) <- c("subject", "activity", stdAmean.names)

#converting activities & subjects into factors
fullData$activity <- factor(fullData$activity, levels = activity_labels[,1], labels = activity_labels[,2])
fullData$subject <- as.factor(fullData$subject)

#finally fing mean for each activity and subject
fullData.melted <- melt(fullData, id = c("subject", "activity"))
fullData.mean <- dcast(fullData.melted, subject + activity ~ variable, mean)

write.table(fullData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
read.table("tidy.txt")