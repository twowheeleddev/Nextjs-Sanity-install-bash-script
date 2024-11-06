#!/bin/bash

# Function to show a spinner animation while a background process is running
show_spinner() {
  # $1 is the process ID of the command that the spinner will track
  local pid=$1
  # delay between each frame of the spinner
  local delay=0.1
  # Array of characters to display as the spinner animation. ** The best I could come up with **
  local spinner=('|' '/' '-' '\')

  # Loop the animation while the given PID is still running
  while kill -0 "$pid" 2>/dev/null; do
    # Loop through each character in the spinners array, basically creating the spinner animation by looping over each character sort of making motion.
    for i in "${spinner[@]}"; do
      # Display the spinner character and overwrite the previous one with \r
      printf "\r%s" "$i"
      # Pause briefly to add effect to the animation
      sleep "$delay"
    done
  done
  printf "\r" # Clear the spinner line after the background process is complete
}

# Step 1: Create Client and Server directories
echo "Checking if Client and Server directories already exist..."

# Check if Client directory exists
# If directory exists, skip creation and move to next step
# If directory does not exist, create the directory using the 'mkdir' command
if [ -d "Client" ]; then
  echo "Directory 'Client' already exists. Skipping creation."
else
  echo "Creating 'Client' directory..."
  mkdir Client
fi

# Check if Server directory exists
# If directory exists, skip creation and move to next step
# If directory does not exist, create the directory using the 'mkdir' command
if [ -d "Server" ]; then
  echo "Directory 'Server' already exists. Skipping creation."
else
  echo "Creating 'Server' directory..."
  mkdir Server
fi

# Step 2: Navigate into Server directory and install Sanity dependencies
echo "Navigating into Server directory and installing Sanity dependencies..."
# Navigate (eg. 'cd') into the Server directory
cd Server
# Run npm install command to install the required dependencies  (next-sanity and @sanity/image-url) use the --force flag to bypass every safety check ever created in a computer system and smile knowing that you have just saved yourself a few minutes of your life.--sarcasm
npm install next-sanity @sanity/image-url --force &

# Start spinner animation while the npm install command is running
show_spinner $!

# Step 3: Go back to the root directory
echo "Returning to the root directory..."
# Again 'cd ..' takes us back to the root where both Client and Server directories were created
cd ..

# Step 4: Navigate into Client directory
echo "Navigating into Client directory..."
# Here comes the broken record Navig......
cd Client

# Step 5: Create a Next.js project with specified options
echo "Creating a Next.js project with Tailwind CSS, TypeScript, and other configurations..."
npx create-next-app@latest nextjs-layer-caker \
  --tailwind \ # Tailwind CSS is a utility-first CSS framework
--typescript \ # TypeScript is a typed superset of JavaScript that compiles to plain JavaScript
--app \ # This is a custom template that includes a few extra configurations
--src-dir \ # This is a custom template that includes a few extra configurations
--eslint \ # ESLint is a tool for identifying and reporting on patterns found in ECMAScript/JavaScript code
--import-alias "@/*" & # This is a custom template that includes a few extra configurations

# Start spinner animation while npx is creating the Next.js project
show_spinner $!

# Step 6: Wait for dependencies to finish installing
echo "Waiting for dependencies to finish installing..."
sleep 10

# Step 7: Navigate into the newly created Next.js project folder
echo "Navigating into the newly created Next.js project folder..."
cd nextjs-layer-caker || exit

# Step 8: Install additional Sanity dependencies
echo "Installing additional Sanity dependencies..."
npm install next-sanity @sanity/image-url --legacy-peer-deps &

# Start spinner animation while npm is installing the additional dependencies
show_spinner $!

# Step 9: Run the Next.js dev server
echo "Starting the Next.js development server..."
npm run dev &

# Step 10: Give the server time to start up
echo "Giving the server time to start up..."
sleep 5

# Final message to indicate setup is complete
echo "Setup complete! You are now running the latest Next.js development server with Sanity dependencies installed. Code Saves Lives!"
