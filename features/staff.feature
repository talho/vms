@ext @vms
Feature: Test staff interactions with site

  In order to assign and manage users between sites in a scenario
  As a VMS User
  I want to be able to mass-manage users for those sites as well as move and remove users via the interface

  Background:
    Given the following users exist:
      | Ad min             | admin@dallas.gov     | Admin | Dallas County | vms |
      | Bartleby Scrivener | bartleby@example.com | Admin | Dallas County | vms |
      | Atticus Finch      | atticus@example.com  | Admin | Potter County | vms |
    And delayed jobs are processed
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"
    And the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |

  Scenario: Add user by dragging new user over
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Add User (drag to site)" to "Malawi"
    Then the "Modify Staff" window should be open
    When I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Bartleby Scrivener" in grid row 2 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"

  Scenario: Add user to site with existing user by dragging new user
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Add User (drag to site)" to "Malawi"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Bartleby Scrivener" in grid row 2 within ".staffGrid"
    And I should see "Atticus Finch" in grid row 3 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should be assigned to "Malawi" for scenario "Test"

  Scenario: Add user to site with existing user by using right-click -> edit on the group
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I right click on staff group "Malawi"
    And I click x-menu-item "Edit"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Atticus Finch" in grid row 3 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should be assigned to "Malawi" for scenario "Test"

  Scenario: Add user to site with existing user by using right-click -> edit on the user
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I right click on staff member "Bartleby Scrivener"
    And I click x-menu-item "Edit"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Atticus Finch" in grid row 3 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should be assigned to "Malawi" for scenario "Test"

  Scenario: Remove user from site via right-click -> edit on the group
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I right click on staff group "Malawi"
    And I click x-menu-item "Edit"
    And I click remove_btn on the "Bartleby Scrivener" grid row within ".user_selection_grid"
    When I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    And I click remove_btn on the "Atticus Finch" grid row within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see "Atticus Finch" in grid row 3 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should not be assigned to "Malawi" for scenario "Test"

  Scenario: Remove user from site via right-click -> remove on the user
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I right click on staff member "Bartleby Scrivener"
    And I click x-menu-item "Remove"
    Then the "Remove User" window should be open
    When I press "No"
    Then I should see "Bartleby Scrivener" in grid row 2 within ".staffGrid"
    When I right click on staff member "Atticus Finch"
    And I click x-menu-item "Remove"
    And I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should not be assigned to "Malawi" for scenario "Test"

  Scenario: Move user using the modify user window via dragging New User
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Add User (drag to site)" to "Immunization Center"
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    Then the "Move User" window should be open
    When I press "No"
    Then I should not see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    When I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then the "Move User" window should be open
    When I press "Yes"
    Then I should see "Atticus Finch" in grid row 1 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see "Atticus Finch" in grid row 3 within ".staffGrid"
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should not be assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" should be assigned to "Immunization Center" for scenario "Test"

  Scenario: Move user to a different site via drag
    And the following sites exist:
      | name | address                                 | lat       | lng       | status | scenario |
      | Jail | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Bartleby Scrivener" to "Jail"
    And I wait for the "Loading..." mask to go away
    Then I should see "Bartleby Scrivener" in grid row 2 within ".staffGrid"
    And "Bartleby Scrivener" should not be assigned to "Malawi" for scenario "Test"
    And "Bartleby Scrivener" should be assigned to "Jail" for scenario "Test"
