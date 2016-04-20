#!/bin/sh
PROCNAME=$1
RESTART=$2
fromemail=lakesideave
toemail=nworksgreg@gmail.com
emailpass=302lakeside
ps auxw | grep ${PROCNAME} | grep -v grep | grep -v ${0} > /dev/null
EXITSTATUS=$?
# echo exit status: ${EXITSTATUS}
if [ ${EXITSTATUS} != 0 ]
then
   echo ${PROCNAME} is not running!
   if [ ! -f "${PROCNAME}Notify" ]
   then
     echo Sending email that ${PROCNAME} is not running!
     echo sendemail -f ${fromemail}@gmail.com -t ${toemail} -u "${PROCNAME} has stopped" -m "message=${PROCNAME} has stopped, restart option is: ${RESTART}" -o tls=auto -s smtp.gmail.com:465 -o tls=yes -xu ${toemail} -xp ${emailpass} >>${PROCNAME}Notify
     sendemail -f ${fromemail}@gmail.com -t ${toemail} -u "${PROCNAME} has stopped" -m "${PROCNAME} has stopped, restart option is: ${RESTART}" -o tls=yes -s smtp.gmail.com:587 -xu ${fromemail} -xp ${emailpass} >>${PROCNAME}Notify 2>&1
#     touch ${PROCNAME}Notify
   fi
  if [ -n "${RESTART}" ]
  then
    echo ${PROCNAME} being restarted
    echo Doing restart of process
    #/etc/init.d/apache2 start > /dev/null
  fi
else
  echo ${PROCNAME} is running.
  rm ${PROCNAME}Notify 2>/dev/null
fi
