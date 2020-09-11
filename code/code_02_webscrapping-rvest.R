library(here)
source(here("code", "code_01_setup.R"))

# Read html from a web link
wiki_r <- read_html("https://en.wikipedia.org/wiki/R_(programming_language)") 

wiki_r

# Select nodes of class "ul" at any level below using //
html_node(wiki_r, xpath = "//ul")     # Only the first node
html_nodes(wiki_r, xpath = "//ul")    # All the nodes

# Select nodes of class "table" at any level below using //
html_node(wiki_r, xpath = "//table")  # Only the first node
html_nodes(wiki_r, xpath = "//table") # All the nodes

# Extract the data from the first table
html_node(wiki_r, xpath = "//table") %>% html_table() %>% as_tibble()
html_text()
html_tag()

santiago <- read_html("https://en.wikipedia.org/wiki/Santiago")
santiago %>% html_node(".mergedtoprow th , .mergedtoprow~ .mergedtoprow+ .mergedtoprow td") %>% 
