#!/bin/bash
MVN="/usr/local/apache-maven/bin/mvn"
LOG_PATH=/public/dpy/deploy/logs
mkdir -p $LOG_PATH
LOG_FILE=$LOG_PATH/sw-simulate-deploy-$(date +%Y%m%d-%H%M-%S-%N).log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>> build dependencies in local" |tee -a $LOG_FILE
BASE_PATH=/public/dpy/workspace/6web-dev/
cd $BASE_PATH
git reset --hard |tee -a $LOG_FILE
git checkout master
git  pull  |tee -a $LOG_FILE
git checkout develop |tee -a $LOG_FILE
git  pull
echo $MVN | tee -a $LOG_FILE
cd $BASE_PATH/module
$MVN clean install -Dmaven.test.skip=true | tee -a $LOG_FILE
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>>>>>> build module mvn package" |tee -a $LOG_FILE
cd $BASE_PATH/dao/southwest
$MVN clean install -Dmaven.test.skip=true | tee -a $LOG_FILE
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>>>>>> build dao mvn package" |tee -a $LOG_FILE
cd $BASE_PATH/app/southwest
$MVN clean install -Dmaven.test.skip=true | tee -a $LOG_FILE
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>>>>>> build app mvn package" |tee -a $LOG_FILE
$MVN clean package -P simulate -Dmaven.test.skip=true |tee -a $LOG_FILE
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>>>>>>>> rsync war to cloud" |tee -a $LOG_FILE
D_HOST=172.18.109.224
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>>>>>>>>>> stop jetty" |tee -a $LOG_FILE
ssh  root@$D_HOST "/sbin/service jetty-swsm stop"
ssh  root@$D_HOST  "rm -rf /opt/jetty-swsm/webapps/ROOT.war "
scp  $BASE_PATH/app/southwest/target/6web*.war root@$D_HOST:/opt/jetty-swsm/webapps/ROOT.war
ssh root@$D_HOST "chown -R jetty.jetty /opt/jetty*"
#done
echo "[$(date '+%Y-%m-%d %H:%M:%S')] >>>>>>>>>>>>>>>>>> start jetty" |tee -a $LOG_FILE
ssh root@$D_HOST "/sbin/service jetty-swsm start"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] finish deploy" |tee -a $LOG_FILE
