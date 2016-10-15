# Random Forests ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(randomForest)
library(foreach)
library(doMC)
registerDoMC(cores = 8)

rf <- foreach(ntree=rep(100, 8), .combine=combine, .multicombine=TRUE,
              .packages='randomForest') %dopar% {
                randomForest(x=boot_train, 
                             y=train_scaled_profit, 
                             mtry=144,
                             ntree=ntree)
              }

rf_pred_train <- predict(rf, boot_train,type="response")
rf_pred_test <- predict(rf, boot_test,type="response")

RMSE(rf_pred_train, train_scaled_profit)
RMSE(rf_pred_test, test_scaled_profit)

saveRDS(rf, file="models/nocurrent_rf_caret.rds")
saveRDS(rf_pred_train, file="models/prediction/rf_train_caret.rds")
saveRDS(rf_pred_test, file="models/prediction/rf_test_caret.rds")
