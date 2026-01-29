#!/bin/bash

check() {
    require_kernel_modules overlay || return 1
    return 255
}

depends() {
    echo base
}

installkernel() {
    hostonly="" instmods overlay
}

install() {
    inst_hook cmdline 29 "$moddir/parse-overlayfs.sh"     # translate overlayroot= to rd.overlay= for dmsquash-live
    inst_hook pre-mount 01 "$moddir/prepare-overlayfs.sh"
    inst_hook mount 01 "$moddir/mount-overlayfs.sh"       # overlay on top of block device
    inst_hook pre-pivot 00 "$moddir/prepare-overlayfs.sh" # prepare for network root (e.g. nfs)
    inst_hook pre-pivot 10 "$moddir/mount-overlayfs.sh"   # overlay on top of network device
}
