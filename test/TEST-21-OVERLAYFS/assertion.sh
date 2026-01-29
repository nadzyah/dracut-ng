#!/bin/sh

if ! grep -q " overlay " /proc/mounts; then
    echo "overlay filesystem not found in /proc/mounts" >> /run/failed
fi

if ! echo > /test-overlay-write; then
    echo "overlay is not writable" >> /run/failed
fi

device_mode_expected=0

if grep -qE 'rd\.overlay=(LABEL|UUID|PARTUUID|PARTLABEL|/dev/)' /proc/cmdline; then
    device_mode_expected=1
    # non-existent device should fallback to tmpfs
    if grep -q "rd.overlay=LABEL=NONEXISTENT" /proc/cmdline; then
        device_mode_expected=0
    fi
fi

if grep -qE 'overlayroot=(LABEL|UUID|PARTUUID|PARTLABEL|/dev/|device:)' /proc/cmdline; then
    device_mode_expected=1
fi

if [ "$device_mode_expected" = "1" ]; then
    if ! grep -q "/run/overlayfs-backing" /proc/mounts; then
        echo "persistent overlay device not mounted at /run/overlayfs-backing" >> /run/failed
    fi
else
    # tmpfs mode - verify persistent backing is NOT mounted
    if grep -q "/run/overlayfs-backing" /proc/mounts; then
        echo "tmpfs mode but persistent backing is mounted at /run/overlayfs-backing" >> /run/failed
    fi
fi

# Dump /proc/mounts at the end if there were any failures for easier debugging
if [ -s /run/failed ]; then
    {
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> /proc/mounts >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        cat /proc/mounts
        echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< /proc/mounts <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    } >> /run/failed
fi
