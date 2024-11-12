# Let's begin this tutorial the same way we begin every other tutorial:
# Reading the data into R.

# The dataset is taken from http://prwolfe.bol.ucla.edu/cfootball/scores.htm



# To fit Bradley-Terry models, we need to build our regression matrix X. Recall
# that X has a row for each game and a column for each team (plus one column
# corresponding to home-field advantage). So to set up X, we need to get a list
# of all teams in the dataset.

# First let's extract the home and away team from the dataset. We use the
# as.character function here to treat the team names as strings rather than
# "factors", which is what they would be by default.




# How many games do we have for each team?




# From the above, we see that there are very many teams, playinng various
# numbers of games. This is because many are non-FBS teams, meaning that they
# are not in the highest division of college football, let's combine them all 
# into one "nonFBS" entity and pretend they are all the same team.

# First, we need to identify the non-FBS teams.



# Next, replace each non-FBS team with the character string "nonFBS".





# Now that we have performed the above pre-processing on the teams, we are
# ready to set up the regression matrix X.



# Next loop through the rows (games) and insert +1's and -1's corresponding to
# the home and away teams in each game.







# Finally, fill in the home-field advantage column, which is 1 for each game
# except those on a neutral field, for which it is 0.



# We successfully completed the regression matrix X, and the response vector y
# is much easier to build.



# Let's pretend that we are using the Bradley-Terry model to predict the
# results of bowl games at the end of the season. Build a logical vector which
# is TRUE for bowl games and FALSE for regular season games.



# The R package that we will use to fit the regularized Bradley-Terry models is
# glmnet, which is short for "generalized linear models with elastic net". This
# R package was written by Stanford professors Trevor Hastie, Rob Tibshirani
# and Jerome Friedman.

# The first time you use an R package, you need to install it. The next time
# you use it, you DO NOT need to install it again. Note that the name of the
# package that we want to install is in quotation marks.



# Every time you use an R package, you need to load it. 



# Now, let's fit a regularized normal Bradley-Terry model, using
# cross validation to choose the regularization parameter lambda. For this
# class, we will aways specify (alpha = 0) in cv.glmnet. Here we specify
# (intercept = FALSE) because we have included a custom intercept ourselves in
# the regression matrix X. So we do not want cv.glmnet to add its own
# intercept. We specify (standardize = FALSE) because we have carefully
# constructed our X, and we do not want cv.glmnet to apply its own automatic
# processing.




# We can plot the cross validation error for each lambda to check that the
# default range of lambda chosen by cv.glmnet is sufficient in this case.
# We hope to find that the lowest cross validation error is somewhere in the
# middle of the range. If it's at the edge of the range, then we should
# consider smaller or larger values of lambda.



# In fact the plot shows us that we need to consider smaller values of lambda.
# To do so, we need to specify lambda in our call to cv.glmnet.





# Now let's check that we've fixed the problem we discovered through the
# diagnostic plot.



# So we check a diagnostic plot and fixed our model. Now
# we can use it to predict the score differential of each game. We do this
# with the predict function. We specify (s = 'lambda.min') so that R knows to
# use the value of lambda which led to the minimum cross validation error.




# Let's plot acutual score differential versus predicted score differential for
# regular season games.





# How many regular season games does our model correctly predict the winner of?



# Using the predict function, let's extract the beta for each team. This is how
# we can rank the teams based on regular season performance.





# What is the magnitude of home-field advantage in college football?



# Ohio State beat Oregon in the College Football Playoff championship game.
# By how many points would our model favor Ohio State over Oregon on a neutral
# field?



# By how many points would our model favor Stanford over Cal at home?



# What percentage of bowl games does our model correctly pick the winner of?
# Why is it so much lower than the percentage of regular season games our model
# correctly picks?




# Let's try a different approach: a regularized binomial Bradley-Terry model.
# We fit it using almost exactly the same code as for the regularized normal
# Bradley-Terry model. There are two differences: 1. We need to turn y into an
# indicator of whether the home team won and 2. we need to specify
# (family = "binomial") in the call to cv.glmnet.




# Don't forget to check the diagnostic plot!



# As before, let's predict the results of the games using this regularized
# binomial Bradley-Terry model. We specify (type = 'response') so that the
# prediction is reported as a probability.



# What fraction of regular season games does our model accurately pick?



# Again, let's extract beta for each team to rank them. How are these rankings
# different from the earlier rankings?





# Finally, how good is the binomial model at predicting the results of bowl
# games? Is is better or worse than the normal model?




#################### CHALLENGE ####################
# Repeat the above analysis by treating each non-FBS team as its own entity,
# instead of combining them under one name. For each model (normal and
# binomial), does this lead to better or worse bowl game predictions?
###################################################
