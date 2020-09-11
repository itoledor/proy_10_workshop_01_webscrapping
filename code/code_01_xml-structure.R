library(here)
source(here("code", "code_01_setup.R"))

movies_xml <- read_xml('
<movies>
  <title>"Star Wars"</title>
  <movie episode = "IV">
    <title>A New Hope</title>
    <year>1977</year>
  </movie>
  <movie episode = "V">
    <title>The Empire Strikes Back</title>
    <year>1980</year>
  </movie>
</movies>')

# Find nodes with xml_find_all()
xml_find_all(movies_xml, xpath = "/movies/movie/title")

# Store the title nodeset
title_nodes <- xml_find_all(movies_xml, xpath = "/movies/movie/title")

# Extract contents with xml_text()
xml_text(title_nodes)

# Extract a node at any level below //
xml_find_all(movies_xml, "//title")

# Extract a node at any level below by attribute // and @
xml_find_all(movies_xml, "//movie/@episode")

# Example
# Find all nodes of class movie using xml_find_all()


# Extract the episode attribute using xml_attr()



