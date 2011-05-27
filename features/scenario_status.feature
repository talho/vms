@ext @vms
Feature: Scenario Status

  In order to execute a scenario
  As a user
  I want to change the status of a scenario between inactive and active states

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"

  Scenario: Execute Scenario
    # We are not checking for alerts and how it handles responses here. We're just interested in scenario state and the state of the polling provider
    Given scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    Then the polling service for "Test" should not be running
    When I click x-btn "Execute"
    Then the "Execute Scenario" window should be open
    When I press "Yes"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test" should be "executing"
    And the polling service for "Test" should be running

  Scenario: Pause Scenario
    Given scenario "Test" is "executing"
    When I open the "Test" scenario
    Then the polling service for "Test" should be running
    When I click x-btn "Pause"
    Then the "Pause Scenario Execution" window should be open
    When I press "No"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test" should be "paused"
    And the polling service for "Test" should not be running

  Scenario: Resume Scenario
    Given scenario "Test" is "paused"
    When I open the "Test" scenario
    Then the polling service for "Test" should not be running
    When I click x-btn "Execute"
    Then the "Resume Scenario Execution" window should be open
    When I press "No"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test" should be "executing"
    And the polling service for "Test" should be running

  Scenario: End Scenario
    Given scenario "Test" is "executing"
    When I open the "Test" scenario
    Then the polling service for "Test" should be running
    When I click x-btn "End Scenario"
    Then the "Stop Scenario Execution" window should be open
    When I press "Yes"
    And I wait for the "Saving..." mask to go away
    Then scenario "Test" should be "complete"
    And the polling service for "Test" should not be running