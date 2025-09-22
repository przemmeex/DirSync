Feature: Directory Synchronization
  As a user of the directory synchronizer
  I want to synchronize files and directories between source and target locations
  So that the target directory mirrors the source directory

  Background:
    Given I have a source directory "C:\temp\source"
    And I have a target directory "C:\temp\target"
    And the directory synchronizer is configured

  Scenario: Synchronize new files from source to target
    Given the source directory contains file "document1.txt" with content "Hello World"
    And the source directory contains file "document2.pdf" with size 1024 bytes
    And the target directory is empty
    When I run the synchronization
    Then the target directory should contain file "document1.txt" with content "Hello World"
    And the target directory should contain file "document2.pdf" with size 1024 bytes
    And the synchronization log should contain "copied or updated: C:\temp\target\document1.txt"
    And the synchronization log should contain "copied or updated: C:\temp\target\document2.pdf"

  Scenario: Synchronize new directories from source to target
    Given the source directory contains subdirectory "subfolder1"
    And the source directory contains subdirectory "subfolder1\nested"
    And the source directory contains file "subfolder1\nested\file.txt" with content "Nested file"
    And the target directory is empty
    When I run the synchronization
    Then the target directory should contain subdirectory "subfolder1"
    And the target directory should contain subdirectory "subfolder1\nested"
    And the target directory should contain file "subfolder1\nested\file.txt" with content "Nested file"
    And the synchronization log should contain "created directory: C:\temp\target\subfolder1"
    And the synchronization log should contain "created directory: C:\temp\target\subfolder1\nested"

  Scenario: Update existing files when source content changes
    Given the source directory contains file "update_test.txt" with content "Original content"
    And the target directory contains file "update_test.txt" with content "Original content"
    When I change the source file "update_test.txt" to contain "Updated content"
    And I run the synchronization
    Then the target directory should contain file "update_test.txt" with content "Updated content"
    And the synchronization log should contain "copied or updated: C:\temp\target\update_test.txt"

  Scenario: Skip copying when files are identical
    Given the source directory contains file "identical.txt" with content "Same content"
    And the target directory contains file "identical.txt" with content "Same content"
    When I run the synchronization
    Then the target directory should contain file "identical.txt" with content "Same content"
    And the synchronization log should not contain "copied or updated: C:\temp\target\identical.txt"

  Scenario: Remove files from target that no longer exist in source
    Given the source directory is empty
    And the target directory contains file "obsolete1.txt" with content "Old file"
    And the target directory contains file "obsolete2.doc" with size 512 bytes
    When I run the synchronization
    Then the target directory should not contain file "obsolete1.txt"
    And the target directory should not contain file "obsolete2.doc"
    And the synchronization log should contain "removed redundant: C:\temp\target\obsolete1.txt"
    And the synchronization log should contain "removed redundant: C:\temp\target\obsolete2.doc"

  Scenario: Remove empty directories from target that no longer exist in source
    Given the source directory is empty
    And the target directory contains subdirectory "old_folder"
    And the target directory contains subdirectory "old_folder\nested"
    When I run the synchronization
    Then the target directory should not contain subdirectory "old_folder\nested"
    And the target directory should not contain subdirectory "old_folder"
    And the synchronization log should contain "removed redundant directory: C:\temp\target\old_folder\nested"
    And the synchronization log should contain "removed redundant directory: C:\temp\target\old_folder"

  Scenario: Mixed synchronization operations
    Given the source directory contains file "keep.txt" with content "Keep this file"
    And the source directory contains file "update.txt" with content "New content"
    And the source directory contains file "new.txt" with content "Brand new file"
    And the source directory contains subdirectory "new_folder"
    And the source directory contains file "new_folder\nested_file.txt" with content "Nested content"
    And the target directory contains file "keep.txt" with content "Keep this file"
    And the target directory contains file "update.txt" with content "Old content"
    And the target directory contains file "delete.txt" with content "Remove this file"
    And the target directory contains subdirectory "old_folder"
    When I run the synchronization
    Then the target directory should contain file "keep.txt" with content "Keep this file"
    And the target directory should contain file "update.txt" with content "New content"
    And the target directory should contain file "new.txt" with content "Brand new file"
    And the target directory should contain subdirectory "new_folder"
    And the target directory should contain file "new_folder\nested_file.txt" with content "Nested content"
    And the target directory should not contain file "delete.txt"
    And the target directory should not contain subdirectory "old_folder"

  Scenario: Synchronize large files with checksum verification
    Given the source directory contains file "large_file.bin" with size 10485760 bytes and checksum "ABC123DEF456"
    And the target directory is empty
    When I run the synchronization
    Then the target directory should contain file "large_file.bin" with size 10485760 bytes and checksum "ABC123DEF456"
    And the synchronization log should contain "copied or updated: C:\temp\target\large_file.bin"

  Scenario: Skip updating large files with identical checksums
    Given the source directory contains file "large_file.bin" with size 10485760 bytes and checksum "ABC123DEF456"
    And the target directory contains file "large_file.bin" with size 10485760 bytes and checksum "ABC123DEF456"
    When I run the synchronization
    Then the target directory should contain file "large_file.bin" with size 10485760 bytes and checksum "ABC123DEF456"
    And the synchronization log should not contain "copied or updated: C:\temp\target\large_file.bin"