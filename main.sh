#!/bin/sh

./prerequisite.sh

#./network.sh

. ./utilities.sh
check_internet
#. ./open_thread.sh
#OTBR_SETUP

. ./lxc_config.sh
preconfig
. ./variables.env

./init_lxc.sh








