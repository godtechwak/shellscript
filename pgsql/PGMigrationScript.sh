#!/bin/sh

export red="\033[1;31m"
export green="\033[1;32m"
export yellow="\033[1;33m"
export blue="\033[1;34m"
export purple="\033[1;35m"
export cyan="\033[1;36m"
export grey="\033[0;37m"
export reset="\033[m"



# =#==#==#==#==#
#  Configuration
# ==#==#==#==#==#

## 0. Common
_database='공통 DB명'
_password='공통 패스워드'
_download_file_dir='다운로드 받을 파일 경로/파일명'
_table_name='이관이 필요한 테이블명'

## 1. Source
_source_username='Source 유저명'
_source_hostname='Source Primary DB Endpoint'

## 2. Target
_target_username='Target 유저명'
_target_hostname='Target Primary DB Endpoint'



# =#==#===#==#
#  Migration
# ==#==#==#==#
echo "${green}Downloading files from SourceDB...${reset}"
PGPASSWORD=${_password} psql -h${_source_hostname} -U${_source_username} -d${_database} -c '\copy ( select * from '${_table_name}' ) to '${_download_file_dir}' csv header;' 2> source_error.log

if [ $? -eq 0 ]; then
    echo "${blue}Download complete!${reset}"
    echo "\n"
    echo "${green}Loading Data to targetDB...${reset}"
    PGPASSWORD=${_password} psql -h${_target_hostname} -U${_target_username} -d${_database} -c '\copy ${_table_name} FROM '${_download_file_dir}' csv header;' 2> target_error.log

    if [ $? -eq 0 ]; then
        echo "${blue}Data loading completed!\n${reset}"
        echo "Source Data:"
        PGPASSWORD=${_password} psql -h${_source_hostname} -U${_source_username} -d${_database} -c 'select min(id), max(id), count(*) from '${_table_name}'' 2> /dev/null
        echo "Target Data:"
        PGPASSWORD=${_password} psql -h${_target_hostname} -U${_target_username} -d${_database} -c 'select min(id), max(id), count(*) from '${_table_name}'' 2> /dev/null
    else
        echo "${red}Target Error!!${reset}"
    fi

else
    echo "${red}Source Error!!${reset}"
fi
