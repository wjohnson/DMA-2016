train_test <- readRDS(file = "data/intermediate/00full_data_combined.rds")

char_cols <- names(train_test)[which(sapply(train_test, class)=="character")]
char_cols <- char_cols[!(char_cols %in% c("desc","title")) ]


char_to_add <- cbind(id=train_test$id, train_test[,char_cols])

numeric_cols <- names(train_test)[which(sapply(train_test, class) %in% c("numeric","integer"))]

# Remove columns not useful for scaling
drop_numerics <- c("id", "Profitability", "open_accounts_perc", numeric_cols[grep(pattern = "_year",numeric_cols)])
numeric_cols_final <- setdiff(numeric_cols,drop_numerics)

#### Scale Numeric Variables ####

scaled_numerics <- cbind(train_test[,drop_numerics],scale(train_test[,numeric_cols_final]))

### Dummy Variables for Factors ####

factor_cols <- names(train_test)[which(sapply(train_test, class) == "factor")]

factor_formula = as.formula(paste("~",paste(factor_cols,collapse = "+"), sep=""))
factor_dummies <- model.matrix(factor_formula, data = train_test)[,-1] # Create dummes and drop intercept

factor_dummies_id <- as.data.frame(cbind(id=train_test$id, factor_dummies))

### Bring in Binary Tokens from Desc ####
binary_tokens <- readRDS(file="data/intermediate/01binary_desc_term_matrix.rds")

names(binary_tokens)[names(binary_tokens) != "id"] <- paste("WRD_",names(binary_tokens)[names(binary_tokens) != "id"],sep="")

### Merge Files ####
nums_facts <- merge(x=scaled_numerics, y=factor_dummies_id, by = "id", sort=F)
rm(scaled_numerics, factor_dummies_id, factor_dummies)
gc()
nums_facts_tokens <- merge(x = nums_facts, y = binary_tokens, by = "id", sort=F)
rm(binary_tokens)
gc()

nums_facts_tokens_chars <- merge(x= nums_facts_tokens, y=char_to_add, by = "id", sort=F)


names(nums_facts_tokens_chars) <- gsub(pattern="\\/|>|<|\\[|\\]|\\.|,|\\(|\\)| ", replacement = "_", x = names(nums_facts_tokens_chars))

# Add in Response Variables ####

nums_facts_tokens_chars$profit_is_pos <- as.factor(ifelse(nums_facts_tokens_chars$Profitability>0,1,0))
nums_facts_tokens_chars$scaled_profitability <- log(abs(nums_facts_tokens_chars$Profitability+1)) * sign(nums_facts_tokens_chars$Profitability)


### Save Final File ####
saveRDS(nums_facts_tokens_chars, file="data/processed/nums_facts_tokens.rds" )
