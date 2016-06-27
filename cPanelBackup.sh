#!/bin/bash
#
# cPanelBackup.sh -- A script for downloading a backup of your
#                    cPanel hosted website.
#
# https://github.com/code2k/cPanelBackup
#
# Copyright 2011 CODE2K:LABS. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY CODE2K:LABS ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL CODE2K:LABS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f "$HOME/.cpanelbackuprc" ]
then
  echo "Error: Missing configuration ~/.cpanelbackuprc"
  echo ""
  echo "To continue please create ~/.cpanelbackuprc with the following content"
  echo "and adjust the values to your environment:"
  echo ""
  echo "CPANEL_USER=\"cpanel_username\""
  echo "CPANEL_PASSWD=\"cpanel_password\""
  echo "#"
  echo "# CPANEL_HOST: URL of the cPanel site (e.g. http://domain.com:2082)"
  echo "#"
  echo "CPANEL_HOST=\"cpanel_url\""
  echo "#"
  echo "# BACKUP_DIR: path to the backup location"
  echo "#"
  echo "BACKUP_DIR=\"backup_path\""
  echo "#"
  echo "# BACKUP_BASENAME: prefix for your backup files (e.g. domainname)"
  echo "#"
  echo "BACKUP_BASENAME=\"backup_basename\""
  echo "#"
  echo "# SED: name of the gnu sed excecutable."
  echo "#      on Mac homebrew change to gsed"
  echo "#"
  echo "SED=sed"
  echo "#"
  echo "# REMOVE_OLDER_THAN: number of days to keep old backups"
  echo "#"
  echo "REMOVE_OLDER_THAN=30"
  exit
fi

source "$HOME/.cpanelbackuprc"

BASENAME="$BACKUP_BASENAME-$(date '+%Y-%m-%d')"
DOWNLOAD_DIR="$BACKUP_DIR/$BASENAME"
URL="$CPANEL_HOST/frontend/x3/backup/index.html"
SEDCMD="$SED -nf $(pwd)/list_urls.sed"

#
# Test if the daily backup already exists, if yes exit
#
if [ -f "$BACKUP_DIR/$BASENAME.tar.gz" ]
then
  echo "backup already exists, exiting..."
  exit
fi

#
# If password is empty ask for it
#
if [ -z "$CPANEL_PASSWD" ]
then
  read -r -s -p "Password for $CPANEL_USER: " CPANEL_PASSWD
  echo
fi

#
# create temporary download dir
#
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

#
# parse cPanel backup page and fetch all partial backups
#
echo "Parsing $URL..."
for i in $(curl -s -u "$CPANEL_USER":"$CPANEL_PASSWD" "$URL" | $SEDCMD | grep gz)
do
  echo "download: $i"
  curl -s -u "$CPANEL_USER":"$CPANEL_PASSWD" -O "$CPANEL_HOST""$i"
done

#
# create archive and remove download dir
#
cd "$BACKUP_DIR"
tar zcpf "$BASENAME".tar.gz "$BASENAME"
rm -rf "$DOWNLOAD_DIR"

#
# remove older backups
#
find "$BACKUP_DIR" -name "$BACKUP_BASENAME-*.tar.gz" -mtime +"$REMOVE_OLDER_THAN" -exec rm {} \;

