int_ext_data <- readRDS(file = "data/processed/internal_external.rds")

numeric_data <- subset(int_ext_data, 
                # Maybe Drop Current loan_status == "Current"
                select = -c(id, ZIP3, zip_code, issue_month,Profitability, 
                            profit_is_pos, loan_status,sourcesystem, scaled_profitability))
rm(numeric_data)
gc()
pcs <- prcomp(x=numeric_data, center = T, scale. = T)

loadings <- cbind(id=int_ext_data$id,as.data.frame(pcs$x[,1:236]),
                  scaled_profitability=int_ext_data$scaled_profitability,
                  profit_is_pos=int_ext_data$profit_is_pos, 
                  Profitability=int_ext_data$Profitability, 
                  sourcesystem=int_ext_data$sourcesystem)

saveRDS(file = "data/processed/int_ext_pca.rds",object = loadings)
