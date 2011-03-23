@ext @vms
Feature: VMS Teams

  In order to group common sets of volunteers
  As a User
  I would like to be able to create on-the-fly teams and manage/assign them

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin  | Dallas County |
      | Atticus Finch      | atticus@example.com  | Admin  | Potter County |
    And delayed jobs are processed
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"
    And the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |

  Scenario: Create a team
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I fill in "Team Name" with "Lawyerin Team"
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" audience

  Scenario: Create a team that is templated
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I fill in "Team Name" with "Lawyerin Team"
    And I fill in "User" with "Bartleby"
    And I select "Bartleby Scrivener" from ext combo "User"
    And I check "Save as template"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" audience
    And a team should exist named "Lawyerin Team" with 1 sub audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" team

  Scenario: Assign a team by importing a team template
    Given a team "Lawyerin Team" with
      | Bartleby Scrivener |
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I press "Import Team"
    Then the "Select Group" window should be open
    When I select the "Lawyerin Team" grid row within ".vms_group_import_selection_grid"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".vms_import_teams_preview"
    And I should see "Atticus Finch" in grid row 2 within ".vms_import_teams_preview"
    When I press "Import" within ".import_group_window"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" audience
    And "Atticus Finch" should be a member of the "Lawyerin Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" team
    And "Atticus Finch" should be a member of the "Lawyerin Team" team

  Scenario: Assign a team by importing a group
    Given the following groups for "admin@dallas.gov" exist:
      | Lawyerin Group | | | bartleby@example.com, atticus@example.com | Personal | Dallas County |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I press "Import Team"
    Then the "Select Group" window should be open
    When I select the "Lawyerin Group" grid row
    Then I should see "Bartleby Scrivener" in grid row 1 within ".vms_import_teams_preview"
    And I should see "Atticus Finch" in grid row 2 within ".vms_import_teams_preview"
    When I press "Import" within ".import_group_window"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I fill in "Team Name" with "Lawyerin Team"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" audience
    And "Atticus Finch" should be a member of the "Lawyerin Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Group" group
    And "Atticus Finch" should be a member of the "Lawyerin Group" group

  Scenario: Assign a team by importing a team template and add a user
    Given a team "Lawyerin Team" with
      | Bartleby Scrivener |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I press "Import Team"
    Then the "Select Group" window should be open
    When I select the "Lawyerin Team" grid row
    Then I should see "Bartleby Scrivener" in grid row 1 within ".vms_import_teams_preview"
    When I press "Import" within ".import_group_window"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" audience
    And "Atticus Finch" should be a member of the "Lawyerin Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" team
    And "Atticus Finch" should not be a member of the "Lawyerin Team" team

  Scenario: Assign a team by importing a group and add a user
    Given the following groups for "admin@dallas.gov" exist:
      | Lawyerin Group | | | bartleby@example.com | Personal | Dallas County |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I press "Import Team"
    Then the "Select Group" window should be open
    When I select the "Lawyerin Group" grid row
    Then I should see "Bartleby Scrivener" in grid row 1 within ".vms_import_teams_preview"
    When I press "Import" within ".import_group_window"
    When I fill in "Team Name" with "Lawyerin Team"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" audience
    And "Atticus Finch" should be a member of the "Lawyerin Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Group" group
    And "Atticus Finch" should not be a member of the "Lawyerin Group" group

  Scenario: Assign a team by importing a team template and remove a user
    Given a team "Lawyerin Team" with
      | Bartleby Scrivener |
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "New Team (drag to site)" to the "Malawi" site
    Then the "Create Team" window should be open
    When I press "Import Team"
    Then the "Select Group" window should be open
    When I select the "Lawyerin Team" grid row
    Then I should see "Bartleby Scrivener" in grid row 1 within ".vms_import_teams_preview"
    And I should see "Atticus Finch" in grid row 2 within ".vms_import_teams_preview"
    When I press "Import" within ".import_group_window"
    Then I should see "Bartleby Scrivener" in grid row 1 within ".user_selection_grid"
    Then I should see "Atticus Finch" in grid row 2 within ".user_selection_grid"
    And I click remove_btn on the "Bartleby Scrivener" grid row within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should not be a member of the "Lawyerin Team" audience
    And "Atticus Finch" should be a member of the "Lawyerin Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" team
    And "Atticus Finch" should be a member of the "Lawyerin Team" team

  Scenario: Modify a team
    Given a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I right click on the team "Lawyerin Team"
    And I click x-menu-item "Edit"
    Then the "Modify Team" window should be open
    When I fill in "Team Name" with "Law Team"
    And I click remove_btn on the "Bartleby Scrivener" grid row within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Law Team" in grid row 2 within ".vms_teams_grid"
    And "Law Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should not be a member of the "Law Team" audience
    And "Atticus Finch" should be a member of the "Law Team" audience

  Scenario: Modify a team that was templated
    Given a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" templated with
      | Bartleby Scrivener |
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I right click on the team "Lawyerin Team"
    And I click x-menu-item "Edit"
    Then the "Modify Team" window should be open
    When I fill in "Team Name" with "Law Team"
    And I click remove_btn on the "Bartleby Scrivener" grid row within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Law Team" in grid row 2 within ".vms_teams_grid"
    And "Law Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should not be a member of the "Law Team" audience
    And "Atticus Finch" should be a member of the "Law Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Team" team
    And "Atticus Finch" should be a member of the "Lawyerin Team" team

  Scenario: Modify a team that was imported from a group
    Given the following groups for "admin@dallas.gov" exist:
      | Lawyerin Group | | | bartleby@example.com | Personal | Dallas County |
    Given a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    And team "Lawyerin Team" was derived from group "Lawyerin Group"
    When I right click on the team "Lawyerin Team"
    And I click x-menu-item "Edit"
    Then the "Modify Team" window should be open
    When I fill in "Team Name" with "Law Team"
    And I click remove_btn on the "Bartleby Scrivener" grid row within ".user_selection_grid"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Law Team" in grid row 2 within ".vms_teams_grid"
    And "Law Team" should be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should not be a member of the "Law Team" audience
    And "Atticus Finch" should be a member of the "Law Team" audience
    And "Bartleby Scrivener" should be a member of the "Lawyerin Group" group
    And "Atticus Finch" should not be a member of the "Lawyerin Group" group

  Scenario: Move a team
    Given a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" with
      | Bartleby Scrivener |
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I drag team "Lawyerin Team" to the "Immunization Center" site
    Then the "Move Team" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then I should see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should be a team assigned to site "Immunization Center", scenario "Test"

  Scenario: Delete a team
    Given a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" with
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I right click on the team "Lawyerin Team"
    And I click x-menu-item "Remove"
    Then the "Remove Team" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then I should not see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should not be a team assigned to site "Malawi", scenario "Test"

  Scenario: Delete a team that was templated
    Given a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" templated with
      | Atticus Finch      |
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I right click on the team "Lawyerin Team"
    And I click x-menu-item "Remove"
    Then the "Remove Team" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then I should not see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should not be a team assigned to site "Malawi", scenario "Test"
    And "Atticus Finch" should be a member of the "Lawyerin Team" team

  Scenario: Delete a team that was imported from a team template or group
    Given the following groups for "admin@dallas.gov" exist:
      | Lawyerin Group | | | bartleby@example.com | Personal | Dallas County |
    And a team "Lawyerin Team" assigned to site "Malawi" scenario "Test" with
      | Atticus Finch |
    And team "Lawyerin Team" was derived from group "Lawyerin Group"
    When I open the "Test" scenario
    And I click x-accordion-hd "Teams"
    When I right click on the team "Lawyerin Team"
    And I click x-menu-item "Remove"
    Then the "Remove Team" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then I should not see "Lawyerin Team" in grid row 2 within ".vms_teams_grid"
    And "Lawyerin Team" should not be a team assigned to site "Malawi", scenario "Test"
    And "Bartleby Scrivener" should be a member of the "Lawyerin Group" group