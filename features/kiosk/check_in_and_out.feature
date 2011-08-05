@ext @vms
Feature: Checking in and out of a VMS site

  In order to keep track of people during a VMS scenario
  As a volunteer
  I want to make my presence known to the scenario administrator

  Background:
    Given the following users exist:
      | Ad min              | admin@austin.gov | Admin   | Travis County | vms |
      | Joseph Underthunder | joe@example.com  | Admin   | Travis County | vms |
      | Ned Neiderlander    | ned@example.com  | Public  | Travis County | vms |
      | Ray Kroc            | ray@example.com  | Public  | Travis County | vms |
      | Egon Spengler       | egg@example.com  | Public  | Travis County | vms |
    And delayed jobs are processed
    And admin@austin.gov has the scenario "Di Scopare Ti"
    And the following sites exist:
      | name                 | address              | lat       | lng        | status | scenario       |
      | Mirrorball Mountain  | 1234 Leisuresuit La. | 30.315071 | -97.726629 | active | Di Scopare Ti  |
      | Bellbottoms 'R' Us   | 4321 Wakachicka Way  | 30.266483 | -97.77121  | active | Di Scopare Ti  |
    And "Joseph Underthunder" is assigned to "Mirrorball Mountain" for scenario "Di Scopare Ti"
    And "Ned Neiderlander" is assigned to "Mirrorball Mountain" for scenario "Di Scopare Ti"
    And "Ray Kroc" is assigned to "Mirrorball Mountain" for scenario "Di Scopare Ti"
    And "joe@example.com" is the site administrator for "Mirrorball Mountain" in "Di Scopare Ti"
    And "joe@example.com" is the site administrator for "Bellbottoms 'R' Us" in "Di Scopare Ti"
    And scenario "Di Scopare Ti" is "executing"
    And I am logged in as "joe@example.com"
    And I go to the ext dashboard page
    And I navigate to "Apps > VMS > Site Administration"
    Then I should see "Mirrorball Mountain" within ".x-window-body"
    When I select the "Mirrorball Mountain" grid row
    And I press "Launch Check-In Kiosk"
    And I press "Yes"
    Then I should see "Please check in and out with your TxPhin Account"

  Scenario: Volunteer list should show all assigned users for the site
    Then I should see "Joseph Underthunder"
    And I should see "Ned Neiderlander"
    And I should see "Ray Kroc"
    And I should not see "Egon Spengler"

  Scenario: Volunteer checks into and out of their assigned site
    When I select the "Ned Neiderlander" grid row
    And I fill in "Password" with "Password1"
    And I press "Check In" within ".vms-kiosk-registered-panel"
    And I wait for the "Loading..." mask to go away
    Then I should see "Ned Neiderlander" within ".vms-checked-in"
    And "Ned Neiderlander" should be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"

    When I select the "Ned Neiderlander" grid row
    And I fill in "Password" with "Password1"
    And I press "Check Out" within ".vms-kiosk-registered-panel"
    And I wait for the "Loading..." mask to go away
    Then "Ned Neiderlander" should not be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"
    
  Scenario: Checked-in volunteer checks into another site
    When I select the "Ned Neiderlander" grid row
    And I fill in "Password" with "Password1"
    And I press "Check In" within ".vms-kiosk-registered-panel"
    And I wait for the "Loading..." mask to go away
    Then I should see "Ned Neiderlander" within ".vms-checked-in"
    And "Ned Neiderlander" should be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"

    And I am logged in as "joe@example.com"
    And I go to the ext dashboard page
    And I navigate to "Apps > VMS > Site Administration"
    Then I should see "Bellbottoms 'R' Us" within ".x-window-body"
    When I select the "Bellbottoms 'R' Us" grid row
    And I press "Launch Check-In Kiosk"
    And I press "Yes"
    Then I should see "Please check in and out with your TxPhin Account"
    And I should not see "Ned Neiderlander"

    When I fill in "Email Address" with "ned@example.com"
    And I fill in "Password" with "Password1"
    And I press "Check In" within ".vms-kiosk-registered-panel"
    And I wait for the "Loading..." mask to go away
    Then I should see "Ned Neiderlander" within ".vms-checked-in"
    And "Ned Neiderlander" should not be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"
    And "Ned Neiderlander" should be checked in to "Bellbottoms 'R' Us" for scenario "Di Scopare Ti"

  Scenario: Phin User checks into non-assigned site
    Given I should not see "Egon Spengler"
    When I fill in "Email Address" with "egg@example.com"
    And I fill in "Password" with "Password1"
    And I press "Check In" within ".vms-kiosk-registered-panel"
    And I wait for the "Loading..." mask to go away
    Then I should see "Egon Spengler" within ".vms-checked-in"
    And "Egon Spengler" should be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"

  Scenario: Walk-up check-in and out without account creation and check-out
    Given I should not see "Bob Dobbs"
    When I fill in "First Name" with "Bob"
    And I fill in "Last Name" with "Dobbs"
    And I uncheck "Create a TxPhin Account?"
    And I press "Check In" within ".vms-kiosk-walkup-panel"
    And I wait for the "Loading..." mask to go away
    And I press "OK" within ".x-window"
    Then I should see "Bob Dobbs" within ".vms-checked-in"
    And I should see the image "/stylesheets/vms/images/walkup-icon.png"
    And "Bob Dobbs" should be checked in as a walk-up volunteer at "Mirrorball Mountain" for scenario "Di Scopare Ti"

    When I select the "Bob Dobbs" grid row
    And I press "Check Out" within ".vms-kiosk-registered-panel"
    Then "Bob Dobbs" should be checked out as a walk-up volunteer at "Mirrorball Mountain" for scenario "Di Scopare Ti"

  Scenario: Walk-up check-in with account creation
    Given I should not see "Bob Dobbs"
    When I fill in "First Name" with "Bob" within ".vms-kiosk-walkup-panel"
    And I fill in "Last Name" with "Dobbs" within ".vms-kiosk-walkup-panel"
    And I fill in "Email Address" with "dobbs@example.com" within ".vms-kiosk-walkup-panel"
    And I check "Create a TxPhin Account?"
    And I fill in "New Password" with "Password1" within ".vms-kiosk-walkup-panel"
    And I fill in "Confirm Password" with "Password1" within ".vms-kiosk-walkup-panel"
    And I press "Check In" within ".vms-kiosk-walkup-panel"
    And I wait for the "Loading..." mask to go away
    And I press "OK" within ".x-window"
    Then I should see "Bob Dobbs" within ".vms-checked-in"
    And I should not see the image "/stylesheets/vms/images/walkup-icon.png"
    And "Bob Dobbs" should be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"

  Scenario: Normal users and walkup users living together in harmony
    Given I should not see "Bob Dobbs"
    When I fill in "First Name" with "Bob"
    And I fill in "Last Name" with "Dobbs"
    And I uncheck "Create a TxPhin Account?"
    And I press "Check In" within ".vms-kiosk-walkup-panel"
    And I wait for the "Loading..." mask to go away
    And I press "OK" within ".x-window"

    And I should see the image "/stylesheets/vms/images/walkup-icon.png"
    When I select the "Ned Neiderlander" grid row
    And I fill in "Password" with "Password1"
    And I press "Check In" within ".vms-kiosk-registered-panel"
    And I wait for the "Loading..." mask to go away
     
    Then I should see "Bob Dobbs" within ".vms-checked-in"
    And I should see "Ned Neiderlander" within ".vms-checked-in"
    And "Ned Neiderlander" should be checked in to "Mirrorball Mountain" for scenario "Di Scopare Ti"
    And "Bob Dobbs" should be checked in as a walk-up volunteer at "Mirrorball Mountain" for scenario "Di Scopare Ti"