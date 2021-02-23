# Assignment 3: Data Visualization (incarceration) 
# Create an analysis.R file to analyze dataframe and think about how the
# measures of incarceration vary by race and year 

# Load in necessary packages to work with data 
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(mapproj)

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

# Function that returns a list of summary information statistics 
summary_info <- list()

# Calculate the total number of counties in Incarceration_Trends 
summary_info$num_counties <- Incarceration_Trends %>%
  group_by(county_name) %>%
  summarize(num_counties = length(unique(county_name))) %>%
  summarize(num_counties = sum(num_counties)) %>%
  pull(num_counties) 

# What is the average amount of female inmates in 1995?
summary_info$avg_female_1995 <- Incarceration_Trends %>%
  filter(year == 1995) %>%
  summarize(female_pop_15to64 = sum(female_pop_15to64)) %>%
  summarize(avg_female_1995 = round(female_pop_15to64 / num_counties)) %>%
  pull(avg_female_1995)  

# What is the average amount of male inmates in 1995?
summary_info$avg_male_1995 <- Incarceration_Trends %>%
  filter(year == 1995) %>%
  summarize(male_pop_15to64 = sum(male_pop_15to64)) %>%
  summarize(avg_male_1995 = round(male_pop_15to64 / num_counties)) %>%
  pull(avg_male_1995)

# What is the proportion of total inmates from 1993 compared to 1995 after the 1994 Crime Bill?
# Calculate total inmate population in 1993 
summary_info$total_1993 <- Incarceration_Trends %>%
  filter(year == 1993) %>%
  summarize(total_pop = sum(total_pop)) %>%
  pull(total_pop)

# Calculate total inmate population in 1995 
summary_info$total_1995 <- Incarceration_Trends %>%
  filter(year == 1995) %>%
  summarize(total_pop = sum(total_pop)) %>%
  pull(total_pop)

# Calculate proportion of 1993 inmates / 1995 inmates to see the difference after 1994 Crime Bill
summary_info$prop_1993_1995 <- (total_1993 / total_1995)

# What was the highest overall incarcerated population before 1994?
summary_info$highest_pre1994 <- Incarceration_Trends %>%
  filter(year < 1994) %>%
  summarize(total_pop = max(total_pop)) %>%
  pull(total_pop)

# What was the highest overall incarcerated population after 1994? 
summary_info$highest_post1994 <- Incarceration_Trends %>%
  filter(year > 1994) %>%
  summarize(total_pop = max(total_pop)) %>%
  pull(total_pop)

# How much did the highest incarcerated population total change after 1994? 
summary_info$change_in_total_pop <- (highest_post1994 - highest_pre1994)

# Make a chart that shows trends over time for a variable of your choice 
# Show more than one but fewer than 10 lines. Your graph should compare the trend
# of your measure over time. This may mean showing the same measure for different locations,
# or different racial groups. Think careful about a meaningful comparison of locations (e.g the
# top 10 counties in a state, top 10 states, etc.)
# Must have clear x/y labels, a clear title, and a clear legend with different line colors

# Mutate incarceration data to narrow down for trends chart 
trends_data <- Incarceration_Trends %>%
  group_by(year) %>%
  filter(state == "CA") %>%
  filter(year > 1993 && year <= 2003) %>%
  select(year, state, county_name, black_pop_15to64) 

# Aggregate the trends data frame to consolidate totals by year 
trends_totals <- aggregate(trends_data['black_pop_15to64'], by = trends_data['year'], sum)
  
# Make a trends line chart displaying the changes in the amount of Black inmates from 1994 to 2003 
# in California to show changes after the implementation of the 1994 Crime Bill 
trends_chart <- ggplot(data = trends_totals) +
  geom_line(mapping = aes(x = year, y = black_pop_15to64)) +
  labs(x = "Year", y = "Number of Black Inmates",
    title = "Population of Black Inmates in California Jails from 1993 to 2003")

plot(trends_chart) # Plot trends_chart 

# Make a chart that compares two continuous variables to one another. Think carefully
# about what such a comparison means, and want to communicate to your user (you may have to find 
# relevant trends in the dataset first!)
# Must have clear x/y labels, clear title, if you choose to add color encoding (not required), you
# need a legend for your different color and a clear legend title 

# Mutate incarceration data to reflect data for continuous chart 
continuous_data <- Incarceration_Trends %>%
  group_by(year) %>%
  filter(state == "CA") %>%
  filter(year > 1993 && year <= 2003) %>%
  mutate(poc_pop = (black_pop_15to64 + latinx_pop_15to64 + native_pop_15to64)) %>%
  select(year, state, county_name, poc_pop, white_pop_15to64) 

# Aggregate the data for total POC inmate population 
white_inmate_total <- aggregate(continuous_data['white_pop_15to64'], by = trends_data['year'], sum)

# Aggregate the data for total black inmate population 
poc_inmate_total <- aggregate(continuous_data['poc_pop'], by = trends_data['year'], sum)

# Join inmate totals 
inmate_total_pop <- left_join(white_inmate_total, poc_inmate_total, by = "year")

# Create a chart to compare the populations of black vs. white inmates in California from 1994 to 2003 
continuous_chart <- ggplot(data = inmate_total_pop) +
  geom_point(mapping = aes(x = white_pop_15to64, y = poc_pop), color = "blue") +
  labs(x = "Number of White Inmates", y = "Number of POC Inmates", 
       title = "Comparing Jail Populations of POC and White Inmates in California (1994-2003)") 

plot(continuous_chart) # Plot continuous_chart 

# Make a map that shows how your measure of interests varies/is distributed  geographically.
# Think carefully about what such a comparison means, and want to communicate to your user
# Must have a title, color scale needs a legend with a clear label
# Use a map based coordinate system to set the aspect ratio of your map (see reading) 
# Use a minimalist theme for the map and cross-reference their visual tool to check how much
# data is present/absent

# Load in data for state codes 
state_codes <- read.csv("https://raw.githubusercontent.com/info201a-w21/a3-maddiewong/main/state_codes.csv?token=ASLHHCLZ72QZ67HUUNCQG73AHVJPG")

# Mutate incarceration data for map chart using data from 1994-2003 to see changes in 
# incarceration populations 
maps_data <- Incarceration_Trends %>%
  group_by(year) %>%
  filter(year > 1993 && year <= 2003) %>%
  select(year, Code = state, county_name, total_pop_15to64)

# Join maps_data and state codes 
join_map_codes <- left_join(maps_data, state_codes, by = "Code") %>%
  mutate(region = tolower(State)) # Mutate state to lower to combine w/ map shape later 
  
# Define a minimalist theme 
map_theme <- theme_bw() +
  theme(
    axis.line = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(), 
    axis.title = element_blank(),
    plot.background = element_blank()
  )

# Load in shape of states 
map_shape <- map_data("state") %>%
  left_join(join_map_codes, by = "region")

# Create a blank map of states 
map_chart <- ggplot(data = map_shape) %>%
  geom_polygon(
    mapping = aes(x = long, y = lat, group = group, fill = total_pop_15to64),
    color = "blue",
    size = .1
  ) +
  coord_map() +
  scale_fill_continuous(low = "aliceblue", high = "navy") +
  map_theme

plot(map_chart) # Plot map_chart 






