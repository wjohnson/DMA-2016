##### DATA SETUP ####
train <- read.csv("data/raw/EY_DMA_Analytics_2016_Training_Data0822.csv",
                  stringsAsFactors = F, header=T)

train$sourcesystem <- "train"
#Rearrange Loan Status to end of file
train_new_order <- c(names(train)[!(names(train) %in% c("loan_status"))],
                     "loan_status")
train <- train[,train_new_order]
rm(train_new_order)

test <- read.csv("data/raw/EY_DMA_Analytics_2016_Testing_Data_0822.csv",
                  stringsAsFactors = F, header=T)

test$Profitability <- NA
test$sourcesystem <- "test"
test$loan_status <- NA


### Data Double check on Column Names
# colnames_train <- names(train)
# colnames_test <- names(test)
# all(colnames_train == colnames_test)

#setdiff(colnames_train, colnames_test)
#setdiff(colnames_test,colnames_train)

full_data <- rbind(train, test)
#summary(full_data)

#### FUNCTIONS ####
library(stringr)
splitMonthYear <-function(mo_year){
  # Take in a vector of Abc-YYYY and return a list
  # with names mo, yr | Depends on stringr str_extract function
  mo_names <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')
  months <- factor(substring(mo_year,1,3), levels = mo_names)
  years <- as.numeric(str_extract(mo_year,"\\d\\d\\d\\d"))
  return(list("mo"=months, "yr" = years))
}

#Variables affected by splitMonthYear
# earliest_cr_line, last_pymnt_d, next_pymnt_d, last_credit_pull_d, issue_d

#### FACTOR CREATION ####
#which(sapply(full_data, class) == "character")

full_data$term <- as.factor(full_data$term)
full_data$emp_length <- as.factor(full_data$emp_length)
full_data$home_ownership <- as.factor(full_data$home_ownership)

#When was Loan Issued
temp_issue <-splitMonthYear(full_data$issue_d)
full_data$issue_month <- temp_issue$mo
full_data$issue_year <- temp_issue$yr
rm(temp_issue)

#Skip Desc - Too High Dimensionality
full_data$purpose <- as.factor(full_data$purpose)
#Skip title - Too High Dimensionality
#Skip Zip Codes - Too High Dimensionality
full_data$addr_state <- as.factor(full_data$addr_state)

#First Credit Line Opening Transformation
temp_first_credit <- splitMonthYear(full_data$earliest_cr_line)
full_data$first_credit_month <- temp_first_credit$mo
full_data$first_credit_year <- temp_first_credit$yr
rm(temp_first_credit)

full_data$initial_list_status <- as.factor(full_data$initial_list_status)
#Last Payment Transformation (last_pymnt_d)
temp_last_pymnt <- splitMonthYear(full_data$last_pymnt_d)
full_data$last_pymnt_month <- temp_last_pymnt$mo
full_data$last_pymnt_year <- temp_last_pymnt$yr
rm(temp_last_pymnt)
#Next Payment Date Transformation (next_pymnt_d)
temp_next_pymnt <- splitMonthYear(full_data$next_pymnt_d)
full_data$next_pymnt_month <- temp_next_pymnt$mo
full_data$next_pymnt_year <- temp_next_pymnt$yr
rm(temp_next_pymnt)
#Last Credit Pull Date (last_credit_pull_d)
temp_last_credit <- splitMonthYear(full_data$last_credit_pull_d)
full_data$last_credit_month <- temp_last_credit$mo
full_data$last_credit_year <- temp_last_credit$yr
rm(temp_last_credit)

full_data$application_type <- factor(full_data$application_type, 
                                     levels = c("INDV","JOINT APPLICATION"),
                                     labels = c("INDIV", "JOINT"))
full_data$verification_status_joint <- as.factor(full_data$verification_status_joint)
full_data$verification_status <- as.factor(full_data$verification_status)

# Added in factors for values with high missing
## mths_since_last_delinq
full_data$months_last_delinq <- as.character(cut(full_data$mths_since_last_delinq,breaks = 40))
full_data$months_last_delinq[is.na(full_data$months_last_delinq)] <- "Never"
full_data$months_last_delinq <- as.factor(full_data$months_last_delinq)

## mths_since_last_record
#hist(full_data$mths_since_last_record,breaks=20)
full_data$months_last_record_catg <- as.character(cut(full_data$mths_since_last_record,breaks = 20))
full_data$months_last_record_catg[is.na(full_data$months_last_record_catg)] <- "Never"
full_data$months_last_record_catg <- as.factor(full_data$months_last_record_catg)

# Impute revol_util
full_data$revol_util[is.na(full_data$revol_util)] <- mean(full_data$revol_util,na.rm = T)

# Impute collections_12_mths_ex_med
full_data$collections_12_mths_ex_med[is.na(full_data$collections_12_mths_ex_med)] <- 0.0

# Impute tot_cur_bal
full_data$tot_cur_bal[is.na(full_data$tot_cur_bal)] <- median(full_data$tot_cur_bal,na.rm = T)

# Impute total_rev_hi_lim
rev_loan_ct <- cut(full_data$loan_amnt,30)
rev_loan_mod <-lm(full_data$total_rev_hi_lim ~ rev_loan_ct)

rev_pred <- predict(rev_loan_mod, rev_loan_ct[is.na(full_data$total_rev_hi_lim)])
full_data$total_rev_hi_lim[is.na(full_data$total_rev_hi_lim)] <- rev_pred[is.na(full_data$total_rev_hi_lim)]


#### Hand Crafted Features ####

#Loan Was Not 100% Funded by Investors
temp_amnt_inv_perc <- full_data$funded_amnt_inv / full_data$funded_amnt
full_data$funded_amnt_inv_not100 <-as.factor(temp_amnt_inv_perc < 1.0)
rm(temp_amnt_inv_perc)

#Remaining Balance of Loan
temp_remain_bal <- full_data$out_prncp / full_data$loan_amnt
full_data$remaining_balance_perc <- ifelse(temp_remain_bal>1.0, 1.0, temp_remain_bal)
rm(temp_remain_bal)

#Accounts that Have Been Closed (Total Accounts Minus Open Accts)
full_data$closed_accounts <- full_data$total_acc-full_data$open_acc

#Percent of Total Accts that are Open
full_data$open_accounts_perc <- full_data$open_acc / full_data$total_acc

#Has never had a Delinquent Record (mths_since_last_delinq)
full_data$no_monthly_delinq <- as.factor(is.na(full_data$mths_since_last_delinq))

### Checks for Interaction of 30 day delinquency and months since delinquency ###
### Results show some relationship
# aggregate(full_data$Profitability[!is.na(full_data$Profitability)], 
#           by = list(NoMonthlyDelinq = is.na(full_data$mths_since_last_delinq[!is.na(full_data$Profitability)]),
#                     No30DayDelinq = (full_data$delinq_2yrs == 0)[!is.na(full_data$Profitability)]), FUN=summary)
# table(list(NoMonthlyDelinq = is.na(full_data$mths_since_last_delinq[!is.na(full_data$Profitability)]),
#            No30DayDelinq = (full_data$delinq_2yrs == 0)[!is.na(full_data$Profitability)]))


#### Data Fixing / Imputing #####

# DTI 
#Transform to anything > 65 to 65 to bring outliers back into control
#head(sort(full_data$dti,decreasing = T))
#h <- hist(sort(full_data$dti,decreasing = T)[-c(1:10)])
#x <- cut(full_data$dti,breaks = seq(from=0,to=95,by=5))
#aggregate(full_data$Profitability, by=list(x), FUN=summary)

full_data$dti <- ifelse(full_data$dti>=65, 65, full_data$dti)

#x <- cut(full_data$dti,breaks = seq(from=0,to=95,by=5))
#aggregate(full_data$Profitability, by=list(x), FUN=summary)

# Clean up Last Missing Values in Factors
full_data$last_credit_month[is.na(full_data$last_credit_month)] <- "Jan"
full_data$last_credit_year[is.na(full_data$last_credit_year)] <- 2016

full_data$last_pymnt_month[is.na(full_data$last_pymnt_month)] <- "Jan"
full_data$last_pymnt_year[is.na(full_data$last_pymnt_year)] <- 2016

#### DROP COLUMNS ####

full_data <- subset(full_data, 
                    select = -c(#Drop the transformed fields
                                earliest_cr_line, last_pymnt_d, 
                                next_pymnt_d, last_credit_pull_d,
                                issue_d,
                                #No Joint loans in test set, don't bother training on them
                                annual_inc_joint, application_type, verification_status_joint,
                                # No Open Balance in Test set
                                out_prncp, out_prncp_inv,remaining_balance_perc, 
                                next_pymnt_month, next_pymnt_year,
                                #member_id is not required
                                member_id,
                                #Drop columns that were converted to factors
                                mths_since_last_major_derog, annual_inc_joint, mths_since_last_record,
                                mths_since_last_delinq,
                                #Drop Title since purpose is alreayd descriptive
                                title
                                ),
                    subset = application_type != "JOINT" #Drop join account since they're not in test set
                    )

#Remaining fields for transformation
# desc and zip code

#### SAVE Intermediate Data ####

saveRDS(object = full_data, file = "data/intermediate/00full_data_combined.rds")
#Use readRDS to load an object