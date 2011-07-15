@ext @vms
Feature: User Profile

  In order to view and manage qualifications and alerts
  As a VMS volunteer
  I would like a profile tab with qualification and alert columns

  Background:
    Given the following users exist:
      | Atticus Finch | atticus@example.com | Volunteer | Angelina County | vms |
    And I am logged in as "atticus@example.com"
    And I go to the ext dashboard page

  Scenario: Launch user profile as vms Volunteer
    When I navigate to "Apps > VMS > My Volunteer Profile"
    Then the "My Volunteer Profile" tab should be open

  Scenario: Can't launch user profile if not a Volunteer
    When I sign out
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Public | Angelina County |     |
      | ad min             | admin@example.com    | Admin  | Angelina County | vms |
    And I am logged in as "bartleby@example.com"
    # do a custom search here to look conditionally look for Apps and search within the layers of Apps until we get to the level we are looking for
    Then I should not see the volunteer profile menu option
    When I sign out
    And I am logged in as "admin@example.com"
    Then I should not see the volunteer profile menu option

  Scenario: View current qualifications
    Given user "Atticus Finch" has the "bilingual" qualification
    And user "Atticus Finch" has the "very strong" qualification
    When I navigate to "Apps > VMS > My Volunteer Profile"
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual" within ".vms-qualification-grid"
    And I should see "very strong" within ".vms-qualification-grid"

  Scenario: Add qualification
    When I navigate to "Apps > VMS > My Volunteer Profile"
    And I fill in "VmsQualificationCombo" with "bilingual"
    And I press "Add"
    And I wait for the "Saving..." mask to go away
    Then I should see "bilingual" within ".vms-qualification-grid"

  Scenario: Remove qualification
    Given user "Atticus Finch" has the "bilingual" qualification
    And user "Atticus Finch" has the "very strong" qualification
    When I navigate to "Apps > VMS > My Volunteer Profile"
    And I wait for the "Loading..." mask to go away
    And I click remove_qual on the "bilingual" grid row within ".vms-qualification-grid"
    And I wait for the "Saving..." mask to go away
    Then I should not see "bilingual" within ".vms-qualification-grid"
    And I should see "very strong" within ".vms-qualification-grid"

  Scenario: View list of alerts and alert detail
    Given I have the scenarios "Test"
    And "Atticus Finch" has received the following alert for scenario "Test":
      | type    | VmsAlert             |
      | title   | Test Alert           |
      | message | This is a test alert |
    And delayed jobs are processed
    When I navigate to "Apps > VMS > My Volunteer Profile"
    And I wait for the "Loading..." mask to go away
    Then I should see "Test Alert" within ".vms-alert-grid"
    When I select the "Test Alert" grid row within ".vms-alert-grid"
    Then I should see "This is a test alert" within ".vms-alert-detail-message"

  Scenario: View alert detail with call downs
    Given I have the scenarios "Test"
    And the following entities exist:
      | Role | Chief Veterinarian | vms |
    And the user "Atticus Finch" with the email "atticus@example.com" has the role "Chief Veterinarian" in "Angelina County"
    And "Atticus Finch" has received the following alert for scenario "Test":
      | type    | VmsExecutionAlert  |
      | title   | Test Alert         |
      | message |                    |
      | roles   | Chief Veterinarian |
    And delayed jobs are processed
    When I navigate to "Apps > VMS > My Volunteer Profile"
    And I wait for the "Loading..." mask to go away
    Then I should see "Test Alert" within ".vms-alert-grid"
    When I select the "Test Alert" grid row within ".vms-alert-grid"
    Then I should see "There has been a call for volunteers put out" within ".vms-alert-detail-message"
    And I should see "1) I cannot respond" within ".vms-alert-detail-call-downs"
    And I should see "2) I can respond as Chief Veterinarian" within ".vms-alert-detail-call-downs"
    And I should see "3) I can respond as any role" within ".vms-alert-detail-call-downs"
    When I click vms-row-button "2) I can respond as Chief Veterinarian"
    And I wait for the "Saving..." mask to go away
    Then I should see "2) I can respond as Chief Veterinarian" within ".vms-call-down-selected-response"
    And the user "Atticus Finch" should have responded to the alert "Test Alert" with 2

  Scenario: View a selected call down response
    Given I have the scenarios "Test"
    And the following entities exist:
      | Role | Chief Veterinarian | vms |
    And the user "Atticus Finch" with the email "atticus@example.com" has the role "Chief Veterinarian" in "Angelina County"
    And "Atticus Finch" has received the following alert for scenario "Test":
      | type    | VmsExecutionAlert  |
      | title   | Test Alert         |
      | message |                    |
      | roles   | Chief Veterinarian |
    And "Atticus Finch" has responded to a VmsExecutionAlert with title "Test Alert" with 3
    And delayed jobs are processed
    When I navigate to "Apps > VMS > My Volunteer Profile"
    And I wait for the "Loading..." mask to go away
    When I select the "Test Alert" grid row within ".vms-alert-grid"
    Then I should see "3) I can respond as any role" within ".vms-call-down-selected-response"