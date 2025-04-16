#!/bin/sh

./prerequisite

#./network.sh

. ./utilities.sh
check_internet
. ./open_thread.sh
OTBR_SETUP

. ./lxc_config.sh
preconfig

init_lxc.sh








