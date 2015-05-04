Narratives of China in the US media: And analysis of NYT articles
----
by Kathryn Zickuhr & Yuqi Liao
<br>Data Science Final Project Write-up


##Project Background & Goals
Public opinion polling demonstrates that [Americans' views of China have changed substantially over the past few decades](http://www.pewresearch.org/fact-tank/2014/06/03/how-americas-opinion-of-china-has-changed-since-tiananmen/) since the country's economic reforms of 1978. The purpose of this project is to examine U.S. media coverage of China over the 1990s by examining the New York Times's coverage of the People's Republic of China from 1990 to the end of 2000.

We chose this decade as an interesting snapshot into a time of change in Chinese relations with the United States, in the period in between the Tiananmen Square protests of 1989 and the September 11, 2001 terrorist attacks that so strongly altered American foreign relations. Some of the major events of this time period include:


| Year | Event | Type |
| ------------- |-------------|-----|
| 1991 | China joins Asia-Pacific Economic Cooperation | Economy;Trade |
| 1992 | Deng Xiaoping accelerates market reforms | Economy;Trade |
| 1992 | China ratifies the Nuclear Non-Proliferation Treaty | National Security |
| 1994 | China Starts the "Three Gorges Dam" Project | Energy; Environment |
| 1995 | Taiwanese president visits U.S. | Taiwan Affairs |
| 1996 | 3rd Taiwan Strait Crisis | Taiwan Affairs |
| 1997 | Hong Kong returns to Chinese Rule | Hong Kong Affairs |
| 1998 | Clinton visits China | Foreign Affairs |
| 1999 | Bombing of the Chinese Embassy in Belgrade | Foreign Affairs|
| 1999 | China Seeks Entry to WTO | Economy;Trade |

Taking these events and others into consideration, we expected to see changes in the NYT's coverage of China over this time period. For instance, because Hong Kong returned to Chinese rule in 1997, we might expect to see an increase in coverage about Hong Kong leading up to and after the handoff.

## Detailed process and findings

# Download & Pre-Process Data
[First](https://github.com/yuqiliao/Data-Science-Final-Project/tree/master/Download%20Data%20from%20NYT%20API), we downloaded NYT articles from 1990-2000 via the [articles API](http://developer.nytimes.com/docs/read/article_search_api_v2) by using a Python script available at https://github.com/casmlab/get-nytimes-articles to pull any articles mentioning "China" -- a deliberately broad net. We focused our analysis on the lead paragraph of each article. The data was saved in JSON format, then converted to a tsv file.

Once we had obtained the raw data, we pre-processed the dataset by adding the header row, changing the format of the article dates, deleting unrelated columns, and deleting rows in which the content under the column “paragraph” is either missing or less than a few words. We also deleted any obvious error lines, such as blocks of rows with identical text. We saved the resulting file in csv format.

Next, we cleaned the data set by utilizing the Python script from Gaurav Sood available at https://github.com/soodoku/Text-as-Data: 
`python preprocessingData.py -c snippet articles.csv -o articles_clean.csv`

We also experiemnted with importing the dataset into R and using the tm package to clean the data, with similar results. Regardless of the method used, we also used R to remove specific words such as "China", "Chinese", "article", and "international" that we thought would be too common in the dataset due to our search parameters, general newspaper conventions, and data import issues (for instance, the newspaper section -- "international" -- was often included in the text of the lead paragraph.)

# Analyzing the data

To analyze the data and examine NYT coverage of China over time, we used methods from the book _R and Data Mining: Examples and Case Studies_, by Yanchang Zhao, available at http://www.rdatamining.com/books/rdm (2012), specifically the tutorial on Twitter data analysis: http://www.rdatamining.com/docs/text-mining-with-r-of-twitter-data-analysis

## Data Overview

Overall, we analyzed 22,339 NYT articles from January 1, 1990 to December 31, 2000 (not including articles from wires services).

1990: 1738
<br>1991: 1657
<br>1992: 1735
<br>1993: 1685
<br>1994: 1821
<br>1995: 1896
<br>1996: 2132
<br>1997: 2502
<br>1998: 2567
<br>1999: 2800
<br>2000: 3226

After converting the dataset to a term document matrix, we examined the dataset to see how often different terms were used, and get a sense of the general shape of the data. For our initial graphs, we decided to focus on unigrams that had been used more than 2000 times in the time period, but less than 5000:

![bar chart of frequent terms](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/frequent%20terms.png)

Focusing still closer, in a word cloud:

![word cloud](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/wordcloud.png)

Bigram and trigram analysis provide another perspective into the characteristics of the texts in the paragraph column, with the top 100 bigrams and trigrams as follows:

![bigrams](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/bigrams.png)

![trigrams](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/trigrams.png)

These basic steps gave us a sense of the data we were working with, and reflected some interesting facts in their own right. First, they show the changes of leadership from China and the US are reflected by the mentioning of “President Clinton” “President Bush” and “Deng Xiaoping” and “Jiang Zemin”. “President Clinton” was mentioned much more than “President Bush”, reflecting Clinton's longer term in office and greater engagement with China (including his 1998 visit). Second, the fact that Hong Kong ranks the third in bigram matrix suggests that the Hong Kong may not become the heated topic all of the sudden in 1997, but rather is fairly common throughout the 10-year period. Third, the keywords about the major events in the period could all be found in these matrix, as we expected.

##Clustering analysis

Due to the unsupervised nature of its methods, this project is not interested in prediction of an associated response variable. Rather, the goal is to discover interesting characteristics about the measurements among independent variables -- specifically, the unigrams used in NYT articles from 1990 to 2000. As described in _An Introduction to Statistical Learning with Applications in R_ (ISLR), there are two common types of unsupervised learning to achieve this goal. The first, principal components analysis (PCA), is a tool used before supervised techniques are applied; it seeks to find a low-dimensional representation of the observations that explain a good fraction of the variance. This project focuses on the clustering approach for this portion: Clustering refers in fact to a broad class of methods for discovering unknown subgroups in data by looking for homogeneous subgroups among the observations. 

As ISLR describes, two of the best-known clustering approaches are K-means clustering and hierarchical clustering. In K-means clustering, the observations are partitioned into a pre-specified number of clusters -- a disadvantage of K-means clustering, because the user must determine how many clusters are needed for the analysis even when it is not entirely clear how many clusters would be ideal. Both the number of clusters determined and the seed used in the analysis affect the final result.

Hierarchical clustering does offer a tree-like visual representation of the observations, a dendrogram, to help determine the number of clusters needed; observations that fuse at the very bottom of the tree are quite similar to each other, whereas observations that fuse close to the top of the tree will tend to be quite different. In the case of this project, however, we found the results far from clear:

![dendrogram: 12 clusters](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/dendogram.png)

_In the above example, we asked R to show us divisions in the hierarchical dendrogram based on 12 clusters._

For our analysis, we experimented with different numbers of clusters. To show the difference in clusters based on predetermined Ks, the difference between 6 and 15 clusters are shown below. (Due to difficulties re-stemming our data during cleaning, some of the terms are more cryptic than they otherwise would be.)

*Example: 6 clusters*
<br>1: new street art york world work open state mr us 
<br>2: new year state presid nation week mr one hous two 
<br>3: year one world last american mr two like new nation 
<br>4: unit state nation american world year offici countri trade new 
<br>5: presid clinton mr american trade administr hous offici state year 
<br>6: new york year citi time art one street mr last 

*Example: 15 clusters*
<br>1: art new street york show work includ time citi american 
<br>2: presid clinton mr hous trade state administr polici american nation 
<br>3: one world mr like new peopl nation govern say day 
<br>4: unit state nation world american offici countri year new trade 
<br>5: japan world war american countri year trade state unit first 
<br>6: new york citi time year mr one compani street state 
<br>7: week mr life last one new hous world time year 
<br>8: last week year month mr one world new govern time 
<br>9: american trade offici state unit administr world clinton nation compani 
<br>10: year last new one world two ago first mr time 
<br>11: new year state week two american compani york last one 
<br>12: two one year mr first world day new nation week 
<br>13: year one ago mr world like die time nation first 
<br>14: street new art york work world open state show includ 
<br>15: new presid nation state year offici clinton govern unit citi

In both cases, the impact of our "wide net" approach to choosing our articles (any article mentioning the word "China") is clear, as we are finding many clusters related to art, music, museums, and restaurants in the New York City area. However, as we increase the number of clusters to 15, we also begin to see more fine-grained clusters emerging around specific issues, such as topic 5 (which includes mentions of Japan, World War [II], and trade). However, we wanted to see how else we could explore these same data based on different methods.

## Topic modeling

The next method in _R and Data Mining: Examples and Case Studies_ was topic modeling. We used Latent Dirichlet Allocation (LDA), a “bag of words” model that uses a Bayes classifier to assign words to topics based on the articles that they appeared in. As with clustering, we had to pre-determine the number of topics we thought the data would contain, and once again we explored many different configurations. The familiar 15 topic frame yielded results that were similar to our cluster analysis, but different at the same time:

| | Topic 1| Topic 2 |Topic 3 | Topic 4 | Topic 5   | Topic 6  | Topic 7   |Topic 8  |Topic 9   |   Topic 10|
| ---|---|---|---|---|---|---|---|---|---|---|
| [1,] |"year"  |"peopl" |"chines"   | "state"  |  "american"| "would"   |"mr"     | "one"|    "trade"     | "a1"    |
| [2,]| "last" | "say"  | "right"  |   "unit"   |  "first"  |  "govern"  |"includ"  |"day" |   "clinton" |   "new" |  
| [3,]| "week" | "may"  | "countri"   |"nation" |  "made"|     "offici"|  "film"|    "like"  | "administr"|  "case"  |
|[4,]| "ago"  | "polit"| "beij"    |  "nuclear"|  "month"  |  "report"|  "work"  |  "citi"   |"econom"   |  "kill"  |
|[5,]| "die"|   "could"| "human"   |  "militari" |"japan"  |  "hong"   | "also" |   "place"  |"polici"     |"charg" |
|[6,]| "two"  | "end" |  "taiwan"   | "north"   | "america"|  "kong"   | "open"   | "around" |"washington" |"feder" |
|[7,]| "three" |"mani" | "call"  |    "secur"   | "asia"   |  "page"  |  "show"|    "build"  |"foreign" |   "court" |
|[8,]| "sinc"|  "take" | "organ"    | "korea"  |  "help"  |   "news"  |  "john"   | "travel" |"meet" |      "polic" |
|[9,]| "time" | "war"  | "asian"    | "weapon" |  "public"  | "announc" |"program"| "design" |"secretari" | "citi"  |
|[10,]| "old"   |"chang" |"democraci" |"soviet" |  "japanes" | "depart" | "earli" |  "small"  |"iraq"   |    "nation"|

| | Topic 11 |   Topic 12 |Topic 13 |  Topic 14   |Topic 15  |
| ---|---|---|---|---|---|---|---|---|---|---|
|[1,]| "world"  |   "one"  |  "presid"|   "new"  |    "compani" |
|[2,]| "women"  |   "like"  | "mr"    |   "york"  |   "million" |
|[3,]| "team"    |  "get"    |"leader"|   "street" |  "market"  |
|[4,]| "men"      | "life" |  "hous"  |   "art"     | "percent" |
|[5,]| "second"   | "go"   |  "clinton"|  "pm"      | "busi"    |
|[6,]| "yesterday" |"book" |  "parti"  |  "center"  | "billion" |
|[7,]| "first"   |  "way"  |  "minist" |  "museum"  | "industri"|
|[8,]| "play"    |  "want" |  "senat"  |  "west"    | "economi" |
|[9,]| "lead"    |  "live" |  "democrat"| "children" |"stock"   |
|[10,]| "final"   |  "make" |  "bush"    | "east"     |"price"|

Interpreting these topics, we might potentially summarize these as:
<br>1: recent events (vague)
<br>2: war (vague)
<br>3: human rights, Taiwan, democracy 
<br>4: nuclear security, North Korea
<br>5: Japan and U.S. relations
<br>6: Hong Kong
<br>7: film
<br>8: travel, design
<br>9: trade, Clinton, Iraq
<br>10: federal court, murder
<br>11: sports
<br>12: books
<br>13: Clinton, Bush, Democrats, House of Representatives
<br>14: NYC museums and the arts
<br>15: stock market, economy

We also charted these topics by week, and by "month" (every 30.5 days):

By week:
![15 topics by week](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/15%20topics%20by%20week.png)

For reference, the legend in the graphs is reversed:
<br>15: stock market, economy
<br>14: NYC museums and the arts
<br>13: Clinton, Bush, Democrats, House of Representatives
<br>12: books
<br>11: sports
<br>10: federal court, murder
<br>9: trade, Clinton, Iraq
<br>8: travel, design
<br>7: film
<br>6: Hong Kong
<br>5: Japan and U.S. relations
<br>4: nuclear security, North Korea
<br>3: human rights, Taiwan, democracy 
<br>2: war (vague)
<br>1: recent events (vague)

By month:
![15 topics by month](https://github.com/yuqiliao/Data-Science-Final-Project/blob/master/Images/15%20topics%20by%20month.png)

We see many things here that would warrant further exploration. We appear to see a spike in coverage in mid-1998, generally coinciding with President Clinton's visit to China in that time period. We see greater coverage of human rights issues at the beginning of the time period, closest to the events of 1989, but also occurring throughout the coverage period. However, we also want to avoid over-interpreting the data, as the models we have created are somewhat vague and do not align perfectly with the highly specific "topics" we might have expected to find at the outset.

# Conclusions

We learned many things in our exploratory analysis. We learned, for instance, that the methods of cluster analysis and topic modeling that we chose contain as much art as science, and require a clear understanding of the data as well as much patience to be used effectively. We were unable to determine, before our analysis, that news coverage of China "naturally" fell into 15 categories; it's possible that the NYT's articles mentioning China fall into only 2-3 categories, or into 30-40. We chose 15 to focus on after trial and error, and in no small part because most of the topics seemed to make intuitive sense to us -- but it's also possible that the topics we intuited were not what the model was in fact picking up.

In the future, we may want to focus our initial pulls on the API to focus on only "hard news" desks covering China, to exclude restaurant reviews and announcements of new books; this may not be a simple process, given that the NYT has changed its classification systems for news desks and general "subject" groupings over time, but it would be possible. We could also filter our initial search on certain words, if we wanted to focus on narrower topics (such as trade with China) or exclude specific ones (such as any mention of a museum). 

Finally, we could move away from machine learning techniques and instead focus on a more deliberate method, by creating our own set of keywords that we would expect coverage of China to include based on topics such as those we identified in our "historical events" section. Such an analysis would specifically look for words related to the economy and trade, the environment, nuclear security, human rights, etc. However, this method would be subject to its own biases, and might be most meaningful when used in conjunction with methods such as those used in this project.