/*
Trigger Name: ReportingSegmentationValuesPopulation
Task: To update Reporting Segmentation Group and Reporting Segmentation fields on Account when Step-3b is created as part of WR-200868
Release : Oct'12 Release
Author: Jayaraju Nulakachandanam
Test Class Name: ReportingSegmentationValuesPopulation_TC
*/

/* 
Date of Modification        Release        Purpose                                        Modified by

*/
trigger ReportingSegmentationValuesPopulation on Authorized_Reseller_Onboarding_Task__c (before insert) 
{
    //Getting the specific record type
    Schema.DescribeSObjectResult des = Schema.SObjectType.Authorized_Reseller_Onboarding_Task__c; 
    Map<String,Schema.RecordTypeInfo> rtMapByName = des.getRecordTypeInfosByName();
    Schema.RecordTypeInfo rtByName =  rtMapByName.get('Task Step 3a,3b,3c');
    Id Step3bRecId = rtByName.getRecordTypeId();      
   
    //Retrieving the required Auth Reseller records on which the account is to be updated
    for(Authorized_Reseller_Onboarding_Task__c AROT:trigger.new)
    {      
        //AuthReseIds.add(AROT.Partner_Onboarding__c.id);
        //system.debug('Step3bRecId'+Step3bRecId+'AROT'+AROT);
        if(AROT.RecordTypeId==Step3bRecId)
        {

           //system.debug('AROT.Partner_Onboarding__c'+AROT.Partner_Onboarding__c);
           
           Partner_Onboarding__c AuthPartOnb = [select id,name,Authorized_Reseller_Account__c from Partner_Onboarding__c where id=: AROT.Partner_Onboarding__c limit 1];

           Account ac= [select id,name,Reporting_Segmentation_Group__c,Reporting_Segmentation__c
                        from Account where id=:AuthPartOnb.Authorized_Reseller_Account__c limit 1];  
           //system.debug('ac'+ac);
               
           ac.Reporting_Segmentation_Group__c = 'Distributor';
           ac.Reporting_Segmentation__c='RESELLER - INDIRECT RESELLER';           
                
           update ac;

        }
    }
}