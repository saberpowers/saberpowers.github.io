# First thing's first: read in the data. Documentation for these data are
# available at: http://chadwick.sourceforge.net/doc/cwevent.html

data = read.csv('MLBpbp2015.csv')
dim(data)
head(data)

####################

stats = function(data) {

# The bases occupied are encoded in the data. The eight possibilities
# are labelled 0 through 7, and the table below shows which configuration each
# number corresponds to.

# START_BASES_CD
# 0 000
# 1 100
# 2 010
# 3 110
# 4 001
# 5 101
# 6 011
# 7 111

# Let's create a "lookup" vector for the base configuration. This vector will
# list out the strings giving a clearer specification of the runners on base,
# by naming the entries of the lookup vector by the corresponding code, we can
# quickly get the clearer specification of each code.

bases.lookup = c('000', '100', '010', '110', '001', '101', '011', '111')
names(bases.lookup) = 0:7

# Next, we need to label the starting base/out state for each play.

state.start = with(data, paste(OUTS_CT, '-',
    bases.lookup[as.character(START_BASES_CD)], sep = ''))

####################

# Now we tabulate for each starting state the average number of runs scored
# after it in the same half inning.

run.expectancy = with(data, aggregate(EVENT_RUNS_CT + FATE_RUNS_CT,
    by = list(state = state.start), mean))

# Next, let's create a "lookup" vector for run expectancy. This vector will
# store the run expectancy for each state, and we will label each value with
# its state. This will make it easy to get the run expectancy of each state.

re.lookup = run.expectancy$x
names(re.lookup) = run.expectancy$state
re.lookup['3-000'] = 0

# Now we are able to get the starting run expectancy for every play in the
# dataset.

re.start = re.lookup[state.start]

####################

# Next what we need is the ending run expectancy for the state after each play.
# To get this, first we need to find the end state after each play.

state.end = with(data, paste(OUTS_CT + EVENT_OUTS_CT, '-',
    bases.lookup[as.character(END_BASES_CD)], sep = ''))
table(state.end)
state.end[data$OUTS_CT + data$EVENT_OUTS_CT == 3] = '3-000'

# And as before, we lookup the run expectancy for each end state.

re.end = re.lookup[state.end]

# The run value of each play is just the difference between the ending run
# expectancy and the starting run expectancy.

run.value = re.end - re.start + data$EVENT_RUNS_CT

# Now we have the observed run value for each event. To find the average run
# value for each event type, e.g. single, home run, etc., we simply tabulate
# the average for each event type.

event.run.value = aggregate(run.value, by = list(event = data$EVENT_CD), mean)

# We get the wOBA weights from this by subtracting the run value of an out from
# the run value of each event.

wOBAweights = event.run.value$x
names(wOBAweights) = event.run.value$event
wOBAweights = wOBAweights - wOBAweights['Generic out']

####################

# Finally, let's compute wOBA for each batter, using the weights we computed
# above. To do so, we need to tabulate the plate appearance results for each
# batter.

batting.table = with(data, aggregate(EVENT_CD[BAT_EVENT_FL],
    list(batter = BAT_ID[BAT_EVENT_FL]), table))
counts = batting.table[, -1]
rownames(counts) = batting.table$batter

# The denominator for wOBA is plate appearances. We get the number of plate
# appearances for each batter by summing the rows of the count matrix.

PA = rowSums(counts)

# The numerator for wOBA is the sum of the counts times their wOBA weight.
# To get wOBA for each batter, we divide this number by their total number of
# plate appearances.

wOBA = rowSums(scale(counts, center = FALSE, scale = 1/wOBAweights))/PA

####################

# An alternative way to evaluate batters would be to give them the credit for
# the change in run expectancy in each of their plate appearances. This would
# award more credit for hitting a home run with the bases loaded than for
# hitting a home run with the bases empty, as opposed to awarding equal credit
# for all home runs. This statistic is call RE24, and given the work we have
# already done, it is very easy to compute. We just need to add up the run
# value of each event for each batter.

batter.run.value = with(data, aggregate(run.value[BAT_EVENT_FL],
    list(batter = BAT_ID[BAT_EVENT_FL]), mean))
RE24 = batter.run.value$x
names(RE24) = batter.run.value$batter

# To compare RE24 with wOBA, let's plot them against each other for all batters
# with more than 500 plate appearances on the season.

#plot(wOBA[PA > 500], RE24[PA > 500])

return(list(PA = PA, wOBA = wOBA, RE24 = RE24))
}

#################### CHALLENGE ####################
# Randomly split the season into two halves, so that each plate appearance is
# equally likely to be put into each half. For each player with at least 200
# plate appearances in each half, compute their wOBA and RE24 in the first half
# and their wOBA and RE24 in the second half. Among these batters, what is the
# correlation between first-half wOBA and second-half wOBA? What is the
# correlation between first-half RE24 and second-half RE24? What are the
# implications of these results?
# Legendary difficulty:
# Do it by adding no more than 10 lines of code to the current script.
###################################################

# The trick is to define a function stats() which takes in a dataset and spits
# out PA, wOBA and RE24 as we've calculated above. I do this by introducing
# one line of code in line 10 of this script to start the function and two
# more lines of code in lines 134-135 to end the function. Next I randomly
# split the data into two halves and compute the stats for each half. See
# below.

firsthalf = sample(1:nrow(data), floor(nrow(data)/2))

stats1 = stats(data[firsthalf, ])
stats2 = stats(data[-firsthalf, ])

keep = intersect(names(stats1$PA)[stats1$PA > 200],
    names(stats2$PA)[stats2$PA > 200])

cor(stats1$wOBA[keep], stats2$wOBA[keep])
cor(stats1$RE24[keep], stats2$RE24[keep])

