#!/bin/bash

function write_log {
    echo "$1" | tee -a "$2"
}

function redir_log {
    while read IN               # If it is output from command then loop it
    do
        echo "${IN}" | tee -a ${1}
    done
}

function get_scriptdir {
	echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
}

function get_time_sec {
	echo $(date "+%s")
}

function time_elapsed {
	start_time=$1
	end_time=$2
	diff=$(( $end_time - $start_time ))

	
	days=$(( $diff / 60 / 60 / 24))
	hours=$(( ($diff  - $days * 60 * 60 * 24) / 60 / 60 ))
	mins=$(( ($diff - $hours * 60 * 60 - $days * 60 * 60 * 24) / 60 ))
	secs=$(( $diff - $hours * 60 * 60 - $days * 60 * 60 * 24 - $mins * 60 ))


	echo "${days}d ${hours}h ${mins}m ${secs}s"
}

