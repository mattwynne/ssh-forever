Feature: Exit statuses

  In order to specify expected exit statuses
  As a developer using SSH-Forever
  I want to use the "the exit status should be" step

  Scenario: exit status of 0
    When I run `ssh-forever -h`
    Then the exit status should be 0

  Scenario Outline: exit status of 1 with incomplete arguments
    When I run `ssh-forever  --<option>`
    Then the exit status should be 1

  Examples:
  | option |
  |batch |
  |auto  |
  |login |
  |port  |
  |identity_file |
  |intense |
  |name |
  |quiet |
  |strict |

