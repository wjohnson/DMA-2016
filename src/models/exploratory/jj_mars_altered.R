source("src/utils/evaluation.R")
data <- readRDS("data/processed/internal_external.rds")

data <- data[, -grep("WRD_", colnames(data))]
data$sprofit <- scale(data$Profitability)
train <- subset(data, data$sourcesystem == 'train')

set.seed(1)
train_logic <- sample(1:nrow(train), nrow(train),replace=T)
train <- train[train_logic,]
test_n <- train[-train_logic,]
rm(data)
rm(train_logic)
gc(verbose=FALSE)

library(earth)
train <- subset(train, select = -c(Profitability, id, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))
test_n <- subset(test_n, select = -c(Profitability, id, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))
mars <- earth(y=train$sprofit, x=subset(train, select = -c(sprofit)))

pred <- predict(mars)
pred_test <- predict(mars, newdata = test_n)

RMSE(pred, train$sprofit)
RMSE(pred_test, test_n$sprofit)
