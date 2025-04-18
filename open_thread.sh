#!/bin/sh

OTBR_SETUP (){

  # Check if the service DON'T exists
  if ! systemctl list-units --type=service --all | grep "otbr-agent"; then
    # Clone the repository
    git clone https://github.com/protectline/ot-br-posix.git --depth 1
    cd ot-br-posix

    # Run bootstrap script
    chmod +x     ./script/bootstrap

    ./script/bootstrap

    # Setup with specific interface
    INFRA_IF_NAME=wlan1 ./script/setup

    # Restart service
    sudo service otbr-agent restart

    # Configure and start the thread network
    sudo ot-ctl dataset init new
    sudo ot-ctl dataset commit active
    sudo ot-ctl ifconfig up
    sudo ot-ctl thread start

    $THREAD_CRED=$(sudo ./ot-br-posix/ot-ctl dataset active -x)
    sed -i '/^thread_cred=/c\thread_cred='"$THREAD_CRED" variables.env

}

OTBR_GET_CREDS()
{
    $THREAD_CRED=$(sudo ./ot-br-posix/ot-ctl dataset active -x)
    sed -i '/^thread_cred=/c\thread_cred='"$THREAD_CRED" variables.env

  
}
