#!/bin/bash

echo "Fix Chrome Browser"
sudo sed -i -e "s#/usr/bin/google-chrome-stable#/usr/bin/google-chrome-stable --no-sandbox#g" /usr/share/applications/google-chrome.desktop
