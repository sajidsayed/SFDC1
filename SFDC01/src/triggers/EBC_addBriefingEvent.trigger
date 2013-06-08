/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Description      :- This trigger will be called on insert and Update of Event and will create Briefing Even id related To field is blank.
  
   Modification History
1. Modified By :- Devi Bal
   Modified Reason:- Briefing Center Location to be populated with the new calendar location
   Modified On:-
   Modified For:-
   
2. Modified By:- Vijo Joy
   Modified Reason:- to prevent this trigger from executing recursively, when called from EBC_AddEventfromBE
   Modified On:- 12/12/12
   Modified For:-WR#207305

*/
trigger EBC_addBriefingEvent on Event (after insert,after update)
{

    
    //This code is used here to get record type id
    Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Event;
    Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('Briefing Event');
    Id rTypeId= record_Type_name_RT.getRecordTypeId();
   try
   { 
    if(trigger.new[0].RecordTypeId==rTypeId)
    { 
        String whatId;
        EBC_Briefing_Event__c bEvent;
        String assigned_to=trigger.new[0].OwnerId+'';
        if(assigned_to.subString(0,3)!='023')
        {
            trigger.new[0].addError(System.Label.EBC_EventfromPublicCalendar);
            return;   
        } 
    

        //for(Event ev:trigger.new)
        if(trigger.new.size()==1)
        {
            Date startDate;
            Date endDate;
            String strStdate = trigger.new[0].StartDateTime.formatGmt('MM/dd/yyyy');
            String[] arrStDate = strStdate.split('/');  
            String strenddate = trigger.new[0].EndDateTime.formatGmt('MM/dd/yyyy');
            String[] arrendDate = strenddate.split('/');
            
            
            startDate= Date.newInstance(integer.valueOf(arrStDate[2]), integer.valueOf(arrStDate[0]), integer.valueOf(arrStDate[1]));
            endDate= Date.newInstance(integer.valueOf(arrendDate[2]), integer.valueOf(arrendDate[0]), integer.valueOf(arrendDate[1]));

            
            if(trigger.isInsert)
            {
                EBC_addCustomInvitees.createInvitees=false;
                
                
                //This condition is used here to check whether selected whatid is Briefing Event or not.
                if(trigger.new[0].WhatId!=null)
                {
                    whatId=trigger.new[0].WhatId+'';
                    if(whatId.startsWith('a0k'))
                    {
                        EBC_Briefing_Event__c briefEvent=[Select id,Briefing_Status__c from EBC_Briefing_Event__c where Id=:whatId];
                        //Vijo: Code added to skip this trigger if the status of briefing status is requested in either of trigger states
                        if(briefEvent.Briefing_Status__c=='Requested')
                        return;
                        //End of code
                        
                        if(briefEvent.Briefing_Status__c!='Cancel')
                        {
                            trigger.new[0].addError(System.Label.EBC_SelectCancelBriefingEvent);
                            return;
                        }
                        
                        //Devi: The following 2 lines are being added to populate the Briefing Center Location with the new calendar location [WR#148089]
                        Event eve=[Select Owner.Name from Event where Id=:trigger.new[0].Id];
                        EBC_Briefing_Center__c[] bc=[Select Id,Name from EBC_Briefing_Center__c where Name=:eve.Owner.Name];
                        
                        bEvent=new EBC_Briefing_Event__c(Projected_of_Attendees__c=trigger.new[0].Projected_Number_of_Attendees__c,Briefing_Status__c='Reschedule',Name=trigger.new[0].Subject,Id=trigger.new[0].WhatId, Briefing_Center__c=bc[0].Id, Start_Date__c=startDate, End_Date__c=endDate,Standard_Event_Id__c=trigger.new[0].Id);
                        update bEvent;
                    }
                    else
                    {
                        trigger.new[0].addError(System.Label.EBC_SelectBEventInWhatId);
                        return;
                    }
                }
                else if(trigger.new[0].WhatId==null)
                {
                   Event eve=[Select Owner.Name,StartDateTime,EndDateTime from Event where Id=:trigger.new[0].Id];
                   EBC_Briefing_Center__c[] bc=[Select Id,Name from EBC_Briefing_Center__c where Name=:eve.Owner.Name];
                   //If Briefing Centre is already available.
                   if(bc.size()>0)
                   {               
                      bEvent=new EBC_Briefing_Event__c(Projected_of_Attendees__c=trigger.new[0].Projected_Number_of_Attendees__c,Name=trigger.new[0].Subject,Briefing_Center__c=bc[0].Id,Start_Date__c=startDate,End_Date__c=endDate,Standard_Event_Id__c=trigger.new[0].Id,Briefing_Status__c='Pending');
                      insert bEvent;
                      eve.WhatId=bEvent.Id;
                      update eve;
                   }
                   else
                   {
                     trigger.new[0].addError(System.Label.EBC_NoBriefingCenterFound);
                     return;
                   }
                }
                EBC_addCustomInvitees.asynchCreateInvitees(bEvent.Id);
                
                EBC_addCustomInvitees AI=new EBC_addCustomInvitees();
                //This method is called here to create Invitee with Scheduler role.
                AI.createSchedulerInvitee(bEvent.Id,trigger.new[0].CreatedById);
            }
            //If event is update
            else if(EBC_addCustomInvitees.createInvitees==true && trigger.isUpdate)
            {
             //Vijo: Code added to skip this trigger if the status of briefing status is requested in either of trigger states
             EBC_Briefing_Event__c briefEvent=[Select id,Briefing_Status__c from EBC_Briefing_Event__c where Id=:trigger.new[0].WhatId];
             if(briefEvent.Briefing_Status__c=='Requested')
             return;
             //End of code
             
               // trigger.new[0].addError('my date = '+startDate);
              if(trigger.new[0].WhatId !=trigger.old[0].WhatId)
              {
                trigger.new[0].addError(System.Label.EBC_CannotChangeWhatId);
                return;
              }
              
              EBC_addCustomInvitees.createInvitees=false;
              whatId=trigger.new[0].WhatId+'';
              //If what Id is Briefing Event Id
              if(whatId.subString(0,3)=='a0k')
              {
                bEvent=new EBC_Briefing_Event__c(Projected_of_Attendees__c=trigger.new[0].Projected_Number_of_Attendees__c,Name=trigger.new[0].Subject,Id=trigger.new[0].WhatId,Start_Date__c=startDate, End_Date__c=endDate,Standard_Event_Id__c=trigger.new[0].Id); 
                 
                 update bEvent;
              }
              //Called this method here to add Invitees in Briefing Event
              EBC_addCustomInvitees.asynchCreateInvitees(bEvent.Id);

            }
        }
    }
   }
   catch(DMLException e)
   {
     trigger.new[0].addError(e+'');
   }
}