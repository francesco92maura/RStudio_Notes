###### data.table ###### 
# McDermott slide pack: 05_datatable.pdf

# load the library
library(data.table)
library(dplyr)

# 1) BASICS of data.table #
sw_dt <- as.data.table(starwars)
# compute the average height by gender of only "Human" charachters
t1 <- sw_dt[species=="Human", mean(height, na.rm = T), by = gender]
View(t1)

# filtering
t1 <- sw_dt[species=="Human"][gender == "feminine"]
View(t1)
t1 <- sw_dt[species=="Human" & gender == "feminine"]
View(t1)

# ordering
t1 <- sw_dt[order(height)]
View(t1)
t1 <- sw_dt[order(-height)]
View(t1)
# ordering and filtering
t1 <- sw_dt[order(-height) & sex == "female"]
View(t1)

# manipulating columns
dt <- data.table(x = 1:4)
dt[, x_sq := x^2][]
dt_copy = dt
dt_copy[, x_sq := NULL][]
dt # attention! modifying the copy we modify also the original
# use the "copy" function
dt[, x_sq := x^2][]
dt_copy = copy(dt)
dt_copy[, ':=' (x_sq = NULL, x2 = x*2)][] # manipulating multiple columns
dt # original data not modified
dt_copy[, x_cube := x^3][, y := (x^2-3)][] # multiple columns manipulation
# multiple column manipulation with "magrittr" pipe
library(magrittr)
dt_copy %>% 
  .[, x_cube := NULL] %>%
  .[, y2 := y*0.5] %>%
  .[]

# Subsetting on columns by:
# row number, column postion
t1 <- sw_dt[1:4, c(1:3, 7, 10)][]
t1
# column name (all the 3 lines do the same thing)
t1 <- sw_dt[1:4, c("name", "height", "mass", "species", "homeworld")][]
t1 <- sw_dt[1:4, list(name, height, mass, species, homeworld)][]
t1 <- sw_dt[1:4, .(name, height, mass, species, homeworld)][]
t1
# subsetting by excluding columns
t1 <- sw_dt[1:4, !c("name", "height", "mass", "species", "homeworld")][]
t1 # all col but the 5 listed

# Renaming columns
setnames(sw_dt, old = c("name", "homeworld"), new = c("alias", "crib"))[]
# set names back
setnames(sw_dt, old = c("alias", "crib"), new = c("name", "homeworld"))[]

sw_dt[1:2, .(name1 = name, planet = homeworld)]
View(sw_dt)

# Aggregating manipulations
sw_dt[, mean(height, na.rm = T), by = gender][]
sw_dt[, avg_h := mean(height, na.rm = T)] %>%
      .[1:5, .(name, height, avg_h)]
sw_dt[, avg_h := mean(height, na.rm = T), by = species] %>%
  .[1:5, .(name, height, avg_h)]
sw_dt[, avg_h := mean(height, na.rm = T), by = gender] %>%
  .[1:5, .(name, height, avg_h)]

# counting
sw_dt[, .N]
t1[, .N]
sw_dt[, .N, by = species]

# Group by
sw_dt[, mean(height, na.rm = T), by = species][] # average height by species
sw_dt[, .(avg_h = mean(height, na.rm = T)), by = species][] # add the new variable to the data.table
sw_dt[, median(mass, na.rm = T), by = height>180][]

# multiple "by" group: .() operator
sw_dt[, .(avg_h = mean(height, na.rm = T)), by = .(species, homeworld)][]
sw_dt[order(species), .(avg_h = mean(height, na.rm = T)), by = .(species, homeworld)][]

# multiple grouping with .SD command
sw_dt[, .(mean(height, na.rm=T), mean(mass, na.rm=T), mean(birth_year, na.rm=T)),
      by = species][]
# is it possible to do it in a more aggregate made? Yes!
sw_dt[,
      lapply(.SD, mean, na.rm=T),
      .SDcols = c("height", "mass", "birth_year"), by = species][] %>%
      head(5)
# keyby: works exactly as "by", but also generate a key (ID?)
t1 <- sw_dt[, lapply(.SD, mean, na.rm=T),
            .SDcols = c("height", "mass"), keyby = species] 
t1 %>% head(6)

#----- keys -----#
# what is a key? is similar to an Identifier, but for groups, not individuals. 
# thus, if I have to subset based on a key, the operation are much faster
# Think of the way a filing cabinet might divide items by alphabetical order: 
# Files starting "ABC" in the top drawer, "DEF" in the second drawer, etc. 
# To find "Alice"'s file, you'd only have to search the top draw, and so on

# how to set a key
dt <- data.table(x = 1:15, y = LETTERS[1:15], key = "x")
key(dt) # which is the "key" variable in the data.table?

t1 <- sw_dt
setDT(t1, key = "species")
key(t1)

setkey(sw_dt, homeworld)
key(sw_dt)#note: here we do not need quotes

# setting multiple keys
setkey(sw_dt, species, homeworld)
key(sw_dt)

# keys and performance
# first: create a keyed version of the "storm" data.table
# note that the "key" variables match the "by" grouping variables below.
storms_dt_key = as.data.table(storms, key = c("name", "year", "month", "day"))
# Collapse function for this keyed data.table. Everything else stays the same.
collapse_dt_key = function() {
  storms_dt_key[, .(wind = mean(wind), pressure = mean(pressure), category = first(category)),
                                                              by = .(name, year, month, day)]
}
# Run the benchmark on all three functions
library(microbenchmark)
microbenchmark(collapse_dplyr(), collapse_dt(), collapse_dt_key(), times = 1)

