#!/bin/bash

# Script to run 3 debug instances of the Flutter app for testing multiplayer functionality
# This allows testing with 1 host + 2 clients

echo "Starting Flutter debug instances..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Flutter command not found. Please make sure Flutter is installed and in your PATH."
    exit 1
fi

# Navigate to the project directory
cd "$(dirname "$0")"

# Function to detect available terminal emulator
detect_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        echo "gnome-terminal"
    elif command -v konsole &> /dev/null; then
        echo "konsole"
    elif command -v xterm &> /dev/null; then
        echo "xterm"
    elif command -v kitty &> /dev/null; then
        echo "kitty"
    elif command -v alacritty &> /dev/null; then
        echo "alacritty"
    elif command -v terminator &> /dev/null; then
        echo "terminator"
    elif command -v xfce4-terminal &> /dev/null; then
        echo "xfce4-terminal"
    elif command -v mate-terminal &> /dev/null; then
        echo "mate-terminal"
    elif command -v lxterminal &> /dev/null; then
        echo "lxterminal"
    else
        echo "none"
    fi
}

# Function to run Flutter in debug mode with different device IDs
run_flutter_instance() {
    local instance_name=$1
    local device_id=$2
    local terminal=$3
    
    echo "Starting $instance_name on device $device_id using $terminal..."
    
    case $terminal in
        "gnome-terminal")
            gnome-terminal --title="Flutter Debug - $instance_name" -- bash -c "
                echo 'Starting $instance_name...';
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p 'Press Enter to close this terminal...'
            " &
            ;;
        "konsole")
            konsole --title "Flutter Debug - $instance_name" -e bash -c "
                echo 'Starting $instance_name...';
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p 'Press Enter to close this terminal...'
            " &
            ;;
        "xterm")
            xterm -title "Flutter Debug - $instance_name" -e bash -c "
                echo 'Starting $instance_name...';
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p 'Press Enter to close this terminal...'
            " &
            ;;
        "kitty")
            kitty --title "Flutter Debug - $instance_name" bash -c "
                echo 'Starting $instance_name...';
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p 'Press Enter to close this terminal...'
            " &
            ;;
        "alacritty")
            alacritty --title "Flutter Debug - $instance_name" -e bash -c "
                echo 'Starting $instance_name...';
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p 'Press Enter to close this terminal...'
            " &
            ;;
        "terminator")
            terminator --title="Flutter Debug - $instance_name" -e "bash -c '
                echo Starting $instance_name...;
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p Press\ Enter\ to\ close\ this\ terminal...
            '" &
            ;;
        "xfce4-terminal")
            xfce4-terminal --title="Flutter Debug - $instance_name" -e "bash -c '
                echo Starting $instance_name...;
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p Press\ Enter\ to\ close\ this\ terminal...
            '" &
            ;;
        "mate-terminal")
            mate-terminal --title="Flutter Debug - $instance_name" -e "bash -c '
                echo Starting $instance_name...;
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p Press\ Enter\ to\ close\ this\ terminal...
            '" &
            ;;
        "lxterminal")
            lxterminal --title="Flutter Debug - $instance_name" -e "bash -c '
                echo Starting $instance_name...;
                flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes;
                read -p Press\ Enter\ to\ close\ this\ terminal...
            '" &
            ;;
        *)
            echo "No supported terminal found. Running in background..."
            nohup flutter run -d $device_id --observatory-port=0 --disable-service-auth-codes > "flutter_$instance_name.log" 2>&1 &
            ;;
    esac
    
    # Wait a moment before starting the next instance
    sleep 1
}

# Check available devices
echo "Checking available devices..."
flutter devices

# Detect available terminal
TERMINAL=$(detect_terminal)
echo "Using terminal: $TERMINAL"

if [ "$TERMINAL" = "none" ]; then
    echo "Warning: No supported terminal found. Instances will run in background."
    echo "Check flutter_*.log files for output."
fi
# Parse number of instances from the first argument, default to 3
NUM_INSTANCES=${1:-3}

# Start instances with different device configurations
for ((i=1; i<=NUM_INSTANCES; i++)); do
    if [ $i -eq 1 ]; then
        NAME="Host"
    else
        NAME="Client$((i-1))"
    fi
    run_flutter_instance "$NAME" "linux" "$TERMINAL"
done


# Wait for user input, then kill all Konsole windows started by this script
read -p "Press Enter to exit this script and close all Konsole windows (instances will be killed)..."

# Kill all Konsole windows with the title "Flutter Debug -"
pkill -f "konsole.*Flutter Debug -"

