# Development Tools
# ===================

This directory contains a number of tools that can be used to help with the development of the project.

## How to use
Run the powershell script `add-external-tools.ps1` to add external tools to your Visual Studio 2022.
This will add the following tools to your Visual Studio 2022:
- `Emscripten: Build` - build the project using Emscripten docker image.
- `Emscripten: Run` - run the project using Nginx docker image (port 8080).
- `Emscripten: Clean` - clean the project by removing the docker compose files.

## Dependencies
- WSL2 (Windows Subsystem for Linux)
- Docker
- Docker Compose 2.0+
