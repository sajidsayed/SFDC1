/*
Author:     Devi Prasad Bal
Created on: 23-April-2010
Description: This trigger would populate the emails of District Manager(contact) and District Manager 2(contact) to the
            fields District_Manager_Email__c and District_Manager_2_Email__c respectively
Modified by: 
Modified on: 
Reason:
*/

trigger EBC_updateGSE_EmailFields on EBC_Global_Strategic_Executive_Account__c (before insert, before update) {
// This trigger would populate the emails of District Manager(contact) and District Manager 2(contact) to the
// fields District_Manager_Email__c and District_Manager_2_Email__c respectively when size of system.trigger.new is 1 

    // Set to get all the contact ids those are District Manager or District Manager2
    Set<Id> con_ids = new Set<Id>();
    for(EBC_Global_Strategic_Executive_Account__c gseacc: System.Trigger.new)
    {
        con_ids.add(gseacc.District_Manager__c);
        con_ids.add(gseacc.District_Manager_2__c);
    }
    
    // Map of all the contacts whose ids are there in the Set above
    Map<Id,Contact> conDMMap= new Map<Id,Contact>([select id, Email from contact where Id IN: con_ids]);
    
    for(EBC_Global_Strategic_Executive_Account__c gseacc: System.Trigger.new)
    {
        if(conDMMap.keySet().contains(gseacc.District_Manager__c))
        {
            Contact c = conDMMap.get(gseacc.District_Manager__c);
            gseacc.District_Manager_Email__c = c.Email; 
        }
        if(conDMMap.keySet().contains(gseacc.District_Manager_2__c))
        {
            Contact c = conDMMap.get(gseacc.District_Manager_2__c);
            gseacc.District_Manager_2_Email__c = c.Email;   
        }
    }
}