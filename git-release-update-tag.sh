#!/bin/bash

RAW_PATH=$PWD
LOG_PATH=/home/sixestates/script/git-flow/logs
mkdir -p $LOG_PATH
LOG_FILE=$LOG_PATH/git-flow-$(date +%Y%m%d-%H%M-%S-%N).log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>> ready to release code in master" | tee -a $LOG_FILE
BASE_PATH=/home/sixestates/6estates/6web
cd $BASE_PATH
git checkout local | tee -a $LOG_FILE
git stash  | tee -a $LOG_FILE
git checkout develop | tee -a $LOG_FILE
git fetch | tee -a $LOG_FILE
git merge | tee -a $LOG_FILE
git checkout local | tee -a $LOG_FILE
git merge develop
out=$?
if [ $out -ne 0 ];then
  echo merge failed
  return
fi
git checkout develop | tee -a $LOG_FILE
git merge local
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
git tag
read -p 'Please input existing tag to point to new commit:' tag
git push origin :refs/tags/$tag
git tag -f $tag
git push origin master $tag
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
git checkout local | tee -a $LOG_FILE
git merge develop | tee -a $LOG_FILE
git stash apply | tee -a $LOG_FILE
cd $RAW_PATH
