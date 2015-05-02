getwd()
setwd("/Users/apple/Desktop/ds final project 1")

clean = read.csv("output1990-2000-processed.csv", header = TRUE)
paragraph <- clean$paragraph

Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
install.packages('rJava', type='source')
library(rJava)
options(java.parameters = "-Xmx8000m")
library(RWeka)

###bigrams & trigrams
bigrams_unsorted <- NGramTokenizer(paragraph, Weka_control(min = 2, max = 2))
trigrams_unsorted <- NGramTokenizer(paragraph, Weka_control(min = 3, max = 3))

bigrams_sorted <- sort(table(bigrams_unsorted),decreasing=T)
trigrams_sorted <- sort(table(trigrams_unsorted),decreasing=T)

View(bigrams_sorted)
View(trigrams_sorted)

write.csv(bigrams_sorted, "bigrams_sorted.csv")
write.csv(trigrams_sorted, "trigrams_sorted.csv")

###Keep only the top 100 observations for bigram
bigrams_sorted_top100 <- head(bigrams_sorted, 100)
View(bigrams_sorted_top100)
write.csv(bigrams_sorted_top100,"bigrams_sorted_top100.csv")

###Keep only the top 100 observations for trigram
trigrams_sorted_top100 <- head(trigrams_sorted, 100)
View(trigrams_sorted_top100)
write.csv(trigrams_sorted_top100,"trigrams_sorted_top100.csv")



