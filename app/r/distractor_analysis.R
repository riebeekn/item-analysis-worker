#
# USAGE: R CMD BATCH distractor_analysis.R <data file> <key file> <output file>
#      : Rscript distractor_analysis.R ... works with command args not above
#
# i.e. Rscript app/r/distractor_analysis.R data/ctt_data.txt data/ctt_key.txt data/distractor_out.txt
#
source("./app/r/customized_packages/ctt/distractor.analysis.R")
source("./app/r/customized_packages/ctt/score.R")

args <- commandArgs(TRUE)
if (length(args) != 3) {
  stop("Invalid command arguments")
}
data_file <- args[1]
key_file <- args[2]
output_file <- args[3]

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
output <- distractor.analysis(data, key)

# convert output to a data frame
output <- do.call(rbind.data.frame, output)

# output results to csv
num_rows <- nrow(output)
write.table(
  output, 
  file=output_file,
  sep=",", 
  col.names=NA
)