nums_facts_tokens <- readRDS(file = "data/processed/internal_external.rds")

train <- subset(nums_facts_tokens, 
                # Maybe Drop Current loan_status == "Current"
                subset = nums_facts_tokens$sourcesystem == "train",
                select = -c(ZIP3, zip_code, issue_month, 
                            sourcesystem))
rm(nums_facts_tokens)
gc()

train <- subset(train, subset=train$loan_status!="Current",
               select = -c(loan_status))

train$scaled_profitability <- scale(train$Profitability)
scale_center <- attr(x = scale(train$Profitability), which = "scaled:center")
scale_scale <- attr(x = scale(train$Profitability), which = "scaled:scale")

train <- train[,!(names(train) %in% "Profitability")]

# BOOTSTRAP SAMPLE ####
set.seed(4958)
boot <- sample(1:nrow(train), nrow(train), replace=T)
numeric_cols <- names(train)[!(names(train) %in% c("profit_is_pos","scaled_profitability"))]

boot_train <- as.matrix(train[boot, numeric_cols])
train_profit_pos <- train[boot, "profit_is_pos"]
train_scaled_profit <- train[boot, "scaled_profitability"]
train_ids <- boot_train[,"id"]
boot_train <- boot_train[,!(colnames(boot_train) %in% c("id"))]

boot_test <- as.matrix(train[-boot, numeric_cols])
test_profit_pos <- train[-boot, "profit_is_pos"]
test_scaled_profit <- train[-boot, "scaled_profitability"]
test_ids <- boot_test[,"id"]
boot_test <- boot_test[,!(colnames(boot_test) %in% c("id"))]

save(boot_train, train_profit_pos, train_scaled_profit,
     boot_test, test_profit_pos, test_scaled_profit,
     scale_center, scale_scale, train_ids, test_ids,
     file = "data/processed/training_objects.rdata")