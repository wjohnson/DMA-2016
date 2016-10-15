# XGBOOST ####
load(file="data/processed/second_layer_inputs.rdata")
source("src/utils/evaluation.R")

# Average Weights ####
RMSE(rowMeans(train_complete[,-1]), train_complete$scaled_profit)
RMSE(rowMeans(test_complete[,-1]), test_complete$scaled_profit)

# STEPWISE LINEAR REGRESSION ####
library(MASS)
base_mod <- lm(scaled_profit~1, data=train_complete)
lm_fit <- stepAIC(base_mod, direction="forward",
        scope=list(upper="~gbm_res+rf_res+rp_res+xgb_res+mars_res+
                   jj_mrs_all+jj_mrs_nocurr+jj_glm_all+jj_glm_nocurr"),
        lower=~1)

stepwise_test_pred <- predict(lm_fit,test_complete)

RMSE(stepwise_test_pred, test_complete$scaled_profit)

# Neural Network ####
library(neuralnet)

train_scaled <- train_complete[,-1]
test_scaled <- test_complete[,-1]
for(i in names(train_scaled)){
  if(i != "scaled_profit"){
    scaled_list <- scale(train_complete[,i])
    temp_scale <- attr(scaled_list,"scaled:scale")
    temp_center <- attr(scaled_list,"scaled:center")
    train_scaled[,i] <- as.numeric(scaled_list)
    test_scaled[,i] <- scale(x = test_complete[,i], scale=temp_scale, center = temp_center)
  }else{
    break
  }
}

library(foreach)

library(doMC)
registerDoMC(cores = 5)
x <- foreach(i = 1:5) %dopar%{
  x_val <- 1:10
  y_val <- c(rep(1,5),rep(0,5))
  lm(y_val~x_val)
}

nn_mod_func <- function(x){
  neuralnet(scaled_profit~gbm_res+rf_res+rp_res+xgb_res+mars_res+
              jj_mrs_all+jj_mrs_nocurr+jj_glm_all+jj_glm_nocurr, data=train_scaled,
            hidden=5, threshold = 6.0,stepmax = 25000, 
            lifesign.step = 500, lifesign = "none",
            learningrate.factor = list(minus = 0.5, plus = 3.5),rep = 1)
}


nn_mod <- foreach(i=1:5, .packages = "neuralnet") %dopar% nn_mod_func(i)

nn_train_pred <- compute(nn_mod[[5]], subset(train_scaled,select=-scaled_profit))
nn_test_pred <- compute(nn_mod[[5]], subset(test_scaled,select=-scaled_profit))
RMSE(nn_train_pred$net.result, train_scaled$scaled_profit)
RMSE(nn_test_pred$net.result, test_scaled$scaled_profit)

# Run Model ####
source("src/utils/evaluation.R")
library(xgboost)
set.seed(1)
xgb <- xgboost(data = train_data, label = train_scaled_profit,
               params = list(objective = "reg:linear",
                             eval_metric = "rmse",
                             max.depth=6
                             ),
               subsample=0.75,
               nrounds=10,
               early.stop.round = 5,
               verbose = 1)
xgb_train_pred <- predict(xgb, train_data)
xgb_pred <- predict(xgb, test_data)

RMSE(xgb_train_pred, train_scaled_profit)
RMSE(xgb_pred, test_scaled_profit)
