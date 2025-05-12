# Use this to start a background job in RStudio that will run the full pipeline

library(targets)
tar_make()



tar_load(p3_ts_sc_qualified)
01484525

questionable = c('03254520', '01115170', '01483700', '01484525', '02055080', '07053450')

a1 = p3_ts_sc_qualified |> filter(site_no == questionable[1])
ggplot(a1 |> filter(year(dateTime) > 2015)) + 
  geom_path(aes(x = dateTime, y = SpecCond))

a2 = p3_ts_sc_qualified |> filter(site_no == questionable[4])
ggplot(a2 |> filter(SpecCond < 1000)) + 
  geom_path(aes(x = dateTime, y = SpecCond))

# Site 4 ('01484525')
# The January 2016 United States blizzard was a deadly, historic and
# crippling blizzard that produced up to 3 ft (91 cm) of snow in parts of the
# Mid-Atlantic and Northeastern United States during January 22–24, 2016

# Site 01483700
# Storm tides



