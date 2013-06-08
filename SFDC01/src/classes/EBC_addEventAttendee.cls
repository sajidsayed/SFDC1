/*
*  Created By       :- Vijo Joy
*  Created Date     :- 16th Feb, 2013
*  Last Modified By :- 
*  Description      :- This class will be called by EBC_addEventfromBE trigger to create attendees
*/

// please note : do not change the version below 27. Explanation given below
public class EBC_addEventAttendee {
    
    /*
    The future method is used to create requestor invitee record in a briefing event.
    This escapes the recurrent calling of calling trigger, EBC_AddEventfromBE, since the method will be excuted after a delay 
    and not within the calling trigger itself
    The method takes the contact id/user id and the briefing event id as parameters
    */
    
    @future
    public static void toCreateRequestorinvitee(Id theRequestorId, Id theBEventId)
    {
        try 
        {
        createRequestorInvitee(theRequestorId, theBEventId);
        }
        catch(Exception e)
        {
        }
    }
            
    //This method is used to create EventAttendee records, in the event object
    //This method uses the latest object, EventRelation, made available in Spring 2013 release, and hence the version
    //should be 27 and above. Any lower versions does not provide ability to create EventAttendee records thru API.
    //Use link for more info: http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_objects_eventattendee.htm
    public void createEventAttendee(Id calEventId, Id eAttendeeId ) {
    
    EventRelation er = new EventRelation(EventId = calEventId,
                                         RelationId = eAttendeeId);
    insert er;
    }
    
    //This method is used to set the requestor name field with the relevant contact, and return appropriate error flags as appropriate
    public String getTheRequestor(Id userId){
    GenUtilMethods uTil = new GenUtilMethods();// utility method to get map of record type(key) and record type id(value)
    User u = [Select id, Name, Email from User where id=:userId LIMIT 1];// getting the created by user info and email
    List<Contact> con = [Select id, RecordTypeId from Contact where Email =:u.Email LIMIT 1];//using the email from above user, to get contact details
    if(con.size()>0){
        if(con[0].RecordTypeId != uTil.getRecordTypesMap('Contact').get('EMC Internal Contact'))
        Return 'Error 2';// if the record type is not internal contact, then the EBC_AddEventfromBE trigger must throw an error. The string 'Error 2' tells what error should be fired
        else
        Return con[0].id+'';// since the contact is valid, the id is passed as a string
    }
    else
    Return 'Error 1';//if a contact is not present for that user, then the EBC_AddEventfromBE trigger must throw an error. The string 'Error 1' tells what error should be fired
    }    
       
    //This method is used to create requestor invitee in briefing event. this will be called after the requestor name field has been set.
    public static void createRequestorInvitee(Id requestorId, Id bEventId) {
    
    String reqId = requestorId+'';
    //A contact already set in requestor field, and hence creating a requestor invitee
    if(reqId.subString(0,3)=='003') {
    Contact reqContact = [Select FirstName, Lastname, Email, Title From Contact where Id =: requestorId];
    EBC_Invitees__c reqInvitee = new EBC_Invitees__c( Briefing_Team_Role__c='Requestor',
                                                      Last_Name__c= reqContact.Lastname,
                                                      First_Name__c= reqContact.FirstName,
                                                      Attendee_Email__c= reqContact.Email,
                                                      From_Object__c='Event',
                                                      EBC_Name__c=reqContact.FirstName+' '+reqContact.Lastname,
                                                      EBC_Title__c= reqContact.Title,
                                                      Attending__c=true,
                                                      Briefing_Event__c= bEventId,
                                                      Contact__c= reqContact.id);
    insert reqInvitee;
    Return;
    } 
    /* the below code has been commented, but could be used at a later date. It says that a requestor invitee can be created thru a user id too.
    //if the id starts with 005, implies that its the created by user who has to be assigned as the requestor invitee
    else if(reqId.subString(0,3)=='005') {
    User reqUser = [Select FirstName, Lastname, Email, Title From User where Id =: requestorId];
    Contact reqCont = [Select FirstName, Lastname, Email, Title From Contact where Email =: reqUser.Email LIMIT 1];
    EBC_Invitees__c reqInvitee = new EBC_Invitees__c( Briefing_Team_Role__c='Requestor',
                                                      Last_Name__c= reqUser.Lastname,
                                                      First_Name__c= reqUser.FirstName,
                                                      Attendee_Email__c= reqUser.Email,
                                                      From_Object__c='Event',
                                                      EBC_Name__c=reqUser.FirstName+' '+reqUser.Lastname,
                                                      EBC_Title__c= reqUser.Title,
                                                      Attending__c=true,
                                                      Briefing_Event__c= bEventId,
                                                      Contact__c= reqCont.id);
    insert reqInvitee;
    Return;
    }
    */
   }
}