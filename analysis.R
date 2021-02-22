# Assignment 3: Data Visualization (incarceration) 
# Create an analysis.R file to analyze dataframe and think about how the
# measures of incarceration vary by race and year 

# Load in necessary packages to work with data 
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# Load in incarceration_trends.csv & Jail Jurisdiction data 
# Beware of missing values: You don't need to worry about "imputing" these, but
# when choosing what to visualize, you will want to focus on a particular
# location and/or year that has sufficient data (note, this varies across variables)

Incarceration_Trends <- read.csv("https://raw.githubusercontent.com/vera-institute/incarceration-trends/master/incarceration_trends.csv")

Jail_Jurisdiction <- read.csv("https://raw.githubusercontent.com/vera-institute/incarceration-trends/master/incarceration_trends_jail_jurisdiction.csv")

# Calculate at least five summary values from the data --  
# Summary stats chosen relate to the differences in genders for inmates (ages 15-64) as well as 
# differences in race between POC and white inmates. Also calculated are the years with
# varying numbers of incarcerated populations to look at the different trends later on 
# specifically relating to the years after the introduction of the 1994 Crime Bill 

# Calculate the total number of counties in Incarceration_Trends 
num_counties <- Incarceration_Trends %>%
  group_by(county_name) %>%
  summarize(num_counties = length(unique(county_name))) %>%
  summarize(num_counties = sum(num_counties)) %>%
  pull(num_counties) 

# What is the average amount of female inmates in 1995?
avg_female_1995 <- Incarceration_Trends %>%
  group_by(county_name) %>%
  filter(year == 1995) %>%
  summarize(female_pop_15to64 = sum(female_pop_15to64)) %>%
  summarize(avg_female_1995 = female_pop_15to64 / num_counties) %>%
  pull(avg_female_1995) 

# What is the average amount of male inmates in 1995?
avg_male_1995 <- Incarceration_Trends %>%
  group_by(county_name) %>%
  filter(year == 1995) %>%
  summarize(male_pop_15to64 = sum(male_pop_15to64)) %>%
  summarize(avg_male_1995 = male_pop_15to64 / num_counties) %>%
  pull(avg_male_1995)

# What is the proportion of total inmates from 1993 compared to 1995 after the 1994 Crime Bill?
# Calculate total inmate population in 1993 
total_1993 <- Incarceration_Trends %>%
  filter(year == 1993) %>%
  summarize(total_pop = sum(total_pop)) %>%
  pull(total_pop)

# Calculate total inmate population in 1995 
total_1995 <- Incarceration_Trends %>%
  filter(year == 1995) %>%
  summarize(total_pop = sum(total_pop)) %>%
  pull(total_pop)

# Calculate proportion of 1993 inmates / 1995 inmates to see the difference after 1994 Crime Bill
prop_1993_1994 <- (total_1993 / total_1995)

# What is the county with the most black inmates in 1995?
county_most_black_inmates <- Incarceration_Trends %>%
  group_by(year) %>%
  filter(year == 1995) %>%
  summarize(black_pop_15to64 = max(black_pop_15to64)) %>%
  pull(county_name)

# What is the county with the least black inmates in 1995?
county_least_black_inmates <- Incarceration_Trends %>%
  group_by(year) %>%
  filter(year == 1995) %>%
  summarize(black_pop_15to64 = min(black_pop_15to64)) %>%
  pull(county_name)

# What was the highest overall incarcerated population before 1994?
highest_pre1994 <- Incarceration_Trends %>%
  filter(year < 1994) %>%
  summarize(total_pop = max(total_pop)) %>%
  pull(total_pop)

# What was the highest overall incarcerated population after 1994? 
highest_post1994 <- Incarceration_Trends %>%
  filter(year > 1994) %>%
  summarize(total_pop = max(total_pop)) %>%
  pull(total_pop)

# How much did the highest incarcerated population total change after 1994? 
change_in_total_pop <- (highest_post1994 - highest_pre1994)

# Make a chart that shows trends over time for a variable of your choice 
# Show more than one but fewer than 10 lines. Your graph should compare the trend
# of your measure over time. This may mean showing the same measure for different locations,
# or different racial groups. Think careful about a meaningful comparison of locations (e.g the
# top 10 counties in a state, top 10 states, etc.)
# Must have clear x/y labels, a clear title, and a clear legend with different line colors


# Make a chart that compares two continuous variables to one another. Think carefully
# about what such a comparison means, and want to communicate to your user (you may have to find 
# relevant trends in the dataset first!)
# Must have clear x/y labels, clear title, if you choose to add color encoding (not required), you
# need a legend for your different color and a clear legend title 



# Make a map that shows how your measure of interests varies/is distributed  geographically.
# Think carefully about what such a comparison means, and want to communicate to your user
# Must have a title, color scale needs a legend with a clear label
# Use a map based coordinate system to set the aspect ratio of your map (see reading) 
# Use a minimalist theme for the map and cross-reference their visual tool to check how much
# data is present/absent 









