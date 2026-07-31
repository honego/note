#!/usr/bin/env bash
# vim:sw=4:ts=4:et
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2025-2026 The JdsGame Authors. All rights reserved.

# 当前脚本版本号
readonly VERSION='v2.1.0 (2026.07.30)'

# Default variable values.
PROCESS_PID="/tmp/process.pid"
LOG_DIR="/data/logbak"
WORK_DIR="/data/tool"
APP_NAME="p8_app_server"
readonly LOG_DIR WORK_DIR APP_NAME

## 功能函数
get_time() {
    local separator tz

    separator="$1"
    tz="$2"

    date -u "+%Y-%m-%d${separator}%H:%M:%S" -d "$tz hours"
}

is_dir_exists() {
    [ -d "$1" ]
}

is_file_exists() {
    [ -f "$1" ]
}

# 检查数组是否为空
is_array_empty() {
    local -n array="$1"
    [ "${#array[@]}" -eq 0 ]
}

# 获取指定路径下 "前缀+数字" 格式的一级目录编号并按数值升序输出
get_server_num() {
    local base_path prefix

    base_path="$1"
    prefix="$2"

    find "$base_path" -maxdepth 1 -type d -regextype posix-extended -regex ".*/${prefix}[0-9]+" -printf '%f\n' | sed "s/^${prefix}//" | sort -n
}

run_check() {
    if [ -f "$PROCESS_PID" ] && kill -0 "$(cat "$PROCESS_PID")" 2> /dev/null; then
        printf "The script is running, please do not repeat the operation!\n" >> "$WORK_DIR/control.txt" && exit 1
    fi
    echo "$$" > "$PROCESS_PID"
    [ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR" 1> /dev/null
    if [ -s "$WORK_DIR/control.txt" ] || [ -s "$WORK_DIR/dump.txt" ]; then
        rm -f "${WORK_DIR:?Error: WORK_DIR is not set}"/{control.txt,dump.txt} 2> /dev/null
    fi
    printf "Current script version: %s Daemon process started. \xe2\x9c\x93 \n" "$VERSION" >> "$WORK_DIR/control.txt"
}

# 检查进程是否存在
is_srv_run() {
    local server_dir pid srv_exe run_exe

    server_dir="$1"

    is_file_exists "$server_dir/pid.txt" || return 1
    read -r pid < "$server_dir/pid.txt"

    [[ $pid =~ ^[0-9]+$ ]] || return 1
    kill -0 "$pid" 2> /dev/null || return 1

    srv_exe="$(readlink -f "$server_dir/$APP_NAME")" || return 1 # 获取程序实际路径
    # https://www.man7.org/linux/man-pages/man5/proc_pid_exe.5.html
    run_exe="$(readlink -f "/proc/$pid/exe" 2> /dev/null)" || return 1 # 获取 pid 对应进程的实际路径

    [ "$srv_exe" = "$run_exe" ]
}

# independent logic called by a function.
check_and_start() {
    local server_name server_dir

    server_name="$1"
    server_dir="$2"

    if ! is_srv_run "$server_dir"; then
        pushd "$server_dir" > /dev/null 2>&1 || return 1
        is_file_exists nohup.txt && mv -f nohup.txt "$LOG_DIR/nohup_${server_name}_$(get_time "_" 8).txt"
        is_file_exists pid.txt && rm -f pid.txt
        ./server.sh start &
        echo "$(get_time " " 8) [ERROR] $server_name Restart" >> "$WORK_DIR/dump.txt"
        popd > /dev/null || return 1
    else
        echo "$(get_time " " 8) [INFO] $server_name Running" >> "$WORK_DIR/control.txt"
    fi
}

## 检查函数
check_entry_srv() {
    check_and_start "gate" "/data/server/gate"
    check_and_start "login" "/data/server/login"
}

check_global_srv() {
    local base_path num server_name server_dir
    local global_server=()

    base_path="/data/center"

    is_dir_exists "$base_path" || return
    mapfile -t global_server < <(get_server_num "$base_path" global)
    is_array_empty global_server && return
    for num in "${global_server[@]}"; do
        server_name="global$num"
        server_dir="$base_path/$server_name"
        check_and_start "$server_name" "$server_dir"
    done
}

check_zk_srv() {
    local base_path num server_name server_dir
    local zk_server=()

    base_path="/data/center"

    is_dir_exists "$base_path" || return
    mapfile -t zk_server < <(get_server_num "$base_path" zk)
    is_array_empty zk_server && return
    for num in "${zk_server[@]}"; do
        server_name="zk$num"
        server_dir="$base_path/$server_name"
        check_and_start "$server_name" "$server_dir"
    done
}

check_game_srv() {
    local base_path num server_name server_dir
    local game_server=()

    base_path="/data"

    is_dir_exists "$base_path" || return
    mapfile -t game_server < <(get_server_num "$base_path" server)
    is_array_empty game_server && return
    for num in "${game_server[@]}"; do
        server_name="server$num"
        server_dir="$base_path/$server_name/game"
        check_and_start "$server_name" "$server_dir"
    done
}

check_log_srv() {
    local base_path num server_name server_dir
    local log_server=()

    base_path="/data"

    is_dir_exists "$base_path" || return
    mapfile -t log_server < <(get_server_num "$base_path" logserver)
    is_array_empty log_server && return
    for num in "${log_server[@]}"; do
        server_name="logserver$num"
        server_dir="$base_path/$server_name"
        check_and_start "$server_name" "$server_dir"
    done
}

check_api_srv() {
    local base_path num server_name server_dir
    local api_server=()

    base_path="/data"

    is_dir_exists "$base_path" || return
    mapfile -t api_server < <(get_server_num "$base_path" apiserver)
    is_array_empty api_server && return
    for num in "${api_server[@]}"; do
        server_name="apiserver$num"
        server_dir="$base_path/$server_name"
        check_and_start "$server_name" "$server_dir"
    done
}

check_cross_srv() {
    local base_path num server_name server_dir
    local cross_server=()

    base_path="/data"

    is_dir_exists "$base_path" || return
    mapfile -t cross_server < <(get_server_num "$base_path" crossserver)
    is_array_empty cross_server && return
    for num in "${cross_server[@]}"; do
        server_name="crossserver$num"
        server_dir="$base_path/$server_name"
        check_and_start "$server_name" "$server_dir"
    done
}

check_gm_srv() {
    local base_path num server_name server_dir
    local gm_server=()

    base_path="/data"

    is_dir_exists "$base_path" || return
    mapfile -t gm_server < <(get_server_num "$base_path" gmserver)
    is_array_empty gm_server && return
    for num in "${gm_server[@]}"; do
        server_name="gmserver$num"
        server_dir="$base_path/$server_name"
        check_and_start "$server_name" "$server_dir"
    done
}

## Main logic.
processcontrol() {
    run_check

    while :; do
        check_entry_srv
        check_global_srv
        check_zk_srv
        check_game_srv
        check_log_srv
        check_api_srv
        check_cross_srv
        check_gm_srv
        sleep 1
    done
}

processcontrol
