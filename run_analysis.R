library(data.table)
library(dplyr)
library(tidyr)

# Read the static/lookup data
#
activities <- fread("Dataset/activity_labels.txt")
features <- fread("Dataset/features.txt")

# Read the test data
#
x_test <- fread("Dataset/test/X_test.txt")
x_test$activity_id <- fread("Dataset/test/y_test.txt")
x_test$subject <- fread("Dataset/test/subject_test.txt")

# Read the train data
#
x_train <- fread("Dataset/train/X_train.txt")
x_train$activity_id <- fread("Dataset/train/y_train.txt")
x_train$subject <- fread("Dataset/train/subject_train.txt")

# Assign human readable column headings to all datasets
#
colNames <- c(features$V2,"activity_id","subject")
names(x_test) <- colNames
names(x_train) <- colNames
names(activities) <- c("activity_id","activity")

# Combine the training and test data sets
#
combined <- rbind(x_test,x_train)

# Join with activities to get the activity labels
#
# This pattern is not correct. Fix later
combined$activity <- factor(sapply(combined$activity_id,function(id) activities[id]$activity))

# Select the required columns
#
cols <- grep("^activity$|^subject$|mean\\(\\)|std\\(\\)",names(combined))
combined <- select(combined,cols)

# Convert the data to a tidy
#
tidy <- combined %>% gather(measurement,value,-subject,-activity)
tidy$measurement <- factor(tidy$measurement)

# Create the new dataset which is the average of the variables per
# activity and subject
#
summary <- summarise(group_by(tidy,subject,activity),average = mean(value))

# Write the summary to a file , 2 versions the tabkle version and the
# useful csv version
#
write.table(summary,"summary.txt",row.name=F)
write.csv(summary,"summary.csv",row.names = F)
