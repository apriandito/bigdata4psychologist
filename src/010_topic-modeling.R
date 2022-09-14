# Set Seed
set.seed(123)

install.packages('servr') 

# Load Packages
library(tidyverse)
library(textclean)
library(tidytext)
library(textrecipes)
library(tidymodels)
library(topicmodels)
library(ldatuning)

# Load Data
df <- read_csv("data/tweet-bjorka.csv")

# Cleaning
df_clean <- df %>%
  select(text) %>%
  mutate(text = replace_non_ascii(text)) %>%
  mutate(text = replace_hash(text, pattern = "#([A-Za-z0-9_]+)", replacement = "")) %>%
  mutate(text = replace_tag(text, pattern = "@([A-Za-z0-9_]+)", replacement = "")) %>%
  mutate(text = replace_html(text, symbol = FALSE)) %>%
  mutate(text = replace_url(text, pattern = qdapRegex::grab("rm_url"), replacement = "")) %>%
  mutate(text = replace_emoji(text)) %>%
  mutate(text = replace_emoticon(text)) %>%
  mutate(text = replace_tag(text, pattern = "\\[([A-Za-z0-9_]+)\\]", replacement = "")) %>%
  mutate(text = str_replace_all(text, pattern = regex("\\W|[:digit:]"), replacement = " ")) %>%
  mutate(text = strip(text))

# Unnest Token
df_text <- df_clean %>%
  rowid_to_column("id") %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%
  group_by(id, word) %>%
  count()

# Create Document Matrix
dtm <- df_text %>%
  cast_dtm(document = id, term = word, value = n)

# Find Topic Number
result <- FindTopicsNumber(
  dtm,
  topics = seq(from = 2, to = 15, by = 1),
  metrics = c("CaoJuan2009", "Deveaud2014"),
  method = "Gibbs",
  mc.cores = 2L,
  verbose = TRUE
)

# Plot Result
FindTopicsNumber_plot(result)

# Generate Topic using LDA
lda <- LDA(dtm, k = 4, method = "Gibbs")

# Function to convert LDAVIS
convert_ldavis <- function(fitted, doc_term) {
  require(LDAvis)
  require(slam)

  # Find required quantities
  phi <- as.matrix(posterior(fitted)$terms)
  theta <- as.matrix(posterior(fitted)$topics)
  vocab <- colnames(phi)
  term_freq <- slam::col_sums(doc_term)

  # Convert to json
  json_lda <- LDAvis::createJSON(
    phi = phi, theta = theta,
    vocab = vocab,
    doc.length = as.vector(table(doc_term$i)),
    term.frequency = term_freq
  )

  return(json_lda)
}

plot_ldavis <- convert_ldavis(
  fitted = lda,
  doc_term = dtm
)

serVis(plot_ldavis)

