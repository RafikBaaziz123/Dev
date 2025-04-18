#!/bin/sh
rotate() 
{
logrotate -f ./cron/rotate.conf
}
purge() 
{
#clean log files and remove compressed history
> ./logs/*.log
rm *.gz
}





















