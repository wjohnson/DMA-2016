# Random Forests ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(randomForest)
library(doMC)
registerDoMC(cores = 4)

rf <- foreach(ntree=rep(100, 8), .combine=combine, .multicombine=TRUE,
              .packages='randomForest') %dopar% {
                randomForest(x=boot_train, 
                             y=train_profit_pos, 
                             ntree=ntree)
              }

rf_pred_fact_num <- predict(rf, boot_test,type="vote")[,"1"]
confuse_thresh(rf_pred_fact_num, test_profit_pos, "1","0",range=seq(0.30, 0.9, by=0.05))

saveRDS(rf, file="models/nocurrent_randomForest.rds")
saveRDS(rf_pred_fact_num, file="models/prediction/randomForest_prob.rds")
