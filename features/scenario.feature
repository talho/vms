@ext @vms
Feature: VMS Scenario

  In order to create vms execution plans and access my command center
  As a user
  I want to be able to create, edit, open, and delete scenarios

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"
    And I go to the ext dashboard page

  Scenario: Create New Scenario
    When I navigate to "VMS > New Scenario"
    Then I should see "New Scenario"
    Then the "New Scenario" window should be open
    When I fill in "Scenario Name" with "My Scenario"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then the "Command Center - My Scenario" tab should be open
    And the "My Scenario" scenario should be created

  Scenario: View List of Scenarios and Open Command Center
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "VMS > Open Scenario"
    Then I should see "Open Scenario"
    And the "Open Scenario" window should be open
    And I should see "Scenario 1" in grid row 1
    And I should see "Scenario 2" in grid row 2
    And I should see "Scenario 3" in grid row 3
    When I select the "Scenario 1" grid row
    And I press "Open"
    Then the "Command Center - Scenario 1" tab should be open

  Scenario: Edit Existing Scenario and Go Back to List
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "VMS > Open Scenario"
    And I click edit on the "Scenario 1" grid row
    Then I should see "Modify Scenario 1"
    And the "Modify Scenario 1" window should be open
    When I fill in "Scenario Name" with "Modified Scenario"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then I should see "Open Scenario"
    And the "Open Scenario" window should be open
    When I wait for the "Loading..." mask to go away
    Then I should see "Modified Scenario" in grid row 1

  Scenario: Edit Existing Scenario and Open Command Center
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "VMS > Open Scenario"
    And I click edit on the "Scenario 1" grid row
    Then I should see "Modify Scenario 1"
    And the "Modify Scenario 1" window should be open
    When I fill in "Scenario Name" with "Modified Scenario"
    And I press "Save and Open Scenario"
    And I wait for the "Saving..." mask to go away
    Then the "Command Center - Modified Scenario" tab should be open

  Scenario: Cancelling from Edit Scenario should return to Scenario List
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "VMS > Open Scenario"
    And I click edit on the "Scenario 1" grid row
    Then I should see "Modify Scenario 1"
    And the "Modify Scenario 1" window should be open
    When press "Cancel"
    Then I should see "Open Scenario"
    And the "Open Scenario" window should be open

  Scenario: Delete Existing Scenario
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "VMS > Open Scenario"
    And I click delete on the "Scenario 1" grid row
    Then the "Delete Scenario" window should be open
    When I press "Yes"
    And I wait for the "Saving..." mask to go away
    Then I should see "Scenario 2" in grid row 1
    And I should see "Scenario 3" in grid row 2