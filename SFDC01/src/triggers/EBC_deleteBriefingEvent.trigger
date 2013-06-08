/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used to change Briefing Event status on deletion of Event.
*/
trigger EBC_deleteBriefingEvent on Event (after delete, before delete)
{
    String whatid=trigger.old[0].WhatId+'';
    
    //This code is usde here to fetch record type id.
    Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Event;
    Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('Briefing Event');
    Id rTypeId= record_Type_name_RT.getRecordTypeId();
                
    if(trigger.isAfter && trigger.old[0].RecordTypeId==rTypeId && whatid.subString(0,3)=='a0k')
    {
        EBC_Briefing_Event__c bEvent=new EBC_Briefing_Event__c(Id=trigger.old[0].WhatId);
        bEvent.Standard_Event_Id__c=null;
        bEvent.Briefing_Status__c='Cancel';
        update bEvent;
        
        List<EBC_Invitees__c> delInvitees=new List<EBC_Invitees__c>();
        List<EBC_Invitees__c> updateInvitees=new List<EBC_Invitees__c>();
        EBC_Invitees__c[] invitees=[Select id,Briefing_Team_Role__c,Sites_Invitee__c from EBC_Invitees__c where Briefing_Event__c=:bEvent.Id];
        
        
        for(Integer i=0;i<invitees.size();i++)
        {
             if(invitees[i].Briefing_Team_Role__c=='Scheduler')
             {
                delInvitees.add(new EBC_Invitees__c(Id=invitees[i].Id));
             }
             else
             {
                updateInvitees.add(new EBC_Invitees__c(Id=invitees[i].Id,Sites_Invitee__c=true));
             }
        }
       
        delete delInvitees;
        update updateInvitees;
    }
}