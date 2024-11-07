#!/bin/bash

# Define colors for the progress bar
COLORS=("\e[31m" "\e[32m" "\e[33m" "\e[34m" "\e[35m" "\e[36m")
RESET_COLOR="\e[0m"

# Function to show a single-pass progress bar animation
show_progress_bar() {
    local pid=$1
    local delay=0.05 # Delay between each segment of the bar
    local color_index=0
    local progress_bar=""
    local width=50 # Width of the progress bar
    
    # Fill the progress bar from start to finish in a single pass
    for i in $(seq 1 $width); do
        # Build the progress bar incrementally
        progress_bar+="#"
        
        # Display the progress bar with color
        local color=${COLORS[color_index]}
        echo -ne "${color}[${progress_bar:0:width}$(printf '%*s' $((width - ${#progress_bar})))]${RESET_COLOR}\r"
        
        # Cycle through colors
        color_index=$(( (color_index + 1) % ${#COLORS[@]} ))
        
        sleep "$delay"
    done
    
    # Wait for the background process to complete after displaying the progress bar once
    wait "$pid" 2>/dev/null
    echo -ne "\r${RESET_COLOR}   \r" # Clear the line after the process finishes
}

# Step 1: Check and create Client and Server directories
echo -e "${COLORS[0]}Checking if Client and Server directories already exist...${RESET_COLOR}"
if [ -d "Client" ]; then
    echo -e "${COLORS[1]}Directory 'Client' already exists. Skipping creation.${RESET_COLOR}"
else
    echo -e "${COLORS[2]}Creating 'Client' directory...${RESET_COLOR}"
    mkdir Client
fi

if [ -d "Server" ]; then
    echo -e "${COLORS[3]}Directory 'Server' already exists. Skipping creation.${RESET_COLOR}"
else
    echo -e "${COLORS[4]}Creating 'Server' directory...${RESET_COLOR}"
    mkdir Server
fi

# Step 2: Navigate to Server and install Sanity dependencies
echo -e "${COLORS[5]}Navigating into Server directory and installing Sanity dependencies...${RESET_COLOR}"
cd Server
npm install next-sanity @sanity/image-url --force & # Run in background
show_progress_bar $!                                # Show progress bar while installing

# Step 3: Return to root directory
echo -e "${COLORS[0]}Returning to the root directory...${RESET_COLOR}"
cd ..

# Step 4: Navigate into Client directory and create Next.js project if it doesn’t exist
echo -e "${COLORS[1]}Navigating into Client directory...${RESET_COLOR}"
cd Client

# Run create-next-app directly in Client directory
if [ ! -f "package.json" ]; then
    echo -e "${COLORS[2]}Creating a Next.js project with Tailwind CSS, TypeScript, and other configurations...${RESET_COLOR}"
    yes no | npx create-next-app@latest . \
    --tailwind \
    --typescript \
    --app \
    --src-dir \
    --eslint \
    --import-alias "@/*" & # Run in background
    show_progress_bar $!    # Show progress bar while creating project

    # Check if package.json was created successfully to verify project setup
    if [ ! -f "package.json" ]; then
        echo -e "${COLORS[0]}Error: The Next.js project was not created. Please check for errors in the create-next-app process.${RESET_COLOR}"
        exit 1
    fi
else
    echo -e "${COLORS[3]}Next.js project already exists in 'Client' directory. Skipping creation.${RESET_COLOR}"
fi

# Step 5: Wait briefly to ensure dependencies finish installing
echo -e "${COLORS[4]}Waiting for dependencies to finish installing...${RESET_COLOR}"
sleep 10

# Step 6: Install additional Sanity dependencies in Client project
echo -e "${COLORS[0]}Installing additional Sanity dependencies...${RESET_COLOR}"
npm install next-sanity @sanity/image-url --legacy-peer-deps & # Run in background
show_progress_bar $!                                            # Show progress bar while installing additional dependencies

# Step 7: Check if start script exists in package.json, if not, add it
echo -e "${COLORS[1]}Ensuring package.json has a 'start' script...${RESET_COLOR}"
if ! grep -q '"start":' package.json; then
    echo "Adding 'start' script to package.json..."
    sed -i '/"scripts": {/a \    "start": "next dev",' package.json
else
    echo "'start' script already exists in package.json."
fi

# Step 8: List available npm scripts and prompt the user
echo -e "${COLORS[2]}Available npm scripts:${RESET_COLOR}"
if command -v jq &>/dev/null; then
    jq -r '.scripts | keys_unsorted[]' package.json
else
    grep -oP '"\K[^"]+(?=":)' package.json | sed 's/^/  - /'
fi

# Prompt for server choice with 'dev' as the default
echo -e "${COLORS[2]}Enter the name of the server you want to start (press Enter for 'dev'):${RESET_COLOR}"
read -r server_choice
server_choice=${server_choice:-dev} # Set default to 'dev' if input is empty

# Step 9: Start the selected npm script in the foreground
if npm run "$server_choice"; then
    echo -e "${COLORS[3]}Starting the Next.js server with '${server_choice}'...${RESET_COLOR}"
else
    echo -e "${COLORS[0]}Error: The selected server script '${server_choice}' is not available.${RESET_COLOR}"
fi

# Final message indicating setup completion
echo -e "${COLORS[4]}Setup complete! The selected server should now be running. If not, ensure the script exists and try again. - Code Saves Lives!${RESET_COLOR}"
