# This R script is a tutorial on visualizing and manipulating data. There are
# five checkpoints that we will go through as a class, but you are encouraged
# to move at a faster pace than the class if you so desire. At the end, there
# are two challenges for those who found the exercises to be two easy.

# Let's start with the most basic capabilities of R, which can be thought of as
# a glorified calculator. To demonstrate this, trying running the line of code
# below, which should output 4.

2 + 2

# Checkpoint 1: Were you able to put 2 and 2 together in R?




# Something that makes R much easier to use on big problems than a calculator
# is strong variables. For example, the line of code before stores 4 as the
# variable x.

x = 2 + 2

# If we run the line of code below (equivalent to typing x and hitting enter in
# the console), then x is printed.

x

# Typing the name of a variable is equivalent to calling the print() function
# with it as an argument, for example:

print(x)

# Now that we have 4 stored in the variable x, we can use x instead of 4 to
# print the sum of 4 and 2:

x + 2

# With the most basic R commands established, let's do something a little more
# interesting.


# Tom Brady won this year his last SuperBowl, after 19 seasons in the NFL.

# In R, we can create a vector by using the function c() and listing the
# the entries we want in the vector, separated by a comma. Below we create
# vectors storing the year-by-year passing yards and game totals for Brady

yards = c(6, 2843, 3764, 3620, 3692, 4110, 3529, 4806, 76, 4398, 3900, 
          5235, 4827, 4343, 4109, 4770, 3554, 4577, 4355)
games = c(1,15,16,16,16,16,16,16,1,16,16,16,16,16,16,16,12,16,16)

# As before, we can simply enter the names of the vectors to print them to the
# console.

yards
games

# Basic arithmetic operations on vectors are done element-wise in R. For
# example we can get Brady's passing yards per game in each season of his
# career using the command below.

yards.per.game = yards/games

# Let's print yards per game to see what it looks like.

yards.per.game

# To create a vector with uniform spacing between the elements, we can use the
# function seq. See ?seg for more details. Below we create a vector containing
# the years of Brady's career by defining a vector from 2007 to 2015,
# counting by 1.

year = seq(2000, 2018, 1)
year

# Another way to create this same vector is by using the : operator as we do
# below.

year = 2000:2018
year

# Arithmetic operations involving a scalar (like 1985) and a vector (like year)
# act elementwise. The operation with the scalar is applied to each element of
# the vector. For example, the command below substract 1985 from each element
# of our year vector. Because Brady was born in 1985, this gives us his age
# in each season of his career.

age = year - 1977
age

# Next let's plot Brady's receiving yards per game by age:

plot(age, yards.per.game)

# The plot() function in R has a lot of options that can be tweaked. For
# example, you can adjust the size, shape and color of the plotted points;
# you can change a x- and y-axis labels, as well as the main plot title;
# and you can add a legend or use custom axes. To learn more about all of these
# options, check out the documentation for plot() using the command below.

?plot

# An important feature in R is indexing, or accessing specific elements of
# vectors and matrices. In R, this is done using square brackets. For example
# the line of code below returns the 5th through 6th elements of the
# yards.per.game vector.

yards.per.game[5:7]

# We can also take remove elements of the vector using negative index. For
# example the line of code below returns all but entries 1, 2 and 3 of the
# yards.per.game vector.

yards.per.game[-c(1, 2, 3)]

# Indexing can also be done with vectors of logicals, as long as those vectors
# of logicals have the same length as the vectors they are indexing. Let's
# create a logical vector which flags seasons in which Brady played 16 games.

games == 16

# Next, we can use this vector to return yards per game for seasons in which
# Brady played at least 16 games.

yards.per.game[games == 16]

# The & operator returns the logical TRUE if and only if both arguments to it
# are true. For example, the line of code below returns TRUE for seasons in
# which Brady played 16 games before 2015.

games == 16 & year < 2015

# And as before we can print his receiving yards per game in those seasons
# using the line of code below.

yards.per.game[games >= 16 & year < 2015]

# As one last example, let's print the seasons in which Brady averaged over
# 100 receiving yards per game.

year[yards.per.game > 100]

# Switching gears, let's cover a few more function in R. The function mean()
# returns the average of a vector (the sum of it's elements divided by its
# length). For example, the command below returns Brady's average passing
# yards per year.

mean(yards)

# The sum() function adds up all of the elements in a vector. For example, the
# command below adds up all of Brady's yards and divides by hist total number
# of games played, thus returning his career average receiving yards per game.

sum(yards)/sum(games)

# The sort() function returns a vector sorted in increasing order.

sort(yards.per.game)

# You can sort instead in decreasing order by toggling one argument to sort().

order(yards.per.game, decreasing = TRUE)

# A related function to sort() is order(), which returns the indices of the
# vector, in order from smallest element to larget element.

order(yards.per.game)

# As you can see, if you then use this to index the vector, you get the same
# output as sorting the vector.

yards.per.game[order(yards.per.game)]

# The reason you would do this instead of sorting is if you want to order a
# variable according to the order of a different variable. For example, let's
# sort Brady's season from most receiving yards per game to least.

year[order(-yards.per.game)]


# Reading data into R

# We don't want to enter all data manually, so let's learn how to read data
# from a CSV file. The first step is to download the CSV file and store it
# somewhere on your computer. Then, in R, we need to navigate to the folder
# in which you have saved this CSV file. In R and RStudio, you can do this
# using the drop-down menu from the top. Alternatively, you can do it using a
# command in R: setwd(), meaning "set working directory". For example, here's
# the directory in which I have saved receiving2015.csv from the class website.

# setwd('Dropbox/stanford/stats50/r')

# We will use the read.csv() function to store the data from the CSV file in a
# variable which we will call data. The read.csv() function has some additional
# arguments that can help you deal with files that aren't formatted perfectly
# (see ?read.csv), but you don't need to worry about that for this particular
# file.

data = read.csv('receiving2018.csv')

# Ensuring that our dataset is "cleaned" for analysis 
# (especially removing the "*" and "+" in players'names, and standardizing players'positions)
data$Player = gsub('\\+','',gsub('\\*', '', data$Player))
data$Pos = toupper(data$Pos)


# Now that the data have been read into R, we can start manipulating them. For
# starters, let's print the first six rows of the data to the console using
# the function head().

head(data)

# We see that the data are receiving statistics for NFL players. The data
# include statistics like team, age, position, games played, targets (the
# number of passes intended for that player), receptions, receiving yards and
# receiving touchdowns. Included in the dataset are all players with at least
# one reception in the 2015 NFL season.

# Checkpoint 2: Were you able to view the first six rows of the data in R?




# Generally, before printing the head of a dataset, it's good to check the size
# of the data. For example, you wouldn't want to print the head of a dataset
# with 10,000 columns. The function dim() returns the numbers of rows and
# columns of the data, which the functions nrow() and ncol() do individually.

dim(data)
nrow(data)
ncol(data)

# Another good way to get a basic overview of the data in R is to use the
# summary() function. For quantitative variables, summary() shows the minimum,
# first quartile, median, mean, third quartile and maximum value of the
# variable. For qualitative variables, summary() shows the most common values.

summary(data)

# Our data variable is a data.frame in R, which we can see by using the
# following line of code:

class(data)

# A data.frame is like a matrix in R, but it's technically a list, not a
# matrix. The distinction is nuanced and will cause you to pull out your hair
# later on in the course, I'm sure. But let's worry about that later. You can
# access individual columns of data.frames using the $ operator like so:

data$Yds

# Let's add a column to the data which records for each player his yards per
# target. For each player, this is how many yards he gained on average per
# attempted pass to him by his quarterback.

data$YPT = data$Yds/data$Tgt

# We can create a histogram to look at the distribution of yards per target
# among all NFL players using the hist() function.

hist(data$YPT)

# The histogram shows some outliers by yards per target, and these are probably
# players who don't have very many targets. Let's ignore all players who do not
# meet a minimum threshold for targets. To choose this threshold, let's look at
# the distribution of targets among the players.

hist(data$Tgt)

# We can get a histogram with more bins by tweaking the breaks argument in
# hist().

hist(data$Tgt, breaks = 20)

# Based on the histogram of targets, I'm inclined to choose 30 as the minimum
# threshold for number of targets. Let's look at the distribution of yards per
# target among all players with at least 30 targets.

hist(data$YPT[data$Tgt >= 30])

# Exercise 1:
# Plot a histogram of receiving yards per game for all running backs who played
# at least 15 games. Write your code below.

hist(data$Y.G[data$Pos == 'RB' & data$G >= 15])

# Checkpoint 3: Did you complete Exercise 1?

# Who led the league in yards per target? First, let's find the highest yards
# per target among all players with at least 30 targets, using the max
# function.

max(data$YPT[data$Tgt >= 30])

# We can use the which.max() function to return the index of the player who
# led the league in yards per target, minimum 30 targets.

leader = which.max(data$YPT[data$Tgt >= 30])

# Finally, let's extract the data for this leader. First, we need to limit the
# data to players with at least 30 targets. We will use indexing to do this.
# For matrices, indexing takes two arguments separated by a comma: which rows
# to keep and which columns to keep. For example, let's define a new variable
# data.min which only includes players with at least 30 targets. To do so,
# we specify data$Tgt >= 30 to index the rows, and we leave the indexing of the
# columns blank. This means that we keep all columns.

data.min = data[data$Tgt >= 30, ]

# Next, let's index data.min to extract the row corresponding to the league
# leader in yards per target.

data.min[leader, ]

# Tyler Lockett is the leader, but this is dissatisfying because Tyler only has
# 70 targets. Let's set the mininum threshold a little bit higher, at 100. The
# next line of code combines the previous three lines of code into one. Observe
# how we first extract the rows of data corresponding to players with at least
# 100 targets, and we then extract the row corresponding to the league leader.

data[data$Tgt >= 100, ][which.max(data$YPT[data$Tgt >= 100]), ]

# Let's create another sub-dataset corresponding only to wide receivers.

wr = data[data$Pos == 'WR', ]
nrow(wr)

# We can use the order() function to sort the entire wr data.frame by yards
# per target. Let's look at the data for the top six wide receivers by yards
# per target.

head(wr[order(-wr$YPT), ])

# Next, let's get the top six wide receivers by yards per target, among all
# wide receivers who have at least as many targets as Sammy Watkins.

wr2 = data[data$Pos == 'WR' & data$Tgt >= 96, ]
nrow(wr2)
head(wr2[order(-wr2$YPT), ])

# We can do the same thing for tight ends. Here are the top six tight ends by
# yards per target.

te = data[data$Pos == 'TE', ]
nrow(te)
head(te[order(-te$YPT), ])

# But some players are listed as "FB/TE" or "TE/WR", and those players won't
# be included if we only consider players whose position is "TE". To include
# these players, we will use the grep() function. grep('TE', data$Pos) returns
# the indices of all players who have "TE" in their position string.

grep('TE', data$Pos)

# We can use these indices to view the data for the top six players who have
# "TE" in their position.

te2 = data[grep('TE', data$Pos), ]
nrow(te2)
head(te2[order(-te2$YPT), ])

# Exercise 2:
# Who led all quarterbacks in receiving yards in 2018? Write your code below.

qb = data[data$Pos == 'QB', ]
head(qb[order(-qb$Yds), ])  # Marcus Mariota (21 yards)


# Checkpoint 4: Did you complete Exercise 2?

# A really neat function in R is aggregate(). You can use aggregate() to group
# data by a specific variable. For example, the code below adds up receiving
# yards by position. The first argument describes the data you wish to be
# aggregated, in this case yards. The second argument describes which variable
# you want to aggregate on, in this case position. The third argument describes
# how you want to aggregate the data, in this case using the sum function.

YdsByPos = aggregate(data$Yds, list(Pos = data$Pos), sum)
YdsByPos

# We can also find the most receiving yards that any one player had at each
# position by using the max function instead of the sum function as the third
# argument.

MaxYdsByPos = aggregate(data$Yds, list(Pos = data$Pos), max)
MaxYdsByPos

# We can also aggregate on more than one variable. For example, the line of
# code below finds for each team, the most receiving yards that any wide
# receiver had, as well as the most receiving yards that any non-wide receiver
# had, because the two variables that we are grouping on are (1) a logical
# indicator of whether position is WR and (2) team.

aggregate(data$Yds, list(WR = data$Pos == 'WR', Team = data$Tm), max)

# We observe that only Carolina, Oakland, Philadelphia, San Francisco
# and Washington had non-wide receivers lead the team in receiving yards.

# Exercise 3:
# Among all receivers who led their team in receiving yards, who had the fewest
# receiving yards? How many yards did he have? Write your code below.

leaderYards = aggregate(data$Yds, list(Team = data$Tm), max)
head(leaderYards[order(leaderYards$x), ])
data[data$Tm == 'WAS' & data$Yds == 558, ]    # Jordan Reed (WAS), 558 yards


# Checkpoint 5: Did you complete Exercise 3?

# CHALLENGE 1
# Download receiving2015.csv from the class website and use it to plot 2018
# receiving yards per target against 2015 receiving yards per target for all
# players who have at least 30 targets in both seasons.
# Hint: ?merge

data15 = read.csv('receiving2015.csv')

# Ensuring that all columns in both datasets are identifiable and have the same name
data15$Player = data15$Receiver
data15$Tm = data15$Team
data15$Team <- NULL
data15$Receiver <- NULL

merged = merge(data15, data, by = 'Player')
subset = merged$Tgt.x >= 30 & merged$Tgt.y >= 30
plot((merged$Yds.x/merged$Tgt.x)[subset], (merged$Yds.y/merged$Tgt.y)[subset])


# CHALLENGE 2
# Add up total receiving yards in 2018 for each unique first name in the
# dataset. For example, for "Michael" add up the receiving yards of Michael
# Crabtree, Michael Thomas, Michael Gallup, Michael Floyd, Michael
# Roberts, and Michael Burton Do not include Mike
# Evans (or any other Mikes). Which first name accumulated the most receiving
# yards in 2018?
# Hint: ?strsplit

splitname = strsplit(as.character(data$Player), split = ' ')
firstname = sapply(splitname, function(x) x[1])
yardsbyname = aggregate(data$Yds, by = list(firstname), sum)
head(yardsbyname[order(-yardsbyname$x), ])




