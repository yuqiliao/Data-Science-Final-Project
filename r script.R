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

raw_data <- read.csv("output1990-2000pre-cleaned.csv",header = TRUE, sep = ",",colClasses=c("character"),stringsAsFactors=F)
raw_data <- subset(raw_data, source=="The New York Times")
dim(raw_data)

myCorpus <- Corpus(VectorSource(raw_data$paragraph))
myCorpusBackup <- myCorpus
myCorpus <- tm_map(myCorpus, content_transformer(function(y) iconv(y, to='UTF-8-MAC', sub='byte')), mc.cores=1)
inspect(myCorpus[11:15])

class(myCorpus[[1]]) 
#myCorpus <- tm_map(myCorpus, PlainTextDocument, lazy=TRUE)

##### Cleaning the text

myCorpus <- tm_map(myCorpus, tolower, lazy=TRUE)
myCorpus <- tm_map(myCorpus, removePunctuation, lazy=TRUE)
myCorpus <- tm_map(myCorpus, removeNumbers, lazy=TRUE)
removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
myCorpus <- tm_map(myCorpus, removeURL, lazy=TRUE)

myCorpusCopy <- myCorpus
myCorpus <- tm_map(myCorpus, stemDocument, language = "english", lazy=TRUE)
# Errors with stem completion, so we will skip it for now
# myCorpus <- tm_map(myCorpus, stemCompletion, dictionary = myCorpusCopy, lazy=TRUE)
# Will try https://stackoverflow.com/questions/25206049/stemcompletion-is-not-working

myStopwords <- c(stopwords("english"), "china", "china's", "chinese", "article", "editor", "none", "said", "international", "today")
myCorpus <- tm_map(myCorpus, removeWords, myStopwords, lazy=TRUE)
#myCorpus <- tm_map(myCorpus, PlainTextDocument, lazy=TRUE)


for (i in 1:length(myCorpus)) {
  attr(myCorpus[[i]], "data") <- raw_data$data[i]
}

####
# Checking to see how it's going

inspect(myCorpus[11:15])

class(myCorpus[[1]]) 
myCorpus <- tm_map(myCorpus, PlainTextDocument)

##not working from below
for (i in 1:5) {
  cat(paste("[[", i, "]] ", sep = ""))
  writeLines(myCorpus[[i]]) }

chinaCases <- tm_map(myCorpus, grep, pattern = "\\<china")
sum(unlist(chinaCases))
#not working from above

dataframe.text <-data.frame(text=unlist(sapply(myCorpus, `[`, "content")), stringsAsFactors=F)

#### Convert to a term document matrix

# class(myCorpus[[1]]) 
# if 'character':
# myCorpus <- tm_map(myCorpus, PlainTextDocument, lazy=TRUE)

tdm <- TermDocumentMatrix(myCorpus,
                          control = list(wordLengths = c(1, Inf)))

#### Looking for frequent words

idx <- which(dimnames(tdm)$Terms == "china")
inspect(tdm[idx + (0:50), 101:110])

(freq.terms <- findFreqTerms(tdm, lowfreq = 2000))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 2000 & term.freq <=5000)
df <- data.frame(term = names(term.freq), freq = term.freq)

library(ggplot2)
ggplot(df, aes(x = term, y = freq)) + geom_bar(stat = "identity") + xlab("Terms") + ylab("Count") + coord_flip()

findAssocs(tdm, "beij", 0.2)
findAssocs(tdm, "tiananmen", 0.2)
findAssocs(tdm, "american", 0.2)

install.packages("wordcloud")
library(wordcloud)
m <- as.matrix(tdm)
# calculate the frequency of words and sort it by frequency
word.freq <- sort(rowSums(m), decreasing = T)
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 300,random.order = F)

# remove sparse terms
tdm2 <- removeSparseTerms(tdm, sparse = 0.95)
m2 <- as.matrix(tdm2)

######### Clustering

# cluster terms
distMatrix <- dist(scale(m2))
fit <- hclust(distMatrix, method = "ward.D")
plot(fit)
rect.hclust(fit, k = 6)

m3 <- t(m2) # transpose the matrix to cluster documents
set.seed(462) # set a fixed random seed
k <- 100 # number of clusters
kmeansResult <- kmeans(m3, k)
round(kmeansResult$centers, digits = 3)

for (i in 1:k) {
  cat(paste("cluster ", i, ": ", sep = ""))
  s <- sort(kmeansResult$centers[i, ], decreasing = T)
  cat(names(s)[1:5], "\n")
}

##this part does not work

install.packages("fpc")
library(fpc)
pamResult <- pamk(m3, metric="manhattan")
k <- pamResult$nc
pamResult <- pamResult$pamobject
for (i in 1:k) {
  cat("cluster", i, ":  ",
      colnames((pamResult$medoids)[which(pamResult$medoids[i,]==1)], "\n"))
}

layout(matrix(c(1, 2), 1, 2)) # set to two graphs per page
plot(pamResult, col.p = pamResult$clustering)

layout(matrix(1))

########## Topic modeling using Latent Dirichlet Allocation (LDA)

dtm <- as.DocumentTermMatrix(tdm)

#Find the sum of words in each Document, remove rows without entries
# rowTotals <- apply(dtm , 1, sum) 
# dtm <- dtm[rowTotals> 0, ]

library(topicmodels)
library(data.table)

# find 8 topics and first 5 terms of every topic term
lda <- LDA(dtm, k = 10) 
term <- terms(lda, 5) 
term

term <- apply(term, MARGIN = 2, paste, collapse = ", ")
topic <- topics(lda, 1)
topics <- data.frame(date=as.IDate(raw_data$time), topic)

qplot(date, ..count.., data=topics, geom="density", fill=term[topic], position="stack")

##############################

####### To complete stemmed words (still working on this)
# where dictCorpus is just a copy of the cleaned corpus, but before it's stemmed:

stemCompletion("compani",dictCorpus)

# or, more fully
stemCompletion_mod <- function(x,dict=dictCorpus) {
  PlainTextDocument(stripWhitespace(paste(stemCompletion(unlist(strsplit(as.character(x)," ")),dictionary=dict, type="shortest"),sep="", collapse=" ")))
}