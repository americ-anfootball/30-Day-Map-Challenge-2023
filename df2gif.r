# Load necessary libraries
library(dplyr)
library(tidyr)
library(sf)
library(rnaturalearth)
library(ggplot2)
library(gganimate)

# Read the CSV file
data <- read.csv("Analog3.csv")

# Convert the data to long format
data_long <- tidyr::pivot_longer(data, cols = c("Officially.launched", "Analog.closedowncommenced", "Analog.closedowncompleted"), names_to = "Event", values_to = "Year")

# Convert the Year column to numeric
data_long$Year <- as.numeric(data_long$Year)

# Create a new dataframe with one row for each country and year
all_years <- expand.grid(Year = 1996:2023, Country = unique(data_long$Country))

# Merge the data with all_years
data_long <- merge(all_years, data_long, all.x = TRUE)

# Categorize the status of each country for each year
data_long <- data_long %>%
  group_by(Country) %>%
  arrange(Year) %>%
  mutate(Status = case_when(
    Year < min(Year[Event == "Officially.launched"], na.rm = TRUE) ~ "Analog closedown not yet launched",
    Event == "Officially.launched" & Year <= Year ~ "Analog closedown officially launched",
    Event == "Analog.closedowncommenced" & Year == Year ~ "Analog closedown commenced",
    Year > min(Year[Event == "Analog.closedowncommenced"], na.rm = TRUE) & Year < min(Year[Event == "Analog.closedowncompleted"], na.rm = TRUE) ~ "Analog closedown in progress",
    Event == "Analog.closedowncompleted" & Year >= Year ~ "Analog closedown completed",
    TRUE ~ NA_character_
  )) %>%
  fill(Status) %>%
  ungroup()

# Get the world map data
world <- ne_countries(scale = "medium", returnclass = "sf")

# Set a fixed order for the polygons
world$order <- 1:nrow(world)

# Create a new dataframe with one row for each country and year
all_years <- expand.grid(Year = 1996:2023, name = world$name)

# Merge the data with all_years
data_long <- merge(all_years, data_long, by.x = c("Year", "name"), by.y = c("Year", "Country"), all.x = TRUE)

# Replace NA values in the Status column with "No data"
data_long$Status[is.na(data_long$Status)] <- "No data"

# Merge your data with the world map data
merged_data <- merge(world, data_long, by.x = "name", by.y = "name", all.x = TRUE)

# Order the merged data by the 'order' column
merged_data <- merged_data[order(merged_data$order), ]

# Create a directory to save the frames
dir.create("frames")

# Create a choropleth map for each year and save it as a PNG file
for(year in 1996:2023) {
  p <- ggplot() +
    geom_sf(data = subset(merged_data, Year == year), aes(fill = Status), color = NA) +
    scale_fill_brewer(palette = "Set3", na.value = "gray", limits = unique(merged_data$Status)) +  # Set the limits of the fill scale
    theme_minimal() +
    theme(legend.position = "bottom") +
    labs(title = paste('Year:', year), x = '', y = '') +
    ggtitle("An Analog Map: Countries' Transition from Analog Television by Year, 1996-2023")
  
  ggsave(paste0("frames/frame_", year, ".png"), plot = p)
}

# Load necessary library
library(magick)
library(purrr)  

# Read the frames
frames <- list.files(path = "frames", full.names = TRUE) %>%
  map(image_read) %>%
  image_join() %>%
  image_animate(fps = 20)

# Save the animation to a GIF file
image_write(frames, "animation.gif")
