
# Install and Load Packages -----------------------------------------------

# Install Packages
install.packages(c("WDI", "tidyverse"))

# Load Packages
library(WDI)
library(tidyverse)

# Search and Collect Data -------------------------------------------------

# Cari data berdasarkan keyword
list_data <- WDIsearch("gdp") %>%
  as_tibble()

# Proses pengumpulan data berita
data <- WDI(indicator = "5.51.01.10.gdp")

# Menampilkan data
data

# Save Data ---------------------------------------------------------------

# Simpan data dalam format .csv
write_csv(data,
  file = "data/worlfbank-data.csv"
)
