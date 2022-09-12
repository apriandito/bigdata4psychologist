# Install and Load Packages -----------------------------------------------

# Install Packages
install.packages("devtools")
devtools::install_github("mohrosidi/newsR")

# Load Packages
library(newsR)
library(tidyverse)

# Auth --------------------------------------------------------------------

# Masukkan API key dari News API
news_api <- "___"

# Set Keyword -------------------------------------------------------------

# Tentukan Kata Kunci
keyword <- "Ferdy Sambo"

# Collect News ------------------------------------------------------------

# Proses Pengumpulan Data Berita
berita <- news_everything(
  keyword = keyword,
  get_all = TRUE,
  api_key = news_api
)

# Save News ---------------------------------------------------------------

# Simpan data berita dalam format .csv
write_csv(berita, "data/berita.csv")
