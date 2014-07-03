# !/bin/bash

#################################################################################
# USAGE:  chmod +x install.sh
#         ./install <worker-name> <app name to take db info from> <aws bucket> <aws key> <aws secret>
#
# SOME GENERAL COMMANDS WHEN USING REMOTE HEROKU APPs:
#   to run app manually:        heroku run ruby app/worker.rb --remote worker-1
#   to start worker:            heroku ps:scale worker=1 --remote worker-1
#   to push updates to heroku:  git push worker-1
#################################################################################

if [ -z $1 ]; then
  echo "**** YOU NEED TO SUPPLY A WORKER NAME... EXITING ****"
  exit 1
elif [ -z $2 ]; then
  echo "**** YOU NEED TO SUPPLY SOURCE APP WHERE DATABASE URL WILL COME FROM... EXITING ****"
  exit 1
elif [ -z $3 ]; then
  echo "**** YOU NEED TO SUPPLY THE AWS BUCKER NAME... EXITING ****"
  exit 1
elif [ -z $4 ];then
  echo "**** YOU NEED TO SUPPLY THE AWS KEY... EXITING ****"
  exit 1
elif [ -z $5 ];then
  echo "**** YOU NEED TO SUPPLY THE AWS SECRET... EXITING ****"
  exit 1
fi

echo "**** STARTING INSTALLATION ****"
echo "    ---> Creating heroku app $1"
heroku create $1 --stack cedar --remote $1 --buildpack https://github.com/ddollar/heroku-buildpack-multi.git

echo "    ---> Pushing app $1 to heroku"
git push $1 master

echo "    ---> Configuring $1"
# fix the path (due to multi-buildpack issue)
heroku config:set PATH=bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin:/app/vendor/R/bin --remote $1
# set the db connection info
db_info=`heroku config:get DATABASE_URL --app $2`
heroku config:set DATABASE_URL=$db_info --remote $1
# set the worker name
heroku config:add WORKER_NAME=$1 --remote $1
# set the worker sleep time
heroku config:add WORKER_SLEEP_SECONDS=10 --remote $1
# set the tmp directory
heroku config:add TMP_DIR="/tmp/" --remote $1
# set the AWS bucket
heroku config:add AWS_BUCKET=$3 --remote $1
# set the AWS key
heroku config:add AWS_ACCESS_KEY_ID=$4 --remote $1
# set the AWS secret
heroku config:add AWS_SECRET_ACCESS_KEY=$5 --remote $1
# default MIRT processing to true
heroku config:add RUN_MIRT=true --remote $1
# default local tmp dir clean up to true
heroku config:add CLEAN_LOCAL_TEMP=true --remote $1
# default S3 tmp dir clean up to true
heroku config:add CLEAN_S3_TEMP=true --remote $1
# by default pull input files from S3
heroku config:add PULL_INPUT_FILES_FROM_S3=true --remote $1
# start the worker
heroku ps:scale worker=1 --remote $1
echo "**** INSTALLATION COMPLETE ****"
