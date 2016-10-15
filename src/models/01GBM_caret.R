# Repeated GBM Numeric on Bootstrap sample ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(gbm)
library(caret)
library(doMC)
registerDoMC(cores = 4)

boot_train_fix <- as.data.frame(boot_train)
boot_test_fix <- as.data.frame(boot_test)
boot_train_fix$scaled_profit <- train_scaled_profit
rm(boot_train, boot_test)
gc()

trc <- trainControl(method="cv", number = 10, repeats = 5)

tgrid <- expand.grid(interaction.depth = 1:3,
                     n.trees = c(150,300,450,600),
                     shrinkage = c(0.05, 0.1, 0.25),
                     n.minobsinnode = 10)

set.seed(783)
gbm_boot <- train(scaled_profit~.,
                 data = boot_train_fix,
                 method="gbm",
                 metric="RMSE",
                 trControl = trc,
                 tuneGrid = tgrid,
                 distribution = "gaussian",
                 verbose = FALSE
)
gc()

gbm_pred_train <- predict(gbm_boot,boot_train_fix, type = "raw",n.trees = 600)
gbm_pred_test <- predict(gbm_boot,boot_test_fix, type = "raw",n.trees = 600)

RMSE(gbm_pred_train, train_scaled_profit)
RMSE(gbm_pred_test, test_scaled_profit)

saveRDS(gbm_boot, file="models/nocurrent_gbm_caret.rds")
saveRDS(gbm_pred_train, file="models/prediction/gbm_train_caret.rds")
saveRDS(gbm_pred_test, file="models/prediction/gbm_test_caret.rds")