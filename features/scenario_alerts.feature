@ext @vms
Feature: Send alerts for different actions on scenarios

  In order to keep my volunteers in line
  As a user
  I would like to send regular alert updates informing them of modifications to the current scenario.

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

  Scenario: Executing a scenario
    Given the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And the site "Immunization Center" for scenario "Test" has the role "Border Health Director"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    And the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    And the user "Bartleby Scrivener" with the email "bartleby@example.com" has the role "Chief Veterinarian" in "Dallas County"
    And the user "Atticus Finch" with the email "atticus@example.com" has the role "Chief Veterinarian" in "Potter County"
    # assign a user or two to a site
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test is now executing" message "Scenario Test is now executing. You are currently assigned to site Malawi at Kenyatta, Lilongwe, Malawi"
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test is looking for volunteers"
    When "Bartleby Scrivener" has responded to a VmsExecutionAlert with title "Scenario Test is looking for volunteers" with 3
    And backgroundrb has processed the vms alert responses
    And "Bartleby Scrivener" should be assigned to "Immunization Center" for scenario "Test"
    Then "bartleby@example.com" should receive a VMS email with title "You have been assigned" message "You have been selected as a volunteer. You have been assigned the role Chief Veterinarian at:\nImmunization Center\n1303 Atkinson Dr, Lufkin, TX 75901, USA"

  Scenario: Pausing a scenario with default alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-btn "Pause"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been paused."
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test has been paused."

  Scenario: Pausing a scenario with custom alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-btn "Pause"
    And I check "Customize alert notification message"
    And I fill in "Alert Message" with "Test Alert"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been paused." message "Test Alert"
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test has been paused." message "Test Alert"

  Scenario: Pausing a scenario with custom users
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-btn "Pause"
    And I click x-tab-strip-text "Alert Audience"
    And I click remove_btn on the "Bartleby Scrivener" grid row
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been paused."
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Resuming a scenario with default alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "paused"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been resumed."
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test has been resumed."

  Scenario: Resuming a scenario with custom alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "paused"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I check "Customize alert notification message"
    And I fill in "Alert Message" with "Test Alert"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been resumed." message "Test Alert"
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test has been resumed." message "Test Alert"

  Scenario: Resuming a scenario with custom users
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "paused"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I click x-tab-strip-text "Alert Audience"
    And I click remove_btn on the "Bartleby Scrivener" grid row
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been resumed."
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Stopping a scenario with default alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-btn "End Scenario"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been stopped."
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test has been stopped."

  Scenario: Stopping a scenario with custom alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-btn "End Scenario"
    And I check "Customize alert notification message"
    And I fill in "Alert Message" with "Test Alert"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been stopped." message "Test Alert"
    And "bartleby@example.com" should receive a VMS email with title "Scenario Test has been stopped." message "Test Alert"

  Scenario: Stopping a scenario with custom users
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-btn "End Scenario"
    And I click x-tab-strip-text "Alert Audience"
    And I click remove_btn on the "Bartleby Scrivener" grid row
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Scenario Test has been stopped."
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Sending a custom alert
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Alert Staff"
    And I fill in "Alert Message" with "Test Alert"
    And I press "OK"
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Custom Alert" message "Test Alert"
    And "bartleby@example.com" should receive a VMS email with title "Custom Alert" message "Test Alert"

  Scenario: Sending a custom alert with custom users
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Alert Staff"
    And I fill in "Alert Message" with "Test Alert"
    And I click x-tab-strip-text "Alert Audience"
    And I click remove_btn on the "Bartleby Scrivener" grid row
    And I press "OK"
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Custom Alert"
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Deactivate a site
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    And I right click on site "Malawi"
    And I click x-menu-item "Deactivate"
    And I wait for the "Loading..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Site Malawi deactivated" message "The site Malawi located at Kenyatta, Lilongwe, Malawi has been deactivated. You were assigned to that site. You will be notified when the site is reactivated."
    And "bartleby@example.com" should receive a VMS email with title "Site Malawi deactivated"

  Scenario: Activate a site
    Given the following sites exist:
      | name         | address                         | lat | lng | status   | scenario |
      | Inactiveness | 2600 McHale Ct, Austin, Tx, USA | -13 | 33  | inactive | Test     |
    And "Bartleby Scrivener" is assigned to "Inactiveness" for scenario "Test"
    And "Atticus Finch" is assigned to "Inactiveness" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    When I drag the "Inactiveness" site to the map at "-13.962475513490757", "33.7866090623169"
    When I press "Save"
    And I wait for the "Loading..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "Site Inactiveness activated" message "The site Inactiveness located at 2600 McHale Ct, Austin, Tx, USA has been activated. You are assigned to that site and should resume your duties."
    And "bartleby@example.com" should receive a VMS email with title "Site Inactiveness activated"

  Scenario: Add a user
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Add User (drag to site)" to "Malawi"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "You have been assigned to a site" message "You have been assigned to Malawi at Kenyatta, Lilongwe, Malawi. Please make your way there now, if you are not already, and check-in when you arrive."
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Move a user
    Given "Bartleby Scrivener" is assigned to "Immunization Center" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Bartleby Scrivener" to "Malawi"
    And I wait for the "Loading..." mask to go away
    And delayed jobs are processed
    Then "bartleby@example.com" should receive a VMS email with title "You have been assigned to a site" message "You have been assigned to Malawi at Kenyatta, Lilongwe, Malawi. Please make your way there now, if you are not already, and check-in when you arrive."
    And "atticus@example.com" should not receive a VMS email

  Scenario: Remove a user
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "executing"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    When I right click on staff member "Atticus Finch"
    And I click x-menu-item "Remove"
    And I press "Yes"
    And I wait for the "Loading..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should receive a VMS email with title "You have been unassigned" message "You have been unassigned from your volunteer site and not reassigned to a different. You will be notified if you are reassigned later."
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Deactivate a site for a non-executing scenario
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And "Atticus Finch" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "paused"
    When I open the "Test" scenario
    And I right click on site "Malawi"
    And I click x-menu-item "Deactivate"
    And I wait for the "Loading..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should not receive a VMS email with title "Site Malawi deactivated" message "The site Malawi located at Kenyatta, Lilongwe, Malawi has been deactivated. You were assigned to that site. You will be notified when the site is reactivated."
    And "bartleby@example.com" should not receive a VMS email with title "Site Malawi deactivated"

  Scenario: Add a user for a non-executing scenario
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    And scenario "Test" is "paused"
    When I open the "Test" scenario
    And I click x-accordion-hd "Staff"
    And I drag staff "Add User (drag to site)" to "Malawi"
    And I fill in "User" with "Atticus"
    And I select "Atticus Finch" from ext combo "User"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    Then "atticus@example.com" should not receive a VMS email with title "You have been assigned to a site" message "You have been assigned to Malawi at Kenyatta, Lilongwe, Malawi. Please make your way there now, if you are not already, and check-in when you arrive."
    And "bartleby@example.com" should not receive a VMS email

  Scenario: Sending a custom alert to the staff at a specific site
    Given "Bartleby Scrivener" is assigned to "Malawi" for scenario "Test"
    Given "Atticus Finch" is assigned to "Immunization Center" for scenario "Test"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-accordion-hd "Site"
    And I right click on site "Malawi"
    And I click x-menu-item "Alert staff at this site"
    And I fill in "Alert Message" with "Test Alert"
    And I press "OK"
    And delayed jobs are processed
    Then "atticus@example.com" should not receive a VMS email with title "Custom Alert" message "Test Alert"
    And "bartleby@example.com" should receive a VMS email with title "Custom Alert" message "Test Alert"