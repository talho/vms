@ext @vms
Feature: Test site creation for scenarios

  In order to create an execution template with different sites
  As a user
  I want to be able to create, edit, activate, and delete sites

  Background:
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County | vms |
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"

  Scenario Outline: Create a new site
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    When I drag the "New Site" site to the map at "<lat>", "<lng>"
    And I fill in "Name" with "<name>"
    Then the "Address" field should contain "<address>"
    When I press "Save"
    Then I should see "<name>" in grid row 2 within ".siteGrid"
    And the site "<name>" should exist at "<address>", "<lat>", "<lng>"

    Examples:
    | name                | address                                 | lat                 | lng              |
    | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        |
    | Malawi Expansion    | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 |

  Scenario: Copy a site from an active site
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    When I drag the "Immunization Center" site to the map at "-13.962475513490757", "33.7866090623169"
    And I fill in "Name" with "Immunization Center 2"
    Then the "Address" field should contain "Kenyatta, Lilongwe, Malawi"
    When I press "Save"
    Then I should see "Immunization Center 2" in grid row 3 within ".siteGrid"
    And the site "Immunization Center 2" should exist at "Kenyatta, Lilongwe, Malawi", "-13.962475513490757", "33.7866090623169"

  Scenario: Create a site from a "template"
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status   | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | inactive |          |
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    When I drag the "New Site" site to the map at "-13.962475513490757", "33.7866090623169"
    And I fill in "Name" with "Immunization Center"
    And I select "Immunization Center" from ext combo "Name"
    Then the "Address" field should contain "1303 Atkinson Dr, Lufkin, TX 75901, USA"
    When I press "Save"
    Then I should see "Immunization Center" in grid row 2 within ".siteGrid"
    And the site "Immunization Center" should exist at "1303 Atkinson Dr, Lufkin, TX 75901, USA", "31.347573", "-94.71391"

  Scenario: Create a site and change the address
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    When I drag the "New Site" site to the map at "-13.962475513490757", "33.7866090623169"
    And I fill in "Name" with "Immunization Center"
    Then the "Address" field should contain "Kenyatta, Lilongwe, Malawi"
    When I fill in "Address" with "1303 Atkinson Dr, Lufkin, TX 75901, USA"
    And I press "Save"
    Then I should see "Immunization Center" in grid row 2 within ".siteGrid"
    And the site "Immunization Center" should exist at "1303 Atkinson Dr, Lufkin, TX 75901, USA", "31.347573", "-94.71391"

  Scenario: Activate an existing site
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status   | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | inactive | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    When I drag the "Immunization Center" site to the map at "-13.962475513490757", "33.7866090623169"
    Then the "Name" field should contain "Immunization Center"
    And the "Address" field should contain "1303 Atkinson Dr, Lufkin, TX 75901, USA"
    When I press "Save"
    Then I should see "Immunization Center" in grid row 2 within ".siteGrid"
    And the site "Immunization Center" should exist at "1303 Atkinson Dr, Lufkin, TX 75901, USA", "31.347573", "-94.71391"
    And the site "Immunization Center" should be "active" for scenario "Test"

  Scenario: Edit a site to change its name and address
    Given the following sites exist:
      | name                | address                    | lat                 | lng              | status | scenario |
      | Immunization Center | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    And I right click on site "Immunization Center"
    And I click x-menu-item "Edit"
    Then the "Edit Site" window should be open
    When I fill in "Name" with "Immunized Quarantine"
    And I fill in "Address" with "1303 Atkinson Dr, Lufkin, TX 75901, USA"
    And I press "Save"
    Then I should see "Immunized Quarantine" in grid row 2 within ".siteGrid"
    And the site "Immunized Quarantine" should exist at "1303 Atkinson Dr, Lufkin, TX 75901, USA", "31.347573", "-94.71391"
    And the site "Immunized Quarantine" should be "active" for scenario "Test"

  Scenario: Deactivate a site
    Given the following sites exist:
      | name                | address                    | lat                 | lng              | status | scenario |
      | Immunization Center | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    And I right click on site "Immunization Center"
    And I click x-menu-item "Deactivate"
    And I wait for the "Loading..." mask to go away
    And the site "Immunization Center" should be "inactive" for scenario "Test"

  Scenario: Delete a site
    Given the following sites exist:
      | name                | address                    | lat                 | lng              | status | scenario |
      | Immunization Center | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    And I right click on site "Immunization Center"
    And I click x-menu-item "Remove"
    Then I should not see "Immunization Center" in grid row 2