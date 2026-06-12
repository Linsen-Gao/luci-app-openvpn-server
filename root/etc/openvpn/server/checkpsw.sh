#!/bin/sh
###########################################################
# checkpsw.sh (C) 2004 Mathias Sundman 
#
# This script will authenticate OpenVPN users against
# a plain text file. The passfile should simply contain
# one row per user with the username first followed by
# one or more space(s) or tab(s) and then the password.

PASSFILE="/etc/openvpn/server/psw-file"
LOG_FILE="/etc/openvpn/openvpn-password.log"
TIME_STAMP=$(date "+%Y-%m-%d %T")

###########################################################

if [ ! -r "${PASSFILE}" ]; then
  echo "${TIME_STAMP}: Could not open password file for reading." >> "${LOG_FILE}"
  exit 1
fi

sanitized_user=$(echo "${username}" | tr -cd "a-zA-Z0-9._-")

CORRECT_PASSWORD=$(awk "!/^;/&&!/^#/&&\$1==\"${sanitized_user}\"{print \$2;exit}" "${PASSFILE}")

if [ "${CORRECT_PASSWORD}" = "" ]; then
  echo "${TIME_STAMP}: User does not exist: username=\"${sanitized_user}\"." >> "${LOG_FILE}"
  exit 1
fi

if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
  echo "${TIME_STAMP}: Successful authentication: username=\"${sanitized_user}\"." >> "${LOG_FILE}"
  exit 0
fi

echo "${TIME_STAMP}: Incorrect password: username=\"${sanitized_user}\"." >> "${LOG_FILE}"
exit 1
