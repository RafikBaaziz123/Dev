#!/bin/sh

purge() 
{
#clean log files and remove compressed history
> ./logs/*.log
rm *.gz
}





















