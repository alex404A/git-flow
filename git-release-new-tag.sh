#!/bin/bash

RAW_PATH=$PWD
LOG_PATH=/home/sixestates/script/git-flow/logs
mkdir -p $LOG_PATH
LOG_FILE=$LOG_PATH/git-flow-$(date +%Y%m%d-%H%M-%S-%N).log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>> ready to release code in master" | tee -a $LOG_FILE
BASE_PATH=/home/sixestates/6estates/6web
cd $BASE_PATH

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout $CURRENT_BRANCH | tee -a $LOG_FILE
git stash  | tee -a $LOG_FILE
git checkout develop | tee -a $LOG_FILE
git fetch | tee -a $LOG_FILE
git merge | tee -a $LOG_FILE
git checkout $CURRENT_BRANCH | tee -a $LOG_FILE
git merge develop
out=$?
if [ $out -ne 0 ];then
  echo merge failed
  return
fi
git checkout develop | tee -a $LOG_FILE
git merge $CURRENT_BRANCH
out=$?
if [ $out -ne 0 ];then
  echo merge failed
  return
fi
git push | tee -a $LOG_FILE
git checkout master | tee -a $LOG_FILE
git fetch --tags | tee -a $LOG_FILE
git merge | tee -a $LOG_FILE
git merge develop
out=$?
if [ $out -ne 0 ];then
  echo merge failed
  return
fi
git push | tee -a $LOG_FILE
read 'flag?Please input flag to filter:'
git tag | grep $flag
read 'tag?Please input new tag:'
git tag $tag
out=$?
if [ $out -ne 0 ];then
  echo tag failed
  return
fi
git log | grep commit | head -1
echo tag $tag
git push origin master $tag | tee -a $LOG_FILE
git checkout develop | tee -a $LOG_FILE
git merge master | tee -a $LOG_FILE
git push | tee -a $LOG_FILE
git checkout $CURRENT_BRANCH | tee -a $LOG_FILE
git merge develop | tee -a $LOG_FILE
git stash apply | tee -a $LOG_FILE
cd $RAW_PATH
