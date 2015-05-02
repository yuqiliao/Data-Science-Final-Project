getwd()
setwd("/Users/apple/Desktop/ds final project 1")

### Using a pre-processed file

install.packages("tm")
install.packages("SnowballC")
install.packages("rJava")
install.packages("RWekajars")
install.packages("RWeka")
install.packages("XML")

library(tm)
library(SnowballC)
library(rJava)
library(RWekajars)
library(RWeka)
library(XML)

raw_data <- read.csv("output1990-2000-processed.csv",header = TRUE, sep = ",",colClasses=c("character"),stringsAsFactors=F)
raw_data <- subset(raw_data, source=="The New York Times")
raw_data$time <- as.Date(raw_data$time, '%m/%d/%y')
dim(raw_data)

myCorpus <- Corpus(VectorSource(raw_data$paragraph))
myCorpusBackup <- myCorpus
myCorpus <- tm_map(myCorpus, content_transformer(function(y) iconv(y, to='UTF-8-MAC', sub='byte')), mc.cores=1)

inspect(myCorpus[11:15])

class(myCorpus[[1]]) 
# myCorpus <- tm_map(myCorpus, PlainTextDocument, lazy=TRUE)

###############################################################
## Cleaning the text (if not pre-cleaned)
###############################################################

myCorpus <- tm_map(myCorpus, tolower, lazy=TRUE)
myCorpus <- tm_map(myCorpus, removeNumbers, lazy=TRUE)

myStopwords <- c(stopwords("english"), "china's", "china", "chinese", "article", "editor", "none", "said", "international", "intern", "today", "chine", "a", "b", "c", "d", "nt")
myCorpus <- tm_map(myCorpus, removeWords, myStopwords) 

myCorpus <- tm_map(myCorpus, removePunctuation)
removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
myCorpus <- tm_map(myCorpus, removeURL)

myCorpus <- tm_map(myCorpus, PlainTextDocument)
myCorpusCopy <- myCorpus

myCorpus <- tm_map(myCorpus, stemDocument, language = "english")
class(myCorpus[[1]]) 

## tm has errors with stem completion, so we will skip this step for now
# myCorpus <- tm_map(myCorpus, stemCompletion, dictionary = myCorpusCopy)
## Alternate stem completion method: https://stackoverflow.com/questions/25206049/stemcompletion-is-not-working

myCorpus <- tm_map(myCorpus, stripWhitespace)
myCorpus <- tm_map(myCorpus, PlainTextDocument)

###############################################################

# Check to see how it's going

inspect(myCorpus[11:15])

for (i in 1:length(myCorpus)) {
  attr(myCorpus[[i]], "time") <- raw_data$time[i]
}

## To check for certain words:
# chinaCases <- tm_map(myCorpus, grep, pattern = "\\<china")
# sum(unlist(chinaCases))

## To save as a data frame
# dataframe.text <-data.frame(text=unlist(sapply(myCorpus, `[`, "content")), stringsAsFactors=F)

## Make sure it's in plain text format
class(myCorpus[[1]]) 
# if 'character':
# myCorpus <- tm_map(myCorpus, PlainTextDocument, lazy=TRUE)

###############################################################

## Convert to a term document matrix

tdm <- TermDocumentMatrix(myCorpus,
                          control = list(wordLengths = c(1, Inf)))

## Look for frequent words

idx <- which(dimnames(tdm)$Terms == "clinton")
inspect(tdm[idx + (0:50), 101:110])

## Check to see which, if any, terms are extremely common, and impose cutoffs accordingly

(freq.terms <- findFreqTerms(tdm, lowfreq = 2000))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 2000&term.freq<=5000)
df <- data.frame(term = names(term.freq), freq = term.freq)

library(ggplot2)
ggplot(df, aes(x = term, y = freq)) + geom_bar(stat = "identity") + xlab("Terms") + ylab("Count") + coord_flip()

## Find associations between words

findAssocs(tdm, "american", 0.2)
findAssocs(tdm, "tiananmen", 0.2)

## Create a word cloud

library(wordcloud)
m <- as.matrix(tdm)
# calculate the frequency of words and sort it by frequency
word.freq <- sort(rowSums(m), decreasing = T)
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 3000,random.order = F,random.color=FALSE,)

###############################################################

## K-means clustering

# Start with the original term document matrix

tdm <- TermDocumentMatrix(myCorpus,
                          control = list(wordLengths = c(1, Inf)))

## Remove sparse terms

tdm <- removeSparseTerms(tdm, sparse = 0.95)
m2 <- as.matrix(tdm)

term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 2000&term.freq<=5000)
df <- data.frame(term = names(term.freq), freq = term.freq)

# cluster terms: 20 clusters
distMatrix <- dist(scale(m2))
fit <- hclust(distMatrix, method = "ward.D")
plot(fit)
rect.hclust(fit, k = 20)

m3 <- t(m2) # transpose the matrix to cluster documents
set.seed(9) # set a fixed random seed
k <- 20 # number of clusters
kmeansResult <- kmeans(m3, k)
round(kmeansResult$centers, digits = 3)

for (i in 1:k) {
  cat(paste("cluster ", i, ": ", sep = ""))
  s <- sort(kmeansResult$centers[i, ], decreasing = T)
  cat(names(s)[1:10], "\n")
}

# cluster terms: 15 clusters
distMatrix <- dist(scale(m2))
fit <- hclust(distMatrix, method = "ward.D")
plot(fit)
rect.hclust(fit, k = 15)

m3 <- t(m2) # transpose the matrix to cluster documents
set.seed(9) # set a fixed random seed
k <- 15 # number of clusters
kmeansResult <- kmeans(m3, k)
round(kmeansResult$centers, digits = 3)

for (i in 1:k) {
  cat(paste("cluster ", i, ": ", sep = ""))
  s <- sort(kmeansResult$centers[i, ], decreasing = T)
  cat(names(s)[1:10], "\n")
}

###############################################################

# Hierarchical clustering of the data

set.seed(2)
idx <- sample(1:dim(m2)[1], 40)
m2sample <- m2[idx, ]
hc <- hclust(dist(m2sample), method="ave")
plot(hc, hang=-1)
rect.hclust(hc, k=12)
groups <- cutree(hc, k=12)

###############################################################

### Partitioning around medoids (PAM)
# (does not work yet)

library(fpc)
pamResult <- pamk(m3, metric="manhattan")
k <- pamResult$nc
pamResult <- pamResult$pamobject
for (i in 1:k) {
  cat("cluster", i, ":  ",
      colnames((pamResult$medoids)[which(pamResult$medoids[i,]==1)], "\n"))
}
## Error in if (do.NULL) NULL else if (nc > 0L) paste0(prefix, seq_len(nc)) else character() : 
##  argument is not interpretable as logical

layout(matrix(c(1, 2), 1, 2)) # set to two graphs per page
plot(pamResult, col.p = pamResult$clustering)

layout(matrix(1))

###############################################################
### Topic modeling using Latent Dirichlet Allocation (LDA)
###############################################################

dtm <- as.DocumentTermMatrix(tdm)

## (If necessary) find the sum of words in each Document, remove rows without entries
# rowTotals <- apply(dtm , 1, sum) 
# dtm <- dtm[rowTotals> 0, ]
## Note: This can cause issues during graphing

library(topicmodels)
library(data.table)

# find 15 topics and first 6 terms of every topic term
lda <- LDA(dtm, k = 15) 
term <- terms(lda, 10) 
term

term <- apply(term, MARGIN = 2, paste, collapse = ", ")
topic <- topics(lda, 1)
topics <- data.frame(date=as.IDate(raw_data$time), topic)

qplot(date, ..count.., data=topics, geom="density", fill=term[topic], position="stack") + guides(fill = guide_legend(reverse=TRUE))

##############################
