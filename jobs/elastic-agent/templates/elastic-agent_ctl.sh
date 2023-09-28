#!/bin/bash -exu

set -o pipefail

PROCESS_NAME=elastic-agent
RUN_DIR="/var/vcap/sys/run/${PROCESS_NAME}"
PIDFILE="${RUN_DIR}/${PROCESS_NAME}.pid"
LOG_DIR="/var/vcap/sys/log/${PROCESS_NAME}"
SCRIPT_NAME="${PROCESS_NAME}_ctl"
JOB_DIR="/var/vcap/jobs/${PROCESS_NAME}"
PKG_DIR="/var/vcap/packages/${PROCESS_NAME}"

function start_logging() {
    exec > >(prepend_datetime >> $LOG_DIR/${SCRIPT_NAME}.stdout.log)
    exec 2> >(prepend_datetime >> $LOG_DIR/${SCRIPT_NAME}.stderr.log)
}

function prepend_datetime() {
    LOG_FORMAT=rfc3339

    if [ "$LOG_FORMAT" == "deprecated" ]; then
        awk -W interactive '{ system("echo -n [$(date +\"%Y-%m-%d %H:%M:%S%z\")]"); print " " $0 }'
    else
        perl -ne 'BEGIN { use Time::HiRes "time"; use POSIX "strftime"; STDOUT->autoflush(1) }; my $t = time; my $fsec = sprintf ".%09d", ($t-int($t))*1000000000; my $time = strftime("[%Y-%m-%dT%H:%M:%S".$fsec."Z]", localtime $t); print("$time $_")'
    fi
}

function pid_exists() {
    ps -p $1 &> /dev/null
}

function create_directories_and_chown_to_vcap() {
    mkdir -p "${LOG_DIR}"
    chown -R vcap:vcap "${LOG_DIR}"
    mkdir -p "${RUN_DIR}"
    chown -R vcap:vcap "${RUN_DIR}"
}

function start() {
    if [ -e "${PIDFILE}" ]; then
        pid=$(head -1 "${PIDFILE}")
        if pid_exists "$pid"; then
            return 0
        fi
    fi

    setcap cap_net_bind_service=+ep "${PKG_DIR}/bin/${PROCESS_NAME}"
    ulimit -n 65536

    pushd "${JOB_DIR}"
    chpst -u vcap:vcap \
    "${PKG_DIR}/bin/${PROCESS_NAME}" \
    --config "${JOB_DIR}/config/config.json" \
    1>> "${LOG_DIR}/${PROCESS_NAME}.stdout.log" \
    2>> "${LOG_DIR}/${PROCESS_NAME}.stderr.log" &
    popd

    echo $! > "${PIDFILE}"
}

function stop() {
    /usr/bin/pkill -9 elastic-agent
}

function main() {
    create_directories_and_chown_to_vcap
    start_logging

    case ${1} in
        start)
            start
        ;;

        stop)
            stop
        ;;

        *)
            echo "Usage: ${0} {start|stop}"
        ;;
    esac
}

main $@