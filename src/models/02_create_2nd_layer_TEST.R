data <- readRDS(file = "data/processed/internal_external.rds")

test <- subset(data, 
                subset = data$sourcesystem == "test",
                select = -c(ZIP3, zip_code, issue_month, 
                            sourcesystem,loan_status, profit_is_pos,Profitability))
test_profit <- test$scaled_profitability
test_ids <- test$id
test <- test[,!(names(test) %in% c("scaled_profitability","id"))]

rm(data);gc()
# Load Models
library(earth)
mars_mod <-readRDS(file="models/nocurrent_mars_caret.rds")
mars_test <- predict(mars_mod,test)

rm(mars_mod);gc()

gbm_mod <- readRDS(file="models/nocurrent_gbm_caret.rds")
gbm_test <- predict(gbm_mod, test)
rm(gbm_mod); gc()

library(randomForest)
rf_mod <- readRDS(file="models/nocurrent_rf_caret.rds")
rf_test <- predict(rf_mod, test)
rm(rf_mod); gc()

library(rpart)
rp_mod <- readRDS(file="models/nocurrent_rpart_caret.rds")
rp_test <- predict(rp_mod, test)
rm(rp_mod); gc()

library(xgboost)
xgb_mod <-readRDS(file="models/nocurrent_xgb_caret.rds")
xgb_test <- predict(xgb_mod, as.matrix(test))

test_output <- data.frame(
  id = test_ids,
  gbm_res = gbm_test,
  rf_res = rf_test,
  rp_res = rp_test,
  xgb_res = xgb_test,
  mars_res = mars_test
)

rm(gbm_test, rf_test, rp_test, xgb_test, mars_test); gc();

# Bring in Josh Data
load(file="models/prediction/jj_test.RData")

# Bring in JJ Train data 
load(file = "models/prediction//jj_train.RData") #jj_test
load("data/processed/training_objects.rdata") #Need scale_scale and center_scale

jj_test_scaled <- data.frame(
  id = jj_test$id,
  jj_mrs_all = as.numeric(scale(jj_test$Unscaled_Pred, scale= scale_scale, center=scale_center)),
  jj_mrs_nocurr = as.numeric(scale(jj_test$Unscaled_Pred_NoCurr, scale= scale_scale, center=scale_center)),
  jj_glm_all = as.numeric(scale(jj_test$Unscaled_Pred_GLM, scale= scale_scale, center=scale_center)),
  jj_glm_nocurr = as.numeric(scale(jj_test$Unscaled_Pred_NoCurr_GLM, scale= scale_scale, center=scale_center))
)

test_output_complete <- merge(test_output, jj_test_scaled,by="id",sort=F)
saveRDS(object = test_output_complete, file="data/processed/test_second_layer_inputs.rds")
