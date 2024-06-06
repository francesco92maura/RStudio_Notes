###### WebScraping ###### 
# McDermott slide pack: 06_web_css.pdf

# Introductory Notes:
# I’ll be using SelectorGadget, which is a Chrome extension that makes it easy to discover CSS selectors.

## Install development version of rvest if necessary
if (numeric_version(packageVersion("rvest")) < numeric_version('0.99.0')) {
  remotes::install_github('tidyverse/rvest')
}
## Load and install the packages that we'll be using today
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rvest, lubridate, janitor, data.table, hrbrthemes)
## My preferred ggplot2 plotting theme (optional)
theme_set(hrbrthemes::theme_ipsum())

# rvest is designed to work with webpages that are built server-side and
# thus requires knowledge of the relevant CSS selectors

# What is a CSS (Cascading Style Sheets) selector? ###############

# The CSS is a language that gives HTML files (e.g., webpages) their appearence.
# In other words, it gives the Style to the webpage we are looking at
# It does so assigning 2 characteristics:
# PROPERTIES: is the "how I want things to appear"? (like fonts, colors...)
# SELECTORS: is the "what do I want to appear?". It is like a tag attached to
#            elements. ".h1" stands for header1, which might be the title page
#            Thus, ".h1" elements have specific fonts, bold, colors...

# An Example: WikiPedia 100m Males WR
library(dplyr)
library(rvest)
m100 <- read_html("http://en.wikipedia.org/wiki/Men%27s_100_metres_world_record_progression")
m100
# that's a XML document (Extensible Markup Language) like viewing all the LaTeX 
# document of a paper, while we only want some tables from that paper.

# Using SelectorGadget, we can find the CSS of, e.g., the first table of the page
# that's the corresponding CSS "div+ .wikitable :nth-child(1)"
# that CSS "div+ .wikitable :nth-child(1)" is unique and identifies only the first
# table in that specific page.
# from rvest, we use html_element and html_table (for conversion into df)
pre_iaaf <-
  m100 %>%
  html_element("div+ .wikitable :nth-child(1)") %>% ## select table element
  html_table()                                      ## convert the table into a df
pre_iaaf
# in other words, from the pre-loaded webpage "m100" we select only one html element
# identified using the CSS identifier that we detect using SelectorGadget


# clean thing a bit
library(janitor) ## Already loaded
library(lubridate) ## Already loaded
pre_iaaf <-
  pre_iaaf %>%
  clean_names() %>% ## fix the column names
  mutate(date = mdy(date)) ## convert string to date format
pre_iaaf

# Aside: Get CSS selectors via browser inspection tools SelectorGadget is a great tool. But it isn’t available on all
# browsers and can involve more work than I’d like sometimes, with all that iterative clicking. I therefore wanted to mention
# an alternative (and very precise) approach to obtaining CSS selectors: Use the “inspect web element” feature of your
# browser. (https://www.thoughtco.com/get-inspect-element-tool-for-browser-756549)

# Here’s a quick example using Google Chrome. First, I open up the inspect console (Ctrl+Shift+I, or right-click and choose
# “Inspect”). I then proceed to scroll over the source elements, until Chrome highlights the table of interest on the actual
# page. Once the table (or other element of interest) is highlighted, I can grab its CSS by right-clicking and selecting Copy
# -> Copy selector.

# Table 2 from wiki 100 meters page
iaaf_12_76 <-
  m100 %>%
  html_element("h3+ .wikitable :nth-child(1)") %>% ## select table element
  html_table()                                      ## convert the table into a df
iaaf_12_76

iaaf_post_76 <-
  m100 %>%
  html_element(".wikitable:nth-child(23) :nth-child(1)") %>% ## select table element
  html_table()                                      ## convert the table into a df
iaaf_post_76

# cleaning (same procedure as before)
iaaf_12_76 <-
  iaaf_12_76 %>%
  clean_names() %>% ## fix the column names
  mutate(date = mdy(date))
iaaf_post_76 <-
  iaaf_post_76 %>%
  clean_names() %>% ## fix the column names
  mutate(date = mdy(date))

# combine
wr100 <- rbind(pre_iaaf %>% select(time, athlete, nationality, date) %>% mutate(era = "Pre-IAAF"),
              iaaf_12_76 %>% select(time, athlete, nationality, date) %>% mutate(era = "1912-1976"),
              iaaf_post_76 %>% select(time, athlete, nationality, date) %>% mutate(era = "1977 +"))
wr100

library(ggplot2)
library(tidyverse)
library(data.table)
wr100 %>%
  ggplot(aes(x=date, y=time, col=fct_reorder2(era, date, time))) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Men's 100m world record progression",
    x = "Date", y = "Time",
    caption = "Source: Wikipedia"
  ) +
  theme(legend.title = element_blank()) ## Switch off legend title

# GOOD, you did it!
# that wikipedia page was a good starting point, as the information we were interested
# in were already in a table, so we can use htl_table() function.
# But WHAT IF we don't want to scrape tables?

# First: read the html
base_url <- "https://www.ebay.it/sch/i.html?_from=R40&_trksid=m570.l2632&_nkw=splitboard&_sacat=112634"
ebayit <- read_html(base_url)
splitboard <- ebayit %>%  html_elements(".s-item__price , .s-item__subtitle , .s-item__title span")
splitboard

splitboard <- html_text(splitboard) ## parse as text
head(splitboard, 20) ## show the first 20 entries

# coercing data frame #
# The general approach that we want to adopt is to look for some kind of “quasi-regular”
# structure that we can exploit
splitboard <- splitboard[7:length(splitboard)] # first 7 elements are noise info
head(splitboard, 10)   # looks we have 3 info for each products: name, 1st or 2nd hand, price
head(as.data.frame(t(matrix(splitboard, nrow = 3))))
tt <- as.data.frame(t(matrix(splitboard, nrow = 3)))
# This approach isn’t going to work because not every sale item lists all 3 text fields. Quite a few are missing something
# sometimes there is this "NUOVA INSERIZIONE" before the title. Try with the following selection
base_url <- "https://www.ebay.it/sch/i.html?_from=R40&_trksid=m570.l2632&_nkw=splitboard&_sacat=112634"
ebayit <- read_html(base_url)
splitboard <- ebayit %>%  html_elements(".s-item__title > span , .s-item__price , .s-item__subtitle")
splitboard

splitboard <- html_text(splitboard) ## parse as text
head(splitboard, 20) ## show the first 20 entries

splitboard <- splitboard[7:length(splitboard)] # first 7 elements are noise info
head(splitboard, 10)   # looks we have 3 info for each products: name, 1st or 2nd hand, price
head(as.data.frame(t(matrix(splitboard, nrow = 3)))) 
# good, it works!
splitboard_dt <- as.data.table(t(matrix(splitboard, nrow = 3)))
names(splitboard_dt) = c('name', 'hand', 'price')
splitboard_dt[, ':=' (price = gsub(",",".",price))]
splitboard_dt[, ':=' (price = as.numeric(gsub("\\b*EUR\\b*","",price)))]

splitboard_dt <- as.data.frame(t(matrix(splitboard, nrow = 3)))
names(splitboard_dt) = c('name', 'hand', 'price')
splitboard_dt <- splitboard_dt %>% mutate(price = gsub(",",".",price))
splitboard_dt <- splitboard_dt %>% mutate(price_n <- as.numeric(gsub('\\b*EUR\\b*','',price)))
names(splitboard_dt) = c('name', 'hand', 'currency', 'price')



# Web content can be rendered either 1) server-side or 2) client-side.
# To scrape web content that is rendered server-side, we need to know the relevant CSS selectors.
# We can find these CSS selectors using SelectorGadget or, more precisely, by inspecting the element in our browser.
# We use the rvest package to read into the HTML document into R and then parse the relevant nodes.
# – A typical workflow is: read_html(URL) %>% html_elements(CSS_SELECTORS) %>% html_table().
# – You might need other functions depending on the content type (e.g. html_text).
# Just because you can scrape something doesn’t mean you should (i.e. ethical and possibly legal considerations).
# Webscraping involves as much art as it does science. Be prepared to do a lot of experimenting and data cleaning.