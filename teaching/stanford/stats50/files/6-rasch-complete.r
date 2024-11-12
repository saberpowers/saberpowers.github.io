# Load necessary packages, installing them if this is your first time using the
# package.

require(glmnet)

install.packages('Matrix')
require(Matrix)

########## PROCESSING ##########

# Load the data into R.

data = read.csv('NBApbp11-12.csv')

# Extract each player occurence from the data.

player = unlist(data[, 1:10])

# How many players are present in the data?

num.players = length(unique(player))

# Label each player occurence as offense or defense.

prefix = rep(c('off', 'def'), each = 5*nrow(data))
tag = paste(prefix, player)
tag.factor = as.factor(tag)

# Define the row and column of X in which to put each 1.

i = rep(1:nrow(data), 10)
j = as.numeric(tag.factor)

# Construct X as a sparse matrix.

X = sparseMatrix(i, j)

# Update i and j to include a column for home court advantage.

i.new = c(which(data$Home == 1), i)
j.new = c(rep(1, sum(data$Home)), j + 1)

# Construct X as a sparse matrix with the updated i and j.

X = sparseMatrix(i.new, j.new)

# Create y, the vector storing the number of points scored on each possession.

y = data$Points

########## ANALYSIS ##########

# Use cv.glmnet to fit a regularized normal Rasch model to predict the expected
# number of points socred on each possession.

start.time = Sys.time()
rasch = cv.glmnet(X, y, alpha = 0, standardize = FALSE)
Sys.time() - start.time

# Check the diagnostic plot to make sure the default range of values considered
# for lambda is sufficient.

plot(rasch)

# Extract and label the fitted regression coefficients.

coef = coef(rasch, s = 'lambda.min')[, 1]
names(coef) = c('Intercept', 'HFA', sort(unique(tag)))

# Extract alpha, theta, delta and beta from coef.

alpha = coef[1]
theta = coef[2]
delta = coef[2 + 1:num.players]
beta = coef[2 + num.players + 1:num.players]
sort(beta)
sort(delta)
sort(beta - delta)

########## PRESENTATION ##########

# Offensive and defensive ratings are how many points you would expect a lineup
# of four average players
def.rating = 100*(alpha + theta/2 + delta)
off.rating = 100*(alpha + theta/2 + beta)

# Compute observed points scored, points allowed per 100 possessions for each
# player.
pp100 = 100*(crossprod(X, y)/colSums(X))[, 1]
names(pp100) = c('Home', sort(unique(tag)))
def.pp100 = pp100[1 + 1:num.players]
off.pp100 = pp100[1 + num.players + 1:num.players]

# Extract player initials for plotting
initials.with.space = gsub('[:a-z:]', '', names(beta))
initials = gsub(' ', '', initials.with.space)

# Who were the best offensive players in 2011-12? If you were to put each of
# them in a lineup with 4 average players, how many points per 100 possesions
# would that team score on offense against a lineup of 5 average players?
tail(round(sort(off.rating), 1))

# Who were the best defensive players in 2011-12? If you were to put each of
# them in a lineup with 4 average players, how many points per 100 possessions
# would that team allow on defense against a lineup of 5 average players?
head(round(sort(def.rating), 1))

# Who were the best overall players in 2011-12? If you were to add each of
# these players to a lineup, how much would that increase the lineup's point
# differential per 200 possessions?
tail(round(2*sort(off.rating - def.rating), 1))

# Plot defensive rating vs. offensive rating
plot(off.rating, def.rating, type = 'n', xlab = 'Offensive Rating',
    ylab = 'Defensive Rating', axes = FALSE)
abline(v = 100*(alpha + theta/2))
abline(h = 100*(alpha + theta/2))
abline(0, 1, lty = 2)
axis(1)
axis(2)
text(off.rating, def.rating, labels = initials, cex = 0.7, col = 'dodgerblue')

# Plot offensive rating vs. observed points scored per 100 poss.
plot(off.pp100, off.rating, type = 'n', axes = FALSE, xlim = c(75, 115),
    xlab = 'Team Points Scored Per 100 Poss', ylab = 'Offensive Rating')
abline(0, 1, lty = 2)
axis(1)
axis(2)
text(off.pp100, off.rating, labels = initials, cex = 0.7, col = 'dodgerblue')

# Plot defensive rating vs. observed points allowed per 100 poss.
plot(def.pp100, def.rating, type = 'n', axes = FALSE, xlim = c(75, 115),
    xlab = 'Team Points Scored Per 100 Poss', ylab = 'Defensive Rating')
abline(0, 1, lty = 2)
axis(1)
axis(2)
text(def.pp100, def.rating, labels = initials, cex = 0.7, col = 'dodgerblue')
