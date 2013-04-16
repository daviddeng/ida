

library(RCurl)
library(ggplot2)
library(reshape2)

if(!file.exists("data/unodc2010_extract.csv")) {
  # Get raw data.
  unodc <- getURL("http://www.quantumforest.com/wp-content/uploads/2012/02/homicides.csv", .encoding= "UTF-8")
  # Turn to text.
  unodc <- textConnection(unodc)
  # Read lines.
  unodc <- readLines(unodc)
  # Convert to CSV.
  unodc <- read.csv(text = unodc)
  # Check for folder.
  if(!file.exists("data")) dir.create("data")
  # Save as CSV.
  write.csv(unodc, file = "data/unodc2010_extract.csv", row.names = FALSE)
}

# Read as CSV.
unodc <- read.csv("data/unodc2010_extract.csv")
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

