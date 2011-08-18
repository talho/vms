@ext @vms
Feature: Accessing site check-in kiosks from the phin app 

  In order to allow volunteers to check in to a site I am in charge of
  As a VMS site admin
  I want to load the check-in kiosk for a that site

  Background:
    Given the following users exist:
      | Ad min             | admin@austin.gov     | Admin | Travis County | vms |
      | Bartleby Scrivener | bartleby@example.com | Admin | Travis County | vms |
      | Atticus Finch      | atticus@example.com  | Admin | Potter County | vms |
    And delayed jobs are processed
    And admin@austin.gov has the scenario "Kaboom"
    And admin@austin.gov has the scenario "Pajama Jammy Jam"
    And the following sites exist:
      | name             | address                 | lat       | lng        | status | scenario         |
      | Triage Station 2 | 1234 Hooberdauber Drive | 30.315071 | -97.726629 | active | Kaboom           |
      | Moon Tower       | 4321 Baloney Blvd       | 30.266483 | -97.77121  | active | Kaboom           |
      | Taco Drop-Off    | 3333 Jurassic Pock      | 30.28321  | -97.716599 | active | Pajama Jammy Jam |
    And "Bartleby Scrivener" is assigned to "Triage Station 2" for scenario "Kaboom"

  Scenario: Scenario Administrator can assign site admin status
    Given I am logged in as "admin@austin.gov"
    And I open the "Kaboom" scenario
    And I click the marker for "Triage Station 2"
    Then the info window for "Triage Station 2" should be open
    When I wait for the "Loading..." mask to go away
    And I right click on the info window staff "Bartleby Scrivener"
    And I click x-menu-item "Set Site Admin"
    And I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then "bartleby@example.com" should be the site administrator for "Triage Station 2" in "Kaboom"

  Scenario: Site Administrator can see all active scenariosites they admin, from the phin
    Given  "bartleby@example.com" is the site administrator for "Triage Station 2" in "Kaboom"
    And  "bartleby@example.com" is the site administrator for "Taco Drop-Off" in "Pajama Jammy Jam"
    And I am logged in as "bartleby@example.com"
    And I go to the ext dashboard page
    And I navigate to "Apps > VMS"
    Then I should not see "Site Administration"
    When scenario "Pajama Jammy Jam" is "executing"
    And I go to the ext dashboard page
    And I navigate to "Apps > VMS > Site Administration"
    Then I should not see "Triage Station 2" within ".x-window-body"
    And I should see "Taco Drop-Off" within ".x-window-body"

  Scenario: Site administrator can launch kiosk from the Phin
    Given "bartleby@example.com" is the site administrator for "Triage Station 2" in "Kaboom"
    And scenario "Kaboom" is "executing"
    And I am logged in as "bartleby@example.com"
    When I go to the ext dashboard page
    And I navigate to "Apps > VMS > Site Administration"
    Then I should see "Triage Station 2" within ".x-window-body"

    When I select the "Triage Station 2" grid row
    And I press "Launch Check-In Kiosk"
    And I press "Yes"
    Then I should see "Please check in and out with your TxPhin Account"