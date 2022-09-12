
# Install and Load Packages -----------------------------------------------

# Install Packages
devtools::install_version("rtweet", version = "0.7.0", repos = "http://cran.us.r-project.org")

# Load Packages
library(rtweet)
library(tidyverse)

# Set Auth. and Parameter -------------------------------------------------

# Set Token (Dari Halaman Twiiter API)
token <- create_token(
  app = "___",
  consumer_key = "___",
  consumer_secret = "___",
  access_token = "___",
  access_secret = "___"
)

# Tentukan Kata Kunci, Jumlah Tweet, dan Parameter Lainnya
keyword <- "depresi"
jumlahtweet <- 100
bahasa <- "id"
retweet <- TRUE

# Collecting Tweet --------------------------------------------------------

# Proses Pengumpulan Data Tweet
tweet_keyword <- search_tweets(keyword,
                               n = jumlahtweet,
                               include_rts = retweet,
                               lang = bahasa
)

# Save Tweet --------------------------------------------------------------

# Simpan Data Tweet dalam format .csv
write_csv(rtweet::flatten(tweet_keyword),
          file = "data/tweet-keyword.csv"
)
