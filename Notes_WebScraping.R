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
base_url <- "https://www.amazon.it/s?k=spugne+cucina&crid=1DOYUJJU6O97J&sprefix=spugne%2Caps%2C88&ref=nb_sb_ss_ts-doa-p_1_6"
amazon <- read_html(base_url)
spugnette <-  craiglist %>%  html_elements("#anonCarousel1 .a-size-base.s-underline-text , .aok-align-bottom , .a-color-secondary .a-text-price span")
spugnette

spugnette <- html_text(spugnette) ## parse as text
head(spugnette, 20) ## show the first 20 entries
