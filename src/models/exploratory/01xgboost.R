# XGBOOST ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(xgboost)
xgb <- xgboost(data = boot_train, label = as.numeric(train_profit_pos=="1"),
               params = list(objective = "binary:logistic",
                             eval_metric = "auc"),
               subsample=0.5,
               nrounds=200)
xgb_pred_fact_num <- predict(xgb, boot_test)
confuse_thresh(xgb_pred_fact_num, test_profit_pos, "1","0",range=seq(0.5, 0.9, by=0.1))

saveRDS(xgb, file="models/nocurrent_rxgb.rds")
saveRDS(xgb_pred_fact_num, file="models/prediction/xgb_prob.rds")
