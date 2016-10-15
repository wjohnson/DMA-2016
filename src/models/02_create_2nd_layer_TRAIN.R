load("data/processed/training_objects.rdata")

# Create Training Set
gbm_res<-readRDS(file="models/prediction/gbm_train_caret.rds")
rf_res<-readRDS(file="models/prediction/rf_train_caret.rds")
rp_res<-readRDS(file="models/prediction/rpart_train_caret.rds")
xgb_res<-readRDS(file="models/prediction/xgb_train_caret.rds")
mars_res <- as.numeric(readRDS(file="models/prediction/mars_train_caret.rds"))

train_data <- cbind(#boot_train,
  id = train_ids,
  gbm_res = gbm_res,
  rf_res = rf_res,
  rp_res = rp_res,
  xgb_res = xgb_res,
  mars_res = mars_res,
  scaled_profit = as.numeric(train_scaled_profit)
)

# Bring in JJ Train data 
load(file = "models/prediction//jj_train.RData") #jj_train
jj_train_scaled <- data.frame(
  id = jj_train$id,
  jj_mrs_all = as.numeric(scale(jj_train$Unscaled_Pred_All, scale= scale_scale, center=scale_center)),
  jj_mrs_nocurr = as.numeric(scale(jj_train$Unscaled_Pred_NoCurr, scale= scale_scale, center=scale_center)),
  jj_glm_all = as.numeric(scale(jj_train$Unscaled_Pred_All_GLM, scale= scale_scale, center=scale_center)),
  jj_glm_nocurr = as.numeric(scale(jj_train$Unscaled_Pred_NoCurr_GLM, scale= scale_scale, center=scale_center))
)

# Merge the Data Sets
train_complete <- merge(train_data, jj_train_scaled,by="id",sort=F)

# Create Testing Set ####
gbm_test<-readRDS(file="models/prediction/gbm_test_caret.rds")
rf_test<-readRDS(file="models/prediction/rf_test_caret.rds")
rp_test<-readRDS(file="models/prediction/rpart_test_caret.rds")
xgb_test<-readRDS(file="models/prediction/xgb_test_caret.rds")
mars_test <- as.numeric(readRDS(file="models/prediction/mars_test_caret.rds"))

test_data <- cbind(
  id = test_ids,
  gbm_res = gbm_test,
  rf_res = rf_test,
  rp_res = rp_test,
  xgb_res = xgb_test,
  mars_res = mars_test,
  scaled_profit = as.numeric(test_scaled_profit)
)

# Use jj_train data to connect against Will's Test (boot strap sample results)
test_complete <- merge(test_data, jj_train_scaled,by="id",sort=F)

# PLOTS ####
library(corrplot)
corrplot(cor(train_complete[,-1]),main="Boot Train")
corrplot(cor(test_complete[,-1]), main="Boot Test")

# SmoothScatters

modelMatrixPlot <- function(mat){
  par(mfcol=c(10,10),mar=rep(0,4))
  for(x in colnames(mat)){
    for(y in colnames(mat)){
      if(x==y){
        plot(1,type="l")
        text(x=1,y=1,x)
      }else{
        smoothScatter(mat[,x],mat[,y],
                      xaxt = 'n', yaxt= 'n')
      }
    }
  }
}
modelMatrixPlot(train_complete[,-1])
modelMatrixPlot(test_complete[,-1])


save(train_complete, test_complete, file="data/processed/second_layer_inputs.rdata")
