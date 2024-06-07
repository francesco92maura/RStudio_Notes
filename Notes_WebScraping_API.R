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

