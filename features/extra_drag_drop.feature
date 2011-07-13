@ext @vms
Feature: Drag drop within a tool grid

  In order to more quickly reorgaize assigned users, roles, etc
  As a user
  I want to be able to drag drop within a tool grid in addition to dragging to the map

  Background:
    Given the following users exist:
      | Ad min             | admin@dallas.gov     | Admin | Dallas County | vms |
      | Ad min             | admin@dallas.gov     | Admin | Dallas County |     |
      | Bartleby Scrivener | bartleby@example.com | Admin | Dallas County | vms |
      | Atticus Finch      | atticus@example.com  | Admin | Potter County | vms |
    And delayed jobs are processed
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"
    And the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |

  Scenario: Drag inventory to a different site
    Given the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | false    |
      | Other POD   | Malawi              | Test     | DSHS   | pod  | false    |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag "Medical POD" to "Other POD" in the inventory grid
    Then the "Move or Copy POD/Inventory" window should be open
    When I press "Copy"
    Then the "Copy POD/Inventory" window should be open
    When I press "Cancel" within ".inventoryWindow"
    And I drag "Medical POD" to "Other POD" in the inventory grid
    When I press "Move"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And "Medical POD" should exist on site "Malawi" for scenario "Test" with source "DSHS" and type "pod"
    And the site "Immunization Center" for scenario "Test" should have no inventories

  Scenario: Dragging inventory to the "new inventory" area should fail gracefully
    Given the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | false    |
      | Other POD   | Malawi              | Test     | DSHS   | pod  | false    |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag "Medical POD" to "New POD/Inventory" in the inventory grid
    Then there should be no open windows

  Scenario: Drag role to a different site in the same grid
    Given the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And the site "Malawi" for scenario "Test" has the role "Border Health Director"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    And I drag "Border Health Director" to "Chief Veterinarian" in the roles grid
    Then the "Modify Roles" window should be open
    And I wait for the "Loading..." mask to go away
    And I press "Add Role"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 1 "Border Health Director" role

  Scenario: Drag role to a different site in the site grid
    Given the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And the site "Malawi" for scenario "Test" has the role "Border Health Director"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    And I drag "Border Health Director" (roles) to the "Immunization Center" site
    Then the "Modify Roles" window should be open
    And I wait for the "Loading..." mask to go away
    And I press "Add Role"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Immunization Center" site for scenario "Test" should have 1 "Border Health Director" role

  Scenario: Drag role to the same site in the site grid should edit
    Given the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And the site "Malawi" for scenario "Test" has the role "Border Health Director"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    And I drag "Border Health Director" (roles) to the "Malawi" site
    Then the "Modify Roles" window should be open
    And I wait for the "Loading..." mask to go away
    When I click increase_count on the "Border Health Director" grid row within ".modifyRoleGrid"
    Then I should see "2" in grid row 1 column 3 within ".modifyRoleGrid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And the "Malawi" site for scenario "Test" should have 2 "Border Health Director" roles

  Scenario: Dragging role to the "new role" area should fail gracefully
    Given the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And the site "Malawi" for scenario "Test" has the role "Border Health Director"
    When I open the "Test" scenario
    And I click x-accordion-hd "Roles"
    And I drag "Border Health Director" to "Add Role" in the roles grid
    Then there should be no open windows

  Scenario: Drag qualification to a different site in the same grid
    Given site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    And site "Immunization Center" is assigned the qualification "very strong" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag "bilingual" to "very strong" in the quals grid
    Then the "Copy Qualification" window should be open
    When the "Qualification" field should contain "bilingual"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And "bilingual" should be a qualification for site "Malawi" on scenario "Test"
    And "bilingual" should be a qualification for site "Immunization Center" on scenario "Test"

  Scenario: Drag qualification to a different site in the site grid
    Given site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag "bilingual" (quals) to the "Immunization Center" site
    Then the "Copy Qualification" window should be open
    And I wait for the "Loading..." mask to go away
    When the "Qualification" field should contain "bilingual"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And "bilingual" should be a qualification for site "Immunization Center" on scenario "Test"

  Scenario: Drag qualification to the same site in the site grid should fail gracefully
    Given site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag "bilingual" (quals) to the "Malawi" site
    Then there should be no open windows

  Scenario: Dragging qualification to the "new qualification" area should fail gracefully
    Given site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    And site "Immunization Center" is assigned the qualification "very strong" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag "bilingual" to "Add Qualification" in the quals grid
    Then there should be no open windows

  Scenario: Drag team to a different site in the same grid
    Given a team "Scribin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
    Given a team "Lawyerin Team" assigned to site "Immunization Center" scenario "Test" with
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag "Scribin Team" to "Lawyerin Team" in the teams grid
    Then the "Move Team" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    And "Scribin Team" should be a team assigned to site "Immunization Center", scenario "Test"

  Scenario: Drag team to a different site in the site grid
    Given a team "Scribin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag "Scribin Team" (teams) to the "Immunization Center" site
    Then the "Move Team" window should be open
    And I wait for the "Loading..." mask to go away
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    And "Scribin Team" should be a team assigned to site "Immunization Center", scenario "Test"

  Scenario: Drag team to the same site in the site grid should fail gracefully
    Given a team "Scribin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag "Scribin Team" (teams) to the "Malawi" site
    Then there should be no open windows

  Scenario: Dragging team to the "new team" area should fail gracefully
    Given a team "Scribin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag "Scribin Team" to "New Team" in the teams grid
    Then there should be no open windows

  Scenario: Drag staff to a different site in the same grid
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Immunization Center" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag "Bartleby Scrivener" to "Atticus Finch" in the staff grid
    And I wait for the "Loading..." mask to go away
    And "Bartleby Scrivener" should not be assigned to "Malawi" for scenario "Test"
    And "Bartleby Scrivener" should be assigned to "Immunization Center" for scenario "Test"

  Scenario: Drag staff to a different site in the site grid
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag "Bartleby Scrivener" (staff) to the "Immunization Center" site
    And I wait for the "Loading..." mask to go away
    Then I should see "Bartleby Scrivener" in grid row 2 within ".staffGrid"
    And "Bartleby Scrivener" should not be assigned to "Malawi" for scenario "Test"
    And "Bartleby Scrivener" should be assigned to "Immunization Center" for scenario "Test"

  Scenario: Drag staff to the same site in the site grid should edit
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag "Bartleby Scrivener" (staff) to the "Malawi" site
    And I wait for the "Loading..." mask to go away
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Atticus Finch" in grid row 3 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should be assigned to "Malawi" for scenario "Test"

  Scenario: Dragging staff to the "new staff" area should fail gracefully
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag "Bartleby Scrivener" to "Add User" in the staff grid
    Then there should be no open windows