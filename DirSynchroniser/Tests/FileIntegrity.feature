Feature: File Integrity and Checksum Validation
  As a user of the directory synchronizer
  I want files to be verified for integrity during synchronization
  So that corrupted or incomplete transfers are detected and handled properly

  Background:
    Given I have a source directory "C:\temp\source"
    And I have a target directory "C:\temp\target"
    And the directory synchronizer is configured

  Scenario: Files with identical checksums are not copied
    Given the source directory contains file "document.txt" with content "Test content" and checksum "A1B2C3D4"
    And the target directory contains file "document.txt" with content "Test content" and checksum "A1B2C3D4"
    When I run the synchronization
    Then the target directory should contain file "document.txt" with checksum "A1B2C3D4"
    And the synchronization log should not contain "copied or updated: C:\temp\target\document.txt"
    And the file should not be transferred

  Scenario: Files with different checksums are updated
    Given the source directory contains file "document.txt" with content "New content" and checksum "E5F6G7H8"
    And the target directory contains file "document.txt" with content "Old content" and checksum "A1B2C3D4"
    When I run the synchronization
    Then the target directory should contain file "document.txt" with checksum "E5F6G7H8"
    And the synchronization log should contain "copied or updated: C:\temp\target\document.txt"
    And the file content should match the source

  Scenario: Files with same size but different content are detected and updated
    Given the source directory contains file "same_size.txt" with size 100 bytes and checksum "NEW12345"
    And the target directory contains file "same_size.txt" with size 100 bytes and checksum "OLD12345"
    When I run the synchronization
    Then the target directory should contain file "same_size.txt" with checksum "NEW12345"
    And the synchronization log should contain "copied or updated: C:\temp\target\same_size.txt"

  Scenario: Large files are verified using checksums
    Given the source directory contains file "large_file.bin" with size 52428800 bytes and checksum "LARGE123"
    And the target directory is empty
    When I run the synchronization
    Then the target directory should contain file "large_file.bin" with size 52428800 bytes
    And the target file should have checksum "LARGE123"
    And the synchronization log should contain "copied or updated: C:\temp\target\large_file.bin"

  Scenario: Binary files maintain integrity during synchronization
    Given the source directory contains binary file "image.jpg" with checksum "IMG12345"
    And the source directory contains binary file "document.pdf" with checksum "PDF67890"
    And the target directory is empty
    When I run the synchronization
    Then the target directory should contain file "image.jpg" with checksum "IMG12345"
    And the target directory should contain file "document.pdf" with checksum "PDF67890"
    And both files should maintain binary integrity

  Scenario: Checksum validation for multiple file updates
    Given the source directory contains file "file1.txt" with checksum "HASH001"
    And the source directory contains file "file2.txt" with checksum "HASH002"
    And the source directory contains file "file3.txt" with checksum "HASH003"
    And the target directory contains file "file1.txt" with checksum "HASH001"
    And the target directory contains file "file2.txt" with checksum "OLDHASH"
    And the target directory contains file "file3.txt" with checksum "HASH003"
    When I run the synchronization
    Then the target directory should contain file "file1.txt" with checksum "HASH001"
    And the target directory should contain file "file2.txt" with checksum "HASH002"
    And the target directory should contain file "file3.txt" with checksum "HASH003"
    And the synchronization log should not contain "copied or updated: C:\temp\target\file1.txt"
    And the synchronization log should contain "copied or updated: C:\temp\target\file2.txt"
    And the synchronization log should not contain "copied or updated: C:\temp\target\file3.txt"

  Scenario: Files with different sizes are always updated regardless of checksum
    Given the source directory contains file "size_test.txt" with size 200 bytes and checksum "SIZE200"
    And the target directory contains file "size_test.txt" with size 150 bytes and checksum "SIZE150"
    When I run the synchronization
    Then the target directory should contain file "size_test.txt" with size 200 bytes
    And the target file should have checksum "SIZE200"
    And the synchronization log should contain "copied or updated: C:\temp\target\size_test.txt"

  Scenario: Zero-byte files are handled correctly
    Given the source directory contains file "empty.txt" with size 0 bytes
    And the target directory contains file "empty.txt" with size 0 bytes
    When I run the synchronization
    Then the target directory should contain file "empty.txt" with size 0 bytes
    And the synchronization log should not contain "copied or updated: C:\temp\target\empty.txt"

  Scenario: Checksum calculation for files in subdirectories
    Given the source directory contains file "folder\subfolder\nested.txt" with checksum "NESTED01"
    And the target directory contains file "folder\subfolder\nested.txt" with checksum "OLDNEST"
    When I run the synchronization
    Then the target directory should contain file "folder\subfolder\nested.txt" with checksum "NESTED01"
    And the synchronization log should contain "copied or updated: C:\temp\target\folder\subfolder\nested.txt"

  Scenario: Files with special characters in names maintain integrity
    Given the source directory contains file "special-file_name(1).txt" with checksum "SPECIAL1"
    And the source directory contains file "file with spaces.doc" with checksum "SPECIAL2"
    And the target directory is empty
    When I run the synchronization
    Then the target directory should contain file "special-file_name(1).txt" with checksum "SPECIAL1"
    And the target directory should contain file "file with spaces.doc" with checksum "SPECIAL2"
    And both files should maintain their integrity