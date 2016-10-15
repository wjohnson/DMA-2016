# LOAD DATA ####
census <- readRDS(file = "data/external/CensusPercents_ZIP3.rds")

fed <- read.csv("data/external/FED_RATES.csv",header=T,skip = 14,
                stringsAsFactors = F)
fed$year <- as.integer(substr(fed$observation_date,1,4))

month_factors <- c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")

fed$month <- as.character(factor(as.integer(substr(fed$observation_date,start = 6, stop=7)),
                    levels = 1:12,
                    labels = month_factors))

provided_data <- readRDS(file = "data/processed/nums_facts_tokens.rds")

# APPEND CENSUS DATA ####
provided_data$ZIP3 <- substr(provided_data$zip_code,1,3)

internal_census <- merge(x=provided_data, y= census,
                         by="ZIP3",sort = F,all.x = T)

# Fix Mising Values 
population_perc_all <- readRDS(file="data/external/CensusPercents_ALL.rds")

internal_census[is.na(internal_census$P0030002), grep(pattern="^P003000\\d",names(internal_census))] <- population_perc_all


# APPEND FED RATES ####
monthDummyToChar <- function(x){
  col <- which(x==1)
  if(length(col)==1){
    return(month_factors[col+1])
  }else{
    return("Jan")
  }
}
internal_census$issue_month <- apply(internal_census[,grep(pattern = "issue_month", x = names(internal_census))],
      MARGIN = 1,
      FUN = monthDummyToChar)

internal_census_fed <- merge(x=internal_census,
                             y=fed,
                             by.x = c("issue_year","issue_month"),
                             by.y = c("year","month"),
                             sort=F,all.x=T)

# Drop Columns and Save ####
final_data <- subset(internal_census_fed,
                     select = -c(observation_date))

# summary(final_data)
saveRDS(file = "data/processed/internal_external.rds", object = final_data)

