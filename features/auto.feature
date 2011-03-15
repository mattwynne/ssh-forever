@announce @slow
Feature: Auto

  In order to run ssh-foprever non-interactively
  As a developer of SSH-Forever
  I want to specify an auto mode

  Scenario: Run non-interactively without a key
    Given I run `ssh-forever hedge@localhost --auto` interactively
     When I type "echo $SSH_CLIENT"
      And I type "echo $SSH_CONNECTION"
      And I type "exit"
     Then the output should match /::1 (.*) 22/
      And the output should match /::1 (.*) ::1 22/


  Scenario: Run non-interactively with a invalid identity file
    Given a file named "identity.file" with:
    """
    """
     And I run `ssh-forever hedge@localhost --auto --identity_file identity.file` interactively
    When I type "echo $SSH_CLIENT"
     And I type "echo $SSH_CONNECTION"
     And I type "exit"
    Then the output should match /::1 (.*) 22/
     And the output should match /::1 (.*) ::1 22/
