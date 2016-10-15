# MARS ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(earth)
library(foreach)
library(doMC)
registerDoMC(cores = 3)
# Not CARET Version ####
set.seed(5297)

mars_out <- foreach(dg = 3:8, .combine = cbind, 
                    .packages = "earth") %dopar% {
                      mars_mod <- earth(x=boot_train, 
                                        y=train_scaled_profit,
                                        degree=dg)
                      pred_train_fe <- predict(mars_mod, boot_train)
                      pred_test_fe <- predict(mars_mod, newdata = boot_test)
                      
                      train_RMSE <- RMSE(pred_train_fe, train_scaled_profit)
                      test_RMSE <- RMSE(pred_test_fe, test_scaled_profit)
                      data.frame(res=c(dg, train_RMSE,test_RMSE))
}



# CARET VERSION ####
library(caret)

boot_train_fix <- as.data.frame(boot_train)
boot_train_fix$profit <- train_scaled_profit
boot_test_fix <- as.data.frame(boot_test)
set.seed(5297)
mars_mod <- train(profit ~ ., 
                    data = boot_train_fix[downsample,],
                    method="bagEarth",
                    metric="RMSE",
                    trControl = trc#,
                    #tuneGrid = tgrid
                    )

# PREDICTIONS ####
pred_train <- predict(mars_mod, boot_train)
pred_test <- predict(mars_mod, newdata = boot_test)

RMSE(pred_train, train_scaled_profit)
RMSE(pred_test, test_scaled_profit)

saveRDS(mars_mod, file="models/nocurrent_mars_caret.rds")
saveRDS(pred_train, file="models/prediction/mars_train_caret.rds")
saveRDS(pred_test, file="models/prediction/mars_test_caret.rds")
