/*
Author:     Devi Prasad Bal
Created on: 05-April-2010
Description: This class acts as an extension to the controller for the visualforce pages -- EBC_feedback_form and EBC_Feedback_Read_Only.
             On click of the button 'Submit Feedback' the EBC_feedback_form page opens up. The 'Submit Feedback' button is not rendered if
             the Feedback Status field on the Briefing Event has value as 'Submitted'. On click of the 'Cancel' button, it gets redirected
             to the Briefing Event.
Modified by: Naveen Hiremath
Modified on: 12-Jan-2012
Reason: 1.Added Briefing Advisor Name to View feedback form

Modified by :   Avinash Kaltari
Modified on :   12-Jun-2012
Reason      :   To eliminate hardcoding of IDs for System Administrator and EBC Power User profiles


*/ 


public class EBC_Feedback
{
    public Id briefingEventId; // to hold the id of the briefing event
    public EBC_Briefing_Event__c objBEvent {get;set;} // to hold the briefing event object record
    public EBC_Session_Presenter__c[] sessionPresentersList {get; set;} // to hold all the session presenters related to the briefing event
    String ErrorMsg;
    public Boolean sessRepeated{get;set;}
    public Boolean NotFromSite {get;set;}
    public Boolean feedbackSubmitted {get;set;}
    Set<Id> sessionSet = new Set<Id>();
    public List<EBC_WrapperSessAndSessPresenters> wrapResourceList=new List<EBC_WrapperSessAndSessPresenters>();
    public String RequestorName {get;set;}
    public String BCenterLocation {get;set;}
    
    public EBC_Feedback(ApexPages.StandardController stdController){
        
        try
        {
            briefingEventId= System.currentPageReference().getParameters().get('id'); // id of the parent Briefing Event Object
            objBEvent=[Select Id  From EBC_Briefing_Event__c where Id=:briefingEventId];
        }
        catch(Exception Ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.Valid_BE_id ));
            return;
        }
        
        if(briefingEventId != null) 
        { 
            
            // retrieve the Feedback fields from the Briefing Event and store it in objBEvent
            objBEvent=[Select   Agenda_Coordination_Planning_Rating__c, Agenda_Coordination_Planning_Notes__c, Customer_Perspective__c, 
                                Evening_Venue_Rating__c, Evening_Venue_Notes__c, Sales_Perspective__c, Relationship_Changing_Impact_Notes__c,
                                Briefing_Registration_Process_Rating__c, Briefing_Registration_Process__c, Briefing_Day_Services_Rating__c,
                                Briefing_Day_Services_Notes__c, Briefing_Catering_Services_Rating__c, Briefing_Catering_Services_Notes__c,
                                Hotel_Rating__c, Hotel_Notes__c, Transportation_Rating__c, Transportation_Notes__c, Briefing_Center__c,  
                                Briefing_Program_Website_Rating__c, Briefing_Program_Website_Notes__c, Feedback_Status_Picklist__c, Name, 
                                Start_Date__c, End_Date__c, Requestor_Name__c, Requestor_Name__r.FirstName, Requestor_Name__r.LastName, Briefing_Center__r.Name,
                                Briefing_Advisor__r.Name          
                        From EBC_Briefing_Event__c where Id=:briefingEventId];
                        
            // Assigning a value to RequestorName to be displayed on the Feedback forms
            if((objBEvent.Requestor_Name__r.FirstName == '' || objBEvent.Requestor_Name__r.FirstName == null) && objBEvent.Requestor_Name__r.LastName !='')
            {
                RequestorName = objBEvent.Requestor_Name__r.LastName;
            }
            else if(objBEvent.Requestor_Name__r.FirstName != '' && (objBEvent.Requestor_Name__r.LastName =='' || objBEvent.Requestor_Name__r.LastName ==null))
            {
                RequestorName = objBEvent.Requestor_Name__r.FirstName;
            }
            else if((objBEvent.Requestor_Name__r.FirstName == '' || objBEvent.Requestor_Name__r.FirstName == null) && (objBEvent.Requestor_Name__r.LastName =='' || objBEvent.Requestor_Name__r.LastName ==null))
            {
                RequestorName = ' ';
            }
            else if(objBEvent.Requestor_Name__r.FirstName != '' && objBEvent.Requestor_Name__r.LastName !='')
            {
                RequestorName = objBEvent.Requestor_Name__r.FirstName + ' ' + objBEvent.Requestor_Name__r.LastName;
            }
            
            if(objBEvent.Briefing_Center__r.Name == '' || objBEvent.Briefing_Center__r.Name == null)
            {
                BCenterLocation = ' ';
            }
            else
            {
                BCenterLocation = objBEvent.Briefing_Center__r.Name;
            }
            
            // retrieve all the sessions related to the briefing event and store it in the Map- sessionTempMap  
            Map<id, EBC_Session__c> sessionTempMap = new Map<id, EBC_Session__c>([ Select Id, Topic_Override__c, Session_Topic_Rating__c, Session_Topic_Rating_Notes__c 
                            from EBC_Session__c where Briefing_Event__c =: briefingEventId ]);
                         
            // retrieve all the session presenters related to the briefing event and store it in the list- sessionPresentersList
            sessionPresentersList =[Select Id, Session__c, Session__r.Topic_Override__c, Discussion_Leader_Rating__c, Discussion_Leader_Notes__c,
                                     Topic_Presenters__c, Presenter_Name__c,Presenter_EBC_Name__c,  
                                     Session__r.Session_Topic_Rating__c, Session__r.Session_Topic_Rating_Notes__c    
                                    from EBC_Session_Presenter__c where Session__c 
                                    IN: sessionTempMap.keySet() ORDER BY Session__r.Topic_Override__c];
            
                       
            wrapSessAndSessPresenters(); // Invoke method to retrieve information of Sessions and Session presenters for the Feedback Read Only page
            
            Id currentUserProfileId;
            String currentUserProfileName;
            NotFromSite = true;
            feedbackSubmitted = false;
            currentUserProfileId = UserInfo.getProfileId();
            Profile p = [Select Name from Profile where Id =: currentUserProfileId];
            currentUserProfileName = p.Name;
            
            if(currentUserProfileName == 'EBC Application Site Profile')
            {
                NotFromSite=false;  
            }
            //EBC Power User Profile Id=00e70000001FbAv and System Administrator Profile Id=00e70000000wBza
            
            
//Avinash's code begins...
            
            Id SystemAdministratorId, EBCPowerUserId ;
            List<Profile> lstid = [SELECT Name, Id FROM Profile where name in (:System.Label.System_Administrator_Profile_Name ,:System.Label.EBC_Power_User_Profile_Name)  limit 2];
            for(Profile prof : lstid)
            {
                if(prof.name == 'System Administrator')
                    SystemAdministratorId = prof.id;
                if(prof.name == 'EBC Power User')
                    EBCPowerUserId = prof.id;
            }
            
//Avinash's code ends.
            
            
            if(objBEvent.Feedback_Status_Picklist__c == 'Submitted' && !(currentUserProfileId == SystemAdministratorId || currentUserProfileId == EBCPowerUserId))
            {
                feedbackSubmitted = true;   
            }
                      
        }
    }
    
    public List<EBC_WrapperSessAndSessPresenters> getSessRecords()
    {
        return wrapResourceList;
    }
        
    //method to club information from Session and Session Presenter for the Feedback Read Only page.
    public void wrapSessAndSessPresenters()
    {   
        String sessCheck=briefingEventId;
        for (EBC_Session_Presenter__c sp : sessionPresentersList)
        {
            EBC_WrapperSessAndSessPresenters ws=new EBC_WrapperSessAndSessPresenters();
            if(sessCheck == sp.Session__c)
            {
                ws.SessionId=NULL;
                ws.TopicOverride='';
                ws.SessionRating='';
                ws.SessionRatingNotes='';
                ws.editField = false;   
            }
            else
            {
                ws.SessionId=sp.Session__c;
                ws.TopicOverride=sp.Session__r.Topic_Override__c;
                ws.SessionRating=sp.Session__r.Session_Topic_Rating__c;
                ws.SessionRatingNotes=sp.Session__r.Session_Topic_Rating_Notes__c;
                ws.editField = true;
                
            }
            
            ws.SessionPresenterId=sp.Id;
            ws.DiscussionLeaderName=sp.Presenter_Name__c;
            ws.DiscussionLeaderEBCName=sp.Presenter_EBC_Name__c;
            ws.DiscussionLeaderRating=sp.Discussion_Leader_Rating__c;
            ws.DiscussionLeaderRatingNotes=sp.Discussion_Leader_Notes__c;
            wrapResourceList.add(ws);
            sessCheck = sp.Session__c;
            
        }
    }
    
    // this method updates the briefing event record, sessions related to the briefing event and the session presenters related to the briefing event  
    public PageReference save()
    {   
        ErrorMsg='';
        
        List<EBC_Session__c> sessionList2 = new List<EBC_Session__c>();
        List<EBC_Session_Presenter__c> sessionPresentersList2 = new List<EBC_Session_Presenter__c>();

        Id sessionCheck = briefingEventId;
        for (EBC_WrapperSessAndSessPresenters ws : wrapResourceList)
        {
            if((ws.SessionId != null) && (sessionCheck != ws.SessionId))
            {   
                if((ws.SessionRating == '2 - Dissatisfied' || ws.SessionRating == '1 - Very Dissatisfied') 
                && (ws.SessionRatingNotes == '' || ws.SessionRatingNotes == NULL))
                {   
                    ErrorMsg= 'Please enter the Rating Notes for the Session with Topic: ' + ws.TopicOverride + ' as the Rating is ' + ws.SessionRating;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
                }
                
                EBC_Session__c ebcSess = new EBC_Session__c(Id=ws.SessionId, 
                                                            Session_Topic_Rating__c=ws.SessionRating, 
                                                            Session_Topic_Rating_Notes__c=ws.SessionRatingNotes,
                                                            Topic_Override__c=ws.TopicOverride);
                sessionList2.add(ebcSess);
            }
            
            sessionCheck = ws.SessionId;
            if((ws.DiscussionLeaderRating == '2 - Dissatisfied' || ws.DiscussionLeaderRating == '1 - Very Dissatisfied') 
                && (ws.DiscussionLeaderRatingNotes == '' || ws.DiscussionLeaderRatingNotes == NULL))
            {   
                ErrorMsg= 'Please enter the Rating Notes for the Session Presenter with Presenter\'s Name: ' + ws.DiscussionLeaderEBCName + ' as the Rating is ' + ws.DiscussionLeaderRating;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
            }            
            
            EBC_Session_Presenter__c ebcSessPrn = new EBC_Session_Presenter__c(Id=ws.SessionPresenterId, 
                                                                               Discussion_Leader_Rating__c=ws.DiscussionLeaderRating,
                                                                               Discussion_Leader_Notes__c=ws.DiscussionLeaderRatingNotes);
            sessionPresentersList2.add(ebcSessPrn);
        }    
                
        if((objBEvent.Agenda_Coordination_Planning_Rating__c == '2 - Dissatisfied' || objBEvent.Agenda_Coordination_Planning_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Agenda_Coordination_Planning_Notes__c == '' || objBEvent.Agenda_Coordination_Planning_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Agenda Coordination & Planning Notes as the Agenda Coordination & Planning Rating is ' + objBEvent.Agenda_Coordination_Planning_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Evening_Venue_Rating__c == '2 - Dissatisfied' || objBEvent.Evening_Venue_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Evening_Venue_Notes__c == '' || objBEvent.Evening_Venue_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Evening Venue Notes as the Evening Venue Rating is ' + objBEvent.Evening_Venue_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Briefing_Registration_Process_Rating__c == '2 - Dissatisfied' || objBEvent.Briefing_Registration_Process_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Briefing_Registration_Process__c == '' || objBEvent.Briefing_Registration_Process__c == NULL))
        {   
            ErrorMsg= 'Please enter Briefing Registration Process Notes as the Briefing Registration Process Rating is ' + objBEvent.Briefing_Registration_Process_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Briefing_Day_Services_Rating__c == '2 - Dissatisfied' || objBEvent.Briefing_Day_Services_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Briefing_Day_Services_Notes__c == '' || objBEvent.Briefing_Day_Services_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Briefing Day Services Notes as the Briefing Day Services Rating is ' + objBEvent.Briefing_Day_Services_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Briefing_Catering_Services_Rating__c == '2 - Dissatisfied' || objBEvent.Briefing_Catering_Services_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Briefing_Catering_Services_Notes__c == '' || objBEvent.Briefing_Catering_Services_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Briefing Catering Services Notes as the Briefing Catering Services Rating is ' + objBEvent.Briefing_Catering_Services_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Hotel_Rating__c == '2 - Dissatisfied' || objBEvent.Hotel_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Hotel_Notes__c == '' || objBEvent.Hotel_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Hotel Notes as the Hotel Rating is ' + objBEvent.Hotel_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Briefing_Program_Website_Rating__c == '2 - Dissatisfied' || objBEvent.Briefing_Program_Website_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Briefing_Program_Website_Notes__c == '' || objBEvent.Briefing_Program_Website_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Briefing Program Website Notes as the Briefing Program Website Rating is ' + objBEvent.Briefing_Program_Website_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
        if((objBEvent.Transportation_Rating__c == '2 - Dissatisfied' || objBEvent.Transportation_Rating__c == '1 - Very Dissatisfied') 
                && (objBEvent.Transportation_Notes__c == '' || objBEvent.Transportation_Notes__c == NULL))
        {   
            ErrorMsg= 'Please enter Transportation Notes as the Transportation Rating is ' + objBEvent.Transportation_Rating__c;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , ErrorMsg));
        }
       
               
        if(ErrorMsg !='')
        {
            return null; 
        }
        
        objBEvent.Feedback_Status_Picklist__c = 'Submitted';
        objBEvent.Feedback_Complete__c = true;
    
        try
        { 
            update sessionList2; // updates the sessions related to the briefing event with the Rating and Notes fields 
            update sessionPresentersList2; // updates the session presenters related to the briefing event with the Rating and Notes fields
            update objBEvent; // updates the briefing event record with the Feedback fields
            feedbackSubmitted = true;
            
            // change of status of the field Feedback_Submitted__c to true
            List<EBC_Invitees__c> invList = new List<EBC_Invitees__c>();
            EBC_Invitees__c[] ebcInvList = [Select Id, Feedback_Submitted__c from EBC_Invitees__c where Briefing_Event__c =: briefingEventId];
            for(EBC_Invitees__c ei : ebcInvList)
            {
                ei.Feedback_Submitted__c=true;
                invList.add(ei);    
            }
            update invList;
        }
        catch(DmlException dex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Unable to submit Feedback. Try again later. Error: ' + dex));
            return null;    
        }
        
        if(NotFromSite == true)
        {
            return backToBriefingEvent();
        }
        else
        {
            //SiteFeedbackSubmitted = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO , 'Feedback submitted successfully'));
            return null;     
        }
         
    }
        
    // on click of cancel go back to the briefing event detail page
    public PageReference cancel()
    {
        return backToBriefingEvent();
    }
    
    // method to go back to the briefing event detail page
    public PageReference backToBriefingEvent()
    { 
        PageReference pageRef = new PageReference('/' + briefingEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //This method will be used to show Rating options in picklist
     // Added new picklist values average and above average and commented "Good" as per request
    public List<SelectOption> getRatingOptions()
    {       
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('5 - Very Satisfied','5 - Very Satisfied'));
         options.add(new SelectOption('4 - Satisfied','4 - Satisfied'));
        options.add(new SelectOption('3 - Neutral','3 - Neutral'));
       // options.add(new SelectOption('Good','Good'));        
        options.add(new SelectOption('2 - Dissatisfied','2 - Dissatisfied'));
        options.add(new SelectOption('1 - Very Dissatisfied','1 - Very Dissatisfied'));
        return options;
    }
    
    //wrapper class for sessions and session presenters with the getter and setter methods
    public class EBC_WrapperSessAndSessPresenters
    {
        public Id SessionId{get;set;}
        public String TopicOverride{get; set;}
        public String SessionRating{get; set;}
        public String SessionRatingNotes{get; set;}
        public Id SessionPresenterId{get; set;}
        public String DiscussionLeaderName{get; set;}
        public String DiscussionLeaderEBCName{get; set;}
        public String DiscussionLeaderRating{get; set;}
        public String DiscussionLeaderRatingNotes{get; set;}
        public Boolean editField {get;set;}
    }
}