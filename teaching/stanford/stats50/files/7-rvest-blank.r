# This tutorial uses the R package rvest, which helps you easily scrape data
# from web pages directly into R.

require(rvest)
require(dplyr)
require(magrittr)

# Below I've spotted you the 12 teams in the WNBA, along with their abbreviated
# identifiers used by ESPN. You could probably do this automatically, but with
# only 12 teams, it was easy enough to do manually.

teams <- c('atl', 'chi', 'conn', 'dal', 'ind', 'la', 'lv', 'min', 'ny', 'phx',
           'sea', 'wsh')
names(teams) <- c('Atlanta', 'Chicago', 'Connecticut', 'Dallas', 'Indiana',
                  'Las Vegas', 'Los Angeles', 'Minnesota', 'NY Liberty', 'Phoenix',
                  'Seattle', 'Washington')

# The read_html() function parses an HTML page and stores the result in R, allowing
# you to scrape data from it. Let's get the web page containing the Chicago
# Sky's 2018 schedule and results.



# There is only one table in this file, so we can easily extract it with the 
# html_table function.



# We extract the headings and drop superfluous rows from this table using the
# subset function. We are only interested in the first three columns, so let's
# ignore the others



# Now, we can format the data frame using the mutate function from dplyr. The
# information we need is
#  1. The date
#  2. Who the opponent was
#  3. Who won?
#  4. Was the game at home?
#  5. What was the final score?
#  6. Did the dame go into overtime?
#
# We'll be using regular expressions. For an excellent tutorial, see the link
# here: https://regexone.com/



# For the Bradley-Terry model, we want variables representing the home score
# and away score



# Let's clean up what we've done so far and package the relevant information
# into a clean dataset using dplyr's transmute function.



# Finally, we have a clean dataset of scores from the 2018 WNBA season! Let's
# write the data to a CSV file!



# That's it! For more material to help you learn how to use rvest, check out
# the rvest tutorial under the Handouts tab of the Stats 50 web site!