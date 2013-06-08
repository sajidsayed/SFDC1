/*
Author:     Devi Prasad Bal
Created on: 29-Dec-2009
Description: This page allows to create new invitees from the Invitees related list of Briefing Event
Modified on: 04-Mar-2010
Reason: Modified based on further inputs from the business
Modified on: 17-May-2013 by Emmanuel Cruz
Reason: Modified based on add a new button and modify functions
Where is this controller is used?: in visual force page "EBC_Other_Invitees_Page"
*/

public class EBC_Other_Invitees
{
   
    //The regular expression for pattern matching against the input email
    String emailRegex = '^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\\-+)|([A-Za-z0-9]+\\.+)|([A-Za-z0-9]+\\++))*[A-Za-z0-9]+@((\\w+\\-+)|(\\w+\\.))*\\w{1,63}\\.[a-zA-Z]{2,6}$';
    Boolean expMatches; // Boolean variable to check whether the email field matched the regular expression
    public String ErrorMsg;
    public List<EBC_WrapperInvitee> wrapResourceList=new List<EBC_WrapperInvitee>(); //List of the wrapper instance to get inputs from the visualforce page
    public Id briefingEventId;
    private Integer NUMBER_OF_RECORDS = 10; //The number of rows/records to be displayed on the page
    public EBC_Briefing_Event__c briefingEvent {get; set;}
    
    public String getErrorMsg() 
    {
        return this.ErrorMsg;
    }
    public void setErrorMsg(String s)
    {
        this.ErrorMsg = s;
    }
     
    //Constructor of the class
    public EBC_Other_Invitees()
    {
        briefingEventId = System.currentPageReference().getParameters().get('id');
        briefingEvent = [Select id, name from EBC_Briefing_Event__c where id =:briefingEventId];
        initialBlankRecords();
    }
    
    //This is the method invoked from the visualforce page
    public List<EBC_WrapperInvitee> getrecords()
    {
        return wrapResourceList;
    }
    
    //method invoked by the constructor to create a list of EBC_WrapperInvitee instances
    public void initialBlankRecords()
    {                 
        for (Integer i=0;i<NUMBER_OF_RECORDS;i++)
        {
            EBC_WrapperInvitee ws=new EBC_WrapperInvitee();
            ws.isError = false;
            ws.AttendeeFirstName='';
            ws.AttendeeLastName='';
            ws.Email='';
            ws.Err='';
            ws.Title='';
            ws.Company='';
            ws.Notes='';
            ws.BriefingEvent=briefingEventId;
            wrapResourceList.add(ws);
        }
    }

    public PageReference save()
    {
       try
       {
           List<EBC_Invitees__c> invList =new List<EBC_Invitees__c>(); //Final list of invitees for insertion into the EBC Invitees custom object
           Integer counter=0;
           Integer RowNo=0;
           Boolean bErrorFound = false;
           ErrorMsg='';
           for(EBC_WrapperInvitee wi:wrapResourceList)
           {
                wi.isError = false;
                wi.Err='';

                               
                //validation for mandatory Last Name and Email when any other field has been filled in
                if((wi.AttendeeFirstName !='' || wi.Title !='' || wi.Company !='' || wi.Notes != '') && (wi.AttendeeLastName =='' && wi.Email==''))
                {
                   wi.Err=System.Label.Last_Name_and_Email_Null;
                   bErrorFound = true;
                   wi.isError = true;
                }
                
                //validation for mandatory Email when Last Name has been filled in
                if(wi.AttendeeLastName !='' && wi.Email=='')
                {
                   wi.Err=System.Label.Invitee_Email_Null;
                   bErrorFound = true;
                   wi.isError = true;
                }
                //validation for mandatory Last Name when Email has been filled in
                if(wi.AttendeeLastName =='' && wi.Email !='')
                {
                   wi.Err=System.Label.Invitee_Last_Name_Null;
                   bErrorFound = true;
                   wi.isError = true;
                }
                
                //validation for checking the format of the Email
                if(wi.AttendeeLastName !='' && wi.Email !='')
                {
                    expMatches = Pattern.compile(emailRegex).matcher(wi.Email).matches();
                                       
                    if(expMatches == false)
                    {
                        wi.Err= System.Label.Invalid_Invitee_Email_address;
                        bErrorFound = true;
                        wi.isError = true;
                    }
                }
            }
            
            if(bErrorFound)
               return null;
               
            //Create a list of invitees to be inserted
            for(EBC_WrapperInvitee wi:wrapResourceList)
            {
                if(wi.AttendeeLastName !='' && wi.Email!='')
                {
                    invList.add(new EBC_Invitees__c(Briefing_Event__c=wi.BriefingEvent, First_Name__c=wi.AttendeeFirstName, Company__c=wi.Company, Last_Name__c=wi.AttendeeLastName, EBC_Title__c=wi.Title, Customer_Notes__c=wi.Notes, Attendee_Email__c=wi.Email, Briefing_Team_Role__c='Other Invitee', Other_Invitee__c=true));  
                }
            }
            insert invList; // Insert the invitees into the EBC Invitees custom object
            
            //Save the records and go back to the Briefing Event record
            PageReference pageRef = backToBriefingEvent();
            return pageRef;
        }
        catch(Exception ex)
        {
            ErrorMsg='Invalid data. Please check the email fields and enter valid data.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
            return null;
        }
    }
    
    
    //Redirect to the Briefing Event record
    public PageReference backToBriefingEvent()
    {
        PageReference pageRef = new PageReference('/apex/EBC_Briefing_Team_Attributes?id=' + briefingEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference saveAndAddMore()
    {
       try
       {
           List<EBC_Invitees__c> invList =new List<EBC_Invitees__c>(); //Final list of invitees for insertion into the EBC Invitees custom object
           Integer counter=0;
           Integer RowNo=0;
           Boolean bErrorFound = false;
           ErrorMsg='';
           for(EBC_WrapperInvitee wi:wrapResourceList)
           {
                wi.isError = false;
                wi.Err='';

                               
                //validation for mandatory Last Name and Email when any other field has been filled in
                if((wi.AttendeeFirstName !='' || wi.Title !='' || wi.Company !='' || wi.Notes != '') && (wi.AttendeeLastName =='' && wi.Email==''))
                {
                   wi.Err=System.Label.Last_Name_and_Email_Null;
                   bErrorFound = true;
                   wi.isError = true;
                }
                
                //validation for mandatory Email when Last Name has been filled in
                if(wi.AttendeeLastName !='' && wi.Email=='')
                {
                   wi.Err=System.Label.Invitee_Email_Null;
                   bErrorFound = true;
                   wi.isError = true;
                }
                //validation for mandatory Last Name when Email has been filled in
                if(wi.AttendeeLastName =='' && wi.Email !='')
                {
                   wi.Err=System.Label.Invitee_Last_Name_Null;
                   bErrorFound = true;
                   wi.isError = true;
                }
                
                //validation for checking the format of the Email
                if(wi.AttendeeLastName !='' && wi.Email !='')
                {
                    expMatches = Pattern.compile(emailRegex).matcher(wi.Email).matches();
                                       
                    if(expMatches == false)
                    {
                        wi.Err= System.Label.Invalid_Invitee_Email_address;
                        bErrorFound = true;
                        wi.isError = true;
                    }
                }
            }
            
            if(bErrorFound)
               return null;
               
            //Create a list of invitees to be inserted
            for(EBC_WrapperInvitee wi:wrapResourceList)
            {
                if(wi.AttendeeLastName !='' && wi.Email!='')
                {
                    invList.add(new EBC_Invitees__c(Briefing_Event__c=wi.BriefingEvent, First_Name__c=wi.AttendeeFirstName, Company__c=wi.Company, Last_Name__c=wi.AttendeeLastName, EBC_Title__c=wi.Title, Customer_Notes__c=wi.Notes, Attendee_Email__c=wi.Email, Briefing_Team_Role__c='Other Invitee', Other_Invitee__c=true));  
                }
            }
            insert invList; // Insert the invitees into the EBC Invitees custom object
            
            //Save the records and go back to the Briefing Event record
            PageReference pageRef = backToAddMoreInvitees();
            return pageRef;
        }
        catch(Exception ex)
        {
            ErrorMsg='Invalid data. Please check the email fields and enter valid data.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
            return null;
        }
    }
    
    
    //Redirect to the EBC_Other_Invitees_Page record
    public PageReference backToAddMoreInvitees()
    {
        PageReference pageRef = new PageReference('/apex/EBC_Other_Invitees_Page?id=' + briefingEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //Redirect to the Briefing Event record on click of the Cancel button
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/' + briefingEventId);
        return pageRef;
    }
    
    //wrapper class for invitees with the getter and setter methods
    public class EBC_WrapperInvitee
    {
        public String AttendeeFirstName{get; set;}
        public String AttendeeLastName{get; set;}
        public String Email{get; set;}
        public Id BriefingEvent{get; set;}
        public String Err{get; set;}
        public Boolean isError{get; set;}
        public String Title{get; set;}
        public String Company{get; set;}
        public String Notes{get; set;}
    }
 }