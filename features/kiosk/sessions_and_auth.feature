@ext @vms
Feature: Checking in and out of a VMS site

  In order to prevent unauthorized access
  As a VMS site admin
  I want to have separate sessions for the phin app and kiosk mode

  Background:
    Given the following users exist:
      | Ad min              | admin@austin.gov | Admin | Travis County | vms |
      | Joseph Underthunder | joe@example.com  | Admin | Travis County | vms |
    And delayed jobs are processed
    And admin@austin.gov has the scenario "Emergency BBQ"
    And the following sites exist:
      | name         | address               | lat       | lng        | status | scenario       |
      | Sauce Depot  | 1234 Extra Pickes Ave | 30.315071 | -97.726629 | active | Emergency BBQ  |
      | Beef Brigade | 4321 Mesquite Blvd    | 30.266483 | -97.77121  | active | Emergency BBQ  |
    And "Joseph Underthunder" is assigned to "Beef Brigade" for scenario "Emergency BBQ"
    And "joe@example.com" is the site administrator for "Beef Brigade" in "Emergency BBQ"
    And scenario "Emergency BBQ" is "executing"

  Scenario: Loading a kiosk from phin causes phin logout
    When I am logged in as "joe@example.com"
    And I go to the ext dashboard page
    And I navigate to "Apps > VMS > Site Administration"
    Then I should see "Beef Brigade" within ".x-window-body"

    When I select the "Emergency BBQ" grid row
    And I press "Launch Check-In Kiosk"
    And I press "Yes"
    Then I should see "Please check in and out with your TxPhin Account"

    When I go to the ext dashboard page
    Then I should see "Sign In to Your Account"

  Scenario: Loading a kiosk without phin or vms session prompts for login
    When I visit the url "/vms/kiosk/1"
    Then I should see "Sign In to Your Account"

  Scenario: Loading a kiosk without permissions for that site shows your site list
    When I am logged in as "joe@example.com"
    When I visit the url "/vms/kiosk/1"
    Then I should see "You are not the Administrator for that site"
    And I should see "Beef Brigade"

  Scenario: Loading a kiosk for site in an inactive scenario prevents access     
    Given scenario "Emergency BBQ" is "unexecuted"
    And I am logged in as "joe@example.com"
    
    When I visit the url "/vms/kiosk/2"
    Then I should see "That scenario is not currently active"
