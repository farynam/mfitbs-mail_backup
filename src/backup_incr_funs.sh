function get_last_version {
  target_dir=$1
  newest_file=$(ls -1 $target_dir |grep -E '^[0-9]+$' |sort -nr|head -1)
  echo "${newest_file}"
}

