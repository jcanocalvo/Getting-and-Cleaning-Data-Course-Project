##Installing packages:
install.packages("data.table")
library(data.table)
install.packages("plyr")
library(plyr)

##Setting working directory:
setwd("~/Desktop/Coursera/3- Getting and cleaning data")

##Downloading the zip:
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- file.path(getwd(), "Dataset.zip")
download.file(url, f)
unzip(zipfile="./Dataset.zip",exdir="./Data")
file<- file.path("./Data" , "UCI HAR Dataset")


##Reading Train and Test data:
subjectTrain<- read.table("Data/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
xTrain<- read.table("Data/UCI HAR Dataset/train/X_train.txt", header=FALSE)
yTrain<- read.table("Data/UCI HAR Dataset/train/y_train.txt", header=FALSE)

subjectTest<- read.table("Data/UCI HAR Dataset/test/subject_test.txt", header=FALSE)
xTest<- read.table("Data/UCI HAR Dataset/test/X_test.txt", header=FALSE)
yTest<- read.table("Data/UCI HAR Dataset/test/y_test.txt", header=FALSE)


#1. Merges the training and the test sets to create one data set.

##Concatenate the data tables by rows:
dataSubject<- rbind(subjectTrain, subjectTest)
dataActivity<- rbind(yTrain, yTest)
dataFeatures<- rbind(xTrain, xTest)

##Set names to variables:

names(dataSubject)<- c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames<- read.table(file.path(file, "features.txt"), head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

##Merge columns to get the dataSet for all data:
dataMerged<- cbind(dataSubject, dataActivity)
dataSet<- cbind(dataFeatures, dataMerged)


#2. Extracts only the measurements on the mean and standard deviation for each measurement.
##Subset Name of Features by measurements on the mean and standard deviation:
dataMeanStd<- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

##Subset the dataSet by seleted names of Features:
dataSubAct<- c(as.character(dataMeanStd), "subject", "activity" )
dataSet<- subset(dataSet, select=dataSubAct)


#3. Uses descriptive activity names to name the activities in the data set

activityLabels<- read.table(file.path(file, "activity_labels.txt"),header = FALSE)
dataSet$activity<- factor (dataSet$activity);
dataSet$activity<- factor(dataSet$activity, labels=as.character(activityLabels$V2))


#4. Appropriately labels the data set with descriptive variable names.

names(dataSet)<- gsub("^t", "time", names(dataSet))
names(dataSet)<- gsub("^f", "frequency", names(dataSet))
names(dataSet)<- gsub("Acc", "Accelerometer", names(dataSet))
names(dataSet)<- gsub("Gyro", "Gyroscope", names(dataSet))
names(dataSet)<- gsub("Mag", "Magnitude", names(dataSet))
names(dataSet)<- gsub("BodyBody", "Body", names(dataSet))


#5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

tidyData<- aggregate(. ~subject + activity, dataSet, mean)
tidyData<- tidyData[order(tidyData$subject, tidyData$activity),]

##txt file: 
write.table(tidyData, file = "tidydata.txt", row.name=FALSE)
