@vms @ext
Feature: Volunteer List

  In order to manage volunteers and send mass alerts
  As a VMS Admin
  I want to be able to view my volunteer list, send status checks, and custom alerts

  Background:
    Given the following users exist:
      | Atticus Finch      | atticus@example.com  | Volunteer | Angelina County | vms |
      | Bartleby Scrivener | bartleby@example.com | Volunteer | Angelina County | vms |
      | Ad Min             | admin@example.com    | Admin     | Angelina County |     |
      | Ad Min             | admin@example.com    | Admin     | Angelina County | vms |
      | Not Volunteering   | novol@example.com    | Volunteer | Dallas County   | vms |
    When I am logged in as "admin@example.com"
    And I go to the ext dashboard page

  Scenario: View Volunteer List as admin
    When I navigate to "Apps > VMS > Volunteer List"
    And I wait for the "Loading..." mask to go away
    Then the grid ".volunteerGrid" should contain:
      | Name               |
      | Atticus Finch      |
      | Bartleby Scrivener |
    And the grid ".volunteerGrid" should not contain:
      | Name             |
      | Not Volunteering |

  Scenario: Cannot view Volunteer List as volunteer
    When I sign out
    And I am logged in as "atticus@example.com"
    And I go to the ext dashboard page
    Then I should not see the volunteer list menu option

  Scenario: Cannot view Volunteer List with no vms roles
    When I sign out
    Given the following users exist:
      | Not VMS | notvms@example.com | Admin | Angelina County |
    When I am logged in as "notvms@example.com"
    And I go to the ext dashboard page
    Then I should not see the volunteer list menu option

  Scenario: Select volunteer, view actions for volunteer
    When I navigate to "Apps > VMS > Volunteer List"
    And I wait for the "Loading..." mask to go away
    And I select the "Atticus Finch" grid row within ".volunteerGrid"
    Then I should see "Edit Volunteer (new tab)"
    And I should see "View/Modify Volunteer Qualifications"

  Scenario: Select volunteer, launch edit profile tab
    When I navigate to "Apps > VMS > Volunteer List"
    And I wait for the "Loading..." mask to go away
    And I select the "Atticus Finch" grid row within ".volunteerGrid"
    And I click vms-row-button "Edit Volunteer"
    Then the "Edit Account: Atticus Finch" tab should be open

  Scenario: Select Volunteer, edit volunteer qualifications
    When I navigate to "Apps > VMS > Volunteer List"
    And I wait for the "Loading..." mask to go away
    And I select the "Atticus Finch" grid row within ".volunteerGrid"
    And I click vms-row-button "View/Modify Volunteer Qualifications"
    Then I should see "Qualifications"
    And I should not see "Edit Volunteer (new tab)"
    And I should not see "View/Modify Volunteer Qualifications"
    When I press "Back"
    Then I should see "Edit Volunteer (new tab)"
    And I should see "View/Modify Volunteer Qualifications"

  Scenario: Select Volunteer, add volunteer qualification
    When I navigate to "Apps > VMS > Volunteer List"
    And I wait for the "Loading..." mask to go away
    And I select the "Atticus Finch" grid row within ".volunteerGrid"
    And I click vms-row-button "View/Modify Volunteer Qualifications"
    And I fill in "VmsQualificationCombo" with "bilingual"
    And I press "Add"
    And I wait for the "Saving..." mask to go away
    Then I should see "bilingual" within ".vms-qualification-grid"

  Scenario: Select Volunteer, remove volunteer qualification
    Given user "Atticus Finch" has the "bilingual" qualification
    And user "Atticus Finch" has the "very strong" qualification
    When I navigate to "Apps > VMS > Volunteer List"
    And I wait for the "Loading..." mask to go away
    And I select the "Atticus Finch" grid row within ".volunteerGrid"
    And I click vms-row-button "View/Modify Volunteer Qualifications"
    And I click remove_qual on the "bilingual" grid row within ".vms-qualification-grid"
    And I wait for the "Saving..." mask to go away
    Then I should not see "bilingual" within ".vms-qualification-grid"
    And I should see "very strong" within ".vms-qualification-grid"

  Scenario: View list of status check requests
    Given a status check alert created on "4/11/11 10:45:00" for:
      | Atticus Finch      |
      | Bartleby Scrivener |
    When I navigate to "Apps > VMS > Volunteer List"
    And I click vms-row-button "Status Check"
    Then I should see "Status Checks" within ".statusCheckListPanel"
    And the grid ".statusChecksGrid" should contain:
      | Name              |
      | 4/11/11, 10:45 AM |

  Scenario: Create new status check, check that users receive alerts
    When I navigate to "Apps > VMS > Volunteer List"
    And I click vms-row-button "Status Check"
    And I wait for the "Loading..." mask to go away
    And I press "New Status Check"
    Then I should see "Volunteers"
    And I should see "Custom Message"
    When I press "Select None"
    And I select the "Atticus Finch" grid row
    And I press "Send Status Check Alert"
    And I wait for the "Saving..." mask to go away
    Then I should not see "Volunteers" within ".newStatusCheck"
    And I should see 1 row in grid "statusChecksGrid"
    And "atticus@example.com" should receive a VMS email with title "Volunteer Status Check" message "Ad Min has initiated a status check for the Angelina County jurisdiction(s). Please acknowledge that you have received this message and still wish to volunteer in Angelina County."

  Scenario: Create new status check with custom message, check that users receive alerts
    When I navigate to "Apps > VMS > Volunteer List"
    And I click vms-row-button "Status Check"
    And I wait for the "Loading..." mask to go away
    And I press "New Status Check"
    Then I should see "Volunteers"
    And I should see "Custom Message"
    When I press "Select None"
    And I select the "Atticus Finch" grid row
    And I fill in "custom_message" with "Custom Message"
    And I press "Send Status Check Alert"
    And I wait for the "Saving..." mask to go away
    Then I should not see "Volunteers" within ".newStatusCheck"
    And I should see 1 row in grid "statusChecksGrid"
    And "atticus@example.com" should receive a VMS email with title "Volunteer Status Check" message "Ad Min has initiated a status check for the Angelina County jurisdiction(s). Please acknowledge that you have received this message and still wish to volunteer in Angelina County.</p>\n\n<p>Custom Message"

  Scenario: View list of status check responses
    Given a status check alert created on "4/11/11 10:45:00" for:
      | Atticus Finch      |
      | Bartleby Scrivener |
    And "Atticus Finch" has responded to a VmsStatusCheckAlert with title "Volunteer Status Check" with 0 at "4/11/11 11:30:00"
    When I navigate to "Apps > VMS > Volunteer List"
    And I click vms-row-button "Status Check"
    And I wait for the "Loading..." mask to go away
    And I select the "4/11/11, 10:45 AM" grid row within ".statusChecksGrid"
    Then I should see "Volunteers" within ".statusResponderPanel"
    And the grid ".statusResponderGrid" should contain:
      | Name               | Acknowledged | At                |
      | Atticus Finch      | Acknowledged | 4/11/11, 11:30 AM |
      | Bartleby Scrivener |              |                   |

  Scenario: Send custom alert with partial list of volunteers
    When I navigate to "Apps > VMS > Volunteer List"
    And I click vms-row-button "Alert Volunteers"
    Then I should see "Volunteers" within ".volunteerGrid"
    And I should see "Custom Alert" within ".customAlertPanel"
    When I press "Select None"
    And I select the "Atticus Finch" grid row
    And I fill in "Title" with "Test Custom Alert"
    And I fill in "Message" with "This is a test message for cucumber"
    And I press "Send Alert"
    Then I should see "Volunteers" within ".volunteerGrid"
    And I should not see "Custom Alert" within ".customAlertPanel"
    And "atticus@example.com" should receive a VMS email with title "Test Custom Alert" message "This is a test message for cucumber"
