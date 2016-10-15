library(RCurl)
my_key = "INSERT_KEY_HERE"

getCensus <- function(get, for_val, key){
  # API Documentation @ http://www.census.gov/prod/cen2010/doc/sf1.pdf
  # Take in selected columns to get (separated by commas) and for_val to determine geo
  # Allowed States c(paste("0",c(1:2,4:9),sep=""),10:13, 15:42,44:51,53:56,72)
  url <- paste("http://api.census.gov/data/2010/sf1?key=",
               key,"&get=",get,"&for=",for_val,sep="")
  print (paste("Accessing...", url))
  out <- readLines(textConnection(getURL(url)))
  #Clean up the data by removing [] and " characters
  clean_out <- gsub(pattern=",$", replacement = "",
                    x = gsub(pattern = '\\[|\\]|\\"|\\\\',"", out))
  header <- unlist(strsplit(clean_out[1],split=","))
  body <- clean_out[2:length(clean_out)]
  body_list <- strsplit(body,split=",")
  body_df <- data.frame(matrix(unlist(body_list), nrow=length(body_list), byrow=T),stringsAsFactors=FALSE)
  names(body_df) <- header
  return(body_df)
}

# Get all States population by Zip
# Create initial section
population_df <- getCensus(get=paste("P003000",1:8,
                                     sep="",
                                     collapse = ","),
                           for_val="zip+code+tabulation+area:*&in=state:01",
                           key = my_key)
states <- c(paste("0",c(2,4:6,8:9),sep=""),10:13, 15:42, 44:51,53:56,72)
vars <- paste("P003000", 1:8,sep="", collapse = ",")
for(st in states){
  geo <- paste("zip+code+tabulation+area:*&in=state:",st,sep="")
  x <- getCensus(get=vars,for_val=geo, key=my_key)
  population_df <- rbind(population_df, x)
}

# Clean up values to integer
for(col in 1:8){
  population_df[,col] <- as.integer(population_df[,col])
}

population_df$ZIP3 <- substr(population_df$`zip code tabulation area`,1,3)

library(sqldf)
population_agg <- sqldf('SELECT ZIP3, 
                        SUM(P0030001) as P0030001,
                        SUM(P0030002) as P0030002,
                        SUM(P0030003) as P0030003,
                        SUM(P0030004) as P0030004,
                        SUM(P0030005) as P0030005,
                        SUM(P0030006) as P0030006,
                        SUM(P0030007) as P0030007,
                        SUM(P0030008) as P0030008
                        FROM population_df
                        GROUP BY ZIP3
                        ')
population_perc <- (population_agg[,paste("P003000",2:8,sep="")]+1) / (population_agg[,"P0030001"]+7)
population_perc$ZIP3 <- population_agg$ZIP3

saveRDS(object = population_perc, file="data/external/CensusPercents_ZIP3.rds")

# Create master aggregate ####
population_agg_all <- sqldf('SELECT 
                        SUM(P0030001) as P0030001,
                        SUM(P0030002) as P0030002,
                        SUM(P0030003) as P0030003,
                        SUM(P0030004) as P0030004,
                        SUM(P0030005) as P0030005,
                        SUM(P0030006) as P0030006,
                        SUM(P0030007) as P0030007,
                        SUM(P0030008) as P0030008
                        FROM population_df
                        ')
population_perc_all <- (population_agg_all[,paste("P003000",2:8,sep="")]+1) / (population_agg_all[,"P0030001"]+7)

saveRDS(object = population_perc_all, file="data/external/CensusPercents_ALL.rds")

