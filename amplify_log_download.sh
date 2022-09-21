#!/bin/sh
# Shell script to download the Amplify log file from AWS
# Path: amplify_log_download.sh
# Requires: awscli, jq, aws credentials configured in ~/.aws/credentials
# Usage: amplify_log_download.sh <appname> <domain> <startDate> <endDate>
# Example: amplify_log_download.sh xyz123 google.com 2022-09-02 2022-09-21
# Tested on: MacOS 12.5.1

# Config
app_id=$1
domain_name=$2
start_date=$3
end_date=$4
output_dir="./logs"

sDateTs=`date -j -f "%Y-%m-%d" $start_date "+%s"`
eDateTs=`date -j -f "%Y-%m-%d" $end_date "+%s"`
dateTs=$sDateTs
offset=86400

mkdir -p -- "$output_dir"

echo "[+] Downloading logs from $start_date to $end_date"

while [ "$dateTs" -le "$eDateTs" ]
do
    log_start_date=`date -j -f "%s" $dateTs "+%Y-%m-%d"`
    dateTs=$(($dateTs+$offset))
    log_end_date=`date -j -f "%s" $dateTs "+%Y-%m-%d"`

    log_to_download=$(aws amplify generate-access-logs --start-time $log_start_date --end-time $log_end_date --app-id $app_id --domain-name $domain_name | jq '.["logUrl"]' | tr -d '"')

    # echo $log_to_download
    log_path="$output_dir/$log_start_date.log"
    echo " - ($log_start_date -> $log_end_date) : $log_path"
    curl -s $log_to_download -o "$log_path"
    echo " => Done"

done
