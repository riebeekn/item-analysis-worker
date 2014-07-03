#
# USAGE: R CMD BATCH score_exam.R <data file> <key file> <output file>
#      : Rscript score_exam.R ... works with command args not above
#
# i.e. Rscript app/r/score_exam.R data/ctt_data.txt data/ctt_key.txt data/score_out.txt
#
source("./app/r/customized_packages/ctt/score.R")
require(ggplot2, quiet = TRUE, warn.conflicts = FALSE)

args <- commandArgs(TRUE)
if (length(args) != 4) {
  stop("Invalid command arguments")
}
data_file <- args[1]
key_file <- args[2]
output_file <- args[3]
histogram_file <- args[4]

# read in the data
if (file.exists(data_file)) {
  data <- read.table(data_file, header = TRUE, sep = ",")
} else {
  stop("Could not find data file: ", data_file)
}

# read in the key
if (file.exists(key_file)) {
  key <- read.table(key_file, header = FALSE, sep = ",")
} else {
  stop("Count not find key file: ", key_file)
}

# convert the key to a vector
key <- unlist(key)

# perform the distractor analysis
output <- score(data, key, output.scored = TRUE)

# output results to csv
write.table(
  output, 
  file=output_file,
  sep=",", 
  col.names=NA
)

# create the histogram of test scores
bin_size <- diff(range(output$score))/100
a <- ggplot(data = as.data.frame(output$score), aes(x = output$score)) +
  # create a histogram type plot
  geom_histogram(fill="lightgreen", color="black", binwidth = bin_size) +
  # add the x and y axis labels
  xlab('Total test score') + ylab('Frequency') +
  # add the theme
  theme_bw() 

# save the plot
ggsave(histogram_file, width=7, height=7)