### Library
library(rpart)
library(RColorBrewer)
library(rpart.plot)
library(rattle)
library(randomForest)

### Initialize all the datasets

train = read.csv('./data/train.csv')
test = read.csv('./data/test.csv')
