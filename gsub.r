# Apply the gsub function to the second, third, and fourth columns
data[,2:4] <- lapply(data[,2:4], function(x) gsub(".*?(\\b\\d{4}\\b).*", "\\1", x))
