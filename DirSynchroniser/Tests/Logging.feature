Feature: Logging and Monitoring
  As a user of the directory synchronizer
  I want comprehensive logging of all synchronization activities
  So that I can monitor the process and troubleshoot issues

  Background:
    Given I have a source directory "C:\temp\source"
    And I have a target directory "C:\temp\target"
    And I have a log directory "C:\temp\logs"
    And the directory synchronizer is configured to log to "C:\temp\logs\sync.log"

  Scenario: Application startup logging
    Given the synchronizer is configured with valid parameters
    When I start the application
    Then the log file should be created at "C:\temp\logs\sync.log"
    And the log should contain "Starting directory synchronisation from C:\temp\source to C:\temp\target every 30 seconds"
    And the log entry should have INFO level
    And the log entry should include timestamp

  Scenario: Synchronization cycle logging
    Given the application is running
    When a synchronization cycle begins
    Then the log should contain "sync is starting"
    And the log entry should have DEBUG level
    When the synchronization cycle completes
    Then the log should contain "Synchronization completed"
    And the log entry should have DEBUG level

  Scenario: File operations logging
    Given the source directory contains file "test.txt" with content "Test content"
    And the target directory is empty
    When I run the synchronization
    Then the log should contain "copied or updated: C:\temp\target\test.txt"
    And the log entry should have INFO level
    And the timestamp should indicate when the operation occurred

  Scenario: Directory creation logging
    Given the source directory contains subdirectory "new_folder"
    And the target directory does not contain "new_folder"
    When I run the synchronization
    Then the log should contain "created directory: C:\temp\target\new_folder"
    And the log entry should have INFO level

  Scenario: File deletion logging
    Given the target directory contains file "obsolete.txt"
    And the source directory does not contain "obsolete.txt"
    When I run the synchronization
    Then the log should contain "removed redundant: C:\temp\target\obsolete.txt"
    And the log entry should have INFO level

  Scenario: Directory deletion logging
    Given the target directory contains subdirectory "old_folder"
    And the source directory does not contain "old_folder"
    When I run the synchronization
    Then the log should contain "removed redundant directory: C:\temp\target\old_folder"
    And the log entry should have INFO level

  Scenario: Error logging for file operations
    Given the source directory contains file "protected.txt"
    And the target directory contains "protected.txt" with read-only permissions
    When I run the synchronization
    Then the log should contain "couldn't update: C:\temp\target\protected.txt"
    And the log entry should have WARN level
    And the log should contain the specific error message

  Scenario: Error logging for directory operations
    Given the source directory contains subdirectory "restricted"
    And the target directory has permission restrictions
    When I run the synchronization
    Then the log should contain "couldn't create directory: C:\temp\target\restricted"
    And the log entry should have WARN level
    And the log should contain the error details

  Scenario: Log file rotation and management
    Given the application has been running for an extended period
    And the log file has grown large
    When log rotation occurs
    Then old log entries should be archived appropriately
    And the current log file should remain accessible
    And log file size should be manageable

  Scenario: Multiple synchronization cycles logging
    Given the application is configured with interval 5 seconds
    When multiple synchronization cycles run
    Then each cycle should have distinct "sync is starting" entries
    And each cycle should have distinct "Synchronization completed" entries
    And timestamps should show the progression of cycles
    And log entries should be in chronological order

  Scenario: Large-scale operations logging
    Given the source directory contains 100 files
    And the target directory is empty
    When I run the synchronization
    Then the log should contain 100 "copied or updated" entries
    And each file operation should be logged separately
    And the log performance should remain acceptable

  Scenario: Log configuration from command line parameters
    Given I provide log path "C:\custom\logs"
    And the custom log directory exists
    When I start the application
    Then the log file should be created at "C:\custom\logs\sync.log"
    And all subsequent logging should go to the custom location

  Scenario: Application exception logging
    Given an unexpected error occurs in the main application
    When the exception is caught
    Then the log should contain the exception message
    And the log entry should have ERROR level
    And the log should contain "Main error" as context

  Scenario: Log shutdown handling
    Given the application is running and logging
    When the application terminates
    Then the logging system should be properly shut down
    And all pending log entries should be flushed
    And log files should be properly closed

  Scenario: Concurrent logging operations
    Given multiple file operations occur simultaneously
    When logging occurs from different parts of the application
    Then log entries should not be corrupted or interleaved
    And each log entry should be complete and readable
    And timestamps should accurately reflect operation timing

  Scenario: Log level configuration
    Given the application is configured with different log levels
    When operations occur at various log levels
    Then DEBUG messages should include detailed operation information
    And INFO messages should include important state changes
    And WARN messages should include recoverable error conditions
    And ERROR messages should include critical failures

  Scenario: Log format consistency
    Given various types of operations occur
    When log entries are written
    Then all entries should follow consistent formatting
    And timestamps should be in a standard format
    And log levels should be clearly indicated
    And messages should be descriptive and actionable