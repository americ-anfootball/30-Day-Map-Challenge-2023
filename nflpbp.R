library(sportyR)
library(ggplot2)
library(gganimate)
library(dplyr)

example_nfl_game <- data.table::fread("NFL21.csv")

example_nfl_game <- as.data.frame(example_nfl_game)

example_nfl_game$color[example_nfl_play$team == "home"] <- "#002147"
example_nfl_game$color[example_nfl_play$team == "away"] <- "#FF0800"
example_nfl_game$color[example_nfl_play$team == "football"] <- "#624a2e"

nfl_field = geom_football(
    "nfl",
    x_trans = 60,
    y_trans = 26.6667,
    color_updates = list(
        field_apron = "#228B22",
        field_border = "#228B22",
        offensive_endzone = "#002147",
        defensive_endzone = "#FF0800",
        offensive_half = "#228B22",
        defensive_half = "#228B22",
        team_bench_area = "#FFFFFF"
    )
)

play_anim <- nfl_field +
    geom_point(data = example_nfl_game, aes(x = x, y = y, color = color)) +
    transition_time(example_nfl_game$frameId)

# Show the animation
play_anim

