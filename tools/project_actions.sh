#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./build.sh <run|build> <web|win64>"
  exit 1
fi

ACTION="$1"
PLATFORM="$2"

if [ "$PLATFORM" = "web" ]; then
  if [ "$ACTION" = "build" ]; then
    # Web build
    docker compose down --volumes
    docker compose build
  elif [ "$ACTION" = "run" ]; then
    docker compose down --volumes
    docker compose up
  elif [ "$ACTION" = "clean" ]; then
    docker compose down --volumes

  else
    echo "Invalid action argument. Please use run, build or clean"
    exit 1
  fi
elif [ "$PLATFORM" = "win64" ]; then
  DESTINATION_FOLDER="${PWD}/build"
  
  if [ "$ACTION" = "build" ]; then
    # Win64 build
    # Build the Docker image
    docker build -t win64-compiler -f Dockerfile.win64 .
    # Run the Docker container in the background
    docker run -d --name win64-compiler-container win64-compiler
    # Copy the compiled files from the running container to the host machine
    docker cp win64-compiler-container:/app/win64 "$DESTINATION_FOLDER"
    # Stop and remove the running container
    docker container rm -f win64-compiler-container
  fi
  
  # Check if the 'run' argument is provided
  if [ "$ACTION" = "run" ]; then
    # Find the .exe file in the destination folder
    EXE_FILE=$(find "$DESTINATION_FOLDER" -iname "*.exe")

    # Execute the .exe file
    if [ -n "$EXE_FILE" ]; then
      echo "Running $EXE_FILE"

      # Convert the WSL path to the Windows path format
      WIN_PATH=$(wslpath -w "$EXE_FILE")

      # Execute the .exe file using the Windows path
      cmd.exe /C start "" "$WIN_PATH"
    else
      echo "No .exe file found in the destination folder."
    fi
  elif [ "$ACTION" != "build" ]; then
    echo "Invalid action argument. Please use run or build"
    exit 1
  fi
else
  echo "Invalid platform argument. Please use web or win64"
  exit 1
fi
