#!/bin/sh

#backup lvm volumes with duplicity.
#based on http://duplicity.nongnu.org/contrib/tmpback

# The Archive is encrypted with this (since it is transfered to FTP)
export PASSPHRASE="foo"
# The FTP-password (not exposed at cmdline
export FTP_PASSWORD="bar"

# Do a fullbackup weekly
OPTIONS="--full-if-older-than 14D"
KEEPFULLS=5

# Where to backup to
TARGETBASE=ftp://user@server/backups/
#TARGETBASE=file:///tmp/test

function create_mysql_snap
{
/usr/bin/mysql --defaults-extra-file=/etc/mysql/debian.cnf <<END
FLUSH TABLES WITH READ LOCK;
\! /sbin/lvcreate --size 10G --snapshot --name snap /dev/vg0/var
UNLOCK TABLES;
END
}

function backup_lvm
{
    LVMNAME=$1
    FILELIST=$2
    CREATECMD=${3:-/sbin/lvcreate --size 10G --snapshot --name snap /dev/vg0/$LVMNAME}
    # Cleanup
    echo `date --rfc-3339=second` Backup LVM-Volume $LVMNAME
    echo `date --rfc-3339=second` Remove old backups:
    /usr/bin/duplicity remove-all-but-n-full $KEEPFULLS --force $TARGETBASE/$LVMNAME
    echo `date --rfc-3339=second` Create snapshot:
    eval $CREATECMD
    [ -d /snap ] || mkdir /snap
    /bin/mount /dev/vg0/snap /snap
    echo `date --rfc-3339=second` Backup:
    # include all files/directories from the filelist (which should be prefixed with /snap!!!)
    # exclude all files/directories prefixed with "- " in filelist
    # exclude snapshot-mountpoint itself
    /usr/bin/duplicity $OPTIONS \
	--include-globbing-filelist $FILELIST \
        --exclude /snap /snap $TARGETBASE/$LVMNAME
    /bin/umount /snap
    echo `date --rfc-3339=second` Destroy snapshot:
    /sbin/lvremove -f /dev/vg0/snap
    echo `date --rfc-3339=second` Done with LVM-Volume $LVMNAME
}

backup_lvm root /root/bin/root-include.txt >>/var/log/lvm-backup.log 2>&1
backup_lvm home /root/bin/home-include.txt >>/var/log/lvm-backup.log 2>&1
backup_lvm var /root/bin/var-include.txt create_mysql_snap >>/var/log/lvm-backup.log 2>&1
