/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR             DESCRIPTION                               
 |  ====       =========     ==             =========== 
 |  15-MAR-10  D. Quinn                     Initial Creation.  Procedures for coying past Event Agendas.
 |   
 |  16-JUN-10  Devi Bal      EBC Phase II   All other conditions remaining same, populate Start Date wherever 
 |                                          Start Date Time field is being populated and populate End Date
 |                                          wherever End Date Time field is being populated.
 |  20-JULY-12 V.Joy         194417         Changed page references, so that it routes to
 |                                          the Agenda Page
 |  19-APR-13  Y. Salazar    248632         Added ability to retrieve session presenters when copying past agendas.       
 +===========================================================================*/

public class EBC_CopyEvent {

    public EBC_Briefing_Event__c targetEvent {get; set;}
    String searchText;
    List<EBC_Briefing_Event__c> results;
    public String selectedEvent;
    public Boolean copyHeader {get;set;}
    public Boolean copySession {get;set;}
    public Boolean copyDateTime {get;set;}
    public Boolean copyPresenter {get;set;}
    
    public EBC_CopyEvent(ApexPages.StandardController controller) {
         targetEvent = (EBC_Briefing_Event__c)controller.getRecord();
    }
    
    public String getSearchText() {
        return searchText;
    }
    public void setSearchText(String s) {
        searchText = s;
    }
    public List<EBC_Briefing_Event__c> getResults() {
        return results;
    }
    public void setSelectedEvent(String s){
        this.selectedEvent=s;
    }
    public String getSelectedEvent(){
        return this.selectedEvent;
    } 
    
    public PageReference doSearch() {
        setSelectedEvent('');
        try {
        results = (List<EBC_Briefing_Event__c>)[FIND :searchText RETURNING
                            EBC_Briefing_Event__c(
                                ID, Name, Briefing_Center__c, 
                                Start_Date__c, End_Date__c,
                                Customer_Name__c,SGE_Account__c,
                                Objective_of_the_Visit__c,
                                Customer_Spend_with_EMC_over_3_years__c,
                                What_is_estimated_spend_for_fiscal_year__c,
                                Account_Designation__c, 
                                Customer_Business_Description__c,
                                Customer_s_Relationship_with_EM__c,
                                Applications__c, Platforms__c,
                                Critical_Data_Center_Information__c,
                                EMC_Products_Installed__c ) ][0];
        for(Integer i=0;i<results.size();i++){
            if(this.targetEvent.id==results[i].id){
                results.remove(i);
                break;
            }
        }
        if(results.size()==0){
            results=null;
        }
        return null;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
    }
   
    public PageReference updateEvent(){
        
        if(getSelectedEvent()==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.RadioSelectRequired);
            ApexPages.addMessage(myMsg);
            return null;
        } 

        try {
        for(EBC_Briefing_Event__c templEvent:results){
            // Loop thru result set and find the one that matches the selectedEvent page parameter
            if(templEvent.id==getSelectedEvent()){
                if(copyHeader==true){
                    this.targetEvent.Customer_Name__c             = templEvent.Customer_Name__c;
                    this.targetEvent.SGE_Account__c               = templEvent.SGE_Account__c;
                    this.targetEvent.Objective_of_the_Visit__c    = templEvent.Objective_of_the_Visit__c;
                    this.targetEvent.Account_Designation__c       = templEvent.Account_Designation__c;
                    this.targetEvent.Applications__c              = templEvent.Applications__c;
                    this.targetEvent.Platforms__c                 = templEvent.Platforms__c;
                    this.targetEvent.EMC_Products_Installed__c    = templEvent.EMC_Products_Installed__c;
                    this.targetEvent.Customer_Spend_with_EMC_over_3_years__c
                                                      = templEvent.Customer_Spend_with_EMC_over_3_years__c;
                    this.targetEvent.What_is_estimated_spend_for_fiscal_year__c
                                                      = templEvent.What_is_estimated_spend_for_fiscal_year__c;
                    this.targetEvent.Customer_Business_Description__c
                                                      = templEvent.Customer_Business_Description__c;
                    this.targetEvent.Customer_s_Relationship_with_EM__c
                                                      = templEvent.Customer_s_Relationship_with_EM__c;
                    this.targetEvent.Critical_Data_Center_Information__c
                                                      = templEvent.Critical_Data_Center_Information__c;
                }
                if(copySession==true) {
                    // override copyDateTime flag under certain data conditions
                    if(copyDateTime==true) {
                        if(templEvent.Start_Date__c==null || this.targetEvent.Start_Date__c==null){
                            // missing start date info which is required for session date calculations
                            copyDateTime = false;
                        } else {
                            if (this.targetEvent.End_Date__c!=null) {
                                if(templEvent.End_Date__c==null){
                                    // target has finite duration but source has indeterminate duration
                                    copyDateTime = false;
                                } else {
                                    if (this.targetEvent.Start_Date__c.daysBetween(this.targetEvent.End_Date__c)
                                            < templEvent.Start_Date__c.daysBetween(templEvent.End_Date__c) ) {
                                        // target event duration shorter than source event duration 
                                        copyDateTime = false;
                                    }
                                }                                  
                            }
                        }
                    }
                    
                    Map<Id,EBC_Session__c> sessionsToCopy = new Map<Id,EBC_Session__c>();
                    Map<Id,EBC_Session_Presenter__c> pastSessionPresenters = new Map<Id,EBC_Session_Presenter__c>();
                    List<EBC_Session_Presenter__c> newPresenterList = new List<EBC_Session_Presenter__c>(); // New Session Presenters for current BE
                    
                    Map<String,List<EBC_Session_Presenter__c>> tempSessionPresenters = new Map<String,List<EBC_Session_Presenter__c>>();
                    
                    for(EBC_Session__c sessions:[SELECT Id, CurrencyIsoCode, Topic__c, Topic__r.Name, Topic_Override__c, Session_Start_Time__c,
                                                           Session_End_Time__c, Session_Start_Date__c, Session_End_Date__c, Briefing_Advisor_Notes__c,
                                                           Requester_Notes__c, Can_this_session_be_changed__c, Status__c FROM EBC_Session__c WHERE Briefing_Event__c = :templEvent.id]){
                        sessionsToCopy.put(sessions.Id, sessions);
                    }
                    
                    if(this.copyPresenter == true){
                        //Get list of presenters by Session
                        for(EBC_Session_Presenter__c sPresenter:[SELECT Id, Name, Topic_Presenters__c, Topic__c, Session__c, Presenter__c,
                            Active__c, Is_the_Presenter_Confirmed__c, Is_Certified__c, Guest_Presenter__c, Guest_Presenter_Last_Name__c,
                            Guest_Presenter_First_Name__c, Guest_Presenter_Email__c, Guest_Presenter_EBC_Title__c, Guest_Company__c
                            FROM EBC_Session_Presenter__c WHERE Session__c IN :sessionsToCopy.keySet()]){
                            pastSessionPresenters.put(sPresenter.Id, sPresenter);
                            pastSessionPresenters.put(sPresenter.Id, sPresenter);
                        }
                        System.debug('Session Presenters: ' + pastSessionPresenters);
                    }

                    List<EBC_Session__c> newEventList = new List<EBC_Session__c>();
                    for(EBC_Session__c session:sessionsToCopy.values()){
                        //for( EBC_Session__c session:sessions ) {
                        EBC_Session__c newEventSess = new EBC_Session__c();
                        newEventSess.Briefing_Event__c = this.targetEvent.id;
                        newEventSess.Topic__c = session.Topic__c;
                        newEventSess.Topic_Override__c = session.Topic_Override__c;
                        newEventSess.Can_this_session_be_changed__c = 'Yes';
            
                        // session datetime copy logic
                        if (copyDateTime==false || session.Session_Start_Time__c==null ){
                            newEventSess.Session_Start_Time__c = null;
                            newEventSess.Session_Start_Date__c = null; // [DB] Make the start date field null
                        } else {
                            newEventSess.Session_Start_Time__c = datetime.newInstance(
                            targetEvent.Start_Date__c.addDays(templEvent.Start_Date__c.daysBetween(session.Session_Start_Time__c.date())),
                            session.Session_Start_Time__c.time());                                         
                            newEventSess.Session_Start_Date__c = newEventSess.Session_Start_Time__c.date(); // [DB] Populate Start Date field with only the date value of Start Date Time field
                        }
                        
                        if (copyDateTime==false || session.Session_End_Time__c==null ){
                            newEventSess.Session_End_Time__c = null;
                            newEventSess.Session_End_Date__c = null; // [DB] Make the start date field null
                        } else {
                            newEventSess.Session_End_Time__c = datetime.newInstance(
                            targetEvent.Start_Date__c.addDays(templEvent.Start_Date__c.daysBetween(session.Session_End_Time__c.date())),
                            session.Session_End_Time__c.time());
                            newEventSess.Session_End_Date__c = newEventSess.Session_End_Time__c.date(); // [DB] Populate End Date field with only the date value of End Date Time field     
                        }
                        
                        //If Copy Presenter is selected    
                        if(this.copyPresenter == true){
                            List<EBC_Session_Presenter__c> newPres = new List<EBC_Session_Presenter__c>();
                                                
                            for(EBC_Session_Presenter__c sPresenter:pastSessionPresenters.values()){
                                if(session.Id == sPresenter.Session__c){
                                    if(sPresenter.Topic_Presenters__c == null && sPresenter.Guest_Presenter__c == false){
                                        newEventSess.Status__c = 'One or more of the presenters assigned to this topic could not be copied because original data is missing.';
                                    } else{
                                        if(sPresenter.Active__c.equals('true') || sPresenter.Guest_Presenter__c == true){
                                            newPres.add(new EBC_Session_Presenter__c(Name = sPresenter.Topic__c, Session__c = sPresenter.Session__c,
                                            Presenter__c = sPresenter.Presenter__c, Is_Certified__c = sPresenter.Is_Certified__c, Topic_Presenters__c = sPresenter.Topic_Presenters__c,
                                            Guest_Presenter__c = sPresenter.Guest_Presenter__c, Guest_Presenter_Last_Name__c = sPresenter.Guest_Presenter_Last_Name__c,
                                            Guest_Presenter_First_Name__c = sPresenter.Guest_Presenter_First_Name__c, Guest_Presenter_Email__c = sPresenter.Guest_Presenter_Email__c,
                                            Guest_Presenter_EBC_Title__c = sPresenter.Guest_Presenter_EBC_Title__c, Guest_Company__c = sPresenter.Guest_Company__c));
                                        }
                                                                                                     
                                        //Notify INACTIVE Presenter
                                        else{
                                            newEventSess.Status__c = 'One or more of the presenters assigned to this topic are no longer active.';
                                        }
                                    }
                                }
                            }
                                                
                            if(newPres.size() > 0){
                                tempSessionPresenters.put(session.Topic__r.Name, newPres);
                                System.debug('List of Presenters for ' + session.Topic__r.Name + ', ' + session.Id + ': ' + newPres);
                            }
                        }
                            
                        newEventList.add(newEventSess);
                        //}
                    }
                    // END SESSIONS LOOP
                    
                    if(newEventList.size() > 0){      
                        Set<Id> eventResult = new Set<Id>();
                                                        
                        for(Database.SaveResult result:Database.insert(newEventList, false)){
                            eventResult.add(result.getId());
                        }
                                                        
                        if(tempSessionPresenters.size() > 0){
                            List<EBC_Session_Presenter__c> presentersList = new List<EBC_Session_Presenter__c>();
                                                        
                            for(EBC_Session__c event:[SELECT Id, Topic__r.Name FROM EBC_Session__c WHERE Briefing_Event__c = :this.targetEvent.Id AND Id IN :eventResult]){
                                if(tempSessionPresenters.containsKey(event.Topic__r.Name)){
                                    for(EBC_Session_Presenter__c presenter:tempSessionPresenters.get(event.Topic__r.Name)){
                                        presenter.Session__c = event.Id;
                                        presentersList.add(presenter);
                                    }
                                }
                            }
                                                                
                            System.debug('presentersList: ' + presentersList);
                            insert presentersList;
                        }
                    }    
                }
                //END COPY SESSION
                
                update this.targetEvent;
                // break out of results loop since we have copied from selectedEvent
                break;
            }
        } // end results loop
        //PageReference returnPage = new PageReference('/'+this.targetEvent.id);
        PageReference returnPage= new PageReference('/apex/EBC_AgendaPage?id='+targetEvent.id);
        returnPage.setRedirect(true);
        return returnPage;
        }
        
        catch (Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public PageReference doCancel(){
        PageReference returnPage= new PageReference('/apex/EBC_AgendaPage?id='+targetEvent.id);
        returnPage.setRedirect(true);
        return returnPage;
    } 
}