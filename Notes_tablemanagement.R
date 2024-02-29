###### data.table ###### 
# McDermott slide pack: 05_datatable.pdf

# load the library
library(data.table)
library(dplyr)

# 1) BASICS of data.table #
sw_dt <- as.data.table(starwars)
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
t1 <- sw_dt[order(-height) & sex == "female"]
View(t1)

