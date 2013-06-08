/*
Author:     Sunil Bansal
Created on: 25-Nov-2009
Description: This page allows to enter custom attribiutes on the Contact(Invitee) for an Briefing Event.
This class is controller for Page(s): EBC_Briefing_Team_Attributes
Modified by: Devi Prasad Bal
Modified on: 05-April-2010
Reason: Modified based on further inputs from the business
Modified by: Naveen Hiremath
Modified on: 12-Jan-2012
Reasons:
1.Add the ability to edit Attendee
2.On the briefing attributes page, allow users to edit the invitees that were manually entered
3.Invitee__c is a formula of first_Name__c white space Last_Name__c that is made editable via inputtext
4.Edited Invitee__c name on the VF page will be copied to First_Name__c and Last_Name__c and saved
5.Invitee name now supports title
*/
public class EBC_Update_Briefing_Team_Attributes
{

    public EBC_Invitees__c[] inviteeList {get; set;} // to hold records list for diplay 
    public EBC_Briefing_Event__c briefingEvent {get; set;}
    public String ErrorMsg;
    
    public Id requestorId; // to hold the id of the contact whose role is that of a Requestor
    public Boolean requestorRole = false;
    public Id briefingAdvisorId; // to hold the id of the contact whose role is that of a Briefing Advisor
    public Boolean briefingAdvisorRole = false;
    public Id logisticAdvisorId; // to hold the id of the contact whose role is that of a Logistic Advisor
    public Boolean logisticAdvisorRole = false;
    
    //String emailRegex = '^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\\-+)|([A-Za-z0-9]+\\.+)|([A-Za-z0-9]+\\++))*[A-Za-z0-9]+@((\\w+\\-+)|(\\w+\\.))*\\w{1,63}\\.[a-zA-Z]{2,6}$';
    //Boolean expMatches=true;
    //public Boolean bErrorFound = false;
    public Id briefingEventId; // id of the parent Briefing Event Object
    public Integer invListCount 
    {
        get{
            if(inviteeList != null)
                return inviteeList.size();
            else
                return 0;
        } 
        set;
    }
    
    
    // constructor
    public EBC_Update_Briefing_Team_Attributes() 
    {
        try
        {
            briefingEventId = System.currentPageReference().getParameters().get('id');
            briefingEvent = [Select id, name, Requestor_Name__c, Briefing_Advisor__c, Logistic_Advisor__c  from EBC_Briefing_Event__c where id =:briefingEventId];
        }
        catch(StringException strEx)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.Valid_BE_id ));
            return;
        }
        //******add validation that Id is passed and valid
        Integer iBriefing = [Select count() from EBC_Briefing_Event__c a where a.Id =:briefingEventId];
        if(iBriefing == null || iBriefing < 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.BE_deleted_or_not_valid));
            return;
        }
    }
    
   
    // This method is called when Update is clicked on VF page and for updating the records
    public PageReference updateAttributes()
    {
        try
        {
            setBlankValuesToInviteeList();
            ErrorMsg = validations();
            if(ErrorMsg != '')
            {
                return null;
            }       
            Boolean updBriefingEvent = false;
            // delete the field value of Requestor if none of the members of the Briefing Team is a Requestor
            if(requestorRole == false ) 
            {
                briefingEvent.Requestor_Name__c = null;
                updBriefingEvent = true;
            }
            // assign the new Contact Id value in the Requestor field of the Briefing Event if the Requestor is changed
            else if(requestorRole == true && requestorId != briefingEvent.Requestor_Name__c)
            {
                briefingEvent.Requestor_Name__c = requestorId;
                updBriefingEvent = true;
            }

            if(briefingAdvisorRole == false )
            {
                briefingEvent.Briefing_Advisor__c = null;
                updBriefingEvent = true;
            }
            else if(briefingAdvisorRole == true && briefingAdvisorId != briefingEvent.Briefing_Advisor__c)
            {
                briefingEvent.Briefing_Advisor__c = briefingAdvisorId;
                updBriefingEvent = true;
            }
            
            if(logisticAdvisorRole == false )
            {
                briefingEvent.Logistic_Advisor__c = null;
                updBriefingEvent = true;
            }
            else if(logisticAdvisorRole == true && logisticAdvisorId != briefingEvent.Logistic_Advisor__c)
            {
                briefingEvent.Logistic_Advisor__c = logisticAdvisorId;
                updBriefingEvent = true;
            }
            
            if(updBriefingEvent)
                update briefingEvent;

			changeFirstNameLastNameOnEachInvitee();
			
            update inviteeList;
            
        }
        catch(DMLException ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , System.Label.Updating_Custom_Attributes_Error));
            return null;
        }
        
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'There has been an error in database transaction. Please contact your System Administrator.'));
            return null;
        }

        return pageRedirect();
    }
    
    private void changeFirstNameLastNameOnEachInvitee() 
    {
    	for(EBC_Invitees__c eachInvitee :inviteeList)
		{
			// Names without a last name also contain a white space
			String firstNameLastName = eachInvitee.Invitee__c;			
			if(firstNameLastName != null && firstNameLastName.contains('')) {
				// Any amount of white space between first name and last name must be handled
				List<String> fullName = firstNameLastName.split('[\\s]+');
				if(fullName.size() >= 2) {
					eachInvitee.First_Name__c = fullName[0]; 
					String lastNameWithTitle = (fullName.size() == 3) ? fullName[1] + ' ' + fullName[2] : fullName[1]; 	 
					eachInvitee.Last_Name__c = lastNameWithTitle;
				} else {
					eachInvitee.First_Name__c = fullName[0];
					eachInvitee.Last_Name__c = null;
				}
			}
		}
    }
    
    // to goback to parent Briefing Event page
    public PageReference cancel()
    {
        return pageRedirect();
    }
    
    // common method for redirection to Briefing Event page
    public PageReference pageRedirect()
    { 
        PageReference pageRef = new PageReference('/' + briefingEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    
    // common method for retrieving Invitees records for the Briefing Event
    public void retrieveInvitees()
    {
        try
        {
            // invitees' list to be displayed on the page
            inviteeList = [Select Briefing_Team_Role__c, Briefing_Event__c, Attitude_towards_EMC__c, Company__c, Position_they_represent_in_their_Company__c, Customer_Notes__c, Contact__r.RecordTypeId , Attendee_Email__c, Invitee__c, Attendee__c,Send_Package__c,Attendee_Type__c,Contact__c,Lead__c,User__c, EBC_Name__c, EBC_Title__c, Attending__c, Send_CBP__c, Send_FBP__c, Send_Feedback__c, Send_Impact__c, Feedback_Output__c from EBC_Invitees__c where Briefing_Event__c =:briefingEventId ORDER BY Attending__c DESC, Briefing_Team_Role_Numeric_Value__c, Invitee__c  Limit 1000];           
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , System.Label.Attendees_Fetch_Error));
        }
    }
    
    // method to assign blank values to fields wherever applicable depending on the Briefing Team Role
    public void setBlankValuesToInviteeList()
    {
        for(Integer i=0;i<inviteeList.size();i++)
        {
            if(inviteeList[i].Briefing_Team_Role__c == 'Customer' || inviteeList[i].Briefing_Team_Role__c == 'Other Invitee')
            {
                inviteeList[i].EBC_Name__c = '';        
            }  
            else if(inviteeList[i].Briefing_Team_Role__c == 'Partner' || inviteeList[i].Briefing_Team_Role__c == 'Requestor')
            {
                inviteeList[i].EBC_Name__c = '';
                inviteeList[i].Attitude_towards_EMC__c = '';    
                inviteeList[i].Position_they_represent_in_their_Company__c = '';  
            }
            else if(inviteeList[i].Briefing_Team_Role__c == 'EMC Employee' || inviteeList[i].Briefing_Team_Role__c == 'Account Team Member')
            {
                inviteeList[i].EBC_Name__c = '';
                inviteeList[i].Attitude_towards_EMC__c = '';    
                inviteeList[i].Position_they_represent_in_their_Company__c = '';
                inviteeList[i].Customer_Notes__c = '';  
            }
            else if(inviteeList[i].Briefing_Team_Role__c == 'Briefing Advisor' || inviteeList[i].Briefing_Team_Role__c == 'Logistic Advisor' || inviteeList[i].Briefing_Team_Role__c == 'Scheduler')
            {
                inviteeList[i].EBC_Name__c = '';
                inviteeList[i].Attitude_towards_EMC__c = '';    
                inviteeList[i].Position_they_represent_in_their_Company__c = '';
                inviteeList[i].Customer_Notes__c = '';
                inviteeList[i].EBC_Title__c = '';  
            }
            else if(inviteeList[i].Briefing_Team_Role__c == 'Presenter (EMC Employee)' || inviteeList[i].Briefing_Team_Role__c == 'Presenter (Non EMC Employee)')
            {
                inviteeList[i].Attitude_towards_EMC__c = '';    
                inviteeList[i].Position_they_represent_in_their_Company__c = '';
                inviteeList[i].Customer_Notes__c = '';  
            }
        }  
    }
    
    // method to validate the data entered in the input fields 
    public String validations()
    {
        ErrorMsg='';
        Integer BACounter=0; // counter to have number of Briefing Advisors entered
        Integer LACounter=0; // counter to have number of Logistic Advisors entered
        Integer RCounter=0; // counter to have number of Requestors entered
        Integer SCounter=0; // counter to have number of Schedulers entered
    
        // code to retrieve the contact record type id where the record type name is 'EMC Internal Contact'       
        Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
        Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
        Id internalContact= record_Type_name_RT.getRecordTypeId();
    
        for(Integer i=0;i<inviteeList.size();i++)
        {   
            /* 
            //Throw error if any of the email fields is blank        
            if(inviteeList[i].Attendee_Email__c == NULL || inviteeList[i].Attendee_Email__c == '' )
            {
                //ErrorMsg='Invalid data. Please enter values in all the email fields.'; 
                ErrorMsg= 'The email field for ' + inviteeList[i].Invitee__c + ' is blank. Please enter an email.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));       
            }
            
                      
            if(inviteeList[i].Attendee_Email__c != NULL || inviteeList[i].Attendee_Email__c != '')
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'List Row No.:' + i )); 
                expMatches = Pattern.compile(emailRegex).matcher(inviteeList[i].Attendee_Email__c).matches();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'expMatches = ' +  expMatches + ' in List Row No.:' + i ));                       
                if(expMatches == false)
                {
                    ErrorMsg= 'The email for ' + inviteeList[i].Invitee__c + ' is not valid. Please enter a valid email.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
                } 
            }
            */
            
            // Throw error if the invitee assigned the role of Account Team Member is not an EMC internal contact
            if(inviteeList[i].Briefing_Team_Role__c == 'Account Team Member')
            {
                if(inviteeList[i].Contact__r.RecordTypeId != internalContact)
                {
                    ErrorMsg= inviteeList[i].Invitee__c + ' is not an EMC internal contact.So, ' + inviteeList[i].Invitee__c + ' cannot be assigned the Role of Account Team Member.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));        
                }
            }
                          
            
            if(inviteeList[i].Briefing_Team_Role__c == 'Briefing Advisor')
            {
                briefingAdvisorRole = true;
                BACounter = BACounter + 1;
                // Throw error if the contact assigned the role fo Briefing Advisor is not an EMC internal contact
                if(inviteeList[i].Contact__r.RecordTypeId != internalContact)
                {
                    ErrorMsg= inviteeList[i].Invitee__c + ' is not an EMC internal contact.So, ' + inviteeList[i].Invitee__c + ' cannot be assigned the Role of Briefing Advisor.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));        
                } 
                else
                {
                    briefingAdvisorId = inviteeList[i].Contact__c;
                }
            }
            
            if(inviteeList[i].Briefing_Team_Role__c == 'Logistic Advisor')
            {
                logisticAdvisorRole = true;
                LACounter = LACounter + 1;
                // Throw error if the contact assigned the role fo Logistic Advisor is not an EMC internal contact
                if(inviteeList[i].Contact__r.RecordTypeId != internalContact)
                {
                    ErrorMsg= inviteeList[i].Invitee__c + ' is not an EMC internal contact.So, ' + inviteeList[i].Invitee__c + ' cannot be assigned the Role of Logistic Advisor.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));        
                }
                else
                {
                    logisticAdvisorId = inviteeList[i].Contact__c;
                }  
            }
            
            if(inviteeList[i].Briefing_Team_Role__c == 'Requestor')
            {
                requestorRole = true;
                RCounter = RCounter + 1;
                // Throw error if the contact assigned the role fo Requestor is not an EMC internal contact
                if(inviteeList[i].Contact__r.RecordTypeId != internalContact)
                {
                    ErrorMsg= inviteeList[i].Invitee__c + ' is not an EMC internal contact.So, ' + inviteeList[i].Invitee__c + ' cannot be assigned the Role of Requestor.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));        
                }
                else
                {
                    requestorId = inviteeList[i].Contact__c;    
                }  
            }
            
            if(inviteeList[i].Briefing_Team_Role__c == 'Scheduler')
            {
                SCounter = SCounter + 1;
                // code commented as the process is not clear if the scheduler can be anyone other than EMC internal contact

                /*
                if(inviteeList[i].Contact__r.RecordTypeId != internalContact)
                {
                    ErrorMsg= inviteeList[i].Invitee__c + ' is not an EMC internal contact.So, ' + inviteeList[i].Invitee__c + ' cannot be assigned the Role of Scheduler.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));        
                } 
                */ 

            }
                          
        }
        
        // Throw error if more than one Briefing Team member has been assigned the role of Briefing Advisor        
        if(BACounter > 1)
        {
            ErrorMsg= System.Label.Only_one_BA_allowed;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        
        // Throw error if more than one Briefing Team member has been assigned the role of Logistic Advisor
        if(LACounter > 1)
        {
            ErrorMsg=System.Label.Only_one_LA_allowed;  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        
        // Throw error if more than one Briefing Team member has been assigned the role of Requestor
        if(RCounter > 1)
        {
            ErrorMsg=System.Label.Only_one_Requestor_allowed; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));   
        }
        
        // Throw error if more than one Briefing Team member has been assigned the role of Scheduler
        if(SCounter > 1)
        {
            ErrorMsg=System.Label.Only_one_Scheduler_allowed; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));  
        }
                
        return ErrorMsg;  
    }
    
}