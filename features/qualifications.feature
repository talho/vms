@ext @vms
Feature: Qualifications tests

  In order to request certain non-role qualifications
  As a user
  I would like to specify which qualifications I want on sites or specific roles

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And the following entities exist:
      | Role | Chief Veterinarian     |
      | Role | Border Health Director |
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"

  Scenario: Add a new qualification to a site
    Given the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    And I drag qualification "Add Qualification (drag to site)" to site "Malawi"
    Then the "Add Qualification" window should be open
    When I fill in "Qualification" with "bilingual"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual" in grid row 2 within ".qualGrid"
    And "bilingual" should be a qualification for site "Malawi" on scenario "Test"

  Scenario: Add a new qualification to a role
    Given the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    And I drag qualification "Add Qualification (drag to site)" to site "Malawi"
    And I fill in "Qualification" with "bilingual"
    And I choose "Apply Qualification to this Role"
    And I select "Chief Veterinarian" from ext combo "Apply to Role"
    And I press "Save"
    Then I should see "bilingual - Chief Veterinarian" in grid row 2 within ".qualGrid"
    And "bilingual" should be a qualification for role "Chief Veterinarian" site "Malawi" on scenario "Test"

  Scenario: Add an existing qualification to a site
    Given a user has a qualification "bilingual"
    And a user has a qualification "bicycle"
    And the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    And I drag qualification "Add Qualification (drag to site)" to site "Malawi"
    Then the "Add Qualification" window should be open
    When I fill in "Qualification" with "bi"
    And I select "bilingual" from ext combo "Qualification"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual" in grid row 2 within ".qualGrid"
    And "bilingual" should be a qualification for site "Malawi" on scenario "Test"

  Scenario: Add an existing qualification to a role
    Given a user has a qualification "bilingual"
    Given a user has a qualification "bicycle"
    And the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag qualification "Add Qualification (drag to site)" to site "Malawi"
    And I fill in "Qualification" with "bi"
    And I select "bilingual" from ext combo "Qualification"
    And I choose "Apply Qualification to this Role"
    And I select "Chief Veterinarian" from ext combo "Apply to Role"
    And I press "Save"
    Then I should see "bilingual - Chief Veterinarian" in grid row 2 within ".qualGrid"
    And "bilingual" should be a qualification for role "Chief Veterinarian" site "Malawi" on scenario "Test"

  Scenario: Copy a qualification to a different site
    And the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag qualification "bilingual" to site "Immunization Center"
    Then the "Copy Qualification" window should be open
    When the "Qualification" field should contain "bilingual"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual" in grid row 2 within ".qualGrid"
    Then I should see "bilingual" in grid row 3 within ".qualGrid"
    And "bilingual" should be a qualification for site "Malawi" on scenario "Test"
    And "bilingual" should be a qualification for site "Immunization Center" on scenario "Test"

  Scenario: Copy a qualification to a different site with a role
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    Given role "Chief Veterinarian" site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag qualification "bilingual" to site "Immunization Center"
    Then the "Copy Qualification" window should be open
    And I wait for the "Loading..." mask to go away
    And the "Qualification" field should contain "bilingual"
    And the "Apply to Role" field should contain "Chief Veterinarian"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual - Chief Veterinarian" in grid row 2 within ".qualGrid"
    Then I should see "bilingual - Chief Veterinarian" in grid row 3 within ".qualGrid"
    And "bilingual" should be a qualification for role "Chief Veterinarian" site "Malawi" on scenario "Test"
    And "bilingual" should be a qualification for role "Chief Veterinarian" site "Immunization Center" on scenario "Test"

  Scenario: Copy a qualification to a different site with no role selected
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given role "Chief Veterinarian" site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag qualification "bilingual" to site "Immunization Center"
    Then the "Copy Qualification" window should be open
    And I wait for the "Loading..." mask to go away
    And the "Qualification" field should contain "bilingual"
    And the "Apply to Role" field should not contain "Chief Veterinarian"
    When I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual" in grid row 2 within ".qualGrid"
    Then I should see "bilingual - Chief Veterinarian" in grid row 3 within ".qualGrid"
    And "bilingual" should be a qualification for role "Chief Veterinarian" site "Malawi" on scenario "Test"
    And "bilingual" should be a qualification for site "Immunization Center" on scenario "Test"

  Scenario: Edit a qualification by dragging to the site
    Given the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given the site "Malawi" for scenario "Test" has the role "Border Health Director"
    Given role "Chief Veterinarian" site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I drag qualification "bilingual" to site "Malawi"
    Then the "Modify Qualification" window should be open
    And I wait for the "Loading..." mask to go away
    And the "Qualification" field should contain "bilingual"
    And the "Apply to Role" field should contain "Chief Veterinarian"
    When I select "Border Health Director" from ext combo "Apply to Role"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bilingual - Border Health Director" in grid row 2 within ".qualGrid"
    And "bilingual" should be a qualification for role "Border Health Director" site "Malawi" on scenario "Test"

  Scenario: Edit a qualification using right-click
    Given the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given role "Chief Veterinarian" site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I right click qualification "bilingual"
    And I click x-menu-item "Edit"
    Then the "Modify Qualification" window should be open
    And I wait for the "Loading..." mask to go away
    And the "Qualification" field should contain "bilingual"
    And the "Apply to Role" field should contain "Chief Veterinarian"
    And I fill in "Qualification" with "bicycle"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "bicycle - Chief Veterinarian" in grid row 2 within ".qualGrid"
    And "bicycle" should be a qualification for role "Chief Veterinarian" site "Malawi" on scenario "Test"

  Scenario: Remove a qualification from a site
    Given the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I right click qualification "bilingual"
    And I click x-menu-item "Remove"
    Then the "Confirm Removal" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then I should not see "bilingual" in grid row 2 within ".qualGrid"
    And "bilingual" should not be a qualification for site "Malawi" on scenario "Test"

  Scenario: Remove a qualification from a role
    Given the following sites exist:
      | name   | address                    | lat                 | lng              | status | scenario |
      | Malawi | Kenyatta, Lilongwe, Malawi | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given role "Chief Veterinarian" site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    When I open the "Test" scenario
    And I click x-accordion-hd "Qualifications"
    When I right click qualification "bilingual"
    And I click x-menu-item "Remove"
    Then the "Confirm Removal" window should be open
    When I press "Yes"
    And I wait for the "Loading..." mask to go away
    Then I should not see "bilingual - Chief Veterinarian" in grid row 2 within ".qualGrid"
    And "bilingual" should not be a qualification for role "Chief Veterinarian" site "Malawi" on scenario "Test"

  Scenario: User with a qualification is automatically assigned to a site with a matching qualification
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    And the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    And site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin,Chief Veterinarian  | Dallas County |
    And "Bartleby Scrivener" has the qualification "bilingual"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    When "Bartleby Scrivener" has responded to a VmsExecutionAlert with title "Scenario Test is looking for volunteers" with 3
    And backgroundrb has processed the vms alert responses
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"

  Scenario: User with a qualification is automatically assigned to a site with a matching qualification reversed
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    And the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    And the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    And site "Immunization Center" is assigned the qualification "bilingual" on scenario "Test"
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin,Chief Veterinarian  | Dallas County |
    And "Bartleby Scrivener" has the qualification "bilingual"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    When "Bartleby Scrivener" has responded to a VmsExecutionAlert with title "Scenario Test is looking for volunteers" with 3
    And backgroundrb has processed the vms alert responses
    And "Bartleby Scrivener" should be assigned to "Immunization Center" for scenario "Test"

  Scenario: User with a qualification is automatically assigned to a site role with a matching qualification
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    Given role "Chief Veterinarian" site "Malawi" is assigned the qualification "bilingual" on scenario "Test"
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin,Chief Veterinarian  | Dallas County |
    And "Bartleby Scrivener" has the qualification "bilingual"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    When "Bartleby Scrivener" has responded to a VmsExecutionAlert with title "Scenario Test is looking for volunteers" with 3
    And backgroundrb has processed the vms alert responses
    And "Bartleby Scrivener" should be assigned to "Malawi" for scenario "Test"

  Scenario: User with a qualification is automatically assigned to a site role with a matching qualification reversed
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi              | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    Given the site "Malawi" for scenario "Test" has the role "Chief Veterinarian"
    Given the site "Immunization Center" for scenario "Test" has the role "Chief Veterinarian"
    Given role "Chief Veterinarian" site "Immunization Center" is assigned the qualification "bilingual" on scenario "Test"
    And the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin,Chief Veterinarian  | Dallas County |
    And "Bartleby Scrivener" has the qualification "bilingual"
    And scenario "Test" is "unexecuted"
    When I open the "Test" scenario
    And I click x-btn "Execute"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And delayed jobs are processed
    When "Bartleby Scrivener" has responded to a VmsExecutionAlert with title "Scenario Test is looking for volunteers" with 3
    And backgroundrb has processed the vms alert responses
    And "Bartleby Scrivener" should be assigned to "Immunization Center" for scenario "Test"