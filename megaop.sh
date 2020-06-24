#!/bin/bash

backup_path="mypool"

snapshot_name=MEGA_OVER_POWER_$(date "+%Y-%m-%d-%H-%M-%S")

ssh_user="fstuba"

ssh_server="192.168.56.104"

backup_pool="backuppool/backup"


if [ -f "/etc/megaop/presnapname" ]; then
    pre_snapshot_name=$(cat /etc/megaop/presnapname)
    echo ${snapshot_name} > /etc/megaop/presnapname

    zfs snapshot -r ${backup_path}@${snapshot_name}
    zfs send -v -i ${backup_path}@${pre_snapshot_name} ${backup_path}@${snapshot_name} | ssh ${ssh_user}@${ssh_server} zfs recv -Fduv ${backup_pool} >> megaop.log

else
    touch /etc/megaop/presnapname

   zfs snapshot -r ${backup_path}@${snapshot_name}
    zfs send -v ${backup_path}@${snapshot_name} | \
    ssh ${ssh_user}@${ssh_server} zfs recv -F ${backup_pool}

    echo ${snapshot_name} > /etc/megaop/presnapname
fi
