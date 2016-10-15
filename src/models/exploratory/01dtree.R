load("data/processed/training_objects.rdata")
source("src/utils/evaluation.R")
#### Basic Decision Tree ####
library(rpart)
library(rpart.plot)

rp_fact <- rpart(train_profit_pos~., 
                 data = as.data.frame(boot_train)
)


rp_pred_fact_prob <- predict(rp_fact, as.data.frame(boot_test), type="prob")[,"1"]

saveRDS(object = rp_fact, file="models/nocurrent_rpart.rds")
saveRDS(object = rp_pred_fact_prob, file="models/prediction/rpart_prob.rds")

rm(rp_fact, rp_pred_fact_prob)

# confuse_thresh(rp_pred_fact_prob, test_profit_pos, "1","0",range=seq(0.30, 0.9, by=0.05))

gc()
