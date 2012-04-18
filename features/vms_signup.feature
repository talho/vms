@ext @vms
Feature: VMS Signup

  In order to view and manage qualifications and alerts
  As a VMS volunteer
  I would like a profile tab with qualification and alert columns

  Background:
    Given the following entities exist:
      | Jurisdiction | Test County |      |
      | Jurisdiction | Texas       |      |
      | Role         | Public      | phin |
      | Role         | Volunteer   | vms  |
    And I visit the url "/vms/users/new"

  Scenario: Sign up as a VMS Volunteer
    When I fill in "First Name" with "VMS Test"
    And I fill in "Last Name" with "User"
    And I fill in "Email Address" with "vmstestuser@example.com"
    And I fill in "Password" with "Password1"
    And I fill in "Password Confirmation" with "Password1"
    And I select "Test County" from "Home County"
    And I press "Sign Up"
    And "vmstestuser@example.com" should have the "Volunteer" role in "Test County"
    And "vmstestuser@example.com" should not have the "Public" role in "Texas"
    And "vmstestuser@example.com" should not have the "Public" role in "Test County"