

# Install the data
zipURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!dir.exists(zipFile))
    download.file(zipURL, zipFile)

unzip(zipFile)

# Read the data
dataPath <- "UCI HAR Dataset"

trainSubject <- read.table(file.path(dataPath, "train", "subject_train.txt"))
trainValue <- read.table(file.path(dataPath, "train", "X_train.txt"))
trainLabel <- read.table(file.path(dataPath, "train", "y_train.txt"))

testSubject <- read.table(file.path(dataPath, "test", "subject_test.txt"))
testValue <- read.table(file.path(dataPath, "test", "X_test.txt"))
testLabel <- read.table(file.path(dataPath, "test", "y_test.txt"))

# Merge the training and testing data
humanActivity <- rbind(cbind(trainSubject, trainLabel, trainValue),
    cbind(testSubject, testLabel, testValue))

# Remove the single data tables after merging
rm(trainSubject, trainValue, trainLabel, testSubject, testValue, testLabel)

# Read the futures into a data table
features <- read.table(file.path(dataPath, "features.txt"))
colnames(features) <- c("FeatureId", "FeatureName")

# Update the column names of the humanActivity table
colnames(humanActivity) <- c("SubjectId", "ActivityLabel", features[, 2])

# Extract only the mean and standard deviation measurements
colsToTake <- grepl("SubjectId|ActivityLabel|mean|std", colnames(humanActivity))
humanActivity <- humanActivity[, colsToTake]

# Name the activities
activityLabels <- read.table(file.path(dataPath, "activity_labels.txt"))
colnames(activityLabels) <- c("ActivityId", "ActivityLabel")
humanActivity$ActivityLabel <- factor(humanActivity$ActivityLabel,
                                      levels = activityLabels[, 1],
                                      labels = activityLabels[, 2])

# Appropriately name the measurements
colnames(humanActivity) <- gsub("[\\(\\)-]", "", colnames(humanActivity))
colnames(humanActivity) <- gsub("mean", "Mean", colnames(humanActivity))
colnames(humanActivity) <- gsub("std", "StandardDeviation", colnames(humanActivity))
colnames(humanActivity) <- gsub("mad", "MadianAbsoluteDeviation", colnames(humanActivity))
colnames(humanActivity) <- gsub("^t", "TimeDomain", colnames(humanActivity))
colnames(humanActivity) <- gsub("^f", "FeatureDomain", colnames(humanActivity))
colnames(humanActivity) <- gsub("Acc", "Accelerometer", colnames(humanActivity))
colnames(humanActivity) <- gsub("Mag", "Magnitude", colnames(humanActivity))
colnames(humanActivity) <- gsub("Freq", "Frequency", colnames(humanActivity))
colnames(humanActivity) <- gsub("Gyro", "Gyroscope", colnames(humanActivity))

# Another tidy data set with the average of each variable for each activity and each subject.
humanActivityGrouped <- humanActivity %>% 
    group_by(SubjectId, ActivityLabel) %>%
    summarise_each(mean)

write.table(humanActivityGrouped, "tidy_result.txt", row.name = FALSE)
