#
# USAGE: R CMD BATCH expected_score.R <data file> <number of questions>
#      : Rscript expected_score.R ... works with command args not above
#
# i.e. Rscript app/r/expected_score.R tmp/ctt_data.scored.csv 20 ./tmp/
#
require(mirt, quiet = TRUE, warn.conflicts = FALSE)

# process command line
args <- commandArgs(TRUE)
if (length(args) != 4) {
  stop("Invalid command arguments")
}
input_file <- args[1]
number_of_questions <- args[2]
tmp_dir <- args[3]
job_id <- args[4]

# read in the data
if (file.exists(input_file)) {
  data <- read.table(input_file, 
    colClasses = c("NULL", "NULL", rep("numeric", number_of_questions)),
    header=TRUE, sep=",")
} else {
  stop("Could not find input file: ", input_file)
}

mirt_result <- mirt(data, 1, SE = TRUE)
for(i in 1:number_of_questions) {
  file_name <- paste(tmp_dir, job_id, ".expected_",i,".svg", sep='')
  svg(file_name)
  print(itemplot(mirt_result,i,type='score'))
  dev.off()
}