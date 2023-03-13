#!/bin/sh

:<<'END'

==============================================================================
Description
- 비밀번호 변경 스크립트

Variable
- MANGER_PASSWORD: MANAGER에서 DB 인스턴스 정보를 가져오기 위한 패스워드
- ADMIN_OLD_PASSWORD: admin 변경 전 패스워드
- ADMIN_NEW_PASSWORD: admin 변경 후 패스워드
- USER_COM_OLD_PASSWORD: USER_COM 변경 전 패스워드
- USER_COM_NEW_PASSWORD: USER_COM 변경 후 패스워드

==============================================================================

END


# password input function
function readPassword(){
  local PW_PROMPT="$1"
  local PW_INPUT=""
  local AUX_PROMPT=""
  while [ -z "${PW_INPUT}" ]; do
    read -p "${PW_PROMPT} (${AUX_PROMPT}) : "$'\n' -s PW_INPUT

    if [ -z "${PW_INPUT}" ]; then
      AUX_PROMPT="--> AGAIN !!, Password must be not empty string"
    else
      AUX_PROMPT=""
    fi

  done
  echo "${PW_INPUT}"
}

# password input again function
function readPasswordAgain(){
  local PW_PROMPT="$1"
  local PW_INPUT=""
  local AUX_PROMPT=""
  while [ -z "${PW_INPUT}" ]; do
    read -p "${PW_PROMPT} (${AUX_PROMPT}) : "$'\n' -s PW_INPUT

    if [ "${DOUBLE_CHECK}" != "${PW_INPUT}" ]; then
      AUX_PROMPT="--> AGAIN !!, New password & Again password do not match"
      PW_INPUT=""
    fi

  done
  echo "${PW_INPUT}"
}


## admin password
MANAGER_PASSWORD=$( readPassword "> MANAGER_PASSWORD" )
echo $MANAGER_PASSWORD
ADMIN_OLD_PASSWORD=$( readPassword "> ADMIN_OLD_PASSWORD" )
echo $ADMIN_OLD_PASSWORD
ADMIN_NEW_PASSWORD=$( readPassword "> ADMIN_NEW_PASSWORD" )
echo $ADMIN_NEW_PASSWORD
DOUBLE_CHECK="${ADMIN_NEW_PASSWORD}"
ADMIN_NEW_PASSWORD_AGAIN=$( readPasswordAgain "> ADMIN_NEW_PASSWORD_AGAIN" )

## USER_COM password
USER_COM_OLD_PASSWORD=$( readPassword "> USER_COM_OLD_PASSWORD" )
echo $USER_COM_OLD_PASSWORD
USER_COM_NEW_PASSWORD=$( readPassword "> USER_COM_NEW_PASSWORD" )
echo $USER_COM_NEW_PASSWORD
DOUBLE_CHECK="${USER_COM_NEW_PASSWORD}"
USER_COM_NEW_PASSWORD_AGAIN=$( readPasswordAgain "> USER_COM_NEW_PASSWORD_AGAIN" )

db_instance_list=`MYSQL_PWD='${MANAGER_PASSWORD}' mysql -htest-manager.xxxxxxxxxxxxx.ap-northeast-2.rds.amazonaws.com -uadmin -e "SELECT endpoint FROM MANAGER.aurora_instance WHERE region='ap-northeast-2'"`

IFS=$'\n'

for rLINE in ${db_instance_list};do
    ## admin
    mysqladmin -h${db_instance_list} -uadmin -p'$ADMIN_OLD_PASSWORD' password '$ADMIN_NEW_PASSWORD' 2> warning_admin.log

    if [ $? -eq 0 ]; then
        echo "Admin password update SUCCESSFULL!! ${db_instance_list}"
    else
        echo ${db_instance_list}
        echo "USER_COM ERROR: $?"
        break;
    fi

    ## USER_COM
    mysqladmin -h${db_instance_list} -uUSER_COM -p'$USER_COM_OLD_PASSWORD' password '$USER_COM_NEW_PASSWORD' 2> warning_USER_COM.log
    
    if [ $? -eq 0 ]; then
        echo "USER_COM password update SUCCESSFULL!! ${db_instance_list}"
    else
        echo ${db_instance_list}
        echo "USER_COM ERROR: $?"
        break;
    fi
done

echo "Password updated"
