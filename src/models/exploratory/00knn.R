# Load Data ####
loadings <- readRDS(file = "data/processed/int_ext_pca.rds")
source("src/utils/evaluation.R")

train <- subset(loadings, 
                # Maybe Drop Current loan_status == "Current"
                subset = loadings$sourcesystem == "train",
                select = -c(id, sourcesystem, scaled_profitability, Profitability))
rm(loadings)
gc()

# Bootstrap Sample ####
set.seed(6238)
boot <- sample(1:nrow(train), nrow(train)*.7, replace=F)
boot_train <- subset(train[boot,], select =-c(profit_is_pos))
boot_train_class <- train[boot, "profit_is_pos"]
boot_test <- subset(train[-boot,], select =-c(profit_is_pos))
boot_test_class <- train[-boot, "profit_is_pos"]

saveRDS(object = boot_test_class, file="models/boot_test_class_justincase.rds")

rm(train)
rm(boot)
gc()

# FNN Training
library(FNN)
start <- proc.time()
knn1 <- knn(train=boot_train[,1:100], test = boot_test[,1:100], cl = boot_train_class, k=1,algorithm = "kd_tree")
saveRDS(object = knn1, file="models/knn1.model")
rm(knn1)
gc()
knn3 <- knn(train=boot_train, test = boot_test, cl = boot_train_class, k=3)
saveRDS(object = knn3, file="models/knn3.model")
rm(knn3)
gc()
knn32 <- knn(train=boot_train, test = boot_test, cl = boot_train_class, k=32)
saveRDS(object = knn32, file="models/knn32.model")
rm(knn32)
gc()
knn64 <- knn(train=boot_train, test = boot_test, cl = boot_train_class, k=64)
saveRDS(object = knn64, file="models/knn64.model")
rm(knn64)
gc()
knn128 <- knn(train=boot_train, test = boot_test, cl = boot_train_class, k=128)
saveRDS(object = knn128, file="models/knn128.model")
rm(knn128)
gc()
knn1024 <- knn(train=boot_train, test = boot_test, cl = boot_train_class, k=1024)
saveRDS(object = knn1024, file="models/knn1024.model")
rm(knn1024)
gc()
finish <- proc.time()