#!/bin/bash

# Define colors for the spinner
COLORS=("\e[31m" "\e[32m" "\e[33m" "\e[34m" "\e[35m" "\e[36m")
RESET_COLOR="\e[0m"

# Define spinner frames for the left-right animation
SPINNER_FRAMES=("⠁" "⠂" "⠄" "⠂")

# Function to show a spinner animation with color changes
show_spinner() {
  # $1 is the process ID of the command being tracked
  local pid=$1
  local delay=0.1 # Delay between frames
  local color_index=0
  local frame_index=0
  local direction=1 # Controls left-to-right and right-to-left animation

  # Loop while the given process ID is running
  while kill -0 "$pid" 2>/dev/null; do
    # Select the current color and spinner frame
    color=${COLORS[color_index]}
    frame=${SPINNER_FRAMES[frame_index]}
    # Display the spinner frame with the current color
    echo -ne "${color}${frame}${RESET_COLOR}\r"

    # Update frame index for left-to-right and back movement
    frame_index=$((frame_index + direction))
    if [ "$frame_index" -eq "${#SPINNER_FRAMES[@]}" ]; then
      direction=-1
      frame_index=$((frame_index - 2))
    elif [ "$frame_index" -lt 0 ]; then
      direction=1
      frame_index=1
    fi

    # Cycle through colors
    color_index=$(((color_index + 1) % ${#COLORS[@]}))
    sleep "$delay"
  done
  echo -ne "\r${RESET_COLOR}   \r" # Clear the line after the process finishes
}

# Step 1: Check and create Client and Server directories
echo "Checking if Client and Server directories already exist..."
if [ -d "Client" ]; then
  echo "Directory 'Client' already exists. Skipping creation."
else
  echo "Creating 'Client' directory..."
  mkdir Client
fi

if [ -d "Server" ]; then
  echo "Directory 'Server' already exists. Skipping creation."
else
  echo "Creating 'Server' directory..."
  mkdir Server
fi

# Step 2: Navigate to Server and install Sanity dependencies
echo "Navigating into Server directory and installing Sanity dependencies..."
cd Server
npm install next-sanity @sanity/image-url --force & # Run in background
show_spinner $!                                     # Show spinner while installing

# Step 3: Return to root directory
echo "Returning to the root directory..."
cd ..

# Step 4: Navigate into Client directory and create Next.js project
echo "Navigating into Client directory..."
cd Client

echo "Creating a Next.js project with Tailwind CSS, TypeScript, and other configurations..."
npx create-next-app@latest nextjs-layer-caker \
  --tailwind \
  --typescript \
  --app \
  --src-dir \
  --eslint \
  --import-alias "@/*" & # Run in background
show_spinner $!          # Show spinner while creating project

# Step 5: Wait briefly to ensure dependencies finish installing
echo "Waiting for dependencies to finish installing..."
sleep 10

# Step 6: Navigate into the new Next.js project folder
echo "Navigating into the newly created Next.js project folder..."
cd nextjs-layer-caker || exit

# Step 7: Install additional Sanity dependencies in Client project
echo "Installing additional Sanity dependencies..."
npm install next-sanity @sanity/image-url --legacy-peer-deps & # Run in background
show_spinner $!                                                # Show spinner while installing additional dependencies

# Step 8: Start the Next.js development server
echo "Starting the Next.js development server..."
npm run dev & # Run in background

# Step 9: Wait for the server to start
echo "Giving the server time to start up..."
sleep 5

# Final message indicating setup completion
echo -e "${COLORS[3]}Setup complete! You are now running the latest Next.js development server with Sanity dependencies installed. Code Saves Lives!${RESET_COLOR}"
