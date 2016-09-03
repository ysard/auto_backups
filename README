# Introduction

This project contains a Wrapper script for rsync & systemd config
in order to automate backup tasks when a dedicated partition is mounted on the system.


# Rsync wrapper

To adapt the script, simply complete the parameters `BACKUP_NAME_ *`
which correspond to the names of the files saved in the main backup folder `BACKUP_ROOT`.

A `SRC_ *` parameter refers to each `BACKUP_NAME_ *`. They are the paths to the directories
containing the files to back up.

The various folders are processed at the end of the script by as many calls to the
`backup_process` function.

Example:

     backup_process $ SRC_DATA $ BACKUP_NAME_DATA "${SCRIPT_DIR}/include_DATA"

The 3rd parameter is optional, it refers to a file that lists the data to
be backed up in `$SRC_DATA`.
The syntax of the patterns in this file is explained in
[rsync documentation](https://download.samba.org/pub/rsync/rsync.html).

# Systemd

If you want the system to start the backup script after mounting a partition
you must use systemd by creating a dedicated service.

Edit the file `auto-backup-MY_MOUNT_POINT.service` by updating the name of the mount point,
and the path of `rsync_wrapper.sh`; Then, copy the file to `/etc/systemd/system`.

Enable the service :

    :::console
    $ systemctl enable auto-backup-MY_MOUNT_POINT.service
    Created symlink from /etc/systemd/system/media-MY_MOUNT_POINT.mount.wants/auto-backup-MY_MOUNT_POINT.service to /etc/systemd/system/auto-backup-MY_MOUNT_POINT.service.

Reload systemd daemon:

    :::console
    $ systemctl --system daemon-reload


The script runs when mounting the partition.
One can visualize the output via the following command:

    :::console
    $ systemctl status auto-backup-MY_MOUNT_POINT.service
    ● auto-backup-MY_MOUNT_POINT.service - Auto backup of the system to a LUKS encrypted partition.
        Loaded: loaded (/etc/systemd/system/auto-backup-MY_MOUNT_POINT.service; enabled)
        Active: inactive (dead) since jeu. 2016-09-01 15:38:51 CEST; 2s ago
        Process: 7140 ExecStart=/PATH/TO/rsync_wrapper.sh (code=exited, status=0/SUCCESS)
        Main PID: 7140 (code=exited, status=0/SUCCESS)

    sept. 01 15:38:38 XXX rsync_wrapper.sh[7140]: Backup DATA in progress... [ OK ]
