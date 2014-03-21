grep -o '^R\|^cpu#[0-9]*\|^runnable' /proc/sched_debug | awk '
{
if ($1 ~ /cpu/) {
  if (cr==1) printf "\n";
  split($1,a,"#");
  filename="/sys/devices/system/cpu/cpu" a[2] "/topology/thread_siblings_list"
  getline sibl < filename;
  split(sibl,b,",");
  printf "%s", b[1]
}
if ($1 == "R") printf " R";
if ($1 == "runnable") cr=1;
}
END { print; }' \
  |grep R | tr -d ' R' |sort -n | uniq -c | awk '{if ($1 == 2) print $2}' |wc -l
