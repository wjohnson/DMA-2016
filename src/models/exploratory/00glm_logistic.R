# Logistic Regression ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
boot_train_fixed <- as.data.frame(cbind(boot_train, 
                                        train_profit_pos=as.numeric(as.character(train_profit_pos))))
boot_test_fixed <- as.data.frame(boot_test)
rm(boot_train, boot_test)

log_reg <- glm(train_profit_pos ~ ., data=boot_train_fixed,
                   family="binomial")
glm_pred_fact_num <- predict(log_reg, boot_test_fixed)