data <- readRDS("data/processed/internal_external.rds")
data <- data[, -grep("WRD_", colnames(data))]
data$sprofit <- scale(data$Profitability)
scale_scale <- attr(scale(data$Profitability), "scaled:scale")
scale_center <- attr(scale(data$Profitability), "scaled:center")

train <- subset(data, data$sourcesystem == 'train')
test <- subset(data,data$sourcesystem == 'test')

set.seed(1)
train_logic <- sample(1:nrow(train), nrow(train)*0.7,replace=F)
train_all <- subset(train, select = -c(Profitability, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))
train <- train[train_logic,]
#test_n <- train[-train_logic,]
rm(data)
rm(train_logic)
gc(verbose=FALSE)

library(earth)
t <- subset(train, train$loan_status != 'Current')
train_id <- subset(train_all, select = c(id, sprofit))

train <- subset(train, select = -c(Profitability, id, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))
#test_n <- subset(test_n, select = -c(Profitability, id, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))
t <- subset(t, select = -c(Profitability, id, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))
test_id <- subset(test, select = c(id))
test <- subset(test, select = -c(Profitability, id, scaled_profitability, profit_is_pos, loan_status, sourcesystem, zip_code, ZIP3))

mars <- earth(y=train$sprofit, x=subset(train, select = -c(sprofit)))
tmars <- earth(y=t$sprofit, x=subset(t, select = -c(sprofit)))

lm <- glm(train$sprofit~., family = gaussian, data = train)
tlm <- glm(t$sprofit~., family = gaussian, data = t)

#pred <- predict(mars)
#pred_test <- predict(mars, newdata = test_n)
#pred_test_real <- predict(mars, newdata = test)

train_id$pred_all <- predict(mars, newdata = subset(train_all, select = -c(id)))
train_id$pred_all_nocurr <- predict(tmars, newdata = subset(train_all, select = -c(id)))

test_id$pred <- predict(mars, newdata = test)
test_id$pred_nocurr <- predict(tmars, newdata=test)

train_id$pred_all_glm <- predict(lm, newdata = subset(train_all, select = -c(id)))
train_id$pred_all_nocurr_glm <- predict(tlm, newdata = subset(train_all, select = -c(id)))

test_id$pred_glm <- predict(lm, newdata = test)
test_id$pred_nocurr_glm <- predict(tlm, newdata = test)

train_id$Unscaled_Profit <- (train_id$sprofit*scale_scale)+scale_center

train_id$Unscaled_Pred_All <- (train_id$pred_all*scale_scale)+scale_center

train_id$Unscaled_Pred_NoCurr <- (train_id$pred_all_nocurr*scale_scale)+scale_center

test_id$Unscaled_Pred <- (test_id$pred*scale_scale)+scale_center

test_id$Unscaled_Pred_NoCurr <- (test_id$pred_nocurr*scale_scale)+scale_center

train_id$Unscaled_Pred_All_GLM <- (train_id$pred_all_glm*scale_scale)+scale_center

train_id$Unscaled_Pred_NoCurr_GLM <- (train_id$pred_all_nocurr_glm*scale_scale)+scale_center

test_id$Unscaled_Pred_GLM <- (test_id$pred_glm*scale_scale)+scale_center

test_id$Unscaled_Pred_NoCurr_GLM <- (test_id$pred_nocurr_glm*scale_scale)+scale_center

jj_train <- subset(train_id, select = c(id, Unscaled_Profit, Unscaled_Pred_All, Unscaled_Pred_NoCurr, Unscaled_Pred_All_GLM, Unscaled_Pred_NoCurr_GLM))
jj_test <- subset(test_id, select = c(id, Unscaled_Pred, Unscaled_Pred_NoCurr, Unscaled_Pred_GLM, Unscaled_Pred_NoCurr_GLM))
save(jj_train, file = 'models/prediction/jj_train.RData')
save(jj_test, file = 'models/prediction/jj_test.RData')

#pred_t <- predict(tmars)
#pred_t_real <- predict(tmars, newdata = test)

#hist(pred_t)
#hist(pred_test_real)

#RMSE <- sqrt(mean((train$sprofit-pred)^2))
#RMSE_test <- sqrt(mean((test_n$sprofit-pred_test)^2))
#RMSE_t <- sqrt(mean((t$sprofit-pred_t)^2))
#stddev <- mean((train$sprofit-(mean(train$sprofit)))^2)^(1/2)