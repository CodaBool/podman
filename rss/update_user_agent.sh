#!/bin/bash
# update_user_agent.sh

# Define the path to the output file.
# Adjust this path as necessary.
FILE="/mnt/volumes/user_agent.toml"

# Fetch the user agent string using curl and jq.
USER_AGENT=$(curl -s "https://jnrbsn.github.io/user-agents/user-agents.json" | jq -r '.[3]')

# Check that a user agent was retrieved.
if [[ -z "$USER_AGENT" ]]; then
  echo "Error: Failed to retrieve user agent."
  exit 1
fi

# Write the user agent to the file in TOML key-value format.
echo "HTTP_CLIENT_USER_AGENT=\"$USER_AGENT\"" > "$FILE"




# Relies on a systemd service and timer
# SERVICE

#[Unit]
#Description=Update User Agent TOML File
#[Service]
#Type=oneshot
#ExecStart=/bin/bash /home/codabool/.config/containers/systemd/rss/update_user_agent.sh


# TIMER
#[Unit]
#Description=Run update-user-agent.service daily
#[Timer]
#OnCalendar=daily
#Persistent=true
#[Install]
#WantedBy=timers.target

