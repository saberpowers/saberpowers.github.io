
game <- data.table::fread("cfb_game_scores.csv") |>
  dplyr::select(
    week = Wk,
    winner_team = Winner, 
    winner_points = Pts, 
    loser_team = Loser, 
    loser_points = Pts.1 
  ) |>
  dplyr::filter(!is.na(Pts), !is.na(Pts.1))

standings <- game |>
  # Reshape the data so each team gets its own row
  tidyr::pivot_longer(
    cols = c(winner_team, loser_team), 
    names_to = "outcome", 
    values_to = "team_ranking"
  ) |>
  # Assign points for and against based on the result_type
  dplyr::mutate(
    points_for = dplyr::if_else(outcome == "winner_team", points_winner, points_loser),
    points_against = dplyr::if_else(outcome == "winner_team", points_loser, points_winner),
    is_win = outcome == "winner_team",
    parenthesis_location = stringr::str_locate(team_ranking, "\\) ")[, "start"],
    team = substring(team_ranking, dplyr::coalesce(parenthesis_location + 2, 1))
  ) |>
  # Group by team and summarize all at once
  dplyr::group_by(team) |>
  dplyr::summarize(
    wins = sum(is_win),
    losses = sum(!is_win),
    win_pct = mean(is_win),
    mean_score_diff = mean(points_for - points_against)
  ) |>
  dplyr::filter(wins + losses > 7) |>
  dplyr::arrange(-wins, -mean_score_diff)

standings |>
  head(10) |>
  gt::gt() |>
  gt::cols_label(
    team = "Team",
    wins = "Wins",
    losses = "Losses",
    win_pct = "Win%",
    mean_score_diff = "Avg Score Diff"
  ) |>
  gt::fmt_percent(win_pct, decimals = 1) |>
  gt::fmt_number(mean_score_diff, decimals = 1, force_sign = TRUE) |>
  gt::cols_align(align = "center", columns = dplyr::where(is.numeric)) |>
  gt::gtsave("~/Downloads/standings.png", zoom = 5)


pdf("~/Downloads/standings.pdf", height = 5, width = 5)
plot <- standings |>
  ggplot2::ggplot(ggplot2::aes(x = win_pct, y = mean_score_diff)) +
  ggplot2::geom_smooth(method = "lm", formula = "y ~ x", color = "gray") +
  ggplot2::geom_point(col = "dodgerblue", alpha = 0.8) +
  ggplot2::labs(x = "Winning Percentage", y = "Average Score Difference") +
  ggplot2::scale_x_continuous(
    name = "Winning Percentage",
    breaks = c(0, 0.25, 0.5, 0.75, 1),
    labels = c("0%", "25%", "50%", "75%", "100%")
  ) +
  ggplot2::theme_classic()
print(plot)
dev.off()
