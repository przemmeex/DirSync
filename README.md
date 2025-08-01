# DirSynchroniser

DirSynchroniser is a .NET 8 console application that synchronizes files from a source directory to a target directory at a specified interval. Logging is handled via NLog, with logs written to a user-specified directory.

## Features

- Periodic directory synchronization
- Configurable source, target, interval, and log file path via command-line arguments
- Logging with NLog

## Usage

````````
DirSynchroniser.exe "C:\Source" "D:\Target" 300 "C:\Logs"
````````

## Command-Line Arguments

- `sourcePath`: Path to the source directory
- `targetPath`: Path to the target directory
- `intervalInSeconds`: Synchronization interval (integer, in seconds)
- `logFilePath`: Directory where logs will be stored

## Requirements

- .NET 8 SDK
- NLog (configured via `NLog.config` or programmatically)

## Notes

- Ensure the `NLog.config` file is present and correctly configured in the output directory.
- All specified directories must exist before running the application.

## Building

1. Clone the repository.
2. Open the solution in Visual Studio.
3. Build the project.
