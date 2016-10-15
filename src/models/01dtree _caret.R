load("data/processed/training_objects.rdata")
# source("src/utils/evaluation.R")
#### Basic Decision Tree ####
library(rpart)
library(rpart.plot)
library(caret)
library(doMC)
registerDoMC(cores = 4)

boot_train_fix <- cbind(scaled_profit = train_scaled_profit,
                        as.data.frame(boot_train))
boot_test_fix <- cbind(scaled_profit = test_scaled_profit,
                        as.data.frame(boot_test))
rm(boot_train, boot_test)
trc <- trainControl(method="cv", number = 10, repeats = 5)

rp_fact <- train(form= scaled_profit ~ .,
                 data = boot_train_fix,
                 method="rpart",
                 metric="RMSE",
                 trControl = trc
                 )

rp_pred_train <- predict(rp_fact$finalModel, boot_train_fix, type="vector")
rp_pred_test <- predict(rp_fact$finalModel, boot_test_fix, type="vector")

RMSE(pred = rp_pred_train, obs = boot_train_fix$scaled_profit)
RMSE(pred = rp_pred_test, obs = boot_test_fix$scaled_profit)

saveRDS(object = rp_fact, file="models/nocurrent_rpart_caret.rds")
saveRDS(object = rp_pred_train, file="models/prediction/rpart_train_caret.rds")
saveRDS(object = rp_pred_test, file="models/prediction/rpart_test_caret.rds")

gc()
