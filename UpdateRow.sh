#!/bin/sh

/*
 1000건씩 배치 업데이트
*/

front_id=1
back_id=1000
max_id=11148508

for (( ; ; ))
do
   MYSQL_PWD='{패스워드}' mysql -h{DB서버주소} -uadmin --comments -e "update test set seq=0 where id between ${front_id} and ${back_id}"

   if [ ${max_id} -lt ${back_id} ]
   then
      break
   fi
   sleep 0.2

   echo ${front_id}
   echo ${back_id}
   echo "==========="
   front_id=$((front_id+1000))
   back_id=$((back_id+1000))
done
