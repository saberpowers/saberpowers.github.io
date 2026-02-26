
########################
# PACKAGE INSTALLATION #
########################

install.packages(c("brms", "devtools", "lme4"))                                                   #
devtools::install_github("statsbomb/StatsBombR")                                                  #




##################
# DATA WRANGLING #
##################

# Download all available NWSL data (it will only be the 2018 season)                              #
comp <- StatsBombR::FreeCompetitions() |>                                                         #
  dplyr::filter(competition_name == "NWSL")                                                       #
matches <- StatsBombR::FreeMatches(comp)                                                          #
data <- StatsBombR::free_allevents(MatchesDF = matches, Parallel = TRUE) |>                       #
  tibble::as_tibble()                                                                             #

# Identify all dribble events                                                                     #
dribble <- data |>                                                                                #
  dplyr::filter(type.name == "Dribble") |>                                                        #
  dplyr::mutate(                                                                                  #
    is_complete = dribble.outcome.name == "Complete"                                              #
  )                                                                                               #

# Create a lookup table for player name and team based on ID                                      #
player <- data |>                                                                                 #
  dplyr::count(player.id, player.name, team.name) |>                                              #
  # If a player appears for multiple teams, choose team with most appearances                     #
  dplyr::arrange(-n) |>                                                                           #
  dplyr::group_by(player.id) |>                                                                   #
  dplyr::slice(1) |>                                                                              #
  dplyr::ungroup() |>                                                                             #
  dplyr::select(player_id = player.id, name = player.name, team = team.name)                      #

# Find the "Dribbled Past" or "Duel" event associated with each "Dribble" to identify the defender#
dribble_related <- tibble::tibble(                                                                #
  id_dribble = rep(dribble$id, times = sapply(dribble$related_events, length)),                   #
  id = do.call(c, args = dribble$related_events)                                                  #
) |>                                                                                              #
  dplyr::inner_join(data, by = "id") |>                                                           #
  # There can be other related events ("Pressure"), but we want only "Dribbled Past" or "Duel"    #
  dplyr::filter(type.name %in% c("Dribbled Past", "Duel")) |>                                     #
  dplyr::select(id = id_dribble, id_related = id)                                                 #

# Create a dataframe of dribbles that includes dribbler ID/name, defender ID/name and outcome     #
dribble_outcome <- dribble |>                                                                     #
  dplyr::inner_join(dribble_related, by = "id") |>                                                #
  dplyr::inner_join(data, by = c("id_related" = "id"), suffix = c("", "_related")) |>             #
  dplyr::select(dribbler_id = player.id, defender_id = player.id_related, is_complete)            #




##############
# EXERCISE 1 #
##############

# Starting from the `dribble_outcome` table, create a `dribbler_summary` table that reports the
# observed dribbling performance of every player. Your table should include the following columns:
# - player_id
# - n (number of dribble attempts)
# - completions (number of successful dribbles)
# - obs_completion_rate (dribble success percentage)
#
# After creating this table, look at who the top dribblers are. Perform a left join with the
# `player` table to get player names and teams, and sort by `obs_completion_rate` (highest to
# lowest). What do you observe?




##############
# EXERCISE 2 #
##############

# Using the brms package, fit a Bayesian regression model using ONLY dribbler identity to predict
# dribble outcomes. << Hint: Use `dribbler_summary` as the data for this model. >>
#
# Extract the estimated player coefficients from this model, and convert them into predicted
# completion percentage using the logistic function. Create a table called `dribbler_est_brms`
# with the following columns:
# - player_id
# - beta (estimated player coefficient)
# - est_completion_rate (predicted completion percentage)




##############
# EXERCISE 3 #
##############

# Using your result from the previous exercise (`dribbler_est_brms`), perform a left join with
# the `player` table to create a leaderboard with player names and teams, sorted by mean-regressed
# completion rate (highest to lowest). Who are the best players by estimated completion rate?
#
# Create a plot with observed dribble completion rate on the x-axis and estimated dribble
# completion rate on the y-axis. What do you observe?




##############
# EXERCISE 4 #
##############

# Fit the same model as in Exercise 2, but use lme4::glmer instead of brms::brm.
# << Hint: Use `formula = cbind(completions, n - completions) ~ (1 | player_id)`. >>
#
# Extract the coefficients and create a table `dribbler_est_lme4` which holds the estimated
# completion rate for each player.
# Note: You can copy and paste your coefficient extraction code from Exercise 2 and then make edits.
#
# Plot these results (`dribbler_est_lme4`) against the results from Exercise 2
# (`dribbler_est_brms`). What do you observe?
# Note: You can copy and paste your plotting code from Exercise 3 and then make edits.




##############
# EXERCISE 5 #
##############

# Now extended the model from Exercise 4 to adjust for quality of opposition (the defender).
# To fit this model, you'll need to use `dribble_outcome` as your data instead of `dribbler_summary`
# because `dribbler_summary` does not include defender information. You'll also need to revise your
# formula to `is_complete ~ (1 | dribbler_id) + (1 | defender_id)`.
#
# Extract the coefficients and create a table `dribbler_est_lme4_sos` which holds the estimated
# completion rate for each dribbler.
# Note: You can copy and paste your coefficient extraction code from Exercise 4 and then make edits.
#
# Plot these results (`dribbler_est_lme4_sos`) against the results from Exercise 4
# (`dribbler_est_lme4`). What do you observe?
# Note: You can copy and paste your plotting code from Exercise 4 and then make edits.



