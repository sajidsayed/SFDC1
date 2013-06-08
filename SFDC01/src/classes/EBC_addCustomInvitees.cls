/*
*  Created By       :- Sunil Arora
*  Created Date     :- 08/03/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This class will be called by EBC_addBriefingEvent trigger to create/delete Invitee records.
*/
public class EBC_addCustomInvitees 
{  
    public static boolean createInvitees=true; //This variable is used here, so that we don't insert/Delete Invitees, if we are upodating BE from Standard Event.
    
   
    
    EventAttendee[] eAttendee;
       
       @future
       //This method is used to call createInvitees method asynchronously.
       //This is done so that the method gets a time-lag during which the  
       //invitees get added to the eventAttendee object. 
       public static void asynchCreateInvitees(Id bId)
       {   
            try
            {
                createInvitees(bId);
            }
            catch(Exception e)
            {
                
            }
       }   
       
      //This method is used to create Invitee record with Role as Scheduler.
      public void createSchedulerInvitee(Id bId,Id CreatedById)
      {
        
            List<EBC_Invitees__c> new_inviteesLst = new List<EBC_Invitees__c>();
            //Created by Id
            User usr=[Select Id,Email,FirstName,LastName,Title from User where Id=:CreatedById];
            
            Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
                Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
                Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
                Id internalContact= record_Type_name_RT.getRecordTypeId();
            
            Contact[] EBC_Contact=[Select Id,FirstName,LastName,Email,RecordTypeId,Account.RecordTypeId,Account.Name,Title
                                  From Contact 
                           where Email =:usr.Email and Active__c=true];
            if(EBC_Contact.size()>0)
            {
                EBC_Invitees__c invitee = new EBC_Invitees__c (
                                                       Briefing_Team_Role__c='Scheduler',
                                                       Last_Name__c=EBC_Contact[0].LastName,
                                                       First_Name__c=EBC_Contact[0].FirstName,
                                                       Contact__c=EBC_Contact[0].Id,
                                                       Attendee_Email__c=EBC_Contact[0].Email,
                                                       From_Object__c='Event',
                                                       EBC_Title__c=EBC_Contact[0].Title,
                                                       EBC_Name__c=EBC_Contact[0].FirstName+' '+EBC_Contact[0].LastName,
                                                       Briefing_Event__c=bId);
                
                if(EBC_Contact[0].RecordTypeId==internalContact)
                {
                     invitee.Company__c='EMC Corporation';
                }
                else
                {
                    invitee.Company__c=EBC_Contact[0].Account.Name;
                }
                 
                new_inviteesLst.add(invitee);                                         
            }
            else
            {
                 EBC_Invitees__c invitee = new EBC_Invitees__c (
                                                       Briefing_Team_Role__c='Scheduler',
                                                       Last_Name__c=usr.LastName,
                                                       First_Name__c=usr.FirstName,
                                                       Attendee_Email__c=usr.Email,
                                                       EBC_Name__c=usr.FirstName+' '+usr.LastName,
                                                       EBC_Title__c=usr.Title,
                                                       From_Object__c='Event',
                                                       Briefing_Event__c=bId);
                new_inviteesLst.add(invitee);                   
            }
        insert new_inviteesLst;
      }
      
      
      
      private static String EXC_PROCID = 'EBC_addCustomInvitees';
      
       //This method is used here to create Invitees from Event Attendees.
       public static void createInvitees(Id bId)
       {         
          List<EventAttendee> attendeesToAddLst = new List<EventAttendee>();
          List<EBC_Invitees__c> attendeesToDeleteLst =new List<EBC_Invitees__c>(); //Creating a list of Invitees (needs to be deleted), in this List
          Set<Id> attendeeIds=new Set<Id>();
          Set<Id> contactIdSet = new Set<Id>();
          Set<String> attendeeEmail = new Set<string>();
          List<String> userEmailLst = new List<string>();
          List<EBC_Invitees__c> new_inviteesLst = new List<EBC_Invitees__c>();
          Set<String> userEmailSet = new Set<string>();
          List<String> userFirstNameLst = new List<string>();
          List<String> userLastNameLst = new List<string>();
          List<String> userTitleLst = new List<string>();
          
         
         
         List <EMCException> errors_Lst = new List <EMCException>();
         Database.DeleteResult[] delResults = null;//This array is used here to get delete results.
         Database.SaveResult[] saveResults = null; //This array is used here to get save results.
        
        
                Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
                Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
                Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
                Id internalContact= record_Type_name_RT.getRecordTypeId();
                
                Schema.DescribeSObjectResult myObjectSchem = Schema.SObjectType.Account;
                Map<String,Schema.RecordTypeInfo> rtMapByNam = myObjectSchem.getRecordTypeInfosByName();
                Schema.RecordTypeInfo record_Type_name_R = rtMapByNam.get('Partner Account Record Type');
                Id partnerAccount= record_Type_name_R.getRecordTypeId();        
         Set<string> inviteeEmailSet=new Set<String> ();
           
           //This call is used here to fetch existing Invitees.                                     
            EBC_Invitees__c[]  inviteeRecordLst =[Select Id,Briefing_Team_Role__c,Event__c,Attendee_Email__c,Contact__c,From_Object__c from EBC_Invitees__c 
                                                         where Briefing_Event__c =: bId and 
                                                         (Briefing_Team_Role__c='EMC Employee' or Briefing_Team_Role__c='Other Invitee' or
                                                          Briefing_Team_Role__c='Customer' or Briefing_Team_Role__c='Partner' or 
                                                          Briefing_Team_Role__c='Briefing Advisor' or Briefing_Team_Role__c='Requestor' or 
                                                          Briefing_Team_Role__c='Logistic Advisor' or Briefing_Team_Role__c='Account Team Member')];
                                                          
                                                         
            
           //This call is used here to fetch Event Attendees
           EventAttendee[] eAttendee = [Select EventId,Event.WhatId, Attendee.Email, Attendee.FirstName, Attendee.LastName,Attendee.Title, AttendeeId 
                                                    From EventAttendee where Event.WhatId=: bId];
           //This loop is used here to fetch records which needs to be deleted.
           for (Integer i=0;i<inviteeRecordLst.size();i++)
           {
               Boolean flag=false;
               for(Integer j=0;j<eAttendee.size();j++)
               {
                if(eAttendee[j].Attendee.Email!=null)
                {
                    if((eAttendee[j].Attendee.Email== inviteeRecordLst[i].Attendee_Email__c && inviteeRecordLst[i].From_Object__c=='Event') || inviteeRecordLst[i].From_Object__c!='Event')
                    {
                        flag=true;
                        break;
                    }
                }
                else
                {
                      if((eAttendee[j].AttendeeId== inviteeRecordLst[i].Contact__c && inviteeRecordLst[i].From_Object__c=='Event') || inviteeRecordLst[i].From_Object__c!='Event')
                        {
                            flag=true;
                            break;
                        }
                }
               }
                
                if(flag==false)
                {
                    attendeesToDeleteLst.add(inviteeRecordLst[i]);
                }   
           }
           

           
           
           //This loop is used here to get List of records needs to be inserted in Invitees.
           for(Integer i=0;i<eAttendee.size();i++)
           {
             attendeeIds.add(eAttendee[i].AttendeeId);
             Boolean flag=false;
             String attId=eAttendee[i].AttendeeId+'';                   
             //If attId is Contact Id
             
             if(attId.substring(0,3)=='003')
             {
                for (Integer j=0;j<inviteeRecordLst.size();j++)
                {
                    if(eAttendee[i].AttendeeId== inviteeRecordLst[j].Contact__c && inviteeRecordLst[j].From_Object__c=='Event')
                    {
                        flag=true;
                        break;
                    }
                }
             }
             else
             {
                for (Integer j=0;j<inviteeRecordLst.size();j++)
                {
                    if(eAttendee[i].Attendee.Email== inviteeRecordLst[j].Attendee_Email__c && inviteeRecordLst[j].From_Object__c=='Event')
                    {
                        flag=true;
                        break;
                    }
                }
             }
             if(flag==false)
             {
                attendeesToAddLst.add(eAttendee[i]);
             }
           }
           
           //delete attendeesToDeleteLst;
           delResults = database.delete(attendeesToDeleteLst);
           
        //This code is used here for exception handling
        for (integer j = 0; j < delResults.size(); j++) {
        Database.DeleteResult dr = delResults[j];
        String dataErrs = '';
        if (!dr.isSuccess()) {
            // if the particular record did not get deleted, we log the data error 
            
            for (Database.Error err : dr.getErrors()) {
                dataErrs += err.getMessage();
            }
             errors_Lst.add(new EMCException(dataErrs, EXC_PROCID + ':DeleteAttendees', new String [] {delResults[j].Id}));
             EMC_UTILITY.logErrors(errors_Lst);
             errors_Lst.clear();
        }
    }


        for(Integer i=0;i<attendeesToAddLst.size();i++)
        {
            String AttendeeId=attendeesToAddLst[i].AttendeeId+'';
            //If attId is Contact Id
            if(AttendeeId.subString(0,3)=='003')
            {
                contactIdSet.add(attendeesToAddLst[i].AttendeeId);
            }
            //If attId is user Id
            else if(AttendeeId.subString(0,3)=='005')
            {       
                userEmailLst.add(attendeesToAddLst[i].Attendee.Email);
                userEmailSet.add(attendeesToAddLst[i].Attendee.Email);
                userFirstNameLst.add(attendeesToAddLst[i].Attendee.FirstName);
                userLastNameLst.add(attendeesToAddLst[i].Attendee.LastName);
                userTitleLst.add(attendeesToAddLst[i].Attendee.Title);
            }
        }
       
     
        
        List<Contact> con=new List<Contact>();
        List<Contact> userContacts=new List<Contact>();
        // This query is used here to fetch Contact Details to create Invite records
        Contact[] cont=[Select Id,FirstName,Lastname,Email,RecordTypeId,Account.RecordTypeId,Title,Account.Name
                              From Contact 
                       where Active__c=true and (id IN:contactIdSet or Email IN:userEmailSet) ];
        for(Integer i=0;i<cont.size();i++)
        {
            if(userEmailSet.contains(cont[i].Email))
            {
                userContacts.add(cont[i]);
            }
            else
            {
                con.add(cont[i]);
            }
        }
        
        for(Integer i=0;i<userEmailLst.size();i++)
        {
            Integer counter=0;
            Contact matchingContact;
            for(Integer j=0;j<userContacts.size();j++)
            {
                if(userEmailLst[i]==userContacts[j].Email)
                {
                    counter=1;
                    matchingContact=userContacts[j];
                    break;
                }
            }
            if(counter==0)
            {
                new_inviteesLst.add(new EBC_Invitees__c (Briefing_Team_Role__c='Other Invitee',
                                                   Last_Name__c=userLastNameLst[i],
                                                   First_Name__c=userFirstNameLst[i],
                                                   Attendee_Email__c=userEmailLst[i],
                                                   From_Object__c='Event',
                                                   EBC_Name__c=userFirstNameLst[i]+' '+userLastNameLst[i],
                                                   EBC_Title__c=userTitleLst[i],
                                                   Attending__c=true,
                                                   Briefing_Event__c=bId));
            }
            //if(counter==1 && attendeeIds.contains(matchingContact.Id)==false)
            
            if(counter==1)
            {
                con.add(matchingContact);
            }
        }
        
        if(con.size()>0)
        {
            for(Integer i=0;i<con.size();i++)
            {   
                
                EBC_Invitees__c invitee = new EBC_Invitees__c (
                                                       Last_Name__c=con[i].LastName,
                                                       First_Name__c=con[i].FirstName,
                                                       Contact__c=con[i].Id,
                                                       Attendee_Email__c=con[i].Email,
                                                       From_Object__c='Event',
                                                       Attending__c=true,
                                                       Briefing_Event__c=bId,
                                                       EBC_Name__c=con[i].FirstName+' '+con[i].LastName,
                                                       EBC_Title__c=con[i].Title);
                if(con[i].recordTypeId==internalContact)
                {
                    invitee.Company__c='EMC Corporation';
                }
                else
                {
                    invitee.Company__c=con[i].Account.Name;
                }
                
                
                
                

                
                
                //if(con[i].RecordTypeId=='012S00000000JE8IAM')
                if(con[i].RecordTypeId==internalContact)
                {
                    invitee.Briefing_Team_Role__c='EMC Employee';
                    
                }
                else if(con[i].Account.RecordTypeId==partnerAccount)
                {
                   invitee.Briefing_Team_Role__c='Partner';
                }
                else
                {
                    invitee.Briefing_Team_Role__c='Customer';
                }
                new_inviteesLst.add(invitee);  
            } 
            }
        
        if(new_inviteesLst.size()>0)
        {
             
             //insert new_inviteesLst;
             saveResults = database.insert(new_inviteesLst);
            //createorUpdateRecords(saveResults);
            
            
            for (integer i = 0; i < saveResults.size(); i++) {
                Database.SaveResult sr = saveResults[i];
                String dataErrs = '';
                if (!sr.isSuccess()) {
                    // if the particular record did not get deleted, we log the data error                    
                    for (Database.Error err : sr.getErrors()) {
                        dataErrs += err.getMessage();
                    }
                    errors_Lst.add(new EMCException(dataErrs, EXC_PROCID + ':InsertInvitees', new String [] {}));
                    EMC_UTILITY.logErrors(errors_Lst);
                    errors_Lst.clear();
                }
                }
              
        }   
            
       }
}