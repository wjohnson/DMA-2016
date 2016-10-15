#### LOAD DATA ####
train_test <- readRDS(file = "data/intermediate/00full_data_combined.rds")

library(tm) # Load text mining library for text transformations
library(SnowballC)  # Used for stemming purposes
corp <- VCorpus(VectorSource(train_test$desc))
corp <- tm_map(corp,PlainTextDocument)
corp <- tm_map(corp,content_transformer(tolower))
corp <- tm_map(corp, content_transformer(gsub), pattern="br", replacement=" ") # Remove the br
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp,removePunctuation)
corp <- tm_map(corp, stemDocument) # Relies on SnowballC
corp <- tm_map(corp, stripWhitespace)
corp <- tm_map(corp,removeWords,c(stopwords("en"),"br"))
dtm_bin <- DocumentTermMatrix(corp, control = list(weighting = function(x) weightBin(x)))
#dtm_tfidf <- DocumentTermMatrix(corp, control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))
#tfidf_dense <- removeSparseTerms(dtm_tfidf, sparse = 0.9982)

bin_dense <- removeSparseTerms(dtm_bin, sparse = 0.9982)

bin_inspect <- as.data.frame(inspect(bin_dense), stringsAsFactors = F)

rownames(bin_inspect) <- NULL

bin_inspect$id <- train_test$id

saveRDS(object = bin_inspect, file = "data/intermediate/01binary_desc_term_matrix.rds")