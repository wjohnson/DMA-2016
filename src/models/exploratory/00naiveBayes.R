# Naive Bayes ####
load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
library(e1071)
nb <- naiveBayes(x = boot_train, y = train_profit_pos, laplace = 1)

nb_pred_fact_num <- predict(nb, boot_test, type="raw")
confuse_thresh(nb_pred_fact_num[,"1"], test_profit_pos, "1","0",range=seq(0.5, 0.9, by=0.1))
