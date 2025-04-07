#!/usr/bin/env bash

echo "Checking if ~/.profile file exists..."

if [ -f "~/.profile" ]; then
  echo " Sourcing ~/.profile..."
  source ~/.profile
  echo " ~/.profile sourced successfully."
else
  echo " No ~/.profile file found. Copying original .bashrc file and sourcing ~/.profile..."
  sudo cp /opt/.bashrc ~/.profile
  source ~/.profile
  echo " ~/.profile sourced successfully."
fi
