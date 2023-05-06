#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

USER=xxx
PASSWORD=xxx
HOST=https://seafile.bloks.com
#资料库id
REPO=16017025-bcc3-4cab-bdc6-f48a8188440e
UPLOAD_REPO=adfcd29e-5f3d-4228-a790-e8b9846e0eb3
#本地文件路径
FILE=/Users/admin/Desktop/Shell
#上传存储路径
PARENT_DIR=/布鲁可－技术/技术开发/App整合/布鲁可发布记录/布鲁可小颗粒积木/iOS
FRAMEWORKS_DIR=/布鲁可－技术/技术开发/App整合/iOS_Frameworks
SEAFILE_FRAMEWORKS=/布鲁可－技术/技术开发/App整合/iOS_Frameworks/Bloks/Build.zip
VERSION_DIR=/布鲁可－技术/技术开发/App整合/版本传输/布鲁可小颗粒积木/Android/v1.0.9/build1093

while getopts "t:" opts; do
   case ${opts} in
      t) DEBUG=${OPTARG} ;;
      *) usage; exit;;
   esac
done

echo "--- Get Token ---"
TOKEN=$(curl -s --location --request POST "${HOST}/api2/auth-token/" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "username=${USER}" --data-urlencode "password=${PASSWORD}" | jq -r ".token")

[ -z "$TOKEN" ] && echo -e "${RED}login seafile faild${NC}, call your administrator plz!\n" && exit 1

#echo "--- Judge Folder ---"
#JUDGE_ERROR=$(curl -s -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; indent=4' "${HOST}/api/v2.1/repos/${REPO}/dir/detail/?path=${PARENT_DIR}/foo" | jq -r ".error_msg")
#echo "Judge Folder Error: ${JUDGE_ERROR}"
#[ -z "$JUDGE_ERROR" ] && echo -e "${RED}faild to found ${PARENT_DIR}/foo${NC}, check folder plz!\n" && exit 1
#
#if [ -z "$JUDGE_ERROR" ]; then
#    # 目录的创建只能逐级创建, 另外重名目录会共存, 以(1)(2)...形式存在
#    echo "--- Create folder ---"
#    CREATE_RESULT=$(curl -d "operation=mkdir" -v -H "Authorization: Token $TOKEN" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api2/repos/${REPO}/dir/?p=${PARENT_DIR}/foo" | jq -r ".")
#    echo "Create folder: ${CREATE_RESULT}"
#    [[ "success" != "$CREATE_RESULT" ]] && echo -e "${RED}faild to create folder${NC}, call your administrator plz!\n" && exit 1
#fi
#
#
#echo "--- Get Upload link ---"
#UPLOAD_LINK=$(curl -s --header "Authorization: Token ${TOKEN}" "${HOST}/api2/repos/${REPO}/upload-link/?p=${PARENT_DIR}/foo" | jq -r ".")
#echo "Get Upload link: ${UPLOAD_LINK}"
#[ -z "$UPLOAD_LINK" ] && echo -e "${RED}get upload link faild${NC}, call your administrator plz!\n" && exit 1
#

#
#echo "--- Upload file ---"
#UPLOAD_RESULT=$(curl -s --header "Authorization: Token ${TOKEN}" -F file="@${FILE}" -F filename=$(basename ${FILE}) -F parent_dir="${PARENT_DIR}" -F replace=1 "${UPLOAD_LINK}?ret-json=1")
#
#[ -z "$UPLOAD_RESULT" ] && echo -e "${RED}faild to upload ${FILE}${NC}, call your administrator plz!\n" && exit 1
#
## print upload result
#[[ "on" == "$DEBUG" ]] && echo -e "TOKEN:${TOKEN} UPLOAD_LINK:${UPLOAD_LINK} UPLOAD_RESULT:${UPLOAD_RESULT}"
#

#!/bin/bash
#upload () {
#    echo "--- Upload file $1 ---"
#    UPLOAD_RESULT=$(curl -s --header "Authorization: Token ${TOKEN}" -F file="@$1" -F filename=$(basename $1) -F parent_dir="${PARENT_DIR}/foo" -F replace=1 "${UPLOAD_LINK}?ret-json=1")
#
#    [ -z "$UPLOAD_RESULT" ] && echo -e "${RED}faild to upload $1${NC}, call your administrator plz!\n" && exit 1
#}
#
#echo "--- Upload file ---"
#cd $FILE
#for k in $(ls)
#do
##    upload $k
#    echo $k
#done

#echo "--- Download file ---"
#Download_Link=$(curl  -v  -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api2/repos/${REPO}/file/?p=${SEAFILE_FRAMEWORKS}&reuse=1" | jq -r ".")
#echo $Download_Link
#
#cd /Users/admin/Desktop/Shell
#curl -o build.zip $Download_Link && unzip build.zip && rm -rf build.zip


#目录的下载是zip形式压缩的, 但是基本很难实现
#echo "--- Download Folder ---"
#cd $FILE
#ZIP_TOKEN=$(curl -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api/v2.1/repos/${REPO}/zip-task/?parent_dir=${PARENT_DIR}&dirents=foo" | jq -r ".zip_token")
#echo $ZIP_TOKEN
#[ -z "$ZIP_TOKEN" ] && echo -e "${RED}faild to download $foo${NC}, call your administrator plz!\n" && exit 1
#
##curl -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api/v2.1/query-zip-progress/?token=${ZIP_TOKEN}"
#
#rm -rf build
#c
#curl -o frame.zip ${HOST}/seafhttp/zip/${ZIP_TOKEN} && unzip frame.zip && rm frame.zip && mv foo build
#

#cd $FILE
#echo "--- Get Seafile xcFrameworks Zip ---"
#ZIP_TOKEN=$(curl -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api/v2.1/repos/${REPO}/zip-task/?parent_dir=${FRAMEWORKS_DIR}&dirents=Classroom" | jq -r ".zip_token")
#echo $ZIP_TOKEN
#[ -z "$ZIP_TOKEN" ] && echo -e "${RED}faild to download Bloks${NC}, call your administrator plz!\n" && exit 1
#
#curl -H "Authorization: Token ${TOKEN}" -H 'Accept: application/json; charset=utf-8; indent=4' "${HOST}/api/v2.1/query-zip-progress/?token=${ZIP_TOKEN}"
#
##https://seafile.bloks.com/seafhttp/zip/e6ff0a05-f394-4cca-86f8-53e8077f41d8
##curl ${HOST}/seafhttp/zip/${ZIP_TOKEN}
#
#echo "--- UnZip xcFrameworks ---"

#&& unzip frame.zip && rm frame.zip && mv Bloks Build


