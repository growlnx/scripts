#!/usr/bin/env bash

# helper.sh - helper functions for daily work
# Author: growlnx | License: MIT

aproxy() {
	local cmd="${FUNCNAME[0]}"

	usage() {
		printf "$cmd -- Android Proxy Manager\n"
		printf "%-28s %s\n" "-a, --address" "proxy's address ipv4:port"
		printf "%-28s %s\n" "-p, --port" "displays this message"
		printf "%-28s %s\n" "-e|-d, --enable|--disable" "enable or disable the proxy"
		printf "%-28s %s\n" "-s, --serial|--disable" "adb serial"
	}

	local getopt_error=$(mktemp /dev/shm/XXXXXX)
	local args
	if ! args=$(getopt -n $cmd -o edtha:,s: --long enable,disable,address:,serial: -- "$@" 2>"$getopt_error"); then
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
				printf "%s: invalid argument $1\n" "$cmd"
			fi
			shift
			;;
		esac
	done

	if [[ -n $action ]]; then
		if [[ -z "$addr" ]]; then
			printf "%s: address is required\n" "$cmd"
			unset usage && return
		fi

		local ipv4_re="^([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}$"
		if [[ ! "$addr" =~ $ipv4_re ]]; then
			printf "%s: invalid proxy address\n" "$cmd"
			unset usage && return
		fi
	fi

	if [[ -n $trans ]]; then
		case $action in
		enable)
			adb $serial shell su -c "iptables -t nat -A OUTPUT -p tcp -m multiport --dport 80,443 -j DNAT --to-destination $addr"
			;;

		disable)
			adb $serial shell su -c "iptables -t nat -D OUTPUT -p tcp -m multiport --dport 80,443 -j DNAT --to-destination $addr"
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	"$@" || exit
fi