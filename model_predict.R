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
## place ages in bins
all_data$Age_group = cut(all_data$Age, 
                         breaks = c(-Inf, 18, 25, 30, 35, 40, 45, 50, 55, Inf), 
                         labels = c("Child", "18-25", "26-30", "31-35", "36-40", "41-45", "46-50", "51-55", "55+"), 
                         right=FALSE)

#scrub cabin numbers
all_data$Cabin = gsub('[[:digit:]]+', '', all_data$Cabin)
all_data$Cabin = gsub(' ', '', all_data$Cabin)
all_data$Cabin = gsub('([[:alpha:]])\\1+', '\\1', all_data$Cabin)
all_data$Cabin = gsub('FG', '', all_data$Cabin)
all_data$Cabin = gsub('FE', '', all_data$Cabin)
all_data$Cabin = gsub('T', '', all_data$Cabin)

## Predict cabin floor
predicted_cabin = rpart(Cabin ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title,
                        data = all_data[all_data$Cabin != "",], method = "class")
cabin = predict(predicted_cabin, all_data[all_data$Cabin == "",], type="class")
all_data[all_data$Cabin == "",]$Cabin = as.factor(unlist(sapply(cabin, as.character)))
all_data$Cabin = as.factor(all_data$Cabin)

# Split datasets again
train <- all_data[1:891,]
test <- all_data[892:1309,]
# Train random forest model
titanic_forest = randomForest(as.factor(Survived) ~ Pclass + Sex + Cabin + Age_group + SibSp + Fare + Title, data=train, method="class", ntree = 100, importance=TRUE)
# Predict on test data and write out
titanic_pred = predict(titanic_forest, test)
# varImpPlot(titanic_forest)

titanic_forest_csv = data.frame(PassengerId = test$PassengerId, Survived = titanic_pred)
write.csv(titanic_forest_csv, "forest_pred2.csv", row.names=FALSE)


