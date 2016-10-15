load("data/processed/training_objects.rdata")
library(rpart)
rp <- readRDS("models/nocurrent_rpart.rds")
rp_train <- predict(rp, as.data.frame(boot_train),type="prob")[,"1"]
saveRDS(rp_train,"models/prediction/rpart_train_prob.rds")
rm(rp_train, rp)
gc()

library(xgboost)
xgb <- readRDS("models/nocurrent_rxgb.rds")
xgb_train <- predict(xgb, boot_train)
saveRDS(xgb_train,"models/prediction/xgb_train_prob.rds")
rm(xgb, xgb_train)
gc()

library(randomForest)
rf <- readRDS("models/nocurrent_randomForest.rds")
rf_train <- predict(rf, boot_train,type="vote")[,"1"]
saveRDS(rf_train, "models/prediction/rf_train_prob.rds")
rm(rf, rf_train)
gc()

library(gbm)
gb <- readRDS("models/nocurrent_gbm.rds")
boot_train_fixed <- as.data.frame(cbind(boot_train, 
                                        train_profit_pos=as.numeric(as.character(train_profit_pos))))
trees <- 900
gb_train <- predict(gb,boot_train_fixed,type = "response",n.trees = trees)
saveRDS(gb_train, "models/prediction/gb_train_prob.rds")
rm(gb, boot_train_fixed,trees, gb_train)
gc()
