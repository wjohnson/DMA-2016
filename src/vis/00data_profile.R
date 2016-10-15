# Set up Training Data ####
train_test <- readRDS(file = "data/intermediate/00full_data_combined.rds")

train <- subset(train_test, subset = train_test$sourcesystem=="train",
                select = -c(id, title) )
test <- subset(train_test, subset = train_test$sourcesystem=="test",
                select = -c(id) )

rm(train_test)

profit <- train$Profitability

profit_is_neg <- ifelse(profit < 0, 1, 0)

train <- subset(train, select = -c(Profitability))

# Generic Functions ####

blankPlot <- function(x = NULL){
  plot(1,type="n",axes=F,xlab="",ylab="")
}


# Profitability of Loans that are closed ####

# hist(profit[train$loan_status != "Current"], breaks=50,
#      xlab="Profit of Closed Loans",
#      main="Closed Loan Profit by $1000 Profit breaks")
hist(profit[train$loan_status != "Current"], breaks=100,
     xlab="Profit of Closed Loans",
     main="Closed Loan Profit by $500 Profit breaks")
dev.copy(png, './vis/explore/profit_hist100brk.png', width=586, height=519)
dev.off()

# Numerics ####
numeric_cols <- names(train)[which(sapply(train, class) %in% c("numeric","integer"))]

## See if there is much correlation between variables
library(corrplot)
train_corr <- cor(cbind(train[,numeric_cols],profit), use="complete.obs")
rownames(train_corr) <- substr(rownames(train_corr),1,8)
colnames(train_corr) <- substr(colnames(train_corr),1,8)

corrplot(train_corr)

# Smooth Scatter
par(mfrow=c(5,3), mar=c(2.1,1.8,2.1,1.8))
#numeric_cols (25)+1 for tile = 26 | 26-15 = 11
for(i in 1:length(numeric_cols)){
  blankPlot()
  text(1,1,numeric_cols[i],cex=1.5)
  for(j in 1:length(numeric_cols)){
    smoothScatter(x=train[profit_is_neg==1,numeric_cols[i]],
                  y=log(train[profit_is_neg==1,numeric_cols[j]]),
                  ylab="", xlab="",main=numeric_cols[j])
    smoothScatter(x=train[profit_is_neg==0,numeric_cols[i]],
                  y=log(train[profit_is_neg==0,numeric_cols[j]]),
                  add=T, colramp = colorRampPalette(c(rgb(1, 1, 1, 0), rgb(1, 0, 0, 1)), alpha = TRUE))
  }
  #Plot blank spaces
  for(extras in seq(1,4)){blankPlot()}
}

# Density Plots
numericDensityPlot <- function(train, profit_is_neg, first_cell = NULL){
  par(mfrow=c(7,4), mar=c(2.1,1.8,2.1,1.8))
  plot(1,type="n",axes=F,xlab="",ylab="")
  text(0.99,1.0, first_cell , cex=0.95)
  for(i in 1:length(numeric_cols)){
    title <- numeric_cols[i]
    neg <- train[profit_is_neg==1  ,numeric_cols[i]]
    pos <- train[profit_is_neg==0 ,numeric_cols[i]]
    if(numeric_cols[i] %in% c("annual_inc","revol_bal","revol_util","total_rec_late_fee","tot_cur_bal","total_rev_hi_lim")){
      neg <- log(neg+1)
      pos <- log(pos+1)
      title <-paste(title,'*',sep="")
    }
    d_neg <- density(neg[!is.na(neg)])
    d_pos <- density(pos[!is.na(pos)])
    
    plot(d_neg, col="black",xlab="",ylab="",
         xlim=c(min(c(d_pos$x,d_neg$x)),
                max(c(d_pos$x,d_neg$x))),
         ylim=c(min(c(d_pos$y,d_neg$y)),
                max(c(d_pos$y,d_neg$y))),
         main=title)
    lines(d_pos,col="red")
  }
}

numericDensityPlot(train, profit_is_neg, first_cell="ALL\nRed = + | * = ln")
dev.copy(png, './vis/explore/numeric_density_all.png', width=900, height=543)
dev.off()
numericDensityPlot(train[train$loan_status!="Current",], profit_is_neg[train$loan_status!="Current"], first_cell="Not Current\nRed = + | * = ln")
dev.copy(png, './vis/explore/numeric_density_notcurr.png', width=900, height=543)
dev.off()
numericDensityPlot(test, sample(0:1,nrow(test),replace=T), first_cell="TEST\n* = ln")
dev.copy(png, './vis/explore/numeric_density_test.png', width=900, height=543)
dev.off()

#### Factors ####
factor_cols <- names(which(sapply(train, class)=="factor"))
profit_is_neg_factor <- as.factor(profit_is_neg)

factorBarPlots <- function(data, profit_is_neg_factor,prefix=""){
  par(mfrow=c(7,2), mar=c(5.1,4.1,4.1,2.1),las=2)
  blankPlot()
  text(1,1,"1 = Neg\n0 = Pos",cex=2.5)
  for(i in 1:length(factor_cols)){
    plot(x=data[,factor_cols[i]],
         y=profit_is_neg_factor,
         main=paste(prefix,factor_cols[i],sep=" ")
    )
  }
}

#height = 519 * 4 
#width = 859
png(filename = "./vis/explore/factors_all.png",
    width = 1073, height = 2080)
factorBarPlots(train, profit_is_neg_factor)
dev.off()

png(filename = "./vis/explore/factors_notcurrent.png",
    width = 1073, height = 2080)
factorBarPlots(train[train$loan_status!="Current",], 
               profit_is_neg_factor[train$loan_status!="Current"],
               prefix="Closed")
dev.off()

png(filename = "./vis/explore/factors_testset.png",
    width = 1073, height = 2080)
factorBarPlots(test, 
               factor(rep(0,nrow(test)),levels=0:1),
               prefix="Test")
dev.off()

par(mfrow=c(1,1), mar=c(5.1,4.1,4.1,2.1),las=2)
plot(x=as.factor(train$loan_status), y=profit_is_neg_factor)

round(prop.table(table(status=as.factor(train$loan_status),
                       profit_is_neg=profit_is_neg_factor)),3)

#Just getting the prior probabilities
round(prop.table(table(profit_is_neg_factor)),3)
round(prop.table(table(profit_is_neg_factor[train$loan_status!="Current"])),3)


# Transformation Decision ####
par(mfrow=c(1,3))
for(i in 1:length(numeric_cols)){
  smoothScatter(x=train[,numeric_cols[i]], y=scale(profit),
                xlab = numeric_cols[i], ylab="Scaled Profit",
                main = "Profit Mean = 0, SD = 1")
  smoothScatter(x=train[,numeric_cols[i]], 
                y=ifelse(profit<0,-1,1) * log(abs(profit)+1),
                xlab = numeric_cols[i], ylab="Sign * ln(abs(profit)+1)",
                main = "Profit Sign * ln(abs(profit)+1)")
  smoothScatter(x=train[,numeric_cols[i]], 
                y=log(profit+35001),
                xlab = numeric_cols[i], ylab="ln(Profit + 35,001)",
                main = "ln(Profit+35,001)")
}