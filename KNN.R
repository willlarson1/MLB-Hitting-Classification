# modified version of the baseballr package used in this example. It solves
# errors caused by additional fields added to statcast data in recent months
# devtools::install_github("mlascaleia/baseballr")

library(baseballr)
library(tidyverse)

# Basic function to get batter data from the baseballr package, used in the function below
# test <- statcast_search_batters(start_date = "2024-04-06",
#                                 end_date = "2024-04-07",
#                                 batterid = NULL)

# Retrieves batting data from a date range, cleans it, and extracts launch angle
# and exit velocity information
get_batting_data <- function(start, end, batter = NULL) {
  
  raw <- statcast_search_batters(start_date = start,
                                 end_date = end,
                                 batterid = batter)
  cleaned <- raw |> 
    filter_at(vars(launch_speed, launch_angle), all_vars(!is.na(.))) |>
    filter(description == "hit_into_play") |>
    rename(XXX = launch_angle) |>                # three rows are inserted due to
    rename(launch_angle = launch_speed) |>       # error in baseballr function;
    rename(launch_speed = hit_distance_sc) |>    # can be removed when patched
    mutate(events = replace(events, # combine all "out equivalents" into just "out"
                            events == "double_play" | events == "field_error" |
                              events == "field_out" | events == "fielders_choice" |
                              events == "fielders_choice_out" | events == "force_out" |
                              events == "grounded_into_double_play" | 
                              events == "sac_bunt" | events == "sac_fly", 
                            "out")) |>
    select(game_date, player_name, launch_speed, launch_angle, events, description) |>
    filter(events == "out" | events == "single" | events == "double" |
             events == "triple" | events == "home_run")
  cleaned
}

# Retrieve batting data in batches, then clean and view it
batting_data <- get_batting_data("2024-05-01", "2024-05-05")
batting_data <- bind_rows(batting_data, get_batting_data("2024-05-06", "2024-05-10"))
batting_data <- na.omit(batting_data)

ggplot(batting_data, aes(x = launch_speed, y = launch_angle, color = events)) + 
  geom_point(shape = "o") + 
  scale_color_manual(values = c("out" = "gray", "single" = "cyan", 
                                  "double" = "darkcyan", "triple" = "blue4",
                                  "home_run" = "darkgoldenrod1")) +
  ggtitle("MLB Hitting Outcomes by Exit Velocity and Launch Angle", 
          subtitle = "Data from 5/1/24 to 5/10/24 (6,477 observations)") +
  xlab("Exit Velocity (mph)") +
  ylab("Launch Angle (deg)") +
  scale_x_continuous(breaks = seq(0, 125, by = 20)) + 
  scale_y_continuous(breaks = seq(-90, 90, by = 15)) +
  geom_hline(yintercept = 0, size=.5) + 
  labs(color = "Outcome")


# K-Nearest Neighbor
library(class)

training_data <- batting_data[1:6000]
testing_data <- batting_data[6001:6477]

training_v <- training_data$events
testing_v <- testing_data$events

training_data <- select(training_data, launch_speed, launch_angle)
testing_data <- select(testing_data, launch_speed, launch_angle)

# finding the best K
set.seed(2)
k = 1
optimal_k = 1
for (k in 1:200) {
  x <- knn(training_data, testing_data, training_v, k = k)
  accuracy = 100 * sum(x == testing_v)/length(testing_v)
  optimal_k[k] <- accuracy
  cat(k, "=", accuracy, "\n")
}

plot(optimal_k, type="l", xlab = "k", ylab = "% accuracy", main="KNN Accuracy by K")
max(optimal_k) # 79.03
match(max(optimal_k), optimal_k) # k=74
