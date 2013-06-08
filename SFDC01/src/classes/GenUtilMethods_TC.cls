/*
Created by: Vijo Joy
Created On: Feb 18th, 2013
Description: Test class to test the EBC_addEventAttendee class
Work Request/eRFC: WR226913

****Modification History****
    Modified By: 
    Modified On:
    Description:
    Work Request/eRFC:

*/
@isTest
private class GenUtilMethods_TC {
    
    //Test 1: To test for the known Sobject Event(standard object)
    //Event contains 2 record types, Briefing Event and standard Event
    static testMethod void test_valid_SObject(){
    //initialising the utility method
    GenUtilMethods testGUM = new GenUtilMethods();
    //testing...
    Map<String,id> testMapRecTypeIds = testGUM.getRecordTypesMap('Event');
    System.assertEquals(true, testMapRecTypeIds.containsKey('Briefing Event'));
    System.assertEquals(true, testMapRecTypeIds.containsKey('Standard Event'));
    }
    //Test 2: to test for the exception, for an illogical SObject
    static testMethod void test_invalid_SObject(){
    //initialising the utility method
    GenUtilMethods testGUM = new GenUtilMethods();
    //testing...
    Map<String,id> testMapRecTypeIds = testGUM.getRecordTypesMap('MyObject');
    System.assertEquals(null, testMapRecTypeIds);
    }
      
}