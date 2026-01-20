# ==============================================================================
# Workshop Skeleton: Data Wrangling in R
# Dataset: data.csv (College Football 2025 Schedule/Results)
# ==============================================================================

# ------------------------------------------------------------------------------
# EXERCISE 1: Subsetting and Renaming
# Goal: Load the data and create a clean foundation.
# ------------------------------------------------------------------------------

# Use data.table::fread() to load "data.csv"
# Use dplyr::select() to pick columns and rename them to snake_case
# Use dplyr::filter() to remove rows with NA in points
cleaned_games <- data.table::fread("data.csv") |>
  dplyr::select(
    # NewName = OldName,
    ____ = ____, 
    ____ = ____, 
    ____ = ____, 
    ____ = ____, 
    ____ = ____
  ) |>
  dplyr::filter(____)


# ------------------------------------------------------------------------------
# EXERCISE 2: Aggregating Winners
# Goal: Calculate total wins and total points gained from the Winner column.
# ------------------------------------------------------------------------------

win_stats <- cleaned_games |>
  dplyr::mutate(point_diff = ____ - ____) |>
  dplyr::group_by(____) |>
  dplyr::summarize(
    total_wins = dplyr::n(),
    total_diff_plus = sum(____)
  )


# ------------------------------------------------------------------------------
# EXERCISE 3: Aggregating Losers
# Goal: Calculate total losses and total points conceded from the Loser column.
# ------------------------------------------------------------------------------

loss_stats <- cleaned_games |>
  dplyr::mutate(point_diff = ____ - ____) |>
  dplyr::group_by(____) |>
  dplyr::summarize(
    total_losses = dplyr::n(),
    total_diff_minus = sum(____)
  )


# ------------------------------------------------------------------------------
# EXERCISE 4: Joining for a Final Record
# Goal: Merge the win/loss tables and calculate the season-long differential.
# ------------------------------------------------------------------------------

league_standings <- win_stats |>
  # Join win_stats to loss_stats
  dplyr::full_join(____, by = c("____" = "____")) |>
  # Handle teams that never won or never lost
  tidyr::replace_na(list(
    total_wins = 0, 
    total_losses = 0, 
    total_diff_plus = 0, 
    total_diff_minus = 0
  )) |>
  # Calculate net differential
  dplyr::mutate(net_differential = ____ - ____) |>
  dplyr::arrange(dplyr::desc(____))


# ------------------------------------------------------------------------------
# EXERCISE 5: The "Tidy" Way (Pivoting)
# Goal: Re-calculate the standings using tidyr::pivot_longer() in one chain.
# ------------------------------------------------------------------------------

tidy_standings <- cleaned_games |>
  # Reshape the data so each team gets its own row
  tidyr::pivot_longer(
    cols = c(____, ____), 
    names_to = "____", 
    values_to = "____"
  ) |>
  # Assign points for and against based on the result_type
  dplyr::mutate(
    pts_for = dplyr::if_else(____ == "winner_team", ____, ____),
    pts_against = dplyr::if_else(____ == "winner_team", ____, ____),
    is_win = ____ == "winner_team"
  ) |>
  # Group by team and summarize all at once
  dplyr::group_by(____) |>
  dplyr::summarize(
    wins = sum(____),
    losses = sum(!____),
    total_diff = sum(____ - ____)
  ) |>
  dplyr::arrange(dplyr::desc(____))


# ------------------------------------------------------------------------------
# FINAL CHECK
# ------------------------------------------------------------------------------
utils::head(tidy_standings, 10)