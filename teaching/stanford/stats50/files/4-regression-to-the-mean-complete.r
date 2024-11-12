# First, read in the data.
data = read.csv('NBAtotals15-16.csv')

# How many players do we have?
nrow(data)


# Look at a histogram of 3-point attempts.
hist(data$X3PA)

# How many players have at least 10 attempts?
sum(data$X3PA > 9)

# Only consider players with at least 10 attempts.
subset = data$X3PA > 9


# Extract numbers of 3-point makes and attempts for each player.
makes = data$X3P[subset]
attempts = data$X3PA[subset]
names(makes) = names(attempts) = data$Player[subset]


# Compute the statistic (3-point percentage) for everyone.
S = makes/attempts

# Estimate the league-average 3-point shooting percentage.
muT = sum(makes)/sum(attempts)
print(muT)


# Compute the variance due to luck for each player.
# Since this is a binomial variable, we just need to use the appropriate
# formula.
sigma2L = muT*(1-muT)/attempts


# Initialize our estimate of population variance to be zero.
sigma2T = 0


# Repeatedly update our estimate using the equation from Wednesday.
for (i in 1:100000) {
    weight = 1/(2*(sigma2T + sigma2L)^2)
    sigma2T = sum(weight*((S - muT)^2 - sigma2L))/sum(weight)
}
print(sigma2T)


# What is the estimated standard deviation in true talent 3-point percentage?
sqrt(sigma2T)


# Regress the statitics toward the mean using the equation from Monday.
talent = (muT/sigma2T + S/sigma2L)/(1/sigma2T + 1/sigma2L)


# Look at the top and bottom players by estimated true talent.
# This can be interpreted as a 3-point shooting percentage leaderboard,
# adjusted for number of attempts but without having to set a minimum number of
# attempts.
head(sort(talent, decreasing = TRUE))
tail(sort(talent, decreasing = TRUE))


# Plot estimated true talent vs. observed 3-point shooting percentage.
plot(S, talent, xlim = c(.2, .5), col = 'darkorange')
abline(0, 1, col = 'dodgerblue')


# Plot densities of observed and estimated true talent.
plot(density(S), ylim = c(0, 35), col = 'darkorange',
    main = 'Distribution of 3-point shooting talent in NBA',
    xlab = '3-point shooting percentage')
lines(density(talent), col = 'dodgerblue')
legend('topright', c('True talent', 'Observed'),
    col = c('dodgerblue', 'darkorange'), lty = 1)


#################### CHALLENGE ####################
# Instead of performing regression to the mean on the dataset as a whole,
# split the players by position and perform regression to the mean within each
# position group. Then plot estimated true talent versus observed 3-point
# shooting percentage for all players, using a different color for each
# position. If you accomplish this, send the figure in an email to Scott.
###################################################
