### Add family size to the table
train$family_size = train$SibSp + train$Parch + 1

### D-tree model for the data
titanic_tree = rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + family_size, data=train, method="class")
## Plot titanic_tree
fancyRpartPlot(titanic_tree)
# make a prediction based on the rpart decision tree
titanic_pred = predict(titanic_tree, test, type="class") 
# Create a data frame with two columns: PassengerId & Survived. Survived contains your predictions
titanic_dtree = data.frame(PassengerId = test$PassengerId, Survived = titanic_pred)
## Write out CSV
write.csv(titanic_dtree, "titanic_dtree.csv", row.names=FALSE)


### Random forest model
set.seed(111)
#Set Embarked to Southampton for those that are missing
all_data$Embarked[c(62, 830)] <- "S"
all_data$Embarked <- factor(all_data$Embarked)
## Set Fare to the median
all_data$Fare[1044] <- median(all_data$Fare, na.rm = TRUE)
## Repopulate missing ags based on ANOVA model for age
predicted_age <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title,
                       data = all_data[!is.na(all_data$Age),], method = "anova")
all_data$Age[is.na(all_data$Age)] <- predict(predicted_age, all_data[is.na(all_data$Age),])
# Split datasets again
train <- all_data[1:891,]
test <- all_data[892:1309,]
# Train random forest model
titanic_forest = randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Fare + Title, data=train, method="class", ntree = 2000, importance=TRUE)
# Predict on test data and write out
titanic_pred = predict(titanic_forest, test)
titanic_forest_csv = data.frame(PassengerId = test$PassengerId, Survived = titanic_pred)
write.csv(titanic_forest_csv, "forest_pred.csv", row.names=FALSE)


