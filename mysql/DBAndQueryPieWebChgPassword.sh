#!/bin/bash

:<<'END'
==============================================================================
Description
- DB 및 쿼리파이웹 계정 패스워드 변경 스크립트
Variable
- ADMIN_OLD_PASSWORD: admin 변경 전 패스워드
- ADMIN_NEW_PASSWORD: admin 변경 후 패스워드
- STAFF_OLD_PASSWORD: staff 변경 전 패스워드
- STAFF_NEW_PASSWORD: staff 변경 후 패스워드
==============================================================================
END

Q_API_TOKEN="쿼리파이 API 토큰 정보 --> 1Password 참조"

function readPassword(){
  local TITLE="$1"
  local INPUTBOX="$2"
  local VALUE=""
  local ERROR_MESSAGE=""
  while [ -z "${VALUE}" ]; do
    VALUE=$(whiptail --title "$TITLE" --inputbox "$INPUTBOX \n${ERROR_MESSAGE}" 10 60 3>&1 1>&2 2>&3)
    
    if [[ $? -eq 1 ]]; then
      exit
    fi

    if [ -z "${VALUE}" ]; then
      ERROR_MESSAGE="AGAIN !!, Password must be not empty string"
    else
      ERROR_MESSAGE=""
    fi

  done
  echo "${VALUE}"
}

function readPasswordAgain(){
  local TITLE="$1"
  local INPUTBOX="$2"
  local VALUE=""
  local ERROR_MESSAGE=""
  while [ -z "${VALUE}" ]; do
    VALUE=$(whiptail --title "$TITLE" --inputbox "$INPUTBOX \n${ERROR_MESSAGE}" 10 60 3>&1 1>&2 2>&3)

    if [[ $? -eq 1 ]]; then
      exit
    fi

    if [ "${DOUBLE_CHECK}" != "${VALUE}" ]; then
      ERROR_MESSAGE="AGAIN !!, New password & Again password do not match"
      VALUE=""
    fi

  done
  echo "${VALUE}"
}

#######################
## 비밀번호 변경 시작
#######################
whiptail --title " DB 계정 & 쿼리파이Web 계정 비밀번호 변경" --yesno "비밀번호 변경 작업을 진행하시겠습니까?" 8 78 
if [[ $? -eq 0 ]]; then
	work_type=$(whiptail --title "작업 유형 선택" --menu "어떤 작업을 진행하시나요?" 15 60 4 "test" ": DB 계정 비밀번호를 변경" "QueryPieWeb" ": 쿼리파이웹 계정 비밀번호를 변경" 3>&1 1>&2 2>&3)

	##  DB 계정 비밀번호 변경 
  	if [[ ${work_type} = "test" ]]; then
  		db_instance_list=`MYSQL_PWD='admin 비밀번호' mysql -h{서버주소} -uadmin -e "쿼리문"`
formatted_db_instance_list=$(echo -e "$db_instance_list" | sed 's/ /\\n/g')
		whiptail --title "admin & staff DB 계정 비밀번호 변경  대상 리스트 확인" --yesno --scrolltext "$formatted_db_instance_list" 40 100 

		## 변경
		if [[ $? -eq 0 ]]; then
      		account_type=$(whiptail --title "DB 계정 작업 유형 선택" --menu "비밀번호를 변경하려는 계정을 선택해주세요" 15 60 4 "admin" ": admin 계정 비밀번호 변경" "staff" ": staff 계정 비밀번호 변경" 3>&1 1>&2 2>&3)

      		## admin 계정 비밀번호 변경
      		if [[ ${account_type} = "admin" ]]; then
        		ADMIN_OLD_PASSWORD=$( readPassword "admin 비밀번호 변경(현재)" "admin 계정의 현재 비밀번호를 입력하세요:")
        	
        		if [[ -z "${ADMIN_OLD_PASSWORD}" ]]; then
          			exit
        		fi
        
        		ADMIN_NEW_PASSWORD=$( readPassword "admin 비밀번호 변경(신규)" "admin 계정의 신규 비밀번호를 입력하세요:" )
        		if [[ -z "${ADMIN_NEW_PASSWORD}" ]]; then
          			exit
        		fi
      
        		DOUBLE_CHECK="${ADMIN_NEW_PASSWORD}"
        		ADMIN_NEW_PASSWORD_AGAIN=$( readPasswordAgain "admin 비밀번호 변경(신규)" "admin 계정의 신규 비밀번호를 재입력하세요:" )
        		
        		if [[ -z "${ADMIN_NEW_PASSWORD_AGAIN}" ]]; then
          			exit
        		fi

      		## staff 계정 비밀번호 변경
      		elif [[ ${account_type} = "staff" ]]; then
        		STAFF_OLD_PASSWORD=$( readPassword "staff 비밀번호 변경(현재)" "staff 계정의 현재 비밀번호를 입력하세요:")
        		
        		if [[ -z "${STAFF_OLD_PASSWORD}" ]]; then
          			exit
        		fi
        		
        		STAFF_NEW_PASSWORD=$( readPassword "staff 비밀번호 변경(신규)" "staff 계정의 신규 비밀번호를 입력하세요:" )
        		if [[ -z "${STAFF_NEW_PASSWORD}" ]]; then
          			exit
        		fi
   
        		DOUBLE_CHECK="${STAFF_NEW_PASSWORD}"
        		staff_NEW_PASSWORD_AGAIN=$( readPasswordAgain "staff 비밀번호 변경(신규)" "staff 계정의 신규 비밀번호를 재입력하세요:" )
        		if [[ -z "${staff_NEW_PASSWORD_AGAIN}" ]]; then
          			exit
        		fi
			fi

			## 변경 작업이 맞는지 마지막 확인
    	whiptail --title "admin & staff DB 계정 비밀번호 변경" --yesno "비밀번호 변경을 진행하시겠습니까? \n예를 누를 경우 ${account_type} DB 계정의 비밀번호 변경 작업이 바로 진행됩니다." 20 60
			
			if [[ $? -eq 0 ]]; then
      			for rDB_INSTANCE_LIST in ${db_instance_list}; do
        		  
              if [[ ${rDB_INSTANCE_LIST} = "endpoint" ]]; then
                continue
              fi

        			## admin
        			if [[ ${account_type} = "admin" ]]; then
                echo ${account_type}
                echo ${rDB_INSTANCE_LIST}
        				# 작업할 때 주석해제
                #MYSQL_PWD=${ADMIN_OLD_PASSWORD} mysqladmin -h${rDB_INSTANCE_LIST} -uadmin password ${ADMIN_NEW_PASSWORD} 2> warning_admin.log
        			## staff
        			elif [[ ${account_type} = "staff" ]]; then
                echo ${account_type}
                echo ${rDB_INSTANCE_LIST}
                # 작업할 때 주석해제
        				#MYSQL_PWD=${ADMIN_NEW_PASSWORD} mysql -u admin -h${rDB_INSTANCE_LIST} -e "ALTER USER 'staff'@'10.%' IDENTIFIED BY '${STAFF_NEW_PASSWORD}'" 2> warning_staff.log
        			fi
        			      			
        			if [ $? -eq 0 ]; then
          				result="$result\nPassword update SUCCESS: ${rDB_INSTANCE_LIST}"
        			else
        				result="$result\nPassword update ERROR: ${rDB_INSTANCE_LIST}"					
        			fi
      			done
    		elif [[ $? -eq 1 ]]; then
    			exit
    		fi      

    	## 취소
    	elif [[ $? -eq 1 ]]; then
      		exit
    	fi

      whiptail --title "업데이트 결과" --msgbox --scrolltext "$result" 40 100
  	
  	## 쿼리파이웹 DB 계정 비밀번호 변경 
  	elif [[ ${work_type} = "QueryPieWeb" ]]; then
  		account_type=$(whiptail --title "쿼리파이웹 계정 작업 유형 선택" --menu "비밀번호를 변경하려는 계정을 선택해주세요" 15 60 4 "admin" ": admin 계정 비밀번호 변경" "staff" ": staff 계정 비밀번호 변경" 3>&1 1>&2 2>&3)

  		  ## admin 계정 비밀번호 변경
    	  if [[ ${account_type} = "admin" ]]; then
    		  cluster_name_list=`curl --location "https://querypie.prod.kr.krtest.io/api/external/connections" --header "Authorization: ${Q_API_TOKEN}" --header 'Accept: application/json' | python3 -c "import sys, json; data=json.load(sys.stdin); print('\n'.join([item['name'] for item in data['list'] if 'dba' in item['name']]))"`
      		cluster_uuid_list=`curl --location "https://querypie.prod.kr.krtest.io/api/external/connections" --header "Authorization: ${Q_API_TOKEN}" --header 'Accept: application/json' | python3 -c "import sys, json; data=json.load(sys.stdin); print('\n'.join([item['name'] for item in data['list'] if 'dba' in item['name']]))"`
      		formatted_cluster_name_list=$(echo -e "$cluster_name_list" | sed 's/ /\\n/g')
      		whiptail --title "admin 쿼리파이웹 계정 비밀번호 변경 대상 리스트 확인" --yesno --scrolltext "$formatted_cluster_name_list" 40 100

      		if [[ $? -eq 0 ]]; then
      			ADMIN_NEW_PASSWORD=$( readPassword "admin 비밀번호 변경(신규)" "admin 계정의 신규 비밀번호를 입력하세요:" )
            
        		## 취소를 누르는 경우
        		if [[ -z "${ADMIN_NEW_PASSWORD}" ]]; then
          			exit
        		fi
        
        		DOUBLE_CHECK="${ADMIN_NEW_PASSWORD}"
        		ADMIN_NEW_PASSWORD_AGAIN=$( readPasswordAgain "admin 비밀번호 변경(신규)" "admin 계정의 신규 비밀번호를 재입력하세요:" )
        
        		## 취소를 누르는 경우
        		if [[ -z "${ADMIN_NEW_PASSWORD_AGAIN}" ]]; then
          			exit
        		fi
        	elif [[ $? -eq 1 ]]; then
        		exit
      		fi
        fi

        ## staff 계정 비밀번호 변경
    	  if [[ ${account_type} = "staff" ]]; then
    		  cluster_name_list=`curl --location "https://querypie.prod.kr.krtest.io/api/external/connections" --header "Authorization: ${Q_API_TOKEN}" --header 'Accept: application/json' | python3 -c "import sys, json; data=json.load(sys.stdin); print('\n'.join([item['name'] for item in data['list'] if 'dba' not in item['name']]))"`
      		cluster_uuid_list=`curl --location "https://querypie.prod.kr.krtest.io/api/external/connections" --header "Authorization: ${Q_API_TOKEN}" --header 'Accept: application/json' | python3 -c "import sys, json; data=json.load(sys.stdin); print('\n'.join([item['name'] for item in data['list'] if 'dba' not in item['name']]))"`
      		formatted_cluster_name_list=$(echo -e "$cluster_name_list" | sed 's/ /\\n/g')
      		whiptail --title "staff 쿼리파이웹 계정 비밀번호 변경 대상 리스트 확인" --yesno --scrolltext "$formatted_cluster_name_list" 40 100

      		if [[ $? -eq 0 ]]; then 
        		STAFF_NEW_PASSWORD=$( readPassword "staff 비밀번호 변경(신규)" "staff 계정의 신규 비밀번호를 입력하세요:" )
        
        		## 취소를 누르는 경우
        		if [[ -z "${STAFF_NEW_PASSWORD}" ]]; then
          			exit
        		fi
   
        		DOUBLE_CHECK="${STAFF_NEW_PASSWORD}"
        		staff_NEW_PASSWORD_AGAIN=$( readPasswordAgain "staff 비밀번호 변경(신규)" "staff 계정의 신규 비밀번호를 재입력하세요:" )
        
        		## 취소를 누르는 경우
        		if [[ -z "${staff_NEW_PASSWORD_AGAIN}" ]]; then
          			exit
        		fi
      		elif [[ $? -eq 1 ]]; then
        		exit
      		fi
      	fi

      	## 변경 작업이 맞는지 마지막 확인
    	  whiptail --title "admin & staff 쿼리파이웹 계정 비밀번호 변경" --yesno "비밀번호 변경을 진행하시겠습니까? \n예를 누를 경우 ${account_type} 쿼리파이웹 계정의 비밀번호 변경 작업이 바로 진행됩니다." 20 60

    	if [[ $? -eq 0 ]]; then
      		for rCLUSTER_UUID_LIST in ${cluster_uuid_list}; do
        		
        		# 작업할 때 주석해제
        		#curl --location --request PATCH "https://querypie.prod.kr.krtest.io/api/external/connections/${rCLUSTER_UUID_LIST}" --header "Authorization: ${Q_API_TOKEN}" --header 'Accept: application/json' --header 'Content-Type: application/json' --data "{\"connectionAccount\": {\"usernamePasswords\": {\"common\": {\"username\": \"${Q_USER}\",\"password\": \"${Q_PASSWORD}\"}}},\"hideCredentialEnabled\": true}        		

        		if [ $? -eq 0 ]; then
          			result="$result\nPassword update SUCCESS: ${rCLUSTER_UUID_LIST}"
        		else
        			result="$result\nPassword update ERROR: ${rCLUSTER_UUID_LIST}"					
        		fi
      		done
    	elif [[ $? -eq 1 ]]; then
    		exit
    	fi

    	whiptail --title "업데이트 결과" --msgbox --scrolltext "$result" 40 100 

  	fi
elif [[ $? -eq 1 ]]; then 
	whiptail --title "MESSAGE" --msgbox "비밀번호 변경 작업이 취소되었습니다." 8 78 
elif [[ $? -eq 255 ]]; then 
  	whiptail --title "MESSAGE" --msgbox "User pressed ESC. Exiting the script" 8 78 
fi
