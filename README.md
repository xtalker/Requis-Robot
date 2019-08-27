# Requis-Robot
This is the Robot Framework test environment for testing Requis.com

The Robot Framework allows test cases to be written in a BDD/"Cucumber" type style.  The test case automation is
implemented with "keywords" that are coded to perform all the steps in a test case.  Test case dirs and files are numbered to
guarantee execution order.  A dir containing test case files is an implied test suite.

A test case file typically has three sections:
   Settings:  Things required to setup the test environment before the test cases are executed
   Variables: Variables common to all the test cases in this file
   Test Cases:  The test cases themselves made up of the test name and the keywowrds required to implement it
   Keywords:  The definition of each keyword used in a test case
   

