load("data/processed/training_objects.rdata")

# Linear Regression ####

lin_reg <- lm(train_scaled_profit ~ . , 
              data = as.data.frame(boot_train)
              )
summary(lin_reg)

boot_pred_lm <- predict(lin_reg, as.data.frame(boot_test))

RMSE(boot_pred_lm, test_scaled_profit)

rm(boot_pred_lm, lin_reg)
gc()

# Neural Network ####
library(neuralnet)
minMaxNormalize <- function(x){
  min_x <- min(x)
  max_x <- max(x)
  return((x-min_x) / (max_x-min_x))
}
boot_train_df <- as.data.frame(boot_train)

# Rescale the Year variables and UMCSENT
for(col in c("issue_year","first_credit_year","last_pymnt_year","last_credit_year",
             "DFF","GS5","GS10","MORTG","UMCSENT")){
  boot_train_df[,col] <- minMaxNormalize(boot_train_df[,col])
}


nn_form <- as.formula(paste("train_profit_pos",
                 paste(names(boot_train_df),collapse = "+"),
                 sep="~"))
boot_train_df$train_profit_pos <- as.numeric(train_profit_pos=="1")

nn_2layer <- neuralnet(nn_form , data = boot_train_df,
                hidden = c(200, 100))

nn_2l_pred <- compute(nn_2layer, boot_test)


# Neural Network 1 Hidden Layer ####
library(neuralnet)
minMaxNormalize <- function(x){
  min_x <- min(x)
  max_x <- max(x)
  return((x-min_x) / (max_x-min_x))
}
boot_train_df <- as.data.frame(boot_train)

# Rescale the Year variables and UMCSENT
for(col in c("issue_year","first_credit_year","last_pymnt_year","last_credit_year",
             "DFF","GS5","GS10","MORTG","UMCSENT")){
  boot_train_df[,col] <- minMaxNormalize(boot_train_df[,col])
}


nn_form <- as.formula(paste("train_profit_pos",
                            paste(names(boot_train_df),collapse = "+"),
                            sep="~"))
boot_train_df$train_profit_pos <- as.numeric(train_profit_pos=="1")

nn_1layer <- neuralnet(nn_form , data = boot_train_df,
                       hidden = c(200))

nn_1l_pred <- compute(nn_1layer, boot_test)

