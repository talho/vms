@ext @vms
Feature: Improve the scenario management process, and allow users to create scenario templates for executing

  In order to create scenario templates and have an easier time managing my scenarios
  As a user
  I want a more complete UI that will allow me to create and execute templates.

  # The scenario.feature file should be updated to cover any new UI changes for scenario management
  Background:
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County | vms |
    And I am logged in as "admin@dallas.gov"
    And I go to the ext dashboard page

  Scenario: Create a new scenario as a template
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I click vms-row-button "Create New Scenario"
    And I fill in "Name" with "My Scenario"
    And I check "Create as a Scenario Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "My Scenario" in grid row 1 within ".vms-template-scenarios-list"
    And scenario "My Scenario" should be "template"
    When I select the "My Scenario" grid row within ".vms-template-scenarios-list"
    And I click vms-row-button "Edit Template"
    Then the "Command Center - My Scenario" tab should be open
    And the "My Scenario" scenario should be created

  Scenario: Convert an unexecuted scenario into a template
    Given I have the scenarios "My Scenario"
    And scenario "My Scenario" is "unexecuted"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "My Scenario" grid row within ".vms-active-scenarios-list"
    And I click vms-row-button "Copy Scenario as Template"
    And I wait for the "Loading..." mask to go away
    Then I should see "My Scenario" in grid row 1 within ".vms-template-scenarios-list"
    And I should see "My Scenario" in grid row 1 within ".vms-active-scenarios-list"
    When I select the "My Scenario" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "My Scenario Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then scenario "My Scenario Template" should be "template"
    And scenario "My Scenario" should be "unexecuted"

  Scenario: Copy and convert an executing scenario into a template
    Given I have the scenarios "My Scenario"
    And scenario "My Scenario" is "executing"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "My Scenario" grid row within ".vms-active-scenarios-list"
    And I click vms-row-button "Copy Scenario as Template"
    And I wait for the "Loading..." mask to go away
    Then I should see "My Scenario" in grid row 1 within ".vms-template-scenarios-list"
    And I should see "My Scenario" in grid row 1 within ".vms-active-scenarios-list"
    When I select the "My Scenario" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "My Scenario Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then scenario "My Scenario Template" should be "template"
    And scenario "My Scenario" should be "executing"

  Scenario: Convert a completed scenario into a template
    Given I have the scenarios "My Scenario"
    And scenario "My Scenario" is "complete"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "My Scenario" grid row within ".vms-completed-scenarios-list"
    And I click vms-row-button "Copy Scenario as Template"
    And I wait for the "Loading..." mask to go away
    Then I should see "My Scenario" in grid row 1 within ".vms-template-scenarios-list"
    And I should see "My Scenario" in grid row 1 within ".vms-completed-scenarios-list"
    When I select the "My Scenario" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "My Scenario Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then scenario "My Scenario Template" should be "template"
    And scenario "My Scenario" should be "complete"

  Scenario: Execute a template (should create a copy to execute)
    Given I have the scenarios "Test"
    And scenario "Test" is "template"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row within ".vms-template-scenarios-list"
    And I click vms-row-button "Edit Template"
    Then the "Command Center - Test" tab should be open
    When I click vms-row-button "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And I close the active tab
    And I close the active tab
    When I navigate to "Apps > VMS > Manage Scenarios"
    Then I should see "Test" in grid row 1 within ".vms-template-scenarios-list"
    And I should see "Test" in grid row 1 within ".vms-active-scenarios-list"
    When I select the "Test" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "Test Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test Template" should be "template"
    And scenario "Test" should be "executing"

  Scenario: Launch Template as new scenario
    Given I have the scenarios "Test"
    And scenario "Test" is "template"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row within ".vms-template-scenarios-list"
    And I click vms-row-button "Launch Template as a New Scenario"
    Then the "Command Center - Test" tab should be open
    And I close the active tab
    Then I should see "Test" in grid row 1 within ".vms-template-scenarios-list"
    And I should see "Test" in grid row 1 within ".vms-active-scenarios-list"
    When I select the "Test" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "Test Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test Template" should be "template"
    And scenario "Test" should be "unexecuted"

  Scenario: Change a template after copying should not change the copied scenario
    Given I have the scenarios "Test"
    And scenario "Test" is "template"
    When I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row within ".vms-template-scenarios-list"
    And I click vms-row-button "Launch Template as a New Scenario"
    Then the "Command Center - Test" tab should be open
    And I close the active tab
    When I select the "Test" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "Test Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    When I select the "Test Template" grid row within ".vms-template-scenarios-list"
    And I click vms-row-button "Edit Template"
    And I click x-accordion-hd "Site"
    When I drag the "New Site" site to the map at "31.347573", "-94.71391"
    And I fill in "Name" with "Template Site"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then the site "Template Site" should exist for scenario "Test Template"
    Then the site "Template Site" should not exist for scenario "Test"

  Scenario: "admin" should be able to execute templated scenario
    Given the following users exist:
      | Atticus Finch      | atticus@example.com  | Admin | Potter County | vms |
    And I have the scenarios "Test"
    And scenario "Test" is "template"
    And "Atticus Finch" is an admin for scenario "Test"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row within ".vms-template-scenarios-list"
    And I click vms-row-button "Launch Template as a New Scenario"
    Then the "Command Center - Test" tab should be open
    And I close the active tab
    Then I should see "Test" in grid row 1 within ".vms-template-scenarios-list"
    And I should see "Test" in grid row 1 within ".vms-active-scenarios-list"
    When I select the "Test" grid row within ".vms-template-scenarios-list"
    And I press "Edit Scenario Details"
    And I fill in "Name" with "Test Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test Template" should be "template"
    And scenario "Test" should be "unexecuted"

  Scenario: "reader" should not be able to execute templated scenario
    Given the following users exist:
      | Atticus Finch      | atticus@example.com  | Admin | Potter County | vms |
    And I have the scenarios "Test"
    And scenario "Test" is "template"
    And "Atticus Finch" is a reader for scenario "Test"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to "Apps > VMS > Manage Scenarios"
    And I select the "Test" grid row within ".vms-template-scenarios-list"
    Then I should see "Open Template"
    And I should not see "Edit Template"
    And I should not see "Launch Template as a New Scenario"
    And I should not see "Delete Scenario"
    And I should not see "Edit Scenario Details"
