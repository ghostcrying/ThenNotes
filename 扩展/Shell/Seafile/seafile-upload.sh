#!/usr/bin/env bash

# this script depend on jq,check it first
RED='\033[0;31m'
NC='\033[0m' # No Color
if ! command -v jq &> /dev/null
then
    echo -e "${RED}jq could not be found${NC}, installed and restart plz!\n"
    exit
fi


usage () { echo "Usage : $0 -u <username> -p <password> -h <seafile server host> -f <upload file path> -d <parent dir default value is /> -r <repo id> -t <print debug info switch off/on,default off>"; }

# parse args
while getopts "u:p:h:f:d:r:t:" opts; do
   case ${opts} in
      u) USER=${OPTARG} ;;
      p) PASSWORD=${OPTARG} ;;
      h) HOST=${OPTARG} ;;
      f) FILE=${OPTARG} ;;
      d) PARENT_DIR=${OPTARG} ;;
      r) REPO=${OPTARG} ;;
      t) DEBUG=${OPTARG} ;;
      *) usage; exit;;
   esac
done

# those args must be not null
if [ ! "$USER" ] || [ ! "$PASSWORD" ] || [ ! "$HOST" ] || [ ! "$FILE" ] || [ ! "$REPO" ]
then
    usage
    exit 1
fi

# optional args,set default value

[ -z "$DEBUG" ] && DEBUG=off

[ -z "$PARENT_DIR" ] && PARENT_DIR=/

# print vars key and value when DEBUG eq on
[[ "on" == "$DEBUG" ]] && echo -e "USER:${USER} PASSWORD:${PASSWORD} HOST:${HOST} FILE:${FILE} PARENT_DIR:${PARENT_DIR} REPO:${REPO} DEBUG:${DEBUG}"

# login and get token
TOKEN=$(curl -s --location --request POST "${HOST}/api2/auth-token/" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "username=${USER}" --data-urlencode "password=${PASSWORD}" | jq -r ".token")

[ -z "$TOKEN" ] && echo -e "${RED}login seafile faild${NC}, call your administrator plz!\n" && exit 1

# gen upload link
UPLOAD_LINK=$(curl -s --header "Authorization: Token ${TOKEN}" "${HOST}/api2/repos/${REPO}/upload-link/?p=${PARENT_DIR}" | jq -r ".")

[ -z "$UPLOAD_LINK" ] && echo -e "${RED}get upload link faild${NC}, call your administrator plz!\n" && exit 1

# upload file
UPLOAD_RESULT=$(curl -s --header "Authorization: Token ${TOKEN}" -F file="@${FILE}" -F filename=$(basename ${FILE}) -F parent_dir="${PARENT_DIR}" -F replace=1 "${UPLOAD_LINK}?ret-json=1")

[ -z "$UPLOAD_RESULT" ] && echo -e "${RED}faild to upload ${FILE}${NC}, call your administrator plz!\n" && exit 1

# print upload result
[[ "on" == "$DEBUG" ]] && echo -e "TOKEN:${TOKEN} UPLOAD_LINK:${UPLOAD_LINK} UPLOAD_RESULT:${UPLOAD_RESULT}"

