###### WebScraping ###### 
# McDermott slide pack: 06_web_css.pdf

# Introductory Notes:
# I’ll be using SelectorGadget, which is a Chrome extension that makes it easy to discover CSS selectors. (Install the
# extension directly here.)

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
# It does so assigning 2 charachteristics:
# PROPERTIES: is the "how I want things to appear"? (like fonts, colours...)
# SELECTORS: is the "what do I want to appear?". It is like a tag attached to
#            elements. ".h1" stands for header1, which might be the titlepage
#            Thus, ".h1" elements have specific fonts, bold, colours...

# An Example: WikiPedia 100m Males WR
library(rvest)
m100 <- read_html("http://en.wikipedia.org/wiki/Men%27s_100_metres_world_record_progression")
m100
# that's a XML document (Extensible Markup Language) like viewing all the LaTeX 
# document of a paper, while we only want some tables.

# Using SelectorGadget, we can find the CSS of, e.g., the first table of the page
# that's the corresponding CSS "div+ .wikitable :nth-child(1)"
# from rvest, we use html_element and html_table (for conversion into df)
pre_iaaf <-
  m100 %>%
  html_element("div+ .wikitable :nth-child(1)") %>% ## select table element
  html_table()                                      ## convert the table into a df
pre_iaaf

# clean thing a bit
library(janitor) ## Already loaded
library(lubridate) ## Already loaded
pre_iaaf <-
  pre_iaaf %>%
  clean_names() %>% ## fix the column names
  mutate(date = mdy(date)) ## convert string to date format
pre_iaaf

# Aside: Get CSS selectors via browser inspection tools SelectorGadget is a great tool. But it isn’t available on all
# browsers and can involve more work than I’d like sometimes, with all that iterative clicking.3 I therefore wanted to mention
# an alternative (and very precise) approach to obtaining CSS selectors: Use the “inspect web element” feature of your
# browser. (https://www.thoughtco.com/get-inspect-element-tool-for-browser-756549)

# Here’s a quick example using Google Chrome. First, I open up the inspect console (Ctrl+Shift+I, or right-click and choose
# “Inspect”). I then proceed to scroll over the source elements, until Chrome highlights the table of interest on the actual
# page. Once the table (or other element of interest) is highlighted, I can grab its CSS by right-clicking and selecting Copy
# -> Copy selector.