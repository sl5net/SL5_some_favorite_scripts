#!/bin/bash

# Kill Windscribe processes (if they exist)
pkill -f "/opt/windscribe/helper"  # Run as root (sudo configured)
pkill -f "/opt/windscribe/Windscribe"

exit 0
