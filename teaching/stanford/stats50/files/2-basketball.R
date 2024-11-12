# This R script contains starter code for the linear regression analysis of 
# basketball data tutorial covered in Stats 50 on April 8, 2016.
# Rather than write the instructions in really long comments on this file,
# I have placed most of the instructions in a pdf file available on the 
# course website.
# 
# As always, we will go through the tutorial together but you are welcome to 
# move at a faster pace if you wish.  I have compiled this lecture from a more
# advanced set of exercises produced by Will Fithian and Jackson Gorham for
# Stats 216.  That complete lecture is also  available on the course website
# and can serve as challenge problems if you find this material too easy.
#
# Happy coding!

#################################
## Part 1: Reading in the data ##
#################################

games <- read.csv("http://statweb.stanford.edu/~jgorham/games.csv",as.is=TRUE)
teams <- read.csv("http://statweb.stanford.edu/~jgorham/teams.csv",as.is=TRUE)

all.teams <- sort(unique(c(teams$team,games$home,games$away)))

# 1. How many games were played?  How many teams are there?


# 2. Did Stanford make the NCAA tournament?  What was its final AP and USA Today ranking?


# 3. How many games did Stanford play?  How did Stanford do against Berkeley?


# 4. What was Stanford's win-loss record?



#########################################################
## Part 2: A Linear Regression Model for Ranking Teams ##
#########################################################

X0 <- as.data.frame(matrix(0,nrow(games),length(all.teams)))
names(X0) <- all.teams

# 1. Create a vector `y` corresponding to the response variable.


# 2. Now fill in the the entries of `X0` column by column.



########################################
## Part 3: An Identifiability Problem ##
########################################

# Modify the `X0` matrix from the previous section to fix the 
# identifiability problem.  Name the modified matrix `X`.



###############################
## Part 4: Fitting the model ##
###############################

# 1. Fit the model using the `lm` function. Recall that if you don't
# know exactly how to use the `lm` function, you should look at the
# documentation by calling `?lm`.


# 2. Explore the estimated coefficients using `summary`.  What is the $R^2$ value?



####################################
## Part 5: Interpreting the model ##
####################################

# 1. What would be a reasonable point spread if Stanford played Berkeley
# (`california-golden-bears`)?  What if Stanford played Louisville
# (`louisville-cardinals`) (that year's national champions)?


# 2. What would be a reasonable point spread if Duke (`duke-blue-devils`)
# played North Carolina (`north-carolina-tar-heels`)?  If North Carolina
# played NC State (`north-carolina-state-wolfpack`)?


# 3. Does the dataset and model support the notion of home field advantage?
# How many points per game is it?



