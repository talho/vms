@ext @vms
Feature: Scen Access Control

  To prevent unauthorized users from accessing a VMS scenario that is not their own
  As a user
  I want to provide a list of other users that can access the scenario and assign their rights between admin and reader

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin  | Dallas County |
      | Atticus Finch      | atticus@example.com  | Admin  | Potter County |
    And delayed jobs are processed
    And I am logged in as "admin@dallas.gov"
    And I go to the ext dashboard page

  Scenario: Create a scenario with a reader
    When I navigate to "Apps > VMS > New Scenario"
    And I fill in "Name" with "Test Scenario"
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    And I press "Save"
    Then the "Command Center - Test Scenario" tab should be open
    And "Bartleby Scrivener" should be a reader for scenario "Test Scenario"

  Scenario: Create a scenario with an admin
    When I navigate to "Apps > VMS > New Scenario"
    And I fill in "Name" with "Test Scenario"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    And I click x-tab-strip-text "Permissions"
    And I select the "Reader" grid cell
    And I select "Admin" from ext combo "vms-scenario-permission-level-combo"
    And I press "Save"
    Then the "Command Center - Test Scenario" tab should be open
    And "Atticus Finch" should be an admin for scenario "Test Scenario"

  Scenario: Edit a scenario to add a reader
    Given I have the scenarios "Test"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I click edit on the "Test" grid row
    Then the "Modify Test" window should be open
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    And I press "Save and Open Scenario"
    Then the "Command Center - Test" tab should be open
    And "Bartleby Scrivener" should be a reader for scenario "Test"

  Scenario: Edit a scenario to change a reader to an admin
    Given I have the scenarios "Test"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I click edit on the "Test" grid row
    Then the "Modify Test" window should be open
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    And I click x-tab-strip-text "Permissions"
    And I select the "Reader" grid cell
    And I select "Admin" from ext combo "vms-scenario-permission-level-combo"
    And I press "Save and Open Scenario"
    Then the "Command Center - Test" tab should be open
    And "Atticus Finch" should be an admin for scenario "Test"

  Scenario: As a reader, view a scenario and confirm that you can't do anything
    Given I have the scenarios "Test"
    And "Bartleby Scrivener" is a reader for scenario "Test"
    When I sign out
    And I log in as "bartleby@example.com"
    And I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row
    And I press "Open"
    Then the "Command Center - Test" tab should be open
    And I should not see "New Site"
    When I click x-accordion-hd "PODs/Inventories"
    Then I should not see "New POD/Inventory"
    When I click x-accordion-hd "Roles"
    Then I should not see "Add Role"
    When I click x-accordion-hd "Qualifications"
    Then I should not see "Add Qualification"
    When I click x-accordion-hd "Teams"
    Then I should not see "New Team"
    When I click x-accordion-hd "Staff"
    Then I should not see "Add Staff"
    # add checks for right clicks and checks against the site info window here

  Scenario: As an admin, view a scenario and perform a basic action
    Given I have the scenarios "Test"
    And "Atticus Finch" is an admin for scenario "Test"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row
    And I press "Open"
    Then the "Command Center - Test" tab should be open
    And I should see "New Site"
    When I drag the "New Site" site to the map at "31.347573", "-94.71391"
    And I fill in "Name" with "Immunization Center"
    Then the "Address" field should contain "1303 Atkinson Dr, Lufkin, TX 75901, USA"
    When I press "Save"
    Then I should see "Immunization Center" in grid row 2 within ".siteGrid"
    And the site "Immunization Center" should exist at "1303 Atkinson Dr, Lufkin, TX 75901, USA", "31.347573", "-94.71391"