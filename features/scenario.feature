@ext @vms
Feature: VMS Scenario

  In order to create vms execution plans and access my command center
  As a user
  I want to be able to create, edit, open, and delete scenarios

  Background:
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County | vms |
    And I am logged in as "admin@dallas.gov"
    And I go to the ext dashboard page

  Scenario: Create New Scenario
    When I navigate to "Apps > VMS > Manage Scenarios"
    Then the "Manage Scenarios" tab should be open
    When I click vms-row-button "Create New Scenario"
    When I fill in "Name" with "My Scenario"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "My Scenario" in grid row 1 within ".vms-active-scenarios-list"
    When I select the "My Scenario" grid row within ".vms-active-scenarios-list"
    And I click vms-row-button "Open Scenario"
    Then the "Command Center - My Scenario" tab should be open
    And the "My Scenario" scenario should be created

  Scenario: View List of Scenarios and Open Command Center
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "Apps > VMS > Manage Scenarios"
    Then I should see "Manage Scenarios"
    And the "Manage Scenarios" tab should be open
    And I should see "Scenario 1" in grid row 1 within ".vms-active-scenarios-list"
    And I should see "Scenario 2" in grid row 2 within ".vms-active-scenarios-list"
    And I should see "Scenario 3" in grid row 3 within ".vms-active-scenarios-list"
    When I select the "Scenario 1" grid row within ".vms-active-scenarios-list"
    And I click vms-row-button "Open Scenario"
    Then the "Command Center - Scenario 1" tab should be open

  Scenario: Edit Existing Scenario and Go Back to List
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I select the "Scenario 1" grid row within ".vms-active-scenarios-list"
    And I press "Edit Scenario Details"
    When I fill in "Name" with "Modified Scenario"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Modified Scenario" in grid row 1

  Scenario: Cancelling from Edit Scenario should return to Scenario List
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I select the "Scenario 1" grid row within ".vms-active-scenarios-list"
    And I press "Edit Scenario Details"
    When press "Cancel"
    Then I should see "Scenario 1" in grid row 1

  Scenario: Delete Existing Scenario
    Given I have the scenarios "Scenario 1, Scenario 2, Scenario 3"
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I select the "Scenario 1" grid row within ".vms-active-scenarios-list"
    And I click vms-row-button "Delete Scenario"
    Then the "Delete Scenario" window should be open
    When I press "Yes"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Scenario 2" in grid row 1
    And I should see "Scenario 3" in grid row 2