# Install and Load Packages -----------------------------------------------

# Install Package
install.packages(c("tidyverse", 
                   "tidygraph", 
                   "ggraph", 
                   "igraph"))

# Load package
library(tidyverse)
library(tidygraph)
library(ggraph)
library(igraph)

# Load Data ---------------------------------------------------------------

# Load data
df <- read_csv("data/tweet-bjorka.csv") 
head(df)

# Convert to Edgelist -----------------------------------------------------

# Membuat edge-List mention
edgelist <- df %>%
  rtweet::unflatten() %>%
  select(screen_name, mentions_screen_name) %>%
  unnest(mentions_screen_name) %>%
  drop_na() %>%
  rename(source = screen_name, target = mentions_screen_name) %>%
  select(source, target)
edgelist

# Simpan Edgelist
write_csv(edgelist, "data/edgelist.csv")

# Membuat network
g <- graph_from_data_frame(edgelist, directed = FALSE)

# Properti Network --------------------------------------------------------

# Pengukuran network secara keseluruhan
properti_network <- tibble(jumlah_node = vcount(g), 
                         jumlah_edge = ecount(g), 
                         average_path_length = average.path.length(g), 
                         diameter = diameter(g), 
                         density = edge_density(g), 
                         modularity = modularity(cluster_louvain(g)))
properti_network


# Sentralitas -------------------------------------------------------------

# Mengukur metrik sentralitas
g_tidy <- as_tbl_graph(g) %>%
  mutate(degree_centrality = centrality_degree()) %>%
  mutate(betweenness_centrality = centrality_betweenness()) %>%
  mutate(eigen_centrality = centrality_eigen()) %>%
  mutate(modularity = group_louvain())

# Menampilkan hasil pengukuran sentralitas
g_tidy %>%
  arrange(desc(degree_centrality)) %>%
  as_tibble()

# Visualisasi -------------------------------------------------------------

# Memvisualisasikan network
plot <- g_tidy %>%
  filter(degree_centrality > 10) %>%
  mutate(connected_component = group_components()) %>%
  filter(connected_component == 1) %>%
  ggraph(layout = "fr") +
  geom_edge_link2(aes(edge_colour = as.factor(node.modularity)),
                 edge_width = 0.3,
                 edge_alpha = 0.4
  ) +
  geom_node_point(aes(
    colour = as.factor(modularity),
    size = degree_centrality,
    alpha = 1
  ), position = "identity") +
  geom_node_text(aes(
    size = degree_centrality,
    label = name
  ),
  alpha = 1,
  check_overlap = T,
  repel = F
  ) +
  scale_size(range = c(1, 7)) +
  theme_graph() +
  theme(legend.position = "none")

# Menyimpan hasil visualisasi network
ggsave(plot,
       filename = "plot/social-network.png",
       width = 20,
       height = 20,
       dpi = 300,
       type = "cairo",
       units = "cm",
       limitsize = FALSE
)
