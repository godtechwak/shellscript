#!/bin/bash

CHUNK=1000
START_ID=0
END_ID=$CHUNK
MAX_ID=16314819 ## SELECT MAX(id) FROM table
_HOSTNAME='서버 주소'
_USERNAME='유저 아이디'
_PASSWORD='유저 비밀번호'

while [ $START_ID -le $MAX_ID ]; do
  PGPASSWORD=${_PASSWORD} psql -h${_HOSTNAME} -U${_USERNAME} -d 'poi' --no-psqlrc -c "UPDATE table SET column = '' where deleted_at is not null AND updated_at is NOT NULL AND id >= ${START_ID} AND id < ${END_ID}"
  RTN_CODE="$?"
  if [ "${RTN_CODE}" -ne "0" ]; then
    echo "`date` ERROR, return value is ${RTN_CODE}"
    exit ${RTN_CODE}
  fi

  echo "`date` --> UPDATE table SET column = '' WHERE id >= ${START_ID} AND id < ${END_ID}"

  START_ID=$END_ID
  END_ID=$(($START_ID + $CHUNK))
done
