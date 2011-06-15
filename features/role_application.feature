@ext @vms
Feature: Roles for application "vms"

  So we can limit who has access to the users and applications based on role
  As a user
  I want to only be able to see VMS menu items if I have the proper roles

  Scenario: User has no vms role
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County |
    And I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    Then I should not see "Apps"

  Scenario: User has vms Admin role
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County | vms |
    And I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    Then I should see the following toolbar items in "top_toolbar":
      | Apps |
    When I press "Apps" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name |
      | VMS  |
    When I click x-menu-item "VMS"
    Then I should see the following ext menu items:
      | name             |
      | New Scenario     |
      | Manage Scenarios |

  Scenario: User has vms Admin role and phin Admin role
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County | vms |
      | Ad min | admin@dallas.gov | Admin | Dallas County |     |
    And I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    Then I should see the following toolbar items in "top_toolbar":
      | Apps |
    When I press "Apps" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name |
      | VMS  |
    When I click x-menu-item "VMS"
    Then I should see the following ext menu items:
      | name             |
      | New Scenario     |
      | Manage Scenarios |

  Scenario: User has vms Volunteer role
    Given the following users exist:
      | Ad min | admin@dallas.gov | Volunteer | Dallas County | vms |
    And I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    Then I should see the following toolbar items in "top_toolbar":
      | Apps |
    When I press "Apps" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name |
      | VMS  |
    When I click x-menu-item "VMS"
    Then I should see the following ext menu items:
      | name                 |
      | My Volunteer Profile |
    Then I should not see the following ext menu items:
      | name             |
      | New Scenario     |
      | Manage Scenarios |

  Scenario: User has vms Volunteer role and phin Admin role
    Given the following users exist:
      | Ad min | admin@dallas.gov | Volunteer | Dallas County | vms |
      | Ad min | admin@dallas.gov | Admin     | Dallas County |     |
    And I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    Then I should see the following toolbar items in "top_toolbar":
      | Apps |
    When I press "Apps" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name |
      | VMS  |
    When I click x-menu-item "VMS"
    Then I should see the following ext menu items:
      | name                 |
      | My Volunteer Profile |
    Then I should not see the following ext menu items:
      | name             |
      | New Scenario     |
      | Manage Scenarios |