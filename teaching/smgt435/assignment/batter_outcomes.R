
year <- 2024

cluster <- parallel::makeCluster(parallel::detectCores())
data <- sabRmetrics::download_statsapi(
  start_date = glue::glue("{year}-01-01"),
  end_date = glue::glue("{year}-12-31"),
  cl = cluster
)
parallel::stopCluster(cluster)

event_table = tibble::tribble(
  ~event,                         ~batter_event,
  "Balk",                         "Not Batter Event",
  "Batter Out",                   "Not Batter Event",
  "Bunt Groundout",               "Groundout",
  "Bunt Lineout",                 "Flyout",
  "Bunt Pop Out",                 "Flyout",
  "Catcher Interference",         "Not Batter Event",
  "Caught Stealing 2B",           "Not Batter Event",
  "Caught Stealing 3B",           "Not Batter Event",
  "Caught Stealing Home",         "Not Batter Event",
  "Double",                       "Double",
  "Double Play",                  "Flyout",
  "Field Error",                  "Reached on Error",
  "Field Out",                    "Groundout",
  "Fielders Choice",              "Groundout",
  "Fielders Choice Out",          "Groundout",
  "Flyout",                       "Flyout",
  "Forceout",                     "Groundout",
  "Game Advisory",                "Not Batter Event",
  "Grounded Into DP",             "Groundout",
  "Groundout",                    "Groundout",
  "Hit By Pitch",                 "Hit By Pitch",
  "Home Run",                     "Home Run",
  "Intent Walk",                  "Not Batter Event",
  "Lineout",                      "Flyout",
  "Passed Ball",                  "Not Batter Event",
  "Pickoff 1B",                   "Not Batter Event",
  "Pickoff 2B",                   "Not Batter Event",
  "Pickoff 3B",                   "Not Batter Event",
  "Pickoff Caught Stealing 2B",   "Not Batter Event",
  "Pickoff Caught Stealing 3B",   "Not Batter Event",
  "Pickoff Caught Stealing Home", "Not Batter Event",
  "Pop Out",                      "Flyout",
  "Runner Out",                   "Not Batter Event",
  "Sac Bunt",                     "Not Batter Event",
  "Sac Bunt Double Play",         "Not Batter Event",
  "Sac Fly",                      "Flyout",
  "Sac Fly Double Play",          "Flyout",
  "Single",                       "Single",
  "Stolen Base 2B",               "Not Batter Event",
  "Stolen Base 3B",               "Not Batter Event",
  "Stolen Base Home",             "Not Batter Event",
  "Strikeout",                    "Strikeout",
  "Strikeout Double Play",        "Strikeout",
  "Triple",                       "Triple",
  "Triple Play",                  "Flyout",
  "Walk",                         "Walk",
  "Wild Pitch",                   "Not Batter Event",
)

batted_ball <- data$pitch |>
  dplyr::transmute(
    game_id,
    event_index,
    launch_speed,
    launch_angle,
    spray_angle = round((atan((hit_coord_x - 125) / (205 - hit_coord_y))) * 180 / pi)
  ) |>
  dplyr::filter(!is.na(launch_speed), !is.na(launch_angle), !is.na(spray_angle))

data$event |>
  dplyr::left_join(event_table, by = "event") |>
  dplyr::left_join(batted_ball, by = c("game_id", "event_index")) |>
  dplyr::mutate(event = batter_event) |>
  dplyr::select(-batter_event) |>
  write.csv("~/Downloads/event.csv", row.names = FALSE, na = "")

cluster <- parallel::makeCluster(parallel::detectCores())
data_test <- sabRmetrics::download_statsapi(
  start_date = glue::glue("{year - 1}-01-01"),
  end_date = glue::glue("{year - 1}-12-31"),
  cl = cluster
)
parallel::stopCluster(cluster)

