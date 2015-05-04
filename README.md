Narratives of China in the US media: And analysis of NYT articles
----
by Kathryn Zickuhr & Yuqi Liao
<br>Data Science Final Project Write-up


##Project Background & Goals
Public opinion polling demonstrates that [Americans' views of China have changed substantially over the past few decades](http://www.pewresearch.org/fact-tank/2014/06/03/how-americas-opinion-of-china-has-changed-since-tiananmen/) since the country's economic reforms of 1978. The purpose of this project is to examine U.S. media coverage of China over the 1990s by examining the New York Times's coverage of the People's Republic of China from 1990 to 2000.

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

## Analyzing the data

