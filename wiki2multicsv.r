library(rvest)
library(XML)

url <- "https://en.wikipedia.org/wiki/Your_Page"
page <- read_html(url)
my_tables <- html_nodes(page, ".wikitable")
my_table <- my_tables[[2]] # Select the second table
my_table <- html_table(my_table, fill = TRUE)
write.csv(my_table, file = "Your_File.csv")
