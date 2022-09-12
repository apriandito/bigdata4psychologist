# Install and Load Packages -----------------------------------------------

# Install Packages 
install.packages("tuber")

# Load Packages
library(tuber)
library(tidyverse)
library(httr)

# Seth Auth.  -------------------------------------------------------------

# Masukkan Google API
yt_oauth(
  "___",
  "___"
)

# Search Video ------------------------------------------------------------

# Mencari daftar video, Ganti term dengan keyword yang ingin dicari
df_video <- yt_search(term = "korupsi")

# Simpan data daftar video dalam format .csv
write_csv(df_video, "data/data-video.csv")

# Search Comment ----------------------------------------------------------

# Mendapatkan komentar dari suatu video
df_comment <- get_all_comments("Hh0ioHFszOo")

# Simpan data komentar dalam format .csv
write_csv(df_comment, "data/data-comment.csv")