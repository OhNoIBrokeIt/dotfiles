#!/bin/bash
# Read two CPU samples 400ms apart to compute usage %
cpu_sample() {
    awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5+$6}' /proc/stat
}

read total1 idle1 <<< $(cpu_sample)
sleep 0.4
read total2 idle2 <<< $(cpu_sample)

dt=$(( total2 - total1 ))
di=$(( idle2  - idle1  ))
cpu=$(( dt > 0 ? (dt - di) * 100 / dt : 0 ))

# CPU temp — Package id 0 from coretemp
cpu_temp=$(sensors 2>/dev/null | awk '/Package id 0/{match($0,/[0-9]+\.[0-9]+/); print int(substr($0,RSTART,RLENGTH)); exit}')

# GPU
gpu_line=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null | head -1)
gpu_use=$(  echo "$gpu_line" | awk -F, '{gsub(/ /,"",$1); print $1+0}')
gpu_temp=$( echo "$gpu_line" | awk -F, '{gsub(/ /,"",$2); print $2+0}')
gpu_mem_u=$(echo "$gpu_line" | awk -F, '{gsub(/ /,"",$3); print $3+0}')
gpu_mem_t=$(echo "$gpu_line" | awk -F, '{gsub(/ /,"",$4); print $4+0}')

# RAM
read mem_total mem_avail <<< $(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{print t,a}' /proc/meminfo)
mem_used=$(( mem_total - mem_avail ))
mem_pct=$(( mem_total > 0 ? mem_used * 100 / mem_total : 0 ))
ram_used_gb=$(awk "BEGIN{printf \"%.1f\", $mem_used/1048576}")
ram_total_gb=$(awk "BEGIN{printf \"%.0f\", $mem_total/1048576}")

printf '{"cpu":%d,"cpu_temp":%d,"gpu":%d,"gpu_temp":%d,"gpu_mem_used":%d,"gpu_mem_total":%d,"ram_pct":%d,"ram_used":"%s","ram_total":"%s"}\n' \
    "$cpu" "${cpu_temp:-0}" "${gpu_use:-0}" "${gpu_temp:-0}" \
    "${gpu_mem_u:-0}" "${gpu_mem_t:-0}" "$mem_pct" "$ram_used_gb" "$ram_total_gb"
