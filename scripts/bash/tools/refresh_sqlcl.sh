#!/usr/bin/env bash

#
# Installs the latest Oracle SQLcl using Oracle’s official sqlcl-latest.zip alias.
#
# The script is designed for Git Bash on Windows and performs a safe, repeatable
# upgrade without requiring version numbers:
#   - Downloads the current SQLcl release from Oracle
#   - Moves the existing installation to a backup folder (sqlcl-latest-old)
#   - Unpacks the new version into sqlcl-latest-new
#   - Updates the sqlcl-latest symbolic link to point to the new installation
#
# This approach avoids in-place overwrites and works reliably with Git Bash,
# where replacing directories with symlinks requires explicit cleanup.
# After completion, sqlcl-latest always points to the most recent installation.
#


set -euo pipefail

SQLCL_URL="https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip"
INSTALL_HOME="/c/Install"
INSTALL_DIR="$INSTALL_HOME/sqlcl-latest-new"
TMP_ZIP="$(mktemp /tmp/sqlcl-XXXXXX.zip)"

echo "Downloading latest SQLcl..."
curl -fL "$SQLCL_URL" -o "$TMP_ZIP"

echo "Installing to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
mv  "$INSTALL_DIR" "$INSTALL_HOME/sqlcl-latest-old"
mkdir -p "$INSTALL_DIR"
unzip -q "$TMP_ZIP" -d "$INSTALL_DIR"

rm -f "$TMP_ZIP"

echo "Create Symbolic Link"

cd $INSTALL_HOME
ln -sf sqlcl-latest-new sqlcl-latest 

echo "SQLcl installed:"
sql.exe -v
