trigger updateHours on Worksheet__c (after update) {
for(Integer i=0;i< Trigger.New.Size(); i++){
System.debug('New Value Planned: ' + Trigger.New[i].Actual_Hours_Planned1__c);
System.debug('Old Value Planned: ' + Trigger.Old[i].Actual_Hours_Planned1__c);
System.debug('New Value UnPlanned: ' + Trigger.New[i].Actual_Hours_Unplanned1__c);
System.debug('Old Value UnPlanned: ' + Trigger.Old[i].Actual_Hours_Unplanned1__c);
if((Trigger.New[i].Actual_Hours_Planned1__c == Trigger.Old[i].Actual_Hours_Planned1__c) && (Trigger.New[i].Actual_Hours_Unplanned1__c == Trigger.Old[i].Actual_Hours_Unplanned1__c))
            return;
        else
    new WorksheetPopulateOnRequirement().PopulateDetails();
    //Trigger.New[i].AfterUpdateHourTriggerFlag__c=true;
    }
   
    
    }