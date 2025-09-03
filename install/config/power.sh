#!/bin/bash

# Setting power cable disconnect notification udev rule
# Define a status variable for this script's overall execution
# Possible values: "SUCCESS", "WARNING", "ERROR"
SCRIPT_STATUS="SUCCESS"
ERROR_MESSAGE=""

# Automatically get the name of the power adapter.
# We look for power supply entries that report their 'type' as 'Mains'.
# This is the most reliable way to identify an AC adapter.

# Preliminary check for /sys/class/power_supply existence and content
POWER_SUPPLY_DIR="/sys/class/power_supply"

if [ ! -d "$POWER_SUPPLY_DIR" ]; then
    echo "Error: Directory '$POWER_SUPPLY_DIR' does not exist. This system might not expose power supply information via sysfs."
    echo "The power unplug/plug udev rule will NOT be set up."
    ADAPTER_NAME_DETECTED="false"
    SCRIPT_STATUS="ERROR"
    ERROR_MESSAGE="'$POWER_SUPPLY_DIR' does not exist."
elif [ -z "$(ls -A "$POWER_SUPPLY_DIR")" ]; then
    echo "Warning: Directory '$POWER_SUPPLY_DIR' is empty or contains no subdirectories. Cannot detect power adapter."
    echo "The power unplug/plug udev rule will NOT be set up."
    ADAPTER_NAME_DETECTED="false"
    SCRIPT_STATUS="WARNING" # System works, but no adapters detected
    ERROR_MESSAGE="'$POWER_SUPPLY_DIR' is empty."
else
    # Automatically get the name of the power adapter (only if dir exists and has content)
    # Store the result of grep and head in a temporary variable
    ADAPTER_TYPE_PATH=$(grep -l "Mains" "$POWER_SUPPLY_DIR"/*/type 2>/dev/null | head -n 1)

    if [ -n "$ADAPTER_TYPE_PATH" ]; then
        # If a path was found, then extract the adapter name
        ADAPTER_NAME=$(basename "$(dirname "$ADAPTER_TYPE_PATH")")
        echo "Detected power adapter name: $ADAPTER_NAME"
        ADAPTER_NAME_DETECTED="true"
    else
        # No adapter of type "Mains" found
        echo "Warning: Could not automatically detect the AC power adapter name (no 'Mains' type found)."
        echo "The power unplug/plug udev rule will NOT be set up."
        echo "Please identify it manually by checking directories in '$POWER_SUPPLY_DIR' (e.g., ADP1, AC, AC0)."
        ADAPTER_NAME_DETECTED="false"
        SCRIPT_STATUS="WARNING"
        ERROR_MESSAGE="Failed to detect 'Mains' type AC adapter name."
    fi
fi

# Only proceed with udev rule creation if an adapter name was detected
if [ "$ADAPTER_NAME_DETECTED" == "true" ]; then

    # Define the udev rule template
    UDEV_RULE_TEMPLATE='SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="ADAPTER_NAME_PLACEHOLDER", ENV{POWER_SUPPLY_ONLINE}=="0",  RUN+="/usr/bin/touch /run/user/USERID_PLACEHOLDER/power-unplug-event"
SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="ADAPTER_NAME_PLACEHOLDER", ENV{POWER_SUPPLY_ONLINE}=="1",  RUN+="/usr/bin/touch /run/user/USERID_PLACEHOLDER/power-plug-event"'

    # Get the current user's ID
    USER_ID=$(id -u)

    # # Check if the /run/user/$USER_ID directory exists, create if not
    # if [ ! -d "/run/user/$USER_ID" ]; then
    #     echo "Warning: /run/user/$USER_ID does not exist. Attempting to create it with sudo."
    #     sudo mkdir -p "/run/user/$USER_ID"
    #     if [ $? -eq 0 ]; then
    #         sudo chown "$USER_ID":"$(id -g)" "/run/user/$USER_ID"
    #         echo "/run/user/$USER_ID created successfully."
    #     else
    #         echo "Error: Failed to create /run/user/$USER_ID. The udev rule might not function correctly for non-root users."
    #         # Even if adapter name was found, this is a problem for the rule
    #         if [ "$SCRIPT_STATUS" == "SUCCESS" ]; then SCRIPT_STATUS="WARNING"; fi # Don't downgrade from ERROR
    #         ERROR_MESSAGE+=" Failed to create /run/user/$USER_ID."
    #     fi
    # fi

    # Populate the udev rule with the correct name and USERID ---
    GENERATED_UDEV_RULE=$(echo "$UDEV_RULE_TEMPLATE" | \
                          sed "s/ADAPTER_NAME_PLACEHOLDER/$ADAPTER_NAME/g" | \
                          sed "s/USERID_PLACEHOLDER/$USER_ID/g")

    echo ""
    echo "--- Generated udev rule ---"
    echo "$GENERATED_UDEV_RULE"
    echo "---------------------------"

    # Install the udev rule ---
    UDEV_RULES_DIR="/etc/udev/rules.d"
    RULE_FILE="$UDEV_RULES_DIR/99-power-notify.rules"

    if [ ! -d $UDEV_RULES_DIR ] ; then
        sudo mkdir -p $UDEV_RULES_DIR 
    fi

    echo ""
    echo "Installing udev rule to $RULE_FILE..."
    # Use sudo tee to write to a system-protected file
    echo "$GENERATED_UDEV_RULE" | sudo tee "$RULE_FILE" > /dev/null

    if [ $? -ne 0 ]; then
        echo "Error: Failed to write udev rule to $RULE_FILE. Please ensure you have sufficient permissions (e.g., run with 'sudo')."
        SCRIPT_STATUS="ERROR" 
        ERROR_MESSAGE+=" Failed to write udev rule to $RULE_FILE."
    else
        # Reload udev rules and trigger events ---
        echo "Reloading udev rules and triggering power_supply events..."
        sudo udevadm control --reload-rules
        #sudo udevadm trigger --subsystem=power_supply

        echo ""
        echo "Udev rule setup complete for adapter '$ADAPTER_NAME'."
        echo "The system will now trigger touch events in /run/user/$USER_ID/."
        echo "Ensure your inotify script is monitoring these files:"
        echo "  - /run/user/$USER_ID/power-unplug-event"
        echo "  - /run/user/$USER_ID/power-plug-event"
    fi
else
    echo "Skipping udev rule installation for power events as adapter name could not be determined."
fi

echo ""
echo "Finished with status: $SCRIPT_STATUS"
if [ -n "$ERROR_MESSAGE" ]; then
    echo "Details: $ERROR_MESSAGE"
fi

# For more granular control, parse the SCRIPT_STATUS output.
if [ "$SCRIPT_STATUS" == "ERROR" ]; then
    exit 1
else
    echo "Done!"
fi

# Setting the performance profile can make a big difference. By default, most systems seem to start in balanced mode,
# even if they're not running off a battery. So let's make sure that's changed to performance.
sudo xbps-install -y tlp power-profiles-daemon

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  # sudo ln -s /etc/sv/power-profiles-daemon /var/service || true
  #powerprofilesctl set balanced || true
  if [ ! -L "/var/service/tlp" ]; then
    sudo ln -s /etc/sv/tlp /var/service || true
  else 
    echo "Seems that tlp service is already running" || true
  fi
else
  # This computer runs on power outlet
  #powerprofilesctl set performance || true
  echo "Desktop PC! Wow" || true
fi

sed -i 's|^source $OMVOID_INSTALL/config/power.sh\s*$|#source $OMVOID_INSTALL/config/power.sh|' ~/.local/share/omvoid/install.sh
