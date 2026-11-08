#!/usr/bin/env bash

# helper.sh - helper functions for daily work
# Author: growlnx | License: MIT

aproxy() {
	local cmd="${FUNCNAME[0]}"

	usage() {
		printf "$cmd -- Android Proxy Manager\n"
		printf "%-28s Proxy's address ipv4:port\n" "-a, --address"
		printf "%-28s ADB serial\n" "-s, --serial"
		printf "%-28s Transparent proxy via Android's iptables\n" "-t, --transparent"
		printf "%-28s Enable or disable the proxy\n" "-e|-d, --enable|--disable"
		printf "%-28s Displays this message\n\n" "-h, --help"
	}

	local getopt_error=$(mktemp /dev/shm/XXXXXX)
	local args
	if ! args=$(getopt -n $cmd -o edtha:s: --long enable,disable,transparent:,address:,serial: -- "$@" 2>"$getopt_error"); then
		cat "$getopt_error"
		usage
		unset usage && return
	fi

	rm -f "$getopt_error"

	eval set -- "$args"

	local serial

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-a | --address)
			local addr="$2"
			shift 2
			;;

		-t | --transparent)
			local trans="true"
			shift 1
			;;

		-e | --enable)
			local action="enable"
			shift 1
			;;

		-d | --disable)
			local action="disable"
			shift 1
			;;

		-s | --serial)
			serial="-s $2"
			shift 2
			;;

		-h | --help)
			usage
			unset usage && return
			;;

		*)
			if [[ $1 != "--" ]]; then
				printf "$cmd: invalid argument %s\n" "$1"
			fi
			shift
			;;
		esac
	done

	if [[ -n $action ]]; then
		if [[ -z "$addr" ]]; then
			printf "$cmd: address is required\n"
			unset usage && return
		fi

		local ipv4_re="^([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}$"
		if [[ ! "$addr" =~ $ipv4_re ]]; then
			printf "$cmd: invalid proxy address\n"
			unset usage && return
		fi
	fi

	if [[ -n $trans ]]; then
		case $action in
		enable)
			adb $serial shell su -c "iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -j DNAT --to-destination $addr"
			;;

		disable)
			adb $serial shell su -c "iptables -t nat -D OUTPUT -p tcp -m multiport --dports 80,443 -j DNAT --to-destination $addr"
			;;

		*)
			printf "$cmd: current transparent proxy config\n"
			adb $serial shell su -c "iptables -t nat -S OUTPUT | grep -F 'to-destination'"
			;;
		esac

		unset usage && return
	fi

	case $action in
	enable)
		adb $serial shell settings put global http_proxy "$addr"
		;;

	disable)
		adb $serial shell settings put global http_proxy :0
		;;

	*)
		printf "$cmd: current global proxy config\n"
		adb $serial shell settings get global http_proxy
		;;
	esac
}

ascr() {
	local cmd="${FUNCNAME[0]}"

	usage() {
		printf "$cmd -- Android Screenshot Manager\n"
		printf "%-28s ADB serial\n" "-s, --serial"
		printf "%-28s Captures a new screenshot\n" "-c, --capture"
		printf "%-28s Downloads N screenshots\n" "-d, --download N"
		printf "%-28s Displays this message\n\n" "-h, --help"
	}

	local getopt_error=$(mktemp /dev/shm/XXXXXX)
	local args
	if ! args=$(getopt -n $cmd -o hcd: --long capture,download:,serial: -- "$@" 2>"$getopt_error"); then
		cat "$getopt_error"
		usage
		unset usage && return
	fi

	rm -f "$getopt_error"

	eval set -- "$args"

	local serial
	local n="1"
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-c | --capture)
			local mode="capture"
			shift 1
			;;

		-d | --download)
			local mode="download"
			local n=$2
			shift 2
			;;

		-s | --serial)
			serial="-s $2"
			shift 2
			;;

		-h | --help)
			usage
			unset usage && return
			;;

		*)
			if [[ $1 != "--" ]]; then
				printf "$cmd: invalid argument %s\n" "$1"
			fi
			shift
			;;
		esac
	done

	case $mode in
	capture)
		adb $serial exec-out "screencap -p" >"screen_$(date +%Y%m%d_%H%M%S).png"
		;;

	download)
		local path="/sdcard/Pictures/Screenshots"
		adb $serial shell "ls -t $path | head -n $n" | xargs -I{} adb $serial pull "$path/{}"
		;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	if [[ $# -eq 0 || $1 =~ ^-h$|^--help$ ]]; then
		declare -F | awk '{print $3}' | while read -r fn; do
			"$fn" -h 2>/dev/null
		done
		exit
	fi

	"$@" || exit
fi
