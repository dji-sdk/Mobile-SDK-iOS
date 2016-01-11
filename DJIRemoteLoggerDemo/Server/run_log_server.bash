#!/bin/bash

if [ `gem query -i -n bundler` = false ]; then
  echo "Attempting to install bundler and necessary gems..."
  sudo gem install bundler
  bundle install
  echo -en '\n'
  echo -en '\n'
fi

STR=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
echo "Starting DJI Log Server..."
echo -en '\n'
printf '\e[0;32m%s%s%s\e[0m \n' 'Webpage at http://' "$STR" ':4567'
printf '\e[0;33m%s%s%s\e[0m \n' "Use \"http://" "$STR" ":4567?filter=<device_ID>\" to filter by device ID"
echo -en '\n'
bundle exec ruby log_server.rb
