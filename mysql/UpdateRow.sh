#!/bin/sh

:<<'END'

- 1,000건씩 배치 업데이트

END

CHUNK=1000
front_id=1
back_id=1000
max_id=420104

for (( ; ; ))
do
   MYSQL_PWD='{비밀번호}' mysql -h{서버주소} -uadmin --comments -e "UPDATE table SET col = 'test WHERE id BETWEEN ${front_id} AND ${back_id};"

   RTN_CODE="$?"

   if [ "${RTN_CODE}" -ne "0" ]; then
      echo "`date` ERROR, return value is ${RTN_CODE}"
      exit ${RTN_CODE}
   fi

   if [ ${max_id} -lt ${back_id} ]
   then
      break
   fi
   sleep 0.1

   echo ${front_id}
   echo ${back_id}
   echo "==========="
   front_id=$((front_id+CHUNK))
   back_id=$((back_id+CHUNK))
done
