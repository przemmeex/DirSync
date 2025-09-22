Feature: Error Handling and Recovery
  As a user of the directory synchronizer
  I want the application to handle errors gracefully
  So that synchronization continues for other files when individual operations fail

  Background:
    Given I have a source directory "C:\temp\source"
    And I have a target directory "C:\temp\target"
    And the directory synchronizer is configured

  Scenario: File access denied during copy operation
    Given the source directory contains file "protected.txt" with content "Protected content"
    And the target directory contains file "protected.txt" that is read-only
    When I run the synchronization
    Then the synchronization should continue without stopping
    And the synchronization log should contain "couldn't update: C:\temp\target\protected.txt"
    And the synchronization log should contain "Error: Access to the path"
    And other files should still be synchronized normally

  Scenario: Directory creation failure due to permissions
    Given the source directory contains subdirectory "restricted"
    And the target directory has restricted write permissions
    When I run the synchronization
    Then the synchronization should continue without stopping
    And the synchronization log should contain "couldn't create directory: C:\temp\target\restricted"
    And the synchronization log should contain "Error:"
    And other operations should continue normally

  Scenario: File deletion failure due to file being in use
    Given the target directory contains file "locked.txt" that is currently in use
    And the source directory does not contain file "locked.txt"
    When I run the synchronization
    Then the synchronization should continue without stopping
    And the synchronization log should contain "could not remove: C:\temp\target\locked.txt"
    And the synchronization log should contain "Error:"
    And other files should still be processed

  Scenario: Directory deletion failure due to files in use
    Given the target directory contains subdirectory "busy_folder"
    And the subdirectory "busy_folder" contains files that are currently in use
    And the source directory does not contain subdirectory "busy_folder"
    When I run the synchronization
    Then the synchronization should continue without stopping
    And the synchronization log should contain "could not remove directory: C:\temp\target\busy_folder"
    And the synchronization log should contain "Error:"
    And other directories should still be processed

  Scenario: Network drive disconnection during synchronization
    Given the source directory is on a network drive "\\server\share\source"
    And the network connection is unstable
    When the network disconnects during synchronization
    Then the synchronization should handle the IOException gracefully
    And the synchronization log should contain appropriate error messages
    And the application should not crash

  Scenario: Disk full during file copy
    Given the source directory contains file "large_file.bin" with size 1073741824 bytes
    And the target drive has insufficient disk space
    When I run the synchronization
    Then the synchronization should continue without stopping
    And the synchronization log should contain "couldn't update: C:\temp\target\large_file.bin"
    And the synchronization log should contain "Error:"
    And other files should still be synchronized

  Scenario: Multiple error conditions in single synchronization run
    Given the source directory contains file "file1.txt" with content "Normal file"
    And the source directory contains file "file2.txt" with content "Protected file"
    And the source directory contains file "file3.txt" with content "Another normal file"
    And the target directory contains file "file2.txt" that is read-only
    And the target directory contains file "locked.txt" that is currently in use
    And the source directory does not contain file "locked.txt"
    When I run the synchronization
    Then the target directory should contain file "file1.txt" with content "Normal file"
    And the target directory should contain file "file3.txt" with content "Another normal file"
    And the synchronization log should contain "copied or updated: C:\temp\target\file1.txt"
    And the synchronization log should contain "copied or updated: C:\temp\target\file3.txt"
    And the synchronization log should contain "couldn't update: C:\temp\target\file2.txt"
    And the synchronization log should contain "could not remove: C:\temp\target\locked.txt"

  Scenario: File path too long error
    Given the source directory contains a file with a very long path exceeding 260 characters
    When I run the synchronization
    Then the synchronization should continue without stopping
    And the synchronization log should contain an appropriate error message about path length
    And other files should still be synchronized

  Scenario: Corrupted file during checksum calculation
    Given the source directory contains file "corrupted.txt"
    And the file "corrupted.txt" becomes corrupted during checksum calculation
    When I run the synchronization
    Then the synchronization should handle the exception gracefully
    And the synchronization log should contain appropriate error information
    And the synchronization should continue with other files

  Scenario: Insufficient memory during large file operation
    Given the source directory contains very large file "huge_file.bin" with size 2147483648 bytes
    And the system has limited available memory
    When I run the synchronization
    Then the synchronization should handle memory constraints gracefully
    And the file should be processed in chunks or skip with appropriate logging
    And other files should continue to be synchronized

  Scenario: Application main exception handling
    Given the directory synchronizer encounters an unexpected exception
    When the main application loop catches the exception
    Then the application should log the error message
    And the application should log "Main error" as the context
    And the logging system should be properly shut down
    And the application should not leave orphaned processes

  Scenario: File system watcher interference
    Given files are being modified by other processes during synchronization
    When the synchronization runs while files are changing
    Then the synchronization should handle concurrent file access gracefully
    And IOException should be caught and logged appropriately
    And the synchronization should not corrupt any files

  Scenario: Antivirus software interference
    Given antivirus software is scanning files during synchronization
    When files are temporarily locked by antivirus
    Then the synchronization should retry or skip locked files gracefully
    And appropriate warning messages should be logged
    And the synchronization should continue with remaining files