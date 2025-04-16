#!/bin/bash

# Define the logrotate configuration file

#read log conf and put it 

 

# Run logrotate with the specified configuration

rotate() 
{

logrotate -f ./cron/rotate.conf
}


purge() 
{
#clean log files and remove compressed history
> *.log
rm *.gz

}





















