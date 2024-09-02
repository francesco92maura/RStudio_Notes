###### WebScraping ###### 
# McDermott slide pack: 07_web_apis.pdf

# External Software:
# JSONView, a browser extension that renders JSON output nicely in Chrome and Firefox (recommended)

## Load and install the packages that we'll be using today
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, httr, lubridate, hrbrthemes, janitor, jsonlite, fredr,
               listviewer, usethis)
## My preferred ggplot2 plotting theme (optional)
# theme_set(hrbrthemes::theme_ipsum())

#define vector of packages to load
some_packages <- c('jsonlite', 'httr', 'listviewer', 'usethis', 'fredr', 'tidyverse', 'lubridate', 'hrbrthemes', 'janitor')
#load all packages at once
lapply(some_packages, library, character.only=TRUE)

# Scraping web data that is rendered CLIENT-SIDE. The good news is that, when
# available, this approach typically makes it much easier to scrape data from the web. The downside is that, again, it can
# involve as much art as it does science. Moreover, just because because we can scrape data,
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

# Aside on limits: Note that the full census dataset contains nearly 700,000 individual trees. However, we only downloaded
# a tiny sample of that, since the API defaults to a limit of 1,000 rows. I don’t care to access the full dataset here, since I just
# want to illustrate some basic concepts. Nonetheless, if you were so inclined and read the docs, you’d see that you can
# override this default by adding ?$limit=LIMIT to the API endpoint. For example, to read in only the first five rows, you
# could use:
## (Not run) ##
# fromJSON("https://data.cityofnewyork.us/resource/uvpi-gqnh.json?$limit=5")

# plot (just to see that what we have done is working and not useless)
# note that the JSON package import everithing as text, thus we should convert numbers
nyc_trees %>%
  select(longitude, latitude, stump_diam, spc_common, spc_latin, tree_id) %>%
  mutate_at(vars(longitude:stump_diam), as.numeric) %>%  # convert to numeric
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


# Application 2: FRED data

# Do it yourself
# As with all APIs, a good place to start is the FRED API developer docs. If you read through these, you’d see that the endpoint
# path we’re interested in is series/observations. This endpoint “gets the observations or data values for an economic data
# series”. The endpoint documentation gives a more in-depth discussion, including the various parameters that it accepts.3
# However, the parameters that we’ll be focused on here are simply:
#   • file_type: “json” (Not required, but our preferred type of output.)
#   • series_id: “GNPCA” (Required. The data series that we want.)
#   • api_key: “YOUR_API_KEY” (Required. Go and fetch/copy your key now.)

# Go to: https://api.stlouisfed.org/fred/series/observations?series_id=GNPCA&api_key=41be5e4aa36e1ebb8224459c17afac6a&file_type=json
# Note: your API key is 41be5e4aa36e1ebb8224459c17afac6

# At this point you’re probably tempted to read the JSON object directly into your R environment using the jsonlite::
# readJSON() function. And this will work. However, that’s not what we’re going to here. Rather, we’re going to
# go through the httr package (link). Why? Well, basically because httr comes with a variety of features that allow us to
# interact more flexibly and securely with web APIs.

# define "endpoint" and "parameters", to be used more later
endpoint = "series/observations"
params = list(
  api_key= "41be5e4aa36e1ebb8224459c17afac6", ## Change to your own key
  file_type="json",
  series_id="GNPCA"
)









