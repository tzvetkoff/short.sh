#!/bin/bash

set -e

#
# Help
#

do_help() {
  case "${1}" in
    config)
      echo 'Usage:'
      echo "  ${0} config [options]"
      echo
      echo 'Options'
      echo '  -s SERVICE, --service=SERVICE         URL shortening service to use'
      echo
      echo 'Supported services:'
      echo '  is.gd (default)'
      echo '  v.gd'
      ;;
    shorten)
      echo 'Usage:'
      echo "  ${0} shorten [options] [url]"
      echo
      echo 'Options:'
      echo '  -s SERVICE, --service=SERVICE         URL shortening service to use'
      echo
      echo "For a list of supported services, see \`${0} config --help'"
      ;;
    *)
      echo 'Usage:'
      echo "  ${0} [options] [command] [args]"
      echo
      echo 'Commands:'
      echo '  config [options]                      Configure the script'
      echo '  shorten [options] [url]               Shorten URL'
      ;;
  esac

  exit "${2}"
}


#
# Config
#

do_config() {
  local parse='true'
  local args=()

  while [[ -n "${1}" ]]; do
    if $parse; then
      case "${1}" in
        -h|--help) do_help 'config' 0;;

        -s|--esrvice) SERVICE="${2}"; shift;;
        --service=*)  SERVICE="${1:9}";;
        -s*)          SERVICE="${1:2}";;

        --) parse='false';;
        -*) echo "${0} config: invalid option: ${1}" >&2; echo >&2; do_help 'config' 1 >&2;;
        *)  args+=("${1}");;
      esac
    else
      args+=("${1}")
    fi

    shift
  done

  mkdir -p "${HOME}/.config/short.sh"
  echo "SERVICE=${SERVICE}" >"${HOME}/.config/short.sh/config"
}


#
# is.gd
#

do_is.gd() {
  curl \
    -X POST \
    --form 'format=simple' \
    --form "url=${1}" \
    'https://is.gd/create.php'
  echo
}

#
# v.gd
#

do_v.gd() {
  curl \
    -X POST \
    --form 'format=simple' \
    --form "url=${1}" \
    'https://v.gd/create.php'
  echo
}


#
# Main
#

do_main() {
  local parse='true'
  local args=()

  while [[ -n "${1}" ]]; do
    if $parse; then
      case "${1}" in
        -h|--help) do_help 'config' 0;;

        -s|--esrvice) SERVICE="${2}"; shift;;
        --service=*)  SERVICE="${1:9}";;
        -s*)          SERVICE="${1:2}";;

        --) parse='false';;
        -*) echo "${0} config: invalid option: ${1}" >&2; echo >&2; do_help 'config' 1 >&2;;
        *)  args+=("${1}");;
      esac
    else
      args+=("${1}")
    fi

    shift
  done

  local arg
  for arg in "${args[@]}"; do
    case "${SERVICE}" in
      is.gd) do_is.gd "${arg}";;
      v.gd)  do_v.gd "${arg}";;
      *)
        echo "Unsupported service '${SERVICE}'." >&2
        exit 1
        ;;
    esac
  done
}


#
# Defaults
#

SERVICE='is.gd'


#
# Load config
#

# shellcheck disable=1091
[[ -f "${HOME}/.config/short.sh/config" ]] && source "${HOME}/.config/short.sh/config"


#
# Go
#

if [[ -z "${1}" ]]; then
  do_help 'main' 0
fi

case "${1}" in
  config)    do_config "${@:2}";;
  shorten)   do_main "${@:2}";;
  -h|--help) do_help 'main' 0;;
  *)         do_main "${@}";;
esac

# vim:ft=sh:ts=2:sts=2:sw=2:et
