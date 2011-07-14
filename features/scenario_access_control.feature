@ext @vms
Feature: Scen Access Control

  To prevent unauthorized users from accessing a VMS scenario that is not their own
  As a user
  I want to provide a list of other users that can access the scenario and assign their rights between admin and reader

  Background:
    Given the following users exist:
      | Ad min             | admin@dallas.gov     | Admin | Dallas County | vms |
      | Bartleby Scrivener | bartleby@example.com | Admin | Dallas County | vms |
      | Atticus Finch      | atticus@example.com  | Admin | Potter County | vms |
    And delayed jobs are processed
    And I am logged in as "admin@dallas.gov"
    And I go to the ext dashboard page

  Scenario: Create a scenario with a reader
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I click vms-row-button "Create New Scenario"
    And I fill in "Name" with "Test Scenario"
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And "Bartleby Scrivener" should be a reader for scenario "Test Scenario"

  Scenario: Create a scenario with an admin
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I click vms-row-button "Create New Scenario"
    And I fill in "Name" with "Test Scenario"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    And I select the "Reader" grid cell
    And I select "Admin" from ext combo "vms-scenario-permission-level-combo"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And "Atticus Finch" should be an admin for scenario "Test Scenario"

  Scenario: Edit a scenario to add a reader
    Given I have the scenarios "Test"
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I select the "Test" grid row within ".vms-active-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And "Bartleby Scrivener" should be a reader for scenario "Test"

  Scenario: Edit a scenario to change a reader to an admin
    Given I have the scenarios "Test"
    When I navigate to "Apps > VMS > Manage Scenarios"
    When I select the "Test" grid row within ".vms-active-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    And I select the "Reader" grid cell
    And I select "Admin" from ext combo "vms-scenario-permission-level-combo"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And "Atticus Finch" should be an admin for scenario "Test"

  Scenario: As a reader, view a scenario and confirm that you can't do anything
    Given I have the scenarios "Test"
    And "Bartleby Scrivener" is a reader for scenario "Test"
    Given the following sites exist:
          | name                | address                                 | lat       | lng       | status | scenario |
          | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | true     |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    And the following entities exist:
      | Role | Chief Veterinarian     |
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    And role "Chief Veterinarian" site "Immunization Center" is assigned the qualification "bilingual" on scenario "Test"
    And "Bartleby Scrivener" is assigned to "Immunization Center" for scenario "Test"
    And a team "Lawyerin Team" assigned to site "Immunization Center" scenario "Test" with
      | Atticus Finch |
    When I sign out
    And I log in as "bartleby@example.com"
    And I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row
    And I click vms-row-button "Open Scenario"
    Then the "Command Center - Test" tab should be open
    And I should not see "New Site"
    When I right click on site "Immunization Center"
    Then I should not see the following ext menu items:
      | name       |
      | Edit       |
      | Remove     |
      | Deactivate |
      | Activate   |
    And I should see the following ext menu items:
      | name                  |
      | Show Site Information |
    And I click x-menu-item "Show Site Information"
    Then the info window for "Immunization Center" should be open
    And I right click on the info window staff "Bartleby Scrivener"
    Then I should not see the following ext menu items:
      | name                |
      | Remove Staff Member |
    When I click x-accordion-hd "Roles" within ".site_info_window"
    And I right click on the info window role "Chief Veterinarian"
    Then I should not see the following ext menu items:
      | name        |
      | Remove Role |
    When I click x-accordion-hd "Inventory" within ".site_info_window"
    And I right click on the info window item "Surgical Mask"
    Then I should not see the following ext menu items:
      | name           |
      | Edit Inventory |
    When I close the open site info window
    When I click x-accordion-hd "PODs/Inventories"
    Then I should not see "New POD/Inventory"
    When I right click on the "Medical POD" inventory
    Then I should not see the following ext menu items:
      | name   |
      | Edit   |
      | Delete |
#TODO: cannot find View Details   
    And I suspend cucumber
    When I click x-menu-item "View Details"
    Then the "View POD/Inventory" window should be open
    And I should see "Close" within ".x-btn"
    And I should not see "Save" within ".x-btn"
    When I close the active ext window
    And I click x-accordion-hd "Roles"
    Then I should not see "Add Role"
    When right click the "Chief Veterinarian" role
    Then I should not see the following ext menu items:
      | name   |
      | Edit   |
      | Remove |
    When I click x-menu-item "Show Details"
    Then the "View Role Details" window should be open
    And I should not see "Save" within ".x-btn"
    And I should see "Close" within ".x-btn"
    When I close the active ext window
    And I click x-accordion-hd "Qualifications"
    Then I should not see "Add Qualification"
    When I right click qualification "bilingual"
    Then I should not see the following ext menu items:
      | name   |
      | Edit   |
      | Remove |
    When I click x-accordion-hd "Teams"
    Then I should not see "New Team"

    When I right click on the team "Lawyerin Team"
    Then I should not see the following ext menu items:
      | name   |
      | Edit   |
      | Remove |
    When I click x-accordion-hd "Staff"
    Then I should not see "Add Staff"
    When I right click on staff member "Bartleby Scrivener"
    Then I should not see the following ext menu items:
      | name   |
      | Edit   |
      | Remove |
    When I click x-menu-item "Staff Details"
    Then the "View Staff Details" window should be open
    And I should not see "Save" within ".x-btn"
    And I should see "Close" within ".x-btn"

  Scenario: As an admin, view a scenario and perform a basic action
    Given I have the scenarios "Test"
    And "Atticus Finch" is an admin for scenario "Test"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row
    And I click vms-row-button "Open Scenario"
    Then the "Command Center - Test" tab should be open
    When I click x-accordion-hd "Site"
    Then I should see "New Site"
    When I drag the "New Site" site to the map at "31.347573", "-94.71391"
    And I fill in "Name" with "Immunization Center"
    Then the "Address" field should contain "1303 Atkinson Dr, Lufkin, TX 75901, USA"
    When I press "Save"
    Then I should see "Immunization Center" in grid row 2 within ".siteGrid"
    And the site "Immunization Center" should exist at "1303 Atkinson Dr, Lufkin, TX 75901, USA", "31.347573", "-94.71391"