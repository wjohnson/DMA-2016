# XGBOOST ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(xgboost)
library(caret)
library(doMC)
registerDoMC(cores = 4)

trc <- trainControl(method="cv", number = 10, repeats = 5)

set.seed(1037)

egrid <- expand.grid(eta=seq(0.01, 0.05, by=0.01),
            max.depth=c(2,3,4),
            nrounds=seq(50,300,by=50))
egrid$test_rmse <- NA

for(i in 1:nrow(egrid)){
  mod_params <- list(objective="reg:linear",
                     eta = egrid$eta[i],
                     max.depth = egrid$max.depth[i],
                     eval_metric="rmse")
  mod <- xgb.cv(data = boot_train, label=train_scaled_profit,
                nfold=5,params = mod_params, nrounds = egrid$nrounds[i])
  egrid$test_rmse[i] <- mod$test.rmse.mean[length(mod$test.rmse.mean)]
}

head(egrid[order(egrid$test_rmse),])

xgb_params = list(objective="reg:linear",
                  eta = 0.05,
                  max.depth = 4,
                  eval_metric="rmse")

xgb <- xgboost(data = boot_train, label=train_scaled_profit,
               params = xgb_params, nrounds = 300,
              nfold = 5
               )

xgb_pred_train <- predict(xgb, boot_train)
xgb_pred_test <- predict(xgb, boot_test)

RMSE(predicted = xgb_pred_test, test_scaled_profit)

saveRDS(xgb, file="models/nocurrent_xgb_caret.rds")
saveRDS(xgb_pred_train, file="models/prediction/xgb_train_caret.rds")
saveRDS(xgb_pred_test, file="models/prediction/xgb_test_caret.rds")
