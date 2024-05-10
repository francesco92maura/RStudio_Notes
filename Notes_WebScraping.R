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
