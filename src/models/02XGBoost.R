load(file="data/processed/second_layer_inputs.rdata")
source("src/utils/evaluation.R")

train_profit <- train_complete$scaled_profit
train_complete <- train_complete[,!(names(train_complete) %in% c("id","scaled_profit"))]
test_profit <- test_complete$scaled_profit
test_complete <- test_complete[,!(names(test_complete) %in% c("id","scaled_profit"))]

# XGBOOST ####
library(xgboost)
set.seed(53)
xgb <- xgboost(data = as.matrix(train_complete), label = train_profit,
               params = list(objective = "reg:linear",
                             eval_metric = "rmse",
                             max.depth=2
               ),
               subsample=0.80,
               nrounds=10,
               early.stop.round = 5,
               verbose = 1)
xgb_train_pred <- predict(xgb, as.matrix(train_complete))
xgb_pred <- predict(xgb, as.matrix(test_complete))

RMSE(xgb_train_pred, train_profit)
RMSE(xgb_pred, test_profit)

saveRDS(xgb,file="models/secondLayer_xgb.rds")