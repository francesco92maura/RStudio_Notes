###### WebScraping ###### 
# McDermott slide pack: 07_web_apis.pdf

# External Software:
# JSONView, a browser extension that renders JSON output nicely in Chrome and Firefox (recommended)

## Load and install the packages that we'll be using today
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, httr, lubridate, hrbrthemes, janitor, jsonlite, fredr,
               listviewer, usethis)
## My preferred ggplot2 plotting theme (optional)
theme_set(hrbrthemes::theme_ipsum())

#define vector of packages to load
some_packages <- c('jsonlite', 'httr', 'listviewer', 'usethis', 'fredr', 'tidyverse', 'lubridate', 'hrbrthemes', 'janitor')
#load all packages at once
lapply(some_packages, library, character.only=TRUE)

# Scraping web data that is rendered CLIENT-SIDE. The good news is that, when
# available, this approach typically makes it much easier to scrape data from the web. The downside is that, again, it can
# involve as much art as it does science. Moreover, as I emphasised last time, just because because we can scrape data,
# doesn’t mean that we should

# API (or Application Program Interface): is the process of accessing an URL, sending the
# request to the hosting server and, if and when accepted, getting back the data to compile
# the webpage.
# API is really just a collection of rules and methods 
# that allow different software applications to interact and share information

# A key point in all of this is that, in the case of web APIs, we can access information
# directly from the API database if we can specify the correct URL(s). These URLs are the API endpoints
# API endpoints are in many ways similar to the normal website URLs that we’re all used to visiting.
# For starters, you can navigate to them in your web browser. However, whereas normal 
# websites display information in rich HTML content — pictures, cat videos, nice formatting,
# etc. — an API endpoint is much less visually appealing (JASON or XML language).

# Application 1: Trees of New York City

# we’re going to do something “earthy” for this first application: 
# Download a sample of tree data from the 2015 NYC Street Tree Census.

# • Open the web page in your browser (if you haven’t already done so):
# https://data.cityofnewyork.us/Environment/2015-Street-Tree-Census-Tree-Data/uvpi-gqnh/about_data
# • You should immediately see the API tab. Click on it.
# • Copy the API endpoint that appears in the popup box.
# • Optional: Paste that endpoint into a new tab in your browser. You’ll see a bunch

# Now that we’ve located the API endpoint, let’s read the data into R. We’ll do so using the fromJSON() function
# library(jsonlite) ## Already loaded
nyc_trees <- fromJSON("https://data.cityofnewyork.us/resource/uvpi-gqnh.json") %>%
  as_tibble()
nyc_trees

# to read in only the first five rows, you could use:
## (Not run)
fromJSON("https://data.cityofnewyork.us/resource/uvpi-gqnh.json?$limit=5")

# plot (just to see that what we have done is working and not useless)
nyc_trees %>%
  select(longitude, latitude, stump_diam, spc_common, spc_latin, tree_id) %>%
  mutate_at(vars(longitude:stump_diam), as.numeric) %>%
  ggplot(aes(x=longitude, y=latitude, size=stump_diam)) +
  geom_point(alpha=0.5) +
  scale_size_continuous(name = "Stump diameter") +
  labs(
    x = "Longitude", y = "Latitude",
    title = "Sample of New York City trees",
    caption = "Source: NYC Open Data"
  )

# I want to remind you that our first application didn’t require prior registration
# on the Open Data NYC website, or creation of an API key. This is ATYPICAL
