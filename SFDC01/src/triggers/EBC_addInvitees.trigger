/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used to create/Delete Invitees.
   
    Modified History
    1. Modified By:- Vijo Joy
       Modified Reason:- To allow users to modify dates (start,end) when the briefing status is still 'requested'
       Modified on: Jan 3, 2013
       Modified for:- WR#207305
    
    2. Modified By:- Vijo Joy
       Modified Reason:- To set the requestor field, without recursively calling the 'EBC_AddEventFromBE' trigger.
       Modified on: 27th Feb, 2013
       Modified for:- WR#226913
*/
trigger EBC_addInvitees on EBC_Briefing_Event__c (before update,after update) {


    if(trigger.isBefore && trigger.new.size()==1)
    {                          

         
          //To check whether user has selected correct Briefing Venue or not.
          if(trigger.new[0].Briefing_Venue__c !=null)
           {
               EBC_Briefing_Venue__c[] bv=[Select id from EBC_Briefing_Venue__c where Briefing_Center__c=:trigger.new[0].Briefing_Center__c and Id=:trigger.new[0].Briefing_Venue__c];
               if(bv.size()==0)
               {
                  trigger.new[0].addError(System.Label.Invalid_Briefing_Venue+''); //If user select invalid Briefing Venue
               }                   
           }

            //If user update Briefing_Venue__c then Room_Assignment__c should be null as it will be updated again by VF page.
            if(trigger.new[0].Briefing_Venue__c != trigger.old[0].Briefing_Venue__c)
            {
               trigger.new[0].Room_Assignment__c=null;
            }
            
            //Vijo: WR#207305: modifying the below condition to exclude briefing event with 'requested' status
            //old condition-->if(trigger.new[0].Start_Date__c != trigger.old[0].Start_Date__c || trigger.new[0].End_Date__c != trigger.old[0].End_Date__c)
            if((trigger.new[0].Briefing_Status__c!='Requested'||trigger.old[0].Briefing_Status__c!='Requested') && (trigger.new[0].Start_Date__c != trigger.old[0].Start_Date__c || trigger.new[0].End_Date__c != trigger.old[0].End_Date__c))
            {
                trigger.new[0].Room_Assignment__c=null;
                trigger.new[0].Briefing_Status__c='Reschedule';
            }
        
			//Vijo: WR#226913:27th Feb: modifying the below condition to skip briefing events that has the requested status in either before or after update
           //old condition-->if(trigger.new[0].Requestor_Name__c !=null && trigger.new[0].Requestor_Name__c != trigger.old[0].Requestor_Name__c)
            if((trigger.new[0].Briefing_Status__c!='Requested'||trigger.old[0].Briefing_Status__c!='Requested')&&(trigger.new[0].Requestor_Name__c !=null && trigger.new[0].Requestor_Name__c != trigger.old[0].Requestor_Name__c))
            {
                Contact cont=[Select id,Email from Contact where Id =:trigger.new[0].Requestor_Name__c];
                Boolean userFound = false;
                if(cont.Email!=null)
                {
                    User[] usr=[Select Id from User where Email =:cont.Email and IsActive=true ];
                    if(usr.size()>0)
                    {
                        trigger.new[0].Requestor_Owner__c=usr[0].Id;
                        trigger.new[0].ownerId=usr[0].Id;
                        userFound = true;
                    }
                }
                if(!userFound)
                {
                    User[] usrs=[Select Id from User where Name=:'Default EBC User' Limit 1];
                    if(usrs.size()>0)
                    {
                       trigger.new[0].Requestor_Owner__c=usrs[0].Id;
                       trigger.new[0].ownerId=usrs[0].Id;
                    }   
                }
    

            }                 
    } 
    else if(trigger.isAfter)
    {
         //Deleting the Event record,if Briefing Status is Closed or Cancelled.
           if(trigger.new[0].Briefing_Status__c=='Cancel' && trigger.new[0].Standard_Event_Id__c!=null && trigger.new[0].Standard_Event_Id__c!='')
           {
                Event ev=new Event(Id=trigger.new[0].Standard_Event_Id__c);
                delete ev;
           }
           
           if(trigger.new[0].Room_Assignment__c ==null && trigger.old[0].Room_Assignment__c !=null)
           {
             EBC_Room_Calendar__c[] rc=[Select Id from EBC_Room_Calendar__c where Briefing_Event__c =: trigger.new[0].Id];
             if(rc.size() != 0)
             {
                delete rc;
             }
             
           }
    }
}