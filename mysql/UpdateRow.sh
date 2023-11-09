#!/bin/sh

:<<'END'

- 3,000건씩 배치 업데이트

END

front_id=1000
back_id=4000
max_id=10000
add_count=3000

for (( ; ; ))
do
   MYSQL_PWD='{패스워드}' mysql -h{DB서버주소} -uadmin -D {DB명} --comments -e "update test set seq=0 where id between ${front_id} and ${back_id}"

   if [ ${max_id} -lt ${back_id} ]
   then
      break
   fi
   sleep 0.1

   echo ${front_id}
   echo ${back_id}
   echo "==========="
   front_id=$((front_id+add_count))
   back_id=$((back_id+add_count))
done
