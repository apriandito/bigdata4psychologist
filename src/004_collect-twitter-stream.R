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

# Tentukan Kata Kunci dan Rentang Waktu Streming (Dalam Detik)
keyword <- "jokowi"
rentang_waktu <- 60


# Stream Tweet ------------------------------------------------------------

# Proses Streaming Data Tweet dalam 60 Detik
stream_tweets(keyword,
              timeout = rentang_waktu,
              file_name = "data/streaming.json",
              parse = FALSE
)

# Parsing hasil streaming
streaming <- parse_stream("data/streaming.json")

# Simpan Data Tweet dalam format .csv
write_csv(rtweet::flatten(streaming),
          file = "data/tweet-stream.csv"
)
