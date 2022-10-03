#!/bin/sh

if [ -e "/dev/dri/card1" ]; then
  echo "eGPU detected"
  if [ ! -z "$(udevadm info -a -n /dev/dri/card0 | grep i915)" ]; then
    intel="/dev/dri/card0"
    egpu="/dev/dri/card1"
  else
    intel="/dev/dri/card1"
    egpu="/dev/dri/card0"
  fi
  sleep 5
  # make sway to use intel, copy display buffers to egpu
  WLR_DRM_DEVICES="${intel}:${egpu}" sway
  # make sway to not use intel, only egpu
  # WLR_DRM_DEVICES="${egpu}" sway
else
  # echo "No eGPU detected"
  sway
fi