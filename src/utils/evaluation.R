RMSE <- function(predicted, actual){
  # Root Mean Sqare Error
  return(sqrt(mean((predicted-actual)**2)))
}
# RMSE(1:10,1:10) == 0
# set.seed(1)
# pred <- rnorm(100,10,2); act <- rnorm(100,10,2);
# RMSE(pred, act)

confuse <- function(predicted, actual, positive, decimals = 3){
  #Create a confusion matrix
  predicted <- relevel(predicted, ref=positive)
  actual <- relevel(actual, ref=positive)
  tbl <- table(actl = actual, pred = predicted)
  TP <- tbl[1,1]; FN <- tbl[1,2];
  FP <- tbl[2,1]; TN <- tbl[2,1];
  acc <- (TP+TN) / (TP+TN+FP+FN)
  sensitivity <- (TP) / (TP+FN)
  precision <- (TP) / (TP+FP)
  print(tbl)
  cat(paste("Accuracy:",round(acc,decimals),sep=" "),"\n")
  cat(paste("Sensitivity:",round(sensitivity,decimals),sep=" "),"\n")
  cat(paste("Precision:",round(precision,decimals),sep=" "),"\n\n")
}
# pred <- as.factor(c("YES","NO","YES","YES","NO"))
# act <- as.factor(c("YES","YES","YES","YES","NO"))
# confuse(pred,act,"YES")

confuse_thresh <- function(predicted, actual, positive, negative, decimals = 3, range = summary(predicted)){
  thresh <- function(vec, split){
    return(factor(ifelse(vec>= split, positive, negative),levels= c(negative,positive)))
  }
  actual <- factor(actual, levels=c(negative,positive))
  for(split in range){
    cat(paste("Threshold is",split,"\n"))
    confuse(thresh(predicted, split), actual, positive, decimals)
  }
}
# pred <- c(0.9, 0.8, 0.6,0.25,0.1)
# act <- as.factor(c(1,1,1,1,0))
# confuse_thresh(pred,act,"1","0")
