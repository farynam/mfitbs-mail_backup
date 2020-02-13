#!/bin/bash
set -e 

#Incremental backup script

RSYNC_CMD="/usr/bin/rsync"
LS_CMD="/bin/ls"
WC_CMD="/usr/bin/wc"
RM_CMD="/bin/rm"
MKDIR_CMD="/bin/mkdir"
SORT_CMD="/usr/bin/sort"
HEAD_CMD="/usr/bin/head"
MAILX_CMD="/usr/bin/mailx"
ECHO_CMD="/bin/echo"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

. $DIR/globals.env
. $DIR/functions.sh
. $DIR/backup_incr_funs.sh

#init env
if [ -n $1 ]; then
  . $1
fi

if [ -z ${BACKUPS_DIR+x} ]; then
  echo "Please import env file"
  exit 1
fi

ssh_opt="-e ssh"

if [ -z "${REMOTE_HOST_}" ]; then
  ssh_opt="" 
else  
  REMOTE_HOST_="${REMOTE_HOST_}:"
fi

start_time=$(get_time_sec)
export backup_dir="$BACKUPS_DIR/$start_time"
mkdir -p "${backup_dir}/boxes"

function remove_overflow {
   limit=$1
   target_dir=$2
   backups_count=$(ls -1 $target_dir| grep -E '^[0-9]+$' | wc -l)
   file_removed=""
   if [ $backups_count -ge $limit ]; then
     oldest_version=$($LS_CMD -1 $target_dir| grep -E '^[0-9]+$'  |$SORT_CMD -n|$HEAD_CMD -1)
     file_removed="$target_dir/$oldest_version"
    $RM_CMD -r "$file_removed"
   fi
   echo "${file_removed}"
}

file_removed=$(remove_overflow $NUM_BACKUPS $BACKUPS_DIR)
link_dst_opt=""

if [ -n "$last_version" ]; then 
  link_dst_opt="--link-dest $BACKUPS_DIR/$last_version/boxes"
fi

excl_opt="--exclude-from $EXCLUDES"
if [ -z $EXCLUDES ] || [ ! -f $EXCLUDES ]; then
  excl_opt=""
fi

echo "starting sync from ${REMOTE_HOST_}${TO_BACKUP}/ to ${backup_dir}/boxes/"
rsync -arlh --stats $ssh_opt $excl_opt $link_dst_opt "${REMOTE_HOST_}${TO_BACKUP}/" "${backup_dir}/boxes/"






