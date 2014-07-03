#
# USAGE: R CMD BATCH item_analysis.R
#      : Rscript item_analysis.R ... works with command args not above
#
require(psychometric, quiet = TRUE, warn.conflicts = FALSE)
require(ggplot2, quiet = TRUE, warn.conflicts = FALSE)

# process command line
args <- commandArgs(TRUE)
if (length(args) != 4) {
  stop("Invalid command arguments")
}
input_file <- args[1]
stats_file <- args[2]
scatter_plot_file <- args[3]
number_of_questions <- args[4]

# read in the data
if (file.exists(input_file)) {
  data <- read.table(input_file, 
    colClasses = c("NULL", "NULL", rep("numeric", number_of_questions)),
    header=TRUE, sep=",")
} else {
  stop("Could not find input file: ", input_file)
}

# data <- read.table("ctt_data_small.scored.csv", 
#   colClasses = c("NULL", rep("numeric",6)),
#   header=TRUE, 
#   sep=",")

# perform the item analysis
output <- item.exam(data, NULL, TRUE)

# output results to csv
num_rows <- nrow(output)
write.table(
  output, 
  file=stats_file,
  sep=",", 
  row.names=seq(1,num_rows), 
  col.names=NA
)

# create the scatter plot --> SVG format
# add a label for the question numbers so we can show them in the plot
output$QNum <- seq(1,num_rows)

# find the min and max values to use for the y-axis
ymin <- min(output['Discrimination'])
ymax <- max(output['Discrimination'])

# create a data frame to represent the warning rectangle
rect <- data.frame (xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 0)

# create the main scatter plot
a <- ggplot(data = output, aes(x = Difficulty, y = Discrimination)) +
  # create a scatter type plot and set attributes of the points 
  # pch and color refers to the border
  geom_point(size = 10, alpha = 0.6, pch = 21, color = 'black', fill = 'grey') +
  # add labels to each point, label will be the question number
  geom_text(data = output, aes(label = QNum), hjust = 0.5, vjust = 0.5, size = 3) + 
  # add the x and y axis labels
  xlab('Item difficulty') + ylab('Discrimination (CPBR)') +
  # add the plot title and set the theme to use
  # ggtitle('Item discrimination by item difficulty') + 
  theme_bw() + 
  # set the x axis values and intervals
  scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.05), expand = c(0, 0)) +
  # set the y axis values and intervals... best result seems to occur with the default
  # scale_y_continuous(breaks = seq(ymin, ymax, 0.1)) +
  # angle the x axis interval text
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  # add the discrimination lines
  geom_hline(yintercept = c(0.225, 0.35), linetype = "dotted", size = 0.6, color = 'blue') +
  annotate('text', x = 0.85, y = 0.20, label = 'Discrimination = 0.225', size = 2.75, 
    fontface = 'italic', color = 'blue', alpha = 0.5) +
  annotate('text', x = 0.85, y = 0.325, label = 'Discrimination = 0.350', size = 2.75, 
    fontface = 'italic', color = 'blue', alpha = 0.5) +
  # add the difficulty lines
  geom_vline(xintercept = c(0.35, 0.75), linetype = 'dotted', size = 0.6, color = 'blue') +
  annotate('text', x = 0.370, y = -Inf, hjust = 1.25, label = 'Difficulty = 0.35', size = 2.75, 
    fontface = 'italic', color = 'blue', alpha = 0.5, angle = -90) +
  annotate('text', x = 0.77, y = -Inf, hjust = 1.25, label = 'Difficulty = 0.75', size = 2.75, 
    fontface = 'italic', color = 'blue', alpha = 0.5, angle = -90) +
  # add the text for the negative CPBR rectangle shaded zone
  annotate('text', x = 0.15, y = -0.025, label = 'Warning zone: negative CPBR', size = 3, 
    fontface = 'italic', color = 'red', alpha = 0.65) + 
  # add a shading rectangle for negative CPBR's
  geom_rect(data = rect, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), 
    linetype = 'blank', color = 'red', fill = 'red', alpha = 0.2, inherit.aes = FALSE)

# save the plot
ggsave(scatter_plot_file, width=7, height=7)
