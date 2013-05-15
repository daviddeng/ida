

library(ggplot2)
library(xlsx)
library(zoo)
url = "http://www.unodc.org/documents/data-and-analysis/statistics/Homicide/Homicide_data_series.xls"
if(!file.exists(file <- "data/UNODC.Homicides.xls"))
  download(, file, mode = "wb")

# Import XLS, selected columns and rows.
unodc <- read.xlsx(file, sheetName = "data series", colIndex = c(1:3, 6:22), rowIndex = 7:213)
# Rename imported variables.
names(unodc) <- c("Region", "Subregion", "Country", "Homicide", 1995:2010)
# Inspect top-left data.
unodc[1:10, 1:5]

# Last observations carried forward for region and subregion.
unodc[, 1:3] <-na.locf(unodc[, 1:3])
# Inspect top-left data.
unodc[1:10, 1:5]

ccode <- c("Australia", "Austria", "Belgium", "Canada", "Denmark",
         "Finland", "France", "Germany", "Greece", "Hungary",
         "Ireland", "Italy", "Japan", "Korea", "Luxembourg",
         "Netherlands", "New Zealand", "Norway", "Portugal", "Spain",
         "Sweden", "Switzerland", "United Kingdom", "United States")

unodc <- melt(unodc, id = names(unodc)[1:4], variable = "Year")
str(unodc)

qplot(subset(unodc, Subregion == "Northern Africa"),
      x = Year, y = Country, size = Count, geom = "point")

# Subset to homicide rates.
unodc <- subset(unodc, Homicide == "Rate")[, -4]
# Number of countries per region and subregion.
with(unodc, table(Region))
with(unodc, table(Subregion))




unodc <- subset(unodc, Region == "Europe" | Country == "United States of America")
# Reshape to long.
unodc <- melt(unodc, id = names(unodc)[1:3], variable_name = "Year")
# Plot.
qplot(data = unodc, x = Year, y = value, group = Country, colour = Subregion, se = F, geom = "smooth")

# Check first rows.
head(unodc)
# Check final rows.
tail(unodc)
# Plot main distribution.
qplot(unodc$rate, geom = "histogram", bin = 5) + xlab("Distribution of homicide rates") + ylab("N")



# Load the plyr library.
library(plyr)
# Mean and median of homicide counts.
tbl <- ddply(unodc, .(country), summarise, mean = round(mean(rate, na.rm = TRUE),1), min = min(rate, na.rm = TRUE), max = max(rate, na.rm = TRUE))
# Check result.
tbl



# Load the reshape library.
library(reshape)
# Reorder levels.
tbl$country <- with(tbl, reorder(country, mean))
# Plot it.
fig <- ggplot(tbl, aes(x = country, y = mean, ymin = min, ymax = max))
# Add pointrange lines.
fig <- fig + geom_pointrange()
# Pivot graph.
fig <- fig + coord_flip()
# Add titles.
fig <- fig + ylab("Homicide rates 1995-2010\n(min-max ranges, dot at mean)") + xlab("")
# Add minimum and maximum on the plot.
fig + 
  geom_text(label = round(tbl$max, 0), y = tbl$max, hjust = -.25, size = 4) + 
  geom_text(label = round(tbl$min, 0), y = tbl$min, hjust = 1.25, size = 4)
# Heatmap.
ggplot(unodc, aes(x = year, y = country, fill = rate)) + geom_tile() + scale_fill_gradient(low="white", high="red", name = "Homicide rate") + theme_bw()



# Load MASS package (provides "rlm" function).
library(MASS)
# Load splines package (provides "ns" function).
library(splines)
# Plot canvas.
fig <- ggplot(unodc, aes(y = rate, x = year, group = country, color = country, fill = country))
# Spline, 2-length knots.
fig <- fig + geom_smooth(method="rlm", formula = y ~ ns(x, 2), alpha = .25)
# Check result.
fig + ylab("Homicide rate per 100,000 population") + xlab("Year")

