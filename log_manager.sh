#!/bin/sh
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





















