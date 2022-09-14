# Set Seed
set.seed(123)

# Load Packages
library(tidyverse)
library(tidytext)
library(textclean)
library(tidygraph)
library(ggraph)
library(widyr)
library(hrbrthemes)

# Load Data
df <- read_csv("data/berita-bjorka.csv")

# Clean Tweet
df_clean <- df %>%
  rename(text = title) %>%
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

stop_words <- read_csv("data/stopwords-id.txt",
  col_names = "word"
)

# Membuat Edgelist
edgelist <- df_clean %>%
  select(text) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  count(word1, word2, sort = TRUE) %>%
  rename(source = word1, target = word2) %>%
  drop_na()

# Membuat Graph
graph <- as_tbl_graph(edgelist,
  directed = FALSE,
  node_key = name
) %>%
  activate(edges) %>%
  distinct() %>%
  activate(nodes) %>%
  mutate(degree_centrality = centrality_degree()) %>%
  mutate(pagerank_centrality = centrality_pagerank()) %>%
  arrange(desc(pagerank_centrality))

graph

visualisasi_tna <- graph %>%
  mutate(modularity = group_louvain()) %>%
  ggraph(layout = "fr") +
  geom_edge_link2(aes(edge_width = n, edge_colour = as.factor(node.modularity)),
    edge_alpha = 0.5
  ) +
  geom_node_point(aes(
    colour = as.factor(modularity),
    size = degree_centrality,
  ), alpha = 1, position = "identity") +
  geom_node_text(aes(
    size = degree_centrality,
    label = name
  ),
  alpha = 1,
  check_overlap = F,
  repel = F
  ) +
  scale_size(range = c(4, 9)) +
  scale_edge_width(range = c(0.4, 1)) +
  theme_graph() +
  theme(legend.position = "none")
visualisasi_tna

# Simpan Graph
ggsave(visualisasi_tna,
  filename = "plot/tna.png",
  bg = "white",
  width = 18,
  height = 18,
  dpi = 300,
  type = "cairo",
  units = "cm",
  limitsize = FALSE
)
