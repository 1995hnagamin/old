#!/bin/sh

dir=`dirname $0`
path=`ruby $dir/../lib/old.rb $@`
man -l $path
