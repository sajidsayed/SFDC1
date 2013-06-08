/*
Author:     Devi Prasad Bal
Created on: 04-April-2010
Description: This class contains test method for the trigger EBC_updateGSE_EmailFields.cls
Modified by: 
Modified on: 
Reason:
*/

@isTest
private class EBC_updateGSE_EmailFields_TC {
    static testMethod void validateUpdateGSE_EmailFields() {
        
        Account acc = new Account(Name='Acc');
        insert acc;
        Contact con = new Contact(LastName='LN', Account=acc , Email='zdpeoafdslk.def@xyz.com');
        insert con;
        Contact con2 = new Contact(LastName='LN2', Account=acc , Email='zxaouod.def@xyz.com');
        insert con2;
        
        EBC_Global_Strategic_Executive_Account__c gseacc = new EBC_Global_Strategic_Executive_Account__c(Name='GSE_acc', District_Manager__c=con.Id, District_Manager_2__c=con2.Id);
        insert gseacc;
    }
}