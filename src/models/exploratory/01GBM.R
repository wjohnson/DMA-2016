# Repeated GBM Numeric on Bootstrap sample ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(gbm)
trees <- 900
boot_train_fixed <- as.data.frame(cbind(boot_train, 
                          train_profit_pos=as.numeric(as.character(train_profit_pos))))
boot_test_fixed <- as.data.frame(boot_test)
rm(boot_train, boot_test)
gc()
set.seed(783)
gbm_boot <- gbm(train_profit_pos ~ .,
                n.trees = trees,
                n.cores = 6,
                data = boot_train_fixed,
                distribution = "bernoulli")
gbm_pred <- predict(gbm_boot,boot_test_fixed,type = "response",n.trees = trees)
confuse_thresh(gbm_pred, test_profit_pos,"1","0")

saveRDS(gbm_boot, file="models/nocurrent_gbm.rds")
saveRDS(gbm_pred, file="models/prediction/gbm_prob.rds")

gc()