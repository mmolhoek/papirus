#!/bin/bash
mkdir -p /tmp/epd/LE
touch /tmp/epd/command
touch /tmp/epd/LE/display
touch /tmp/epd/LE/display_inverse
echo "EPD 2.7 264x176 COG 2 FILM 231" > /tmp/epd/panel
