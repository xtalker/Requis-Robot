# Requis-Robot
This is the Robot Framework test environment that I used to test Requis.com

The vision driving Requis.com was to become integral to a targeted industry's supplychain management by creating an online marketplace for surplus capital equipment.  By creating a web app with a user experience something like Amazon/Ebay only focused not on consumers but the B2B supplychain.  The major workflows in this app included buying, listing, selling and auctions.  Initially targeted at the oil & gas and IT idustries.

The Robot Framework allows test cases to be written in a BDD/"Cucumber" type style.  The test case automation is
implemented with "keywords" that are coded to perform all the steps in a test case.  

Test case dirs and files are numbered to guarantee execution order.  
A dir containing test case files is an implied test suite.

A test case (.robot) file typically has three sections:

   Settings:  Things required to setup the test environment before the test cases are executed.
   
   Variables: Variables common to all the test cases in this file.
   
   Test Cases:  The test cases themselves made up of the test name and the keywowrds required to implement it.
   
   Keywords:  The definition of each keyword used in a test case.
   

