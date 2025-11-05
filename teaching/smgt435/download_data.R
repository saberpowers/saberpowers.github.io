
download_test_data <- FALSE
year <- 2025

cluster <- parallel::makeCluster(parallel::detectCores())
data_statsapi <- sabRmetrics::download_statsapi(
  start_date = glue::glue("{year}-01-01"),
  end_date = glue::glue("{year}-12-31"),
  cl = cluster
)
parallel::stopCluster(cluster)

player <- sabRmetrics::download_player()
data.table::fwrite(player, file = "~/Downloads/player.csv")

event_table <- tibble::tribble(
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
  "Pickoff Error 1B",             "Not Batter Event",
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
  # TODO: Use batted ball trajectory for triple play 
  "Triple Play",                  "Flyout",
  "Walk",                         "Walk",
  "Wild Pitch",                   "Not Batter Event",
)

data_statsapi$pitch |>
  dplyr::mutate(spray_angle = round((atan((hit_coord_x - 125) / (205 - hit_coord_y))) * 180 / pi)) |>
  dplyr::filter(!is.na(launch_speed), !is.na(launch_angle), !is.na(spray_angle)) |>
  dplyr::select(game_id, event_index, launch_speed, launch_angle, spray_angle) |>
  data.table::fwrite(file = "~/Downloads/batted_ball.csv")

data_statsapi$event |>
  dplyr::left_join(event_table, by = "event") |>
  dplyr::left_join(batted_ball, by = c("game_id", "event_index")) |>
  dplyr::mutate(event = batter_event) |>
  dplyr::select(-batter_event) |>
  data.table::fwrite(file = "~/Downloads/event.csv")

data_statsapi$pitch |>
  sabRmetrics::get_quadratic_coef() |>
  sabRmetrics::get_trackman_metrics() |>
  dplyr::select(
    play_id, game_id, event_index, play_index, pitch_number, outs, balls, strikes, description,
    pitch_type, plate_x, plate_z,
    ax, ay, az, vx0, vy0, vz0, x0, z0, extension, strike_zone_top, strike_zone_bottom
  ) |>
  data.table::fwrite(file = "~/Downloads/pitch.csv")

data_statsapi$play |>
  dplyr::filter(is_stolen_base | is_caught_stealing) |>
  dplyr::transmute(
    play_id, game_id, event_index, play_index, pitch_number,
    event = dplyr::case_when(
      is_stolen_base ~ "Stolen Base",
      is_caught_stealing ~ "Caught Stealing"
    ),
    pre_runner_1b_id, pre_runner_2b_id, pre_runner_3b_id, pre_outs, pre_balls, pre_strikes,
    runs_on_play,
    post_runner_1b_id, post_runner_2b_id, post_runner_3b_id, post_outs, post_balls, post_strikes
  ) |>
  data.table::fwrite(file = "~/Downloads/sb_attempt.csv")


if (download_test_data) {

  cluster <- parallel::makeCluster(parallel::detectCores())
  data_statsapi_test <- sabRmetrics::download_statsapi(
    start_date = glue::glue("{year - 1}-01-01"),
    end_date = glue::glue("{year - 1}-12-31"),
    cl = cluster
  )
  parallel::stopCluster(cluster)

  pitch_test <- data_statsapi_test$pitch |>
    sabRmetrics::get_quadratic_coef() |>
    sabRmetrics::get_trackman_metrics() |>
    dplyr::arrange(play_id) |>
    dplyr::mutate(index = 1:dplyr::n())

  pitch_test |>
    dplyr::select(
      index, outs, balls, strikes,
      pitch_type, plate_x, plate_z,
      ax, ay, az, vx0, vy0, vz0, x0, z0, extension, strike_zone_top, strike_zone_bottom
    ) |>
    data.table::fwrite(file = "~/Downloads/pitch_test.csv")

  pitch_test |>
    dplyr::select(
      index,
      play_id, game_id, event_index, play_index, pitch_number, outs, balls, strikes, description,
      pitch_type, plate_x, plate_z,
      ax, ay, az, vx0, vy0, vz0, x0, z0, extension, strike_zone_top, strike_zone_bottom
    ) |>
    data.table::fwrite(file = "~/Downloads/pitch_test_full.csv")
}