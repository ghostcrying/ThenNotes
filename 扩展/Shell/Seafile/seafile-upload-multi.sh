#!/usr/bin/env bash

# this script depend on jq,check it first
RED='\033[0;31m'
NC='\033[0m' # No Color
if ! command -v jq &> /dev/null
then
    echo -e "${RED}jq could not be found${NC}, installed and restart plz!\n"
    exit
fi


usage () { echo "Usage : $0 -u <username> -p <password> -h <seafile server host> -v <apk version code> -f <upload file path> -d <parent dir default value is /> -r <repo id> -t <print debug info switch off/on,default off>"; }

# parse args
while getopts "u:p:h:v:f:d:r:t:" opts; do
   case ${opts} in
      u) USER=${OPTARG} ;;
      p) PASSWORD=${OPTARG} ;;
      h) HOST=${OPTARG} ;;
      v) VERSION=${OPTARG} ;;
      f) FILE=${OPTARG} ;;
      d) PARENT_DIR=${OPTARG} ;;
      r) REPO=${OPTARG} ;;
      t) DEBUG=${OPTARG} ;;
      *) usage; exit;;
   esac
done

# those args must be not null
if [ ! "$USER" ] || [ ! "$PASSWORD" ] || [ ! "$HOST" ] || [ ! "$VERSION" ] || [ ! "$FILE" ] || [ ! "$REPO" ]
then
    usage
    exit 1
fi

# optional args,set default value

[ -z "$DEBUG" ] && DEBUG=off

[ -z "$PARENT_DIR" ] && PARENT_DIR=/

# print vars key and value when DEBUG eq on
[[ "on" == "$DEBUG" ]] && echo -e "USER:${USER} PASSWORD:${PASSWORD} HOST:${HOST} VERSION:${VERSION} FILE:${FILE} PARENT_DIR:${PARENT_DIR} REPO:${REPO} DEBUG:${DEBUG}"

# login and get token
TOKEN=$(curl -s --location --request POST "${HOST}/api2/auth-token/" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "username=${USER}" --data-urlencode "password=${PASSWORD}" | jq -r ".token")
[ -z "$TOKEN" ] && echo -e "${RED}login seafile faild${NC}, call your administrator plz!\n" && exit 1


# create version folder: judge & create
JUDGE_ERROR=$(curl -s -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; indent=4' "${HOST}/api/v2.1/repos/${REPO}/dir/detail/?path=${PARENT_DIR}/${VERSION}" | jq -r ".error_msg")
echo "Judge Folder Error: ${JUDGE_ERROR}"
if [ "$JUDGE_ERROR" != "null" ]; then
    # 目录的创建只能逐级创建, 另外重名目录会共存, 以(1)(2)...形式存在
    echo "--- Create Version Folder ---"
    CREATE_RESULT=$(curl -d "operation=mkdir" -v -H "Authorization: Token $TOKEN" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api2/repos/${REPO}/dir/?p=${PARENT_DIR}/${VERSION}" | jq -r ".")
    echo "Create folder: ${CREATE_RESULT}"
    [[ "success" != "$CREATE_RESULT" ]] && echo -e "${RED}faild to create folder${NC}, call your administrator plz!\n" && exit 1
fi


echo "--- Get Walle Upload link ---"
UPLOAD_LINK=$(curl -s --header "Authorization: Token ${TOKEN}" "${HOST}/api2/repos/${REPO}/upload-link/?p=${PARENT_DIR}/${VERSION}" | jq -r ".")
echo "Get Upload link: ${UPLOAD_LINK}"
[ -z "$UPLOAD_LINK" ] && echo -e "${RED}get upload link faild${NC}, call your administrator plz!\n" && exit 1


#!/bin/bash
upload () {
    echo "--- Upload Walle file $1 ---"
    UPLOAD_ID=$(curl -s -v --header "Authorization: Token ${TOKEN}" -F file="@$1" -F filename=$(basename $1) -F parent_dir="${PARENT_DIR}/${VERSION}" -F replace=1 "${UPLOAD_LINK}?ret-json=1" | jq -r ". | last | .id")

    # [ -z "$UPLOAD_ID" ] && echo -e "${RED} faild to upload $1 ${NC}, call your administrator plz!\n" && exit 1
}

echo "--- Upload Walle Apks ---"
cd $FILE
for k in $(ls)
do
    upload $k
done
