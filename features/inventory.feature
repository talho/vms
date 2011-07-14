@ext @vms
Feature: Inventory creation on sites

  In order to create an execution template and track the locations of various inventory items
  As a user
  I want to be able to create, edit, copy, move, and delete inventories

  Background:
    Given the following users exist:
      | Ad min | admin@dallas.gov | Admin | Dallas County | vms |
    And I am logged in as "admin@dallas.gov"
    And I have the scenarios "Test"

  Scenario: Create Inventory by dragging onto site
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "New POD/Inventory" inventory onto the "Immunization Center" site
    Then the "Create POD/Inventory" window should be open
    When I fill in the following:
      | Inventory/POD Name | Medical Inventory |
      | Source             | DSHS              |
    And I choose "Inventory"
    And I press "Add Item"
    Then the "Add Item" window should be open
    When I fill in the following within ".addItemWindow":
      | Name       | Surgical Mask    |
      | Category   | Medical Supplies |
      | Quantity   | 10               |
    And I uncheck "Consumable" within ".addItemWindow"
    And I press "Add"
    Then I should see "Surgical Mask" in grid row 1 column name_column within ".itemGrid"
    And I should see "10" in grid row 1 column 2 within ".itemGrid"
    When I press "Add Item"
    Then the "Add Item" window should be open
    When I fill in the following within ".addItemWindow":
      | Name       | Cold Vaccine  |
      | Category   | Immunizations |
      | Quantity   | 100           |
    And I check "Consumable" within ".addItemWindow"
    And I press "Add"
    Then I should see "Cold Vaccine" in grid row 2 column name_column within ".itemGrid"
    And I should see "100" in grid row 2 column 2 within ".itemGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical Inventory" in grid row 2 within ".inventoryGrid"
    And "Medical Inventory" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "inventory"
    And "Medical Inventory" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

  Scenario: Create POD
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "New POD/Inventory" inventory onto the "Immunization Center" site
    Then the "Create POD/Inventory" window should be open
    When I fill in the following:
      | Inventory/POD Name | Medical POD |
      | Source             | CDC         |
    And I choose "POD"
    And I press "Add Item"
    Then the "Add Item" window should be open
    When I fill in the following within ".addItemWindow":
      | Name       | Surgical Mask    |
      | Category   | Medical Supplies |
      | Quantity   | 10               |
    And I uncheck "Consumable" within ".addItemWindow"
    And I press "Add"
    Then I should see "Surgical Mask" in grid row 1 column name_column within ".itemGrid"
    And I should see "10" in grid row 1 column 2 within ".itemGrid"
    When I press "Add Item"
    Then the "Add Item" window should be open
    When I fill in the following within ".addItemWindow":
      | Name       | Cold Vaccine  |
      | Category   | Immunizations |
      | Quantity   | 100           |
    And I check "Consumable" within ".addItemWindow"
    And I press "Add"
    Then I should see "Cold Vaccine" in grid row 2 column name_column within ".itemGrid"
    And I should see "100" in grid row 2 column 2 within ".itemGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical POD" in grid row 2 within ".inventoryGrid"
    And "Medical POD" should exist on site "Immunization Center" for scenario "Test" with source "CDC" and type "pod"
    And "Medical POD" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

  Scenario: Use Inventory Template to pre-populate values
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following inventories exist:
      | name        | site | scenario | source | type | template |
      | Medical POD |      |          | DSHS   | pod  | true     |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "New POD/Inventory" inventory onto the "Immunization Center" site
    Then the "Create POD/Inventory" window should be open
    When I fill in "Name" with "Medical POD"
    And I select "Medical POD" from ext combo "Name"
    Then the "Source" field should contain "DSHS"
    And the "POD" checkbox should be checked
    Then the grid ".itemGrid" should contain:
      | Name          | Quantity |
      | Cold Vaccine  | 100      |
      | Surgical Mask | 10       |
    And the "Template" checkbox should not be checked
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical POD" in grid row 2 within ".inventoryGrid"
    And "Medical POD" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "pod"
    And "Medical POD" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

  Scenario: Edit Inventory Details
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | true     |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I right click on the "Medical POD" inventory
    And I click x-menu-item "Edit"
    Then the "Edit POD/Inventory" window should be open
    When I fill in "Name" with "Medical Inventory"
    And I fill in "Source" with "CDC"
    And I choose "Inventory"
    Then the "POD" checkbox should not be checked
    And the "Template" checkbox should not be checked
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical Inventory" in grid row 2 within ".inventoryGrid"
    And "Medical Inventory" should exist on site "Immunization Center" for scenario "Test" with source "CDC" and type "inventory"
    And "Medical Inventory" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

  Scenario: Edit Inventory Items
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | true     |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | false      |
      | The Flu       | A Virus          | 1        | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I right click on the "Medical POD" inventory
    And I click x-menu-item "Edit"
    Then the "Edit POD/Inventory" window should be open
    When I right click on the "Surgical Mask" item
    And I click x-menu-item "Edit"
    Then the "Change Item" window should be open
    When I fill in "Item Name" with "Gas Mask"
    And I fill in "Category" with "Emergency Supplies"
    And I fill in "Quantity" with "15"
    And I check "Consumable"
    And I press "Save" within ".addItemWindow"
    When I right click on the "Cold Vaccine" item
    And I click x-menu-item "Edit"
    Then the "Change Item" window should be open
    And I check "Consumable"
    And I press "Save" within ".addItemWindow"
    And I click decreaseItem on the "Cold Vaccine" grid row within ".itemGrid"
    And I should see "99" in grid row 2 column 2 within ".itemGrid"
    And I click increaseItem on the "Cold Vaccine" grid row within ".itemGrid"
    And I should see "100" in grid row 2 column 2 within ".itemGrid"
    And I click increaseItem on the "Cold Vaccine" grid row within ".itemGrid"
    And I should see "101" in grid row 2 column 2 within ".itemGrid"
    When I right click on the "The Flu" item
    And I click x-menu-item "Remove"
    Then I should not see "The Flu" in grid row 3 within ".itemGrid"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical POD" in grid row 2 within ".inventoryGrid"
    And "Medical POD" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "pod"
    Then "Medical POD" on site "Immunization Center" for scenario "Test" should have the following items:
      | name         | category           | quantity | consumable |
      | Gas Mask     | Emergency Supplies | 15       | true       |
      | Cold Vaccine | Immunizations      | 101      | true       |
    And "" on site "" for scenario "" should have the following items:
      | name          | category           | quantity | consumable |
      | Surgical Mask | Medical Supplies   |          | false      |
      | The Flu       | A Virus            |          | true       |

  Scenario: Load Items and Categories from existing items and categories
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following items exist:
      | name          | category         | consumable |
      | Surgical Mask | Medical Supplies | true       |
      | Cold Vaccine  | Immunizations    | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "New POD/Inventory" inventory onto the "Immunization Center" site
    Then the "Create POD/Inventory" window should be open
    When I fill in the following:
      | Inventory/POD Name | Medical Inventory |
      | Source             | DSHS              |
    And I choose "Inventory"
    And I press "Add Item"
    And I fill in "Item Name" with "Surgical Mask"
    And I select "Surgical Mask" from ext combo "Item Name"
    Then the "Category" field should contain "Medical Supplies"
    And the "Consumable" checkbox should be checked
    When I fill in "Quantity" with "1"
    And I press "Add"
    And I press "Add Item"
    And I fill in "Item Name" with "Flu Vaccine"
    And I fill in "Category" with "Imm"
    And I select "Immunizations" from ext combo "Category"
    And I fill in "Quantity" with "1"
    And I press "Add"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical Inventory" in grid row 2 within ".inventoryGrid"
    And "Medical Inventory" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "inventory"
    And "Medical Inventory" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 1        | true       |
      | Flu Vaccine   | Immunizations    | 1        | false      |

  Scenario: Edit Inventory to Make It a Template
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | false    |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I right click on the "Medical POD" inventory
    And I click x-menu-item "Edit"
    Then the "Edit POD/Inventory" window should be open
    And I check "Template"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical POD" in grid row 2 within ".inventoryGrid"
    And "Medical POD" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "pod"
    And "Medical POD" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    And I should have a "Medical POD" template with the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

  Scenario: Move Inventory
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi Center       | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    And the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | false    |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "Medical POD" inventory onto the "Malawi Center" site
    Then the "Move or Copy POD/Inventory" window should be open
    When I press "Move"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical POD" in grid row 2 within ".inventoryGrid"
    And "Medical POD" should exist on site "Malawi Center" for scenario "Test" with source "DSHS" and type "pod"
    And "Medical POD" on site "Malawi Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    And the site "Immunization Center" for scenario "Test" should have no inventories

  Scenario: Copy Inventory
    Given the following sites exist:
      | name                | address                                 | lat                 | lng              | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573           | -94.71391        | active | Test     |
      | Malawi Center       | Kenyatta, Lilongwe, Malawi              | -13.962475513490757 | 33.7866090623169 | active | Test     |
    And the following inventories exist:
      | name              | site                | scenario | source | type      | template |
      | Medical Inventory | Immunization Center | Test     | CDC    | inventory | true     |
    And the "Medical Inventory" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "Medical Inventory" inventory onto the "Malawi Center" site
    Then the "Move or Copy POD/Inventory" window should be open
    When I press "Copy"
    Then the "Copy POD/Inventory" window should be open
    And I wait for the "Loading..." mask to go away
    Then the "Name" field should contain "Copy of Medical Inventory"
    And the "Source" field should contain "CDC"
    And the "Inventory" checkbox should be checked
    Then the grid ".itemGrid" should contain:
      | Name          | Quantity |
      | Cold Vaccine  | 100      |
      | Surgical Mask | 10       |
    And the "Template" checkbox should not be checked
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then the grid ".inventoryGrid" should contain:
      | Name                      |
      | Medical Inventory         |
      | Copy of Medical Inventory |
    And "Medical Inventory" should exist on site "Immunization Center" for scenario "Test" with source "CDC" and type "inventory"
    And "Medical Inventory" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    And "Copy of Medical Inventory" should exist on site "Malawi Center" for scenario "Test" with source "CDC" and type "inventory"
    And "Copy of Medical Inventory" on site "Malawi Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

  Scenario: Delete Inventory
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    And the following inventories exist:
      | name        | site                | scenario | source | type | template |
      | Medical POD | Immunization Center | Test     | DSHS   | pod  | true     |
    And the "Medical POD" inventory has the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I right click on the "Medical POD" inventory
    And I click x-menu-item "Delete"
    Then the "Confirm Deletion" window should be open
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see "Medical Inventory" in grid row 2 within ".inventoryGrid"
    And the site "Immunization Center" for scenario "Test" should have no inventories

  Scenario: Create Inventory Template, Delete Created Inventory, and Initialize From Template
    Given the following sites exist:
      | name                | address                                 | lat       | lng       | status | scenario |
      | Immunization Center | 1303 Atkinson Dr, Lufkin, TX 75901, USA | 31.347573 | -94.71391 | active | Test     |
    When I open the "Test" scenario
    And I click x-accordion-hd "PODs/Inventories"
    And I drag the "New POD/Inventory" inventory onto the "Immunization Center" site
    Then the "Create POD/Inventory" window should be open
    When I fill in the following:
      | Inventory/POD Name | Medical Inventory |
      | Source             | DSHS              |
    And I choose "Inventory"
    And I check "Template"
    And I press "Add Item"
    When I fill in the following within ".addItemWindow":
      | Name       | Surgical Mask    |
      | Category   | Medical Supplies |
      | Quantity   | 10               |
    And I uncheck "Consumable" within ".addItemWindow"
    And I press "Add"
    When I press "Add Item"
    When I fill in the following within ".addItemWindow":
      | Name       | Cold Vaccine  |
      | Category   | Immunizations |
      | Quantity   | 100           |
    And I check "Consumable" within ".addItemWindow"
    And I press "Add"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then the grid ".inventoryGrid" should contain:
      | Inventory         |
      | Medical Inventory |
    And "Medical Inventory" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "inventory"
    And "Medical Inventory" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    And I should have a "Medical Inventory" template with the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

    And I right click on the "Medical Inventory" inventory
    And I click x-menu-item "Delete"
    And I press "Yes"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see "Medical Inventory" in grid row 2 within ".inventoryGrid"
    And the site "Immunization Center" for scenario "Test" should have no inventories
    And I should have a "Medical Inventory" template with the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |

    When I drag the "New POD/Inventory" inventory onto the "Immunization Center" site
    Then the "Create POD/Inventory" window should be open
    When I fill in "Name" with "Med"
    And I select "Medical Inventory" from ext combo "Name"
    Then the "Source" field should contain "DSHS"
    And the "Inventory" checkbox should be checked
    Then the grid ".itemGrid" should contain:
      | Name          | Quantity |
      | Cold Vaccine  | 100      |
      | Surgical Mask | 10       |
    And the "Template" checkbox should not be checked
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Medical Inventory" in grid row 2 within ".inventoryGrid"
    And "Medical Inventory" should exist on site "Immunization Center" for scenario "Test" with source "DSHS" and type "inventory"
    And "Medical Inventory" on site "Immunization Center" for scenario "Test" should have the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |
    And I should have a "Medical Inventory" template with the following items:
      | name          | category         | quantity | consumable |
      | Surgical Mask | Medical Supplies | 10       | false      |
      | Cold Vaccine  | Immunizations    | 100      | true       |