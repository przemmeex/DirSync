Feature: Command Line Argument Validation
  As a user of the directory synchronizer
  I want the application to validate command line arguments
  So that I receive clear error messages for invalid inputs

  Scenario: Valid command line arguments
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\temp\target"
    And I provide interval "30"
    And I provide log path "C:\temp\logs"
    And all directories exist
    When I start the application
    Then the application should start successfully
    And the synchronization should be configured with source "C:\temp\source"
    And the synchronization should be configured with target "C:\temp\target"
    And the synchronization should be configured with interval 30 seconds
    And the log file should be created at "C:\temp\logs\sync.log"

  Scenario: Missing command line arguments
    Given I provide fewer than 4 arguments
    When I start the application
    Then the application should display error "usage: DirSynchroniser sourcePath targetPath intervalInSeconds logFilePath"
    And the application should exit without starting synchronization

  Scenario: Invalid source directory path
    Given I provide source path "C:\nonexistent\source"
    And I provide target path "C:\temp\target"
    And I provide interval "30"
    And I provide log path "C:\temp\logs"
    And the source directory does not exist
    And the target directory exists
    And the log directory exists
    When I start the application
    Then the application should display error "entered path(s) is invalid"
    And the application should exit without starting synchronization

  Scenario: Invalid target directory path
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\nonexistent\target"
    And I provide interval "30"
    And I provide log path "C:\temp\logs"
    And the source directory exists
    And the target directory does not exist
    And the log directory exists
    When I start the application
    Then the application should display error "entered path(s) is invalid"
    And the application should exit without starting synchronization

  Scenario: Invalid log directory path
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\temp\target"
    And I provide interval "30"
    And I provide log path "C:\nonexistent\logs"
    And the source directory exists
    And the target directory exists
    And the log directory does not exist
    When I start the application
    Then the application should display error "entered path(s) is invalid"
    And the application should exit without starting synchronization

  Scenario: Invalid interval parameter - non-numeric
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\temp\target"
    And I provide interval "invalid"
    And I provide log path "C:\temp\logs"
    And all directories exist
    When I start the application
    Then the application should display error "enter an integer for interval"
    And the application should exit without starting synchronization

  Scenario: Invalid interval parameter - negative number
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\temp\target"
    And I provide interval "-10"
    And I provide log path "C:\temp\logs"
    And all directories exist
    When I start the application
    Then the application should display error "enter an integer for interval"
    And the application should exit without starting synchronization

  Scenario: Invalid interval parameter - decimal number
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\temp\target"
    And I provide interval "30.5"
    And I provide log path "C:\temp\logs"
    And all directories exist
    When I start the application
    Then the application should display error "enter an integer for interval"
    And the application should exit without starting synchronization

  Scenario: Zero interval parameter
    Given I provide source path "C:\temp\source"
    And I provide target path "C:\temp\target"
    And I provide interval "0"
    And I provide log path "C:\temp\logs"
    And all directories exist
    When I start the application
    Then the application should start successfully
    And the synchronization should be configured with interval 0 seconds

  Scenario: Multiple invalid arguments
    Given I provide source path "C:\nonexistent\source"
    And I provide target path "C:\nonexistent\target"
    And I provide interval "invalid"
    And I provide log path "C:\nonexistent\logs"
    When I start the application
    Then the application should display error "entered path(s) is invalid"
    And the application should exit without starting synchronization

  Scenario: Paths with spaces in names
    Given I provide source path "C:\temp\source with spaces"
    And I provide target path "C:\temp\target with spaces"
    And I provide interval "30"
    And I provide log path "C:\temp\logs with spaces"
    And all directories exist
    When I start the application
    Then the application should start successfully
    And the synchronization should be configured with source "C:\temp\source with spaces"
    And the synchronization should be configured with target "C:\temp\target with spaces"
    And the log file should be created at "C:\temp\logs with spaces\sync.log"

  Scenario: Long directory paths
    Given I provide source path "C:\very\long\path\with\many\subdirectories\source"
    And I provide target path "C:\very\long\path\with\many\subdirectories\target"
    And I provide interval "60"
    And I provide log path "C:\very\long\path\with\many\subdirectories\logs"
    And all directories exist
    When I start the application
    Then the application should start successfully
    And the synchronization should be configured with the provided long paths