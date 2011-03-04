@ext @vms
Feature: Modify Roles for VMS Sites

  In order to specify which roles I want to be filled at each site
  As a user
  I want to be able to select roles and assign them to a site instance

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"

  Scenario: Add a role to the site using "New Role"
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When I drag "Add Role" to the "Immunization Center" site
    Then the "Modify Roles" window should be open
    When I fill in "Select Role" with "Chief"
    And I select "Chief Veterinarian" from ext combo "Select Role"
    And I press "Add Role"
    Then I should see "Chief Veterinarian" in grid row 1 within ".modifyRoleGrid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Chief Veterinarian" in grid row 2 within ".roleGrid"
    And the "Immunization Center" site for scenario "Test" should have 1 "Chief Veterinarian" role

  Scenario: Add a role to a site that already has a Role with "New Role"
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    Given the site "Immunization Center" for scenario "Test" has the role "Border Health Director"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When I drag "Add Role" to the "Immunization Center" site
    Then the "Modify Roles" window should be open
    When I fill in "Select Role" with "Chief"
    And I select "Chief Veterinarian" from ext combo "Select Role"
    And I press "Add Role"
    Then I should see "Chief Veterinarian" in grid row 1 within ".modifyRoleGrid"
    Then I should see "Border Health Director" in grid row 2 within ".modifyRoleGrid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 1 "Chief Veterinarian" role

  Scenario: Add a role to a site that doesn't have a role from an existing role
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
      | Malawi Center       | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi Center" for scenario "Test" has the role "Border Health Director"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When I drag "Border Health Director" to the "Immunization Center" site
    Then the "Modify Roles" window should be open
    And I press "Add Role"
    Then I should see "Border Health Director" in grid row 1 within ".modifyRoleGrid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 1 "Border Health Director" role

  Scenario: Modify the roles on a site after cancelling adding with "New Role"
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    Given the site "Immunization Center" for scenario "Test" has the role "Border Health Director"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When I drag "Add Role" to the "Immunization Center" site
    Then the "Modify Roles" window should be open
    When I press "Cancel" within ".addRolePanel"
    And I click decrease_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "1" in grid row 1 column 3 within ".modifyRoleGrid"
    When I click increase_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "2" in grid row 1 column 3 within ".modifyRoleGrid"
    When I click decrease_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "1" in grid row 1 column 3 within ".modifyRoleGrid"
    When I click increase_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "2" in grid row 1 column 3 within ".modifyRoleGrid"
    When I click remove_role on the "Chief Veterinarian" grid row within ".modifyRoleGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 2 "Border Health Director" role
    And the "Immunization Center" site for scenario "Test" should not have the "Chief Veterinarian" role

  Scenario: Modify the roles on a site using edit on the group header
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    Given the site "Immunization Center" for scenario "Test" has the role "Border Health Director"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When right click the "Immunization Center" role group header
    And I click x-menu-item "Edit"
    Then the "Modify Roles" window should be open
    When I click increase_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "2" in grid row 1 column 3 within ".modifyRoleGrid"
    When I click remove_role on the "Chief Veterinarian" grid row within ".modifyRoleGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 2 "Border Health Director" role
    And the "Immunization Center" site for scenario "Test" should not have the "Chief Veterinarian" role

  Scenario: Modify and remove the roles on a site using edit on a role
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    Given the site "Immunization Center" for scenario "Test" has the role "Border Health Director"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When right click the "Chief Veterinarian" role
    And I click x-menu-item "Edit"
    Then the "Modify Roles" window should be open
    When I click increase_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "2" in grid row 1 column 3 within ".modifyRoleGrid"
    When I click remove_role on the "Chief Veterinarian" grid row within ".modifyRoleGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 2 "Border Health Director" role
    And the "Immunization Center" site for scenario "Test" should not have the "Chief Veterinarian" role

  Scenario: Remove a role from a site using remove on that role
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    Given the site "Immunization Center" for scenario "Test" has the role "Border Health Director"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    When right click the "Chief Veterinarian" role
    And I click x-menu-item "Remove"
    Then the "Modify Roles" window should be open
    When I click increase_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "2" in grid row 1 column 3 within ".modifyRoleGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 2 "Border Health Director" role
    And the "Immunization Center" site for scenario "Test" should not have the "Chief Veterinarian" role