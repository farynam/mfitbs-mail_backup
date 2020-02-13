#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

. ${DIR}/functions.sh
. ${DIR}/backup_incr_funs.sh
. ${DIR}/globals.env
. $1

success=0
ret=0
messages_err=()
messages_err_idx=0

err_report() {
    echo "Error on line $1" > ${LOG_FILE}
    rm "${BLOCKING_FILE}"
}

trap 'err_report $LINENO' ERR

[ ! -d "${BACKUPS_DIR}" ] && mkdir -p "${BACKUPS_DIR}"

if [ ! -d "${TO_BACKUP}" ]; then
    mkdir -p "${TO_BACKUP}"
fi

if [ -f ${BLOCKING_FILE} ]; then
  echo "Backup in progress skipping"
  exit 1
  else
    touch ${BLOCKING_FILE}
fi

start_time_sync=$(get_time_sec)
export start_time=${start_time_sync}

write_log "backup started at: $(date -d @${start_time_sync})" "${LOG_FILE}"

export last_version=$(get_last_version ${BACKUPS_DIR})

for email_dir in ${EMAILS_TO_BACKUP}
do
    write_log "Capturing ${email_dir}" ${LOG_FILE}
	/usr/bin/offlineimap -c ${BACKUP_ROOT}/conf/offlineimap.conf -a "${email_dir}" 2>&1 | redir_log "${LOG_FILE}"
done	

start_time_backup=$(get_time_sec)

time_report_sync=$(time_elapsed ${start_time_sync} ${start_time_backup})

${DIR}/backup_incremental.sh "$1" 2>&1 | redir_log "${RSYNC_LOG_FILE}"

end_time_backup=$(get_time_sec)
time_report_backup=$(time_elapsed ${start_time_backup} ${end_time_backup} )

write_log "Backup ended at: $(date -d @${end_time_backup})" "${LOG_FILE}"

time_report="Backup time elapsed:${time_report_backup}.\n Sync time elapsed:${time_report_sync}"
write_log "${time_report}" "${LOG_FILE}"



mv ${LOG_FILE} ${BACKUPS_DIR}/${start_time_sync}/
mv ${RSYNC_LOG_FILE} ${BACKUPS_DIR}/${start_time_sync}/

rm "${BLOCKING_FILE}"