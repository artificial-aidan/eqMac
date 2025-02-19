#!/bin/sh

# Uninstall the new driver
rm -rf /Library/Audio/Plug-Ins/HAL/eqMac.driver/

# Restart CoreAudio
coreaudiod_plist="/System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist"
(launchctl kickstart -k system/com.apple.audio.coreaudiod &>/dev/null || \
launchctl kill SIGTERM system/com.apple.audio.coreaudiod &>/dev/null || \
launchctl kill TERM system/com.apple.audio.coreaudiod &>/dev/null || \
launchctl kill 15 system/com.apple.audio.coreaudiod &>/dev/null || \
launchctl kill -15 system/com.apple.audio.coreaudiod &>/dev/null || \
(launchctl unload "$coreaudiod_plist" &>/dev/null && \
launchctl load "$coreaudiod_plist" &>/dev/null) || \
killall coreaudiod &>/dev/null) && \
sleep 2

# Wait until coreaudiod has restarted and device is ready to use.
retries=5
while [[ $retries -gt 0 ]]; do
  if system_profiler SPAudioDataType | grep "eqMac:" >/dev/null 2>&1; then
    retries=$((retries - 1))
    if [[ $retries -gt 0 ]]; then
      echo "Device is still preset, waiting..."
      sleep 3
    else
      echo "ERROR: Device did not become active"
      exit 1
    fi
  else
    retries=0
  fi
done
echo "Device removed"
