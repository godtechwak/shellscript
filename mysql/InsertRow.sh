#!/bin/sh

:<<'END'

- 1건씩 데이터 삽입

END

id=1
max_id=100000

for (( ; ; ))
do
        MYSQL_PWD='{password}' mysql -h{host endpoint} -uadmin --comments -e "BEGIN; INSERT INTO test.test VALUES (null, ${id}, 'test'); COMMIT;"

   if [[ ${max_id} -lt ${id} ]]
   then
      break
   fi

   echo ${id}
   echo "==========="
   id=$((id+1))
done
