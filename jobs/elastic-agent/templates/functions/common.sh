#!/bin/bash

function start_logging() {
    local log_dir="${1}"
    local script_name="${2}"

    exec > >(prepend_datetime >> "${log_dir}/${script_name}.stdout.log")
    exec 2> >(prepend_datetime >> "${log_dir}/${script_name}.stderr.log")
}

function prepend_datetime() {
    perl -ne 'BEGIN { use Time::HiRes "time"; use POSIX "strftime"; STDOUT->autoflush(1) }; my $t = time; my $fsec = sprintf ".%09d", ($t-int($t))*1000000000; my $time = strftime("[%Y-%m-%dT%H:%M:%S".$fsec."Z]", localtime $t); print("$time $_")'
}

function overwrite_agent_config() {
    local bosh_config_dir="${1}"
    local agent_program_dir="${2}"
    local process_name="${3:-elastic-agent}"

    cp -v "${bosh_config_dir}/${process_name}.yml" "${agent_program_dir}"
}