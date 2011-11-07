@ext @vms
Feature: Malicious VMS Kiosk tests

  In order to keep the data on volunteer positions accurate
  As a developer
  I want to be sure kiosk functions cannot be accesed without proper credentials

  Background:
    Given the following users exist:
      | Ad min              | admin@austin.gov     | Admin   | Travis County | vms |
      | Black Hat           | stabby@example.com   | Public  | Travis County | vms |
      | White Hat           | explody@example.com  | Public  | Travis County | vms |
    And delayed jobs are processed
    And admin@austin.gov has the scenario "Spy vs Spy"
    And the following sites exist:
      | name                 | address                  | lat       | lng        | status | scenario    |
      | Bomb Dispensary      | 1234 Slings & Arrows Ct. | 30.315071 | -97.726629 | active | Spy vs Spy  |
    And "White Hat" is assigned to "Bomb Dispensary" for scenario "Spy vs Spy"

  Scenario: VMS User cannot access kiosk if they aren't scenariosite admin
    Given scenario "Spy vs Spy" is "executing"
    And I am logged in as "stabby@example.com"
    And I force open the kiosk page for "Bomb Dispensary" in scenario "Spy vs Spy"
    Then I should see "You are not a VMS Site Administrator"
    And I should see "Sign In to Your Account"

  Scenario: User cannot maliciously check into a non-active site
    Given I am logged in as "stabby@example.com"
    And I maliciously attempt to check in as "stabby@example.com" to site "Bomb Dispensary" in scenario "Spy vs Spy"
    And I wait for 1 second
    Then I should see "That scenario is not currently active"
    And no user should be checked in to site "Bomb Dispensary" in scenario "Spy vs Spy"
    
  Scenario: Walkup cannot maliciously check in to non-active site
    Given I am on the signin page
    And I maliciously attempt to check in as a walkup user to site "Bomb Dispensary" in scenario "Spy vs Spy"
    Then I should see "You must sign in to access this page"
    And I should see "Sign In to Your Account"
    And no walkup should be checked in to site "Bomb Dispensary" in scenario "Spy vs Spy"

  Scenario: Malicious person cannot pull kiosk info without appropriate session
    Given I am on the signin page
    And scenario "Spy vs Spy" is "executing"
    And I maliciously attempt to fetch kiosk information for site "Bomb Dispensary" in scenario "Spy vs Spy"
    Then I should see "You must sign in to access this page"
    And I should see "Sign In to Your Account"
    