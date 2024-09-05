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
endpoint <- "series/observations"
params = list(
  series_id = "GNPCA",
  api_key = "e38117fdeb141bf80af8b4bae49a7d07", ## Change to your own key
  file_type = "json"
)

# Next, we’ll use the httr::GET() function to request (i.e. download) the data. I’ll assign this to an object called fred
# library(httr) ## Already loaded above
fred <-
  httr::GET(
    url = "https://api.stlouisfed.org/", ## Base URL
    path = paste0("fred/", endpoint),    ## The API endpoint
    query = params                       ## Our parameter list
  )

# Take a second to print the fred object in your console. 
# What you’ll see is pretty cool; i.e. it’s the actual API response,
# including the Status Code and Content. Something like:
fred

fred_content = fred
# now we extract content from the "fred" element
fred_content =
  fred_content %>%
  httr::content("text") %>% ## Extract the reponse content (i.e. text)
  jsonlite::fromJSON() ## Convert from JSON to R object
## What type of object did we get?
typeof(fred_content)
View(fred_content)
# library(listviewer) ## Already loaded
jsonedit(fred_content, mode = "view") ## Better for RMarkdown documents

# Luckily, this particular list object isn’t too complicated. We can see that what we’re really interested in, is the
# fred$observations sub-element.

fred_content =
  fred_content %>%
  purrr::pluck("observations") %>% ## Extract the "$observations" list element
  # .$observations %>% ## I could also have used this
  # magrittr::extract("observations") %>% ## Or this
  as_tibble() ## Just for nice formatting
fred_content

# We should convert from charavters to number, as JSON import everithing as character
# library(lubridate) ## Already loaded above
fred_content =
  fred_content %>%
  mutate(across(realtime_start:date, ymd)) %>%
  mutate(value = as.numeric(value))

# Now finally plot!
fred_content %>%
  ggplot(aes(date, value)) +
  geom_line() +
  scale_y_continuous(labels = scales::comma) +
  labs(
    x="Date", y="2012 USD (Billions)",
    title="US Real Gross National Product", caption="Source: FRED"
  )

# Aside: Safely store and use API keys as environment variables ####

# In the above example, I assumed that you would just replace the “YOUR_FRED_KEY” holder text with your actual API
# key. This is obviously not very secure or scalable, since it means that you can’t share your R script without giving away
# your key.
# Solution: ENVIRONMENT VARIABLES

### 1) Set an environment variable for the current R session only 
# Set new environment variable called MY_API_KEY. Current session only.
Sys.setenv(MY_API_KEY="pu yout key here") 
## Assign the environment variable to an R object
my_api_key = Sys.getenv("MY_API_KEY")
## Print it out just to show that it worked
my_api_key

# Important: While this approach is very simple, note that in practice the Sys.setenv() part should only be run directly
# in your R console. Never include code chunks with sensitive Sys.setenv() calls in an R Markdown file or other shared
# documents.

### 2) Set an environment variable that persist across R sessions

# The trick to setting an R environment variable that is
# available across sessions is to add it to a special file called ~/.Renviron. This is a text file that lives on your home directory
# — note the ~/ path — which R automatically reads upon startup. Because ~/.Renviron is just a text file, you can edit it
# with whatever is your preferred text editor. However, you may need to create it first if it doesn’t exist. A convenient way
# to do all of this from RStudio is with the usethis::edit_r_environ() function. You will need to run the next few lines
# interactively:

## Open your .Renviron file. Here we can add API keys that persist across R sessions.
usethis::edit_r_environ()

# Once you have saved your changes, you’ll need to refresh so that this new environment variable is available in the current
# session. You could also restart R, but that’s overkill

## Optional: Refresh your .Renviron file.
readRenviron("~/.Renviron") ## Only necessary if you are reading in a newly added R environment variable

params = list(
  api_key= Sys.getenv("FRED_API_KEY"), ## Get API directly and safely from the stored environment variable
  file_type="json",
  series_id="GNPCA"
)
fred <-
  httr::GET(
    url = "https://api.stlouisfed.org/", ## Base URL
    path = paste0("fred/", endpoint),    ## The API endpoint
    query = params                       ## Our parameter list
  )

# Take a second to print the fred object in your console. 
# What you’ll see is pretty cool; i.e. it’s the actual API response,
# including the Status Code and Content. Something like:
fred


### Application 3: World Rugby rankings ###

# Locating the hidden API endpoint
# Fortunately, there’s a better way: Access the full database of rankings through the API.
# First we have to find the endpoint, though. 
# Here’s a step-by-step guide of how to that that. It’s fairly tedious, but pretty intuitive once you get the hang of it.

# • Start by inspecting the page. (Ctr+Shift+I in Chrome. Ctrl+Shift+Q in Firefox.)
# • Head to the Network tab at the top of the inspect element panel.
# • Click on the XHR button.10
# • Refresh the page (Ctrl+R). This will allow us to see all the web traffic coming to and from the page in our inspect
# panel.
# • Our task now is to scroll these different traffic links and see which one contains the information that we’re after.
# • The top traffic link item references a URL called https://api.wr-rims-prod.pulselive.com/rugby/v3/rankings/wru?language=en.
# Hmmm. “API” you say? “Rankings” you say? Sounds promising…
# • Click on this item and open up the Preview tab.
# • In this case, we can see what looks to be the first row of the rankings table (“New Zealand”, etc.)
# • To make sure, you can grab that https://api.wr-rims-prod.pulselive.com/rugby/v3/rankings/wru?language=en,
# and paste it into our browser (using the JSONView plugin) from before.

# Pulling data into R

endpoint = "https://api.wr-rims-prod.pulselive.com/rugby/v3/rankings/wru?language=en"
rugby = fromJSON(endpoint)
str(rugby)

# listviewer::jsonedit(rugby, mode = "view")
head(rugby$entries$team)

# It looks like we can just bind the columns of the rugby$entries$team
# data frame directly to the other elements of the parent $team “data frame” (actually: “list”). Let’s do that using
# dplyr::bind_cols() and then clean things up a bit. I’m going to call the resulting data frame rankings.

rankings =
  bind_cols(
    rugby$entries$team,
    rugby$entries %>% select(pts:previousPos)
  ) %>%
  clean_names() %>%
  select(-c(id, alt_id, annotations)) %>% ## These columns aren't adding much of interest
  select(pos, pts, everything()) %>% ## Reorder remaining columns
  as_tibble() ## "Enhanced" tidyverse version of a data frame
rankings

### BONUS: Get and plot the rankings history ###

## We'll look at rankings around Jan 1st each year. I'll use 2005 as an
## arbitrary start year and then proceed until the present year.
start_date = ymd("2005-01-01")
end_date = floor_date(today(), unit="years")
dates = seq(start_date, end_date, by="years")
## Get the nearest Monday to Jan 1st to coincide with rankings release dates.
dates = floor_date(dates, "week", week_start = getOption("lubridate.week.start", 1))
dates

# Next, I’ll write out a function that I’ll call rugby_scrape. This function will take a single argument: a date that it will
# use to construct a new API endpoint during each iteration. Beyond that, it will pretty do much exactly the same things
# that we did in our previous, manual data scrape.

## First remove our existing variables. This is not really necessary, since R is smart enough
## to distinguish named objects in functions from named objects in our global environment.
## But I want to emphasise that we're creating new data here and avoid any confusion.
rm(rugby, rankings, endpoint)

## Now, create the function. I'll call it "rugby_scrape".
rugby_scrape =
  function(x) {
    endpoint = paste0("https://api.wr-rims-prod.pulselive.com/rugby/v3/rankings/wru?language=en&date=", x)
    rugby = fromJSON(endpoint)
    rankings =
      bind_cols(
        rugby$entries$team,
        rugby$entries %>% select(pts:previousPos)
      ) %>%
      clean_names() %>%
      mutate(date = x) %>% ## New column to keep track of the date
      select(-c(id, alt_id, annotations)) %>% ## These columns aren't adding much of interest
      select(date, pos, pts, everything()) %>% ## Reorder remaining columns
      as_tibble() ## "Enhanced" tidyverse version of a data frame
    Sys.sleep(3) ## Be nice!
    return(rankings)
  }

rankings_history =
  lapply(dates, rugby_scrape) %>% ## Run the iteration
  bind_rows() ## Bind the resulting list of data frames into a single data frame
rankings_history

# Okay! Let’s plot the data and highlight a select few countries in the process.

teams = c("NZL", "RSA", "ENG", "JPN")
team_cols = c("NZL"="black", "RSA"="#4DAF4A", "ENG"="#377EB8", "JPN" = "red")
rankings_history %>%
  ggplot(aes(x=date, y=pts, group=abbreviation)) +
  geom_line(col = "grey") +
  geom_line(
    data = rankings_history %>% filter(abbreviation %in% teams),
    aes(col=fct_reorder2(abbreviation, date, pts)),
    lwd = 1
  ) +
  scale_color_manual(values = team_cols) +
  labs(
    x = "Date", y = "Points",
    title = "International rugby rankings - Women", caption = "Source: World Rugby"
  ) +
  theme(legend.title = element_blank())










