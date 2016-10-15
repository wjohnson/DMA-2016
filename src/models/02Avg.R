load(file="data/processed/second_layer_inputs.rdata")
source("src/utils/evaluation.R")

train_profit <- train_complete$scaled_profit
train_complete <- train_complete[,!(names(train_complete) %in% c("id","scaled_profit"))]
test_profit <- test_complete$scaled_profit
test_complete <- test_complete[,!(names(test_complete) %in% c("id","scaled_profit"))]

# Average Weights ####
RMSE(rowMeans(train_complete), train_profit)
RMSE(rowMeans(test_complete), test_profit)

# The Combinations ####
bestRMSE <- 9.999
bestCols <- 1:1#ncol(train_complete)
for(col_len in 1:ncol(train_complete)){
  combos <- combn(ncol(train_complete),col_len)
  permuts <- ncol(combos)
  for(col in 1:permuts){
    selected_columns <- as.numeric(combos[,col])
    if(col_len > 1){
      train_RMSE <- RMSE(rowMeans(train_complete[,selected_columns]),train_profit)
      test_RMSE <- RMSE(rowMeans(test_complete[,selected_columns]),test_profit)
    }else{
      train_RMSE <- RMSE(train_complete[,selected_columns],train_profit)
      test_RMSE <- RMSE(test_complete[,selected_columns],test_profit) 
    }
    if(test_RMSE < bestRMSE){
      bestRMSE <- test_RMSE
      bestCols <- selected_columns
      names_of_cols <- colnames(train_complete)[selected_columns]
      cat("Used: ",paste(names_of_cols,sep=" "),"\n")
      cat("---------------\n")
      cat(paste("Train RMSE:",train_RMSE),"\n")
      cat(paste("Test RMSE:",test_RMSE),"\n\n")
    }
  }
}

