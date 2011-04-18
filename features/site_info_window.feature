@ext @vms
Feature: Site Info Window

  In order to check the status of my sites on the map
  As a scenario viewer
  I want to be able to click on a map marker and see a breakdown of the site information

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin, Border Health Director | Dallas County |
      | Atticus Finch      | atticus@example.com  | Admin, Chief Veterinarian     | Potter County |
    And delayed jobs are processed
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"

  Scenario Outline: Display Site Information
    Given the site "<site_name>" exists for scenario "Test"
    And inventories "<inventory_name>" are assigned to "<site_name>" for scenario "Test"
    And staff "<staff_list>" are assigned to "<site_name>" for scenario "Test"
    And team "<team_name>" is assigned to "<site_name>" for scenario "Test"
    And roles "<role_list>" are assigned to "<site_name>" for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "<site_name>"
    Then the info window for "<site_name>" should be open
    When I wait for the "Loading..." mask to go away
    Then I should see staff information for "<staff_list>"
    Then I should see staff information for "<team_name>"
    When I click x-accordion-hd "Roles" within ".site_info_window"
    Then I should see role information for "<role_list>"
    When I click x-accordion-hd "Inventory" within ".site_info_window"
    Then I should see inventory information for "<inventory_name>"

    Examples:
    | site_name | staff_list     | team_name | role_list            | inventory_name   |
    | Malawi    | Just Atticus   |           |                      |                  |
    | Malawi    | Atticus & Team | Bart Team |                      |                  |
    | Malawi    | Atticus & Bart |           |                      |                  |
    | Malawi    |                |           | Chief Vet            |                  |
    | Malawi    |                |           | Vet & BHD            |                  |
    | Malawi    |                |           |                      | One Item         |
    | Malawi    |                |           |                      | Many Items       |
    | Malawi    |                |           |                      | Many Inventories |
    | Malawi    |                |           |                      | Out of Items     |
    | Malawi    | Just Atticus   |           | Filled Vet           | One Item         |
    | Malawi    | Atticus & Bart |           | Filled Vet & BHD     |                  |
    | Malawi    | Just Atticus   |           | Unfilled BHD         |                  |
    | Malawi    | Just Atticus   |           | Mixed Fill Vet & BHD |                  |

  Scenario: Ensure only one info window can be open at once
    Given the site "Malawi" exists for scenario "Test"
    And the site "Immunization Center" exists for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "Malawi"
    Then the info window for "Malawi" should be open
    When I click the marker for "Immunization Center"
    Then the info window for "Immunization Center" should be open
    And the info window for "Malawi" should not be open

  Scenario: Edit staff from site info window
    Given the site "Malawi" exists for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "Malawi"
    And I click x-tool-gear "" within ".site_info_window .staff_grid"
    Then the "Modify Staff" window should be open
    When I wait for the "Loading..." mask to go away
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see staff information for "Just Atticus"

  Scenario: Remove staff member from site info window
    Given the site "Malawi" exists for scenario "Test"
    And staff "Just Atticus" are assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "Malawi"
    And I right click on the info window staff "Atticus Finch"
    And I click x-menu-item "Remove"
    And I press "Yes"
    And I wait for the "Loading..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see staff information for "Just Atticus"

  Scenario: Edit roles from site info window
    Given the site "Malawi" exists for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "Malawi"
    And I click x-tool-gear "" within ".site_info_window .roles_grid"
    Then the "Modify Roles" window should be open
    And I press "Add New Role"
    When I fill in "Select Role" with "Chief"
    And I select "Chief Veterinarian" from ext combo "Select Role"
    And I press "Add Role"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And I wait for the "Loading..." mask to go away
    When I click x-accordion-hd "Roles" within ".site_info_window"
    Then I should see role information for "Chief Vet"

  Scenario: Remove role from site info window
    Given the site "Malawi" exists for scenario "Test"
    And roles "Cheif Vet" are assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "Malawi"
    And I click x-accordion-hd "Roles" within ".site_info_window"
    And I right click on the info window role "Chief Veterinarian"
    And I click x-menu-item "Remove"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And I wait for the "Loading..." mask to go away
    When I click x-accordion-hd "Roles" within ".site_info_window"
    Then I should not see role information for "Chief Vet"

  Scenario: Edit inventory from site info window
    Given the site "Malawi" exists for scenario "Test"
    And inventories "Many Inventories" are assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click the marker for "Malawi"
    And I click x-accordion-hd "Inventory" within ".site_info_window"
    And I right click on the info window item "Item 1"
    And I click x-menu-item "Edit"
    Then the "Edit POD/Inventory" window should be open
    When I click increaseItem on the "Item 1" grid row within ".itemGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see inventory information for "Modified Many Inventories"
