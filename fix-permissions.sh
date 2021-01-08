#!/bin/bash
#
# This script configures WordPress file permissions based on recommendations
# from http://codex.wordpress.org/Hardening_WordPress#File_permissions
#
# Author: Michael Conigliaro <mike [at] conigliaro [dot] org>
#

WP_ROOT=$1  # <-- wordpress root directory
EDITABLE=$2 # <-- webserver group
WP_OWNER=$3 # <-- wordpress owner
WP_GROUP=$4 # <-- wordpress group

# Check the arguments before proceeding

# If user, returns number. Not a user, no value
ISUSER=$(id -u $WP_OWNER 2> /dev/null)
# Is group in the group file? If so, returns line
ISGRP=$(egrep -i $WP_GROUP /etc/group)

echo "Start fix-permission"

if [[ ${#WP_ROOT} -eq 0 ]]
  then
    echo "No path arguments supplied. Bye."
    exit 1
fi

if [[ ! -d ${WP_ROOT}/wp-admin ]]
then
  echo "${WP_ROOT}/wp-admin is not a valid path. Bye."
  exit 1
fi

if [[ ${EDITABLE} == "readonly" ]]
then
  echo "Set readonly permissions"

  if [[ ${#ISUSER} -eq 0 ]]
  then
      echo "${WP_OWNER} is not a user"
      exit 1
  fi

  if [[ ${#ISGRP} -eq 0 ]]
    then
      echo "${WP_GROUP} is not a group"
      exit 1
  fi

  # reset to safe defaults
  echo "Reseting permissions to readonly values"

  find ${WP_ROOT} -exec chown ${WP_OWNER}:${WP_GROUP} {} \;
  find ${WP_ROOT} -type d -exec chmod 755 {} \;
  find ${WP_ROOT} -type f -exec chmod 644 {} \;

  # allow wordpress to manage wp-config.php (but prevent world access)
  echo "Allowing wordpress to manage wp-config.php (but prevent world access)"

  chgrp ${WP_GROUP} ${WP_ROOT}/wp-config.php
  chmod 660 ${WP_ROOT}/wp-config.php
fi

if [[ ${EDITABLE} == "writable" ]]
then
  echo "Set writable permissions"

  # reset to safe defaults
  echo "Reseting permissions to default values"

  chown www-data:www-data -R ${WP_ROOT}/*;
  find ${WP_ROOT} -type d -exec chmod 755 {} \;
  find ${WP_ROOT} -type f -exec chmod 755 {} \;

  # allow wordpress to manage wp-config.php (but prevent world access)
  echo "Allowing wordpress to manage wp-config.php (but prevent world access)"

  chgrp ${WP_GROUP} ${WP_ROOT}/wp-config.php
  chmod 660 ${WP_ROOT}/wp-config.php
fi

echo "Stop fix-permission"
exit 1
