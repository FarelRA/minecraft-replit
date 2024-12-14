#!/bin/bash

# Amount of memory to allocate to the server
MEMORY_ALLOCATION="2G"

echo "Starting the Minecraft server..."

# Infinite loop to handle restarts
while true; do
    # Start the server
    java -Xmx${MEMORY_ALLOCATION} -Xms${MEMORY_ALLOCATION} -jar server.jar nogui
    
    # Check the server exit code
    if [ $? -eq 0 ]; then
        echo "Server stopped successfully. Exiting loop."
        exit 0
    fi

    echo "Server restarting in 5 seconds..."
    sleep 5
    
    # Break the loop after 3 restarts
    (( restarts++ ))
    if [[ $restarts -ge 3 ]]; then
        echo "Server failed to restart after 3 attempts. Exiting."
        exit 1
    fi
done