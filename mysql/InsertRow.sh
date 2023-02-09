#!/bin/sh

:<<'END'

- 1건씩 삽입

END

front_id=1
max_id=100000

for (( ; ; ))
do
        MYSQL_PWD='{패스워드}' mysql -h{DB주소} -uadmin --comments -e "INSERT INTO test.test SELECT null, ${id}, 'asdgkasjdghkasjdfhasdfadddddddddddddddddddddddddddddddddddddddddddddaaaaaaaaaaaaaaaaaaaghhhhhhhhhhhhhhhhhhhhhhhhdddddddddddddddddddddddddddddddddddddddddddddddddd';"

   if [ ${max_id} -lt ${id} ]
   then
      break
   fi

   echo ${id}
   echo "==========="
   id=$((id+1))
done
