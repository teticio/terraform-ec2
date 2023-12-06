#!/bin/bash

# Mount the EBS volume at /home
if [ -e /dev/xvdh ]; then
    device=/dev/xvdh
else
    device=/dev/nvme1n1
fi
if ! sudo file -s $device | grep -q "filesystem"; then
    mkfs -t ext4 $device
    mount $device /mnt
    rsync -aXv /home/ /mnt/
    umount /mnt
fi
mount $device /home
echo "$device /home ext4 defaults,nofail 0 2" >> /etc/fstab

# Install packages etc.
