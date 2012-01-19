@ext @vms
Feature: Alert Acknowledgement

  So I can acknowledge alerts that I receive
  As a recipient of an alert
  I want to be able to acknowledge alerts outside of the phin application with and without logging in

  Background:
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Volunteer | Angelina County | vms |
    And bartleby@example.com has the scenarios "Test"

  Scenario: Acknowledge a VMS Status Check Alert without logging in
    Given "Bartleby Scrivener" has received the following alert for scenario "Test":
      | type    | VmsStatusCheckAlert  |
      | title   | Test Alert           |
      | message | This is a test alert |
      | author  | Bartleby Scrivener   |
    Then the "Test Alert" email should contain an acknowledgement link
    When I visit the "Test Alert" acknowledgement link without login
    Then I should see "This is a test alert"
    When I click alert_ack_option "Acknowledge Alert"
    Then I should see "Acknowledge Alert" within ".selected"
    And the user "Bartleby Scrivener" should have responded to the alert "Test Alert" with 1

  Scenario: Acknowledge a VMS Status Check Alert while logging in
    Given "Bartleby Scrivener" has received the following alert for scenario "Test":
      | type    | VmsStatusCheckAlert  |
      | title   | Test Alert           |
      | message | This is a test alert |
      | author   | Bartleby Scrivener   |
    Then the "Test Alert" email should contain an acknowledgement link
    When I visit the "Test Alert" acknowledgement link with login
    Then I should see "Sign In"
    When I fill in "Email" with "bartleby@example.com"
    And I fill in "Password" with "Password1"
    And I press "Sign in"
    Then I should see "This is a test alert"
    When I click alert_ack_option "Acknowledge Alert"
    Then I should see "Acknowledge Alert" within ".selected"
    And the user "Bartleby Scrivener" should have responded to the alert "Test Alert" with 1

  Scenario: Acknowledge a VMS Execution alert without logging in
    Given "Bartleby Scrivener" has received the following alert for scenario "Test":
      | type    | VmsExecutionAlert    |
      | title   | Test Alert           |
      | message | This is a test alert |
      | roles   | Volunteer            |
    Then the "Test Alert" email should contain an acknowledgement link
    When I visit the "Test Alert" acknowledgement link without login
    Then I should see "There has been a call for volunteers put out."
    When I click alert_ack_option "I can respond as Volunteer"
    Then I should see "I can respond as Volunteer" within ".selected"
    And the user "Bartleby Scrivener" should have responded to the alert "Test Alert" with 2

  Scenario: Acknowledge a VMS Execution alert while logging in
    Given "Bartleby Scrivener" has received the following alert for scenario "Test":
      | type    | VmsExecutionAlert    |
      | title   | Test Alert           |
      | message | This is a test alert |
      | roles   | Volunteer            |
    Then the "Test Alert" email should contain an acknowledgement link
    When I visit the "Test Alert" acknowledgement link with login
    Then I should see "Sign In"
    When I fill in "Email" with "bartleby@example.com"
    And I fill in "Password" with "Password1"
    And I press "Sign in"
    Then I should see "There has been a call for volunteers put out."
    When I click alert_ack_option "I can respond as any role"
    Then I should see "I can respond as any role" within ".selected"
    And the user "Bartleby Scrivener" should have responded to the alert "Test Alert" with 3