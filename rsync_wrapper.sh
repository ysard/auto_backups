#!/bin/bash
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

########################################
# Script for incremental rsync backups #
# Return 1 on errors, 0 otherwise      #
########################################

# Names of saved directories
BACKUP_NAME_DEBIAN="home"

# Paths of directories to save
SRC_DEBIAN="/home/MY_USERNAME/"

# PS : Include patterns may have to be specified
# as argument of backup_process function.


# Mount point of the partition/volume where the backup will be made
MOUNT_POINT="/media/MY_MOUNT_POINT"
# Root directory of backup stuff
BACKUP_ROOT="backups"

########################################
# From this line you probably do not   #
# want to change unless you know what  #
# you are doing.                       #
########################################

CURRENT_DATE=$(date +%Y-%m-%d)
# Directory where the script and include/exclude files are stored
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
EXIT_VALUE=0

check_directories()
{
    # Check the existence of the directory where the last backup will be put
    # Param: Directory name

    #echo "Checking ${MOUNT_POINT}/${BACKUP_ROOT}/$1_current/ ..."

    if [ ! -d  "${MOUNT_POINT}/${BACKUP_ROOT}/$1_current/" ]; then
        echo -n "Init backup dir..."
        mkdir -p "${MOUNT_POINT}/${BACKUP_ROOT}/$1_current/"

        # get the exit code from the last command executed
        if [ $? -ne 0 ]; then
            echo -e " [${RED}FAIL${NC}]"
            # Stop the script
            exit 1
        else
            # 0 on success
            echo -e " [ ${GREEN}OK${NC} ]"
            return 0
        fi
    fi
}

backup_process()
{
    # Check directory & do the backup process
    # Param 1: Path of directory to save
    # Param 2: Name used for the destination
    # Param 3 (optional): File with patterns that will filter the source files

    #check_directories $BACKUP_NAME_WINDOWS
    check_directories $2

    echo -n "Backup $2 in progress..."

    LOG_FILE="${MOUNT_POINT}/${BACKUP_ROOT}/log_$2_$(date +%Y-%m-%d_%Hh-%Mm-%Ss).log"

    rsync --stats -av --force --ignore-errors --delete --delete-excluded \
        --exclude-from="${SCRIPT_DIR}/exclude_all" \
        --include-from=$3 \
        --backup --backup-dir="${MOUNT_POINT}/${BACKUP_ROOT}/$2_${CURRENT_DATE}/" \
        $1 "${MOUNT_POINT}/${BACKUP_ROOT}/$2_current/" \
        &> ${LOG_FILE}

    # get the exit code from the last command executed
    if [ $? -ne 0 ]; then
        echo -e " cf log [${RED}FAIL${NC}]"
        # Update exit value
        EXIT_VALUE=1
        return 1
    else
        # 0 on success
        echo -e " [ ${GREEN}OK${NC} ]"
        return 0
    fi
}

#########################################


if df | grep -q $MOUNT_POINT; then

    # Check include files here as third parameter !
    backup_process $SRC_DEBIAN $BACKUP_NAME_DEBIAN
else
    echo -e "ERROR: Can't find mount point ! [${RED}FAIL${NC}]"
    EXIT_VALUE=1
fi

# Uncomment these lines if the script is not run through systemd (in user env)
#if [ $EXIT_VALUE -ne 0 ]; then
#    kdialog --passivepopup "Some errors occured !"
#else
#    kdialog --passivepopup "Backup is done."
#fi
exit $EXIT_VALUE

