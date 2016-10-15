# Load Data ####
test_data <- readRDS(file="data/processed/test_second_layer_inputs.rds")
load(file="data/processed/training_objects.rdata") #Need Scale and Center
rm(boot_test, boot_train, test_scaled_profit, 
   train_scaled_profit, test_profit_pos, train_profit_pos,
   test_ids, train_ids)
gc()

# Apply Straight Averages ####
avg_pred <- rowMeans(test_data[,names(test_data) %in% c("gbm_res","rf_res")])
avg_pred_unscale <- (avg_pred* scale_scale)+scale_center

submit_avg_df <- data.frame(id = test_data$id,
                            predicted_profitability = avg_pred_unscale)

write.csv(x = submit_avg_df, file="data/submit/Uline_JJ_WJ_avg.csv",
         row.names = F)

# Apply XGBOOST Model to Second Layer Inputs ####
test_matrix <- as.matrix(test_data[,-1])

library(xgboost)
model <- readRDS(file="models/secondLayer_xgb.rds")

test_2nd_pred <- predict(model, test_matrix)

test_2nd_pred_unscaled <- (test_2nd_pred * scale_scale)+scale_center

submit_df <- data.frame(id = test_data$id,
                        predicted_profitability = test_2nd_pred_unscaled)

write.csv(x = submit_df, file="data/submit/Uline_JJ_WJ_xgb.csv")


par(mfrow=c(1,2))
hist(avg_pred_unscale, breaks = 30,main="Avg GBM + RF", xlab="Profitability")
hist(test_2nd_pred_unscaled, breaks = 30,main="XGBoost Combo", xlab="Profitability")
