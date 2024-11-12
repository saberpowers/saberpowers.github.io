# First, read in the data.


# How many players do we have?



# Look at a histogram of 3-point attempts.


# How many players have at least 10 attempts?


# Only consider players with at least 10 attempts.



# Extract numbers of 3-point makes and attempts for each player.





# Compute the statistic (3-point percentage) for everyone.


# Estimate the league-average 3-point shooting percentage.




# Compute the variance due to luck for each player.
# Since this is a binomial variable, we just need to use the appropriate
# formula.



# Initialize our estimate of population variance to be zero.



# Repeatedly update our estimate using the equation from Wednesday.







# What is the estimated standard deviation in true talent 3-point percentage?



# Regress the statitics toward the mean using the equation from Monday.



# Look at the top and bottom players by estimated true talent.
# This can be interpreted as a 3-point shooting percentage leaderboard,
# adjusted for number of attempts but without having to set a minimum number of
# attempts.




# Plot estimated true talent vs. observed 3-point shooting percentage.




# Plot densities of observed and estimated true talent.








#################### CHALLENGE ####################
# Instead of performing regression to the mean on the dataset as a whole,
# split the players by position and perform regression to the mean within each
# position group. Then plot estimated true talent versus observed 3-point
# shooting percentage for all players, using a different color for each
# position. If you accomplish this, send the figure in an email to Scott.
###################################################
