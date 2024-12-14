#!/bin/bash

# Constants
APP_DIR="$HOME/main"
SERVER_DIR="$APP_DIR/server"
FABRIC_INSTALLER="fabric-installer.jar"
FABRIC_VERSION="1.0.1"
MINECRAFT_VERSION="1.21.4"
EULA_FILE="eula.txt"
FRPC_CONFIG="frpc.toml"
DENO_PROXY="proxy.ts"

# Ensure app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "Creating server directory: $APP_DIR"
    mkdir -p "$APP_DIR"
fi

# Ensure server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo "Creating server directory: $SERVER_DIR"
    mkdir -p "$SERVER_DIR"
fi

# Change directory to app directory
cd "$APP_DIR" || exit 1 && (
    # Start the fake HTTP service in the background
    echo "Starting fake HTTP service on port 8080..."
    deno run --allow-net "$DENO_PROXY" &

    # Start the frpc service
    echo "Starting frpc service..."
    frpc -c "$FRPC_CONFIG" &

    # Start backup service
    echo "Starting backup service..."
    bash backup.sh "$SERVER_DIR" &
)

# Change directory to server directory
cd "$SERVER_DIR" || exit 1 && (
    # Download Fabric installer if not present
    if [ ! -f "$FABRIC_INSTALLER" ]; then
        echo "Downloading Fabric installer..."
        wget -O "$FABRIC_INSTALLER" "https://maven.fabricmc.net/net/fabricmc/fabric-installer/$FABRIC_VERSION/fabric-installer-$FABRIC_VERSION.jar"
    fi

    # Install Fabric server if not already set up
    if [ ! -f "server.jar" ]; then
        echo "Installing Fabric server..."
        java -jar "$FABRIC_INSTALLER" server nogui -mcversion "$MINECRAFT_VERSION" -downloadMinecraft
        if [ $? -ne 0 ]; then
            echo "Failed to install Fabric server."
            exit 1
        fi
    fi

    # Accept the EULA
    if [ ! -f "$EULA_FILE" ]; then
        echo "eula=true" > "$EULA_FILE"
        echo "Minecraft EULA has been accepted."
    fi

    # Start the Minecraft server using start.sh
    chmod +x start.sh
    bash start.sh
)