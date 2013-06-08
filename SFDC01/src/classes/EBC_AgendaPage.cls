/*=================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR             DESCRIPTION                               
 |  ====       =========     ==             =========== 
 |  20-JULY-12  V. Joy     194417         Initial Creation.
 |
 |  19-APR-13   Y. Salazar 248632         Status added to keep track of missing/inactive presenters.  
 |
 |  17-MAY-13   E. Cruz    258321         Modify addsession method to add new row at the beginning of table    
 +=================================================================================*/

  public with sharing class  EBC_AgendaPage
    {
    //variable declaration
    private ApexPages.StandardController pg;
    
    public EBC_Briefing_Event__c BEvent {get;set;}
    public List<Session> SessionDetails {get;set;}
    
    
    public Boolean TwntyFourHour {get;set;}
    
//The constructor
public EBC_AgendaPage(ApexPages.StandardController page)
    {
    pg=page;
    BEvent =[Select Id, Name, Start_Date__c, End_Date__c, Agenda_Print_Date__c, Feedback_Status_Picklist__c, 
            Agenda_Status__c,Briefing_Advisor__c, Briefing_Advisor_Notes__c,Briefing_Center__c, 
            Briefing_Status__c, Briefing_Venue__c, Requestor_Name__c, Session_End_Time__c, 
            Session_Start_Time__c from EBC_Briefing_Event__c where Id=:pg.getId() LIMIT 1];
    
    Map<String, User_Locales__c> mcs = User_Locales__c.getAll();
            String userLocale=UserInfo.getLocale();
            if(mcs.containsKey(userLocale))
            {
                TwntyFourHour=true;
            }
            else
            {
                TwntyFourHour=false;
            }
    }//END of the constructor

// Method to get the sessions.

public void ComputeSessionDetails(){
    if (SessionDetails == Null){
        SessionDetails = new List<Session>();
        for(EBC_Session__c ESc : [Select Id, Name, Briefing_Event__c, Briefing_Advisor_Notes__c,
                                                            Requester_Notes__c, Session_End_Date__c, Session_End_Time__c,
                                                            Session_Start_Date__c, Session_Start_Time__c, Topic_Category__c,
                                                            Topic_Override__c, Topic__c, Topic__r.Name, Status__c From EBC_Session__c where Briefing_Event__c=:BEvent.id 
                                                            ORDER BY Session_Start_Time__c, Session_End_Time__c ASC NULLS FIRST]){
        SessionDetails.add(new Session(ESc));
        }
    }
}
    
    
   
    // method to post the sessions to the vf page
public List<Session> getSessionlisttodisplay()
    {
    ComputeSessionDetails();
    
    return SessionDetails;
    }


// The Wrapper class
public class Session
    {
    public EBC_Session__c ESession {get;set;}
    public EBC_Session_Presenter__c Presenter1 {get;set;}
    public EBC_Session_Presenter__c Presenter2 {get;set;}
    public EBC_Session_Presenter__c Presenter3 {get;set;}
    public EBC_Session_Presenter__c Presenter4 {get;set;}
    public EBC_Session_Presenter__c Presenter5 {get;set;}
    
    //time calculation variables
    public String StartHours {get;set;}
    public String StartMinutes {get;set;}
    public String EndHours {get;set;}
    public String EndMinutes {get;set;}
    
    List<EBC_Session_Presenter__c> tempsessplist= new List<EBC_Session_Presenter__c>();

public Session (EBC_Session__c ES)
    {
    ESession=ES;
    if(ESession!=Null)
    {
     Presenter1 = new EBC_Session_Presenter__c(Session__c=ES.id, Name=ES.Name);
     Presenter2 = new EBC_Session_Presenter__c(Session__c=ES.id, Name=ES.Name);
     Presenter3 = new EBC_Session_Presenter__c(Session__c=ES.id, Name=ES.Name);
     Presenter4 = new EBC_Session_Presenter__c(Session__c=ES.id, Name=ES.Name);
     Presenter5 = new EBC_Session_Presenter__c(Session__c=ES.id, Name=ES.Name);
    }
    
    //Time Calculation START
    if(ES.Session_Start_Time__c!=Null)
            {
                Integer startHr=ES.Session_Start_Time__c.hour();
                Integer startMin=ES.Session_Start_Time__c.minute();
                StartHours=startHr+'';
                StartMinutes=startMin+'';
                
                String strStdate = ES.Session_Start_Time__c.format('MM/dd/yyyy');
                String[] arrStDate = strStdate.split('/');
                Date sessStartDate= Date.newInstance(integer.valueOf(arrStDate[2]), integer.valueOf(arrStDate[0]), integer.valueOf(arrStDate[1]));
                ESession.Session_Start_Date__c=sessStartDate;
            }   
     
     if(ES.Session_End_Time__c!=null)
            {
                Integer endHr=ES.Session_End_Time__c.hour();
                Integer endMin=ES.Session_End_Time__c.minute();
                EndHours=endHr+'';
                EndMinutes=endMin+'';
                
                String strEnddate = ES.Session_End_Time__c.format('MM/dd/yyyy');
                String[] arrEndDate = strEnddate.split('/');
                Date sessEndDate= Date.newInstance(integer.valueOf(arrEndDate[2]), integer.valueOf(arrEndDate[0]), integer.valueOf(arrEndDate[1]));
                ESession.Session_End_Date__c=sessEndDate;
            }
     //Time Calculation END
    
    // Presenters are assigned randomly as presenter 1, 2, 3, 4, 5 
    if(ES.id!=Null)
    {
    tempsessplist = [Select Id, Name, Is_the_Presenter_Confirmed__c, Organization__c, Session__c,Topic_Presenters__c, 
                    Guest_Presenter_Name__c, Guest_Presenter_Last_Name__c, Guest_Presenter_First_Name__c, 
                    Guest_Presenter_Email__c, Guest_Presenter_EBC_Title__c, Guest_Company__c, 
                    Presenter_EBC_Name__c, Guest_Presenter__c  From EBC_Session_Presenter__c where Session__c =:ES.id LIMIT 5 ];
    }
       
    for (Integer i=0; i<tempsessplist.size();i++)
    {
    if(i==0)
    {
    Presenter1=tempsessplist[0];
    continue;
    }
    else
        {
        if(i==1)
        {
        Presenter2=tempsessplist[1];
        continue;
        }
        else 
            {
            if(i==2)
            {
            Presenter3=tempsessplist[2];
            continue;
            }
            else 
                {
                if(i==3)
                {
                Presenter4=tempsessplist[3];
                continue;
                }    
                else 
                    {
                    Presenter5=tempsessplist[4];
                    continue;
                    }
                }
            }
        }
     }           
    }
   
    }// End of Wrapper Class


    // The select options
    //For Time   
    public List<SelectOption> getMinuteOptions()
        {       
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('0','00'));
            options.add(new SelectOption('5','05'));
            options.add(new SelectOption('10','10'));
            options.add(new SelectOption('15','15'));
            options.add(new SelectOption('20','20'));
            options.add(new SelectOption('25','25'));
            options.add(new SelectOption('30','30'));
            options.add(new SelectOption('35','35'));
            options.add(new SelectOption('40','40'));
            options.add(new SelectOption('45','45'));
            options.add(new SelectOption('50','50'));
            options.add(new SelectOption('55','55'));
            return options;
        }

    public List<SelectOption> getHourOptions()
        {
        List<SelectOption> options = new List<SelectOption>();
          if(TwntyFourHour==true)
            {
            options.add(new SelectOption('0','0'));
            options.add(new SelectOption('1','1'));
            options.add(new SelectOption('2','2'));
            options.add(new SelectOption('3','3'));
            options.add(new SelectOption('4','4'));
            options.add(new SelectOption('5','5'));
            options.add(new SelectOption('6','6'));
            options.add(new SelectOption('7','7'));
            options.add(new SelectOption('8','8'));
            options.add(new SelectOption('9','9'));
            options.add(new SelectOption('10','10'));
            options.add(new SelectOption('11','11'));
            options.add(new SelectOption('12','12'));
            options.add(new SelectOption('13','13'));
            options.add(new SelectOption('14','14'));
            options.add(new SelectOption('15','15'));
            options.add(new SelectOption('16','16'));
            options.add(new SelectOption('17','17'));
            options.add(new SelectOption('18','18'));
            options.add(new SelectOption('19','19'));
            options.add(new SelectOption('20','20'));
            options.add(new SelectOption('21','21'));
            options.add(new SelectOption('22','22'));
            options.add(new SelectOption('23','23'));
            }
           else
            {
            options.add(new SelectOption('1','1 AM'));
            options.add(new SelectOption('2','2 AM'));
            options.add(new SelectOption('3','3 AM'));
            options.add(new SelectOption('4','4 AM'));
            options.add(new SelectOption('5','5 AM'));
            options.add(new SelectOption('6','6 AM'));
            options.add(new SelectOption('7','7 AM'));
            options.add(new SelectOption('8','8 AM'));
            options.add(new SelectOption('9','9 AM'));
            options.add(new SelectOption('10','10 AM'));
            options.add(new SelectOption('11','11 AM'));
            options.add(new SelectOption('12','12 PM'));
            options.add(new SelectOption('13','1 PM'));
            options.add(new SelectOption('14','2 PM'));
            options.add(new SelectOption('15','3 PM'));
            options.add(new SelectOption('16','4 PM'));
            options.add(new SelectOption('17','5 PM'));
            options.add(new SelectOption('18','6 PM'));
            options.add(new SelectOption('19','7 PM'));
            options.add(new SelectOption('20','8 PM'));
            options.add(new SelectOption('21','9 PM'));
            options.add(new SelectOption('22','10 PM'));
            options.add(new SelectOption('23','11 PM'));
            options.add(new SelectOption('00','12 AM'));
            }
                             
        return options;
        }
    //For presenter confirmation  
    public List<SelectOption> getconfirmoptions()
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('No','No'));
            options.add(new Selectoption('Yes','Yes'));
         return options;
         }
    //End of Select options

//Methods for the visualforce page
    
    //method invoked when add a session button is clicked.
    public PageReference addasession()
        {
        try
            {
            dothefinalsave();
            SessionDetails = null;
            ComputeSessionDetails();
            update BEvent;
            
            List<Session> auxNewSession = new List<Session>();
            for(Session s:this.SessionDetails){
                auxNewSession.add(s);
            }
            this.SessionDetails = null;
            this.SessionDetails = new List<Session>();
            
            EBC_Session__c holdEBCsession = new EBC_Session__c(Briefing_Event__c=BEvent.id,
                                                               Session_Start_Date__c=BEvent.Start_Date__c,
                                                               Session_End_Date__c=BEvent.End_Date__c);
            SessionDetails.add(new Session(holdEBCsession));
            
            for(Session a:auxNewSession){
                this.SessionDetails.add(a);
            }
            
            return null;
            }
        catch(Exception e)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.EBC_Session_Exception+' Error: '+e.getMessage()));
            return null;
            }
        }
    
    //method invoked when save button is clicked.
    public Pagereference savepage()
        {
       try
          {
            this.cleanTopicMessage();
            dothefinalsave();
            SessionDetails = null;
            ComputeSessionDetails();
            update BEvent;
            return null;
          }
       catch(Exception e)
           {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.EBC_Session_Exception+' Error: '+e.getMessage()));
            return null;
            }
          }      
    //method called when the delete link against a session is clicked   
    public PageReference doDelete()
        {
        try
            {
            string tempid = ApexPages.currentPage().getParameters().get('deletedId');
              if(tempid!=Null && tempid!='')
              {
              EBC_Session__c tmpsession = new EBC_Session__c();
              tmpsession = [Select id from EBC_Session__c where id =:tempid LIMIT 1];
              List<EBC_Session_Presenter__c> tempSessPresenters = [Select id from EBC_Session_Presenter__c where Session__c =:tempid];
              if(tempSessPresenters.size()>0)
              Delete tempSessPresenters;
              Delete tmpsession;
              PageReference goback= new PageReference('/apex/EBC_AgendaPage?id='+BEvent.id);
              goback.setRedirect(true);
              return goback;
              }
              else
              {
              SessionDetails.remove(SessionDetails.size()-1);
              return null;
              }
            }
            catch(Exception e)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.EBC_Session_Exception+' Error: '+e.getMessage()));
            return null;
            }
        }
        // The below code is written to diable all buttons on the Agenda page, except 'cancel', for the conditions
        // if the user profile is 'EBC View Only' or the briefing status is closed
        // no requirement has been proposed, hence commenting the below code for future use
        // how to use: assign the paramerter, 'disabled' to the buttons 'Add a session','save','view agenda' and 'copy past agenda' and call the below function to assign a boolean value
        // like--->disabled="{!valid}"
        /*
        public Boolean getvalid()
          {
         Profile p = [select Name from Profile where id=:UserInfo.getProfileId()];
         if((p.Name=='EBC View Only')||(BEvent.Briefing_Status__c=='Closed'))
         return true;
         else
         return false;
          }
          */
            
  //the final save function incorporating all finer elements of ingenious programming.    
                 public void dothefinalsave()
                 {
                 EBC_Session__c temptosavesession = new EBC_Session__c();
                 List<EBC_Session__c> existingSessions = new List<EBC_Session__c>();
                 List<EBC_Session__c> newSession = new List<EBC_Session__c>(); 
                 List<EBC_Session_Presenter__c> existingSess_UpdatePresenters = new List<EBC_Session_Presenter__c>();
                 List<EBC_Session_Presenter__c> existingSess_InsertPresenters = new List<EBC_Session_Presenter__c>();
                 List<EBC_Session_Presenter__c> newSess_Presenters = new List<EBC_Session_Presenter__c>();
                 List<EBC_Session_Presenter__c> delete_Presenters = new List<EBC_Session_Presenter__c>();// to delete those presenters, when the user has cleared the presenters field an hit save.
                 if(SessionDetails!=Null && SessionDetails.size()>0)
                 { 
                 system.debug('the wrapper sessions'+SessionDetails);
                 for(Session S:SessionDetails)
                     {
                     //Time calculation
                     if(S.ESession.Session_Start_Date__c!=null)
                        {
                            Date StartDateTime=S.ESession.Session_Start_Date__c;
                            Integer stYear=StartDateTime.year();
                            Integer stMonth=StartDateTime.month();
                            Integer stDay=StartDateTime.day();
                            Integer stHours = integer.valueOf(S.StartHours);
                            Integer stMinutes = integer.valueOf(S.StartMinutes);
                            
                            Datetime stDate =datetime.newInstance(stYear, stMonth, stDay, stHours,stMinutes, 0);
                            S.ESession.Session_Start_Time__c=stDate;
                        
                            Date EndDateTime=S.ESession.Session_Start_Date__c;
                            Integer endYear=EndDateTime.year();
                            Integer endMonth=EndDateTime.month();
                            Integer endDay=EndDateTime.day();
                            Integer endHours = integer.valueOf(S.EndHours);
                            Integer endMinutes = integer.valueOf(S.EndMinutes);
                            
                            Datetime endDate =datetime.newInstance(endYear, endMonth, endDay, endHours,endMinutes, 0);
                            S.ESession.Session_End_Time__c=endDate;
                        }
                     //time calculation end
          
                         if((String.valueof(S.Esession.id))!=Null && (String.valueof(S.Esession.id))!='')
                         {
                          existingSessions.add(S.ESession);
                          if(String.valueof(S.Presenter1.id)!=NULL && String.valueof(S.Presenter1.id)!='')
                          {
                            if(S.Presenter1.Presenter_EBC_Name__c!=Null && S.Presenter1.Presenter_EBC_Name__c!='')
                                existingSess_UpdatePresenters.add(S.Presenter1);
                            else delete_Presenters.add(S.Presenter1);   
                          }
                          else
                          {
                              if((String.valueof(S.Presenter1.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter1.Topic_Presenters__c)!='') || 
                                 (S.Presenter1.Guest_Presenter_Last_Name__c!=NULL && S.Presenter1.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter1.Guest_Presenter_Email__c!=NULL && S.Presenter1.Guest_Presenter_Email__c!=''))
                                      {
                                     existingSess_InsertPresenters.add(S.Presenter1);
                                      }
                          }
                          if(String.valueof(S.Presenter2.id)!=NULL && String.valueof(S.Presenter2.id)!='')
                          {
                            if(S.Presenter2.Presenter_EBC_Name__c!=Null && S.Presenter2.Presenter_EBC_Name__c!='')
                                existingSess_UpdatePresenters.add(S.Presenter2);
                            else delete_Presenters.add(S.Presenter2);
                          }
                          else
                          {
                              if((String.valueof(S.Presenter2.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter2.Topic_Presenters__c)!='') || 
                                 (S.Presenter2.Guest_Presenter_Last_Name__c!=NULL && S.Presenter2.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter2.Guest_Presenter_Email__c!=NULL && S.Presenter2.Guest_Presenter_Email__c!=''))
                                      {
                                      existingSess_InsertPresenters.add(S.Presenter2);
                                      }
                          }                          
                          if(String.valueof(S.Presenter3.id)!=NULL && String.valueof(S.Presenter3.id)!='')
                          {
                            if(S.Presenter3.Presenter_EBC_Name__c!=Null && S.Presenter3.Presenter_EBC_Name__c!='')
                                existingSess_UpdatePresenters.add(S.Presenter3);
                            else delete_Presenters.add(S.Presenter3);
                          }
                          else
                          {
                              if((String.valueof(S.Presenter3.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter3.Topic_Presenters__c)!='') || 
                                 (S.Presenter3.Guest_Presenter_Last_Name__c!=NULL && S.Presenter3.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter3.Guest_Presenter_Email__c!=NULL && S.Presenter3.Guest_Presenter_Email__c!=''))
                                      {
                                      existingSess_InsertPresenters.add(S.Presenter3);
                                      }
                          }                                  
                          if(String.valueof(S.Presenter4.id)!=NULL && String.valueof(S.Presenter4.id)!='')
                          {
                            if(S.Presenter4.Presenter_EBC_Name__c!=Null && S.Presenter4.Presenter_EBC_Name__c!='')
                                existingSess_UpdatePresenters.add(S.Presenter4);
                            else delete_Presenters.add(S.Presenter4);
                          }
                          else
                          {
                              if((String.valueof(S.Presenter4.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter4.Topic_Presenters__c)!='') || 
                                 (S.Presenter4.Guest_Presenter_Last_Name__c!=NULL && S.Presenter4.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter4.Guest_Presenter_Email__c!=NULL && S.Presenter4.Guest_Presenter_Email__c!=''))
                                      {
                                      existingSess_InsertPresenters.add(S.Presenter4);
                                      }
                          }                         
                          if(String.valueof(S.Presenter5.id)!=NULL && String.valueof(S.Presenter5.id)!='')
                          {
                            if(S.Presenter5.Presenter_EBC_Name__c!=Null && S.Presenter5.Presenter_EBC_Name__c!='')
                                existingSess_UpdatePresenters.add(S.Presenter5);
                            else delete_Presenters.add(S.Presenter5);
                          }
                          else
                          {
                              if((String.valueof(S.Presenter5.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter5.Topic_Presenters__c)!='') || 
                                 (S.Presenter5.Guest_Presenter_Last_Name__c!=NULL && S.Presenter5.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter5.Guest_Presenter_Email__c!=NULL && S.Presenter5.Guest_Presenter_Email__c!=''))
                                      {
                                      existingSess_InsertPresenters.add(S.Presenter5);
                                      }
                          }                         
                         }
                         else
                         {
                             newSession.add(S.ESession);
                             if((S.Presenter1.Presenter_EBC_Name__c!=Null && S.Presenter1.Presenter_EBC_Name__c!='')&&
                                 (String.valueof(S.Presenter1.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter1.Topic_Presenters__c)!='') || 
                                 (S.Presenter1.Guest_Presenter_Last_Name__c!=NULL && S.Presenter1.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter1.Guest_Presenter_Email__c!=NULL && S.Presenter1.Guest_Presenter_Email__c!=''))
                                      {
                                      newSess_Presenters.add(S.Presenter1);
                                      }
                             if((S.Presenter2.Presenter_EBC_Name__c!=Null && S.Presenter2.Presenter_EBC_Name__c!='')&&
                                 (String.valueof(S.Presenter2.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter2.Topic_Presenters__c)!='') || 
                                 (S.Presenter2.Guest_Presenter_Last_Name__c!=NULL && S.Presenter2.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter2.Guest_Presenter_Email__c!=NULL && S.Presenter2.Guest_Presenter_Email__c!=''))
                                      {
                                      newSess_Presenters.add(S.Presenter2);
                                      }
                             if((S.Presenter3.Presenter_EBC_Name__c!=Null && S.Presenter3.Presenter_EBC_Name__c!='')&&
                                 (String.valueof(S.Presenter3.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter3.Topic_Presenters__c)!='') || 
                                 (S.Presenter3.Guest_Presenter_Last_Name__c!=NULL && S.Presenter3.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter3.Guest_Presenter_Email__c!=NULL && S.Presenter3.Guest_Presenter_Email__c!=''))
                                      {
                                      newSess_Presenters.add(S.Presenter3);
                                      }
                             if((S.Presenter4.Presenter_EBC_Name__c!=Null && S.Presenter4.Presenter_EBC_Name__c!='')&&
                                 (String.valueof(S.Presenter4.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter4.Topic_Presenters__c)!='') || 
                                 (S.Presenter4.Guest_Presenter_Last_Name__c!=NULL && S.Presenter4.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter4.Guest_Presenter_Email__c!=NULL && S.Presenter4.Guest_Presenter_Email__c!=''))
                                      {
                                      newSess_Presenters.add(S.Presenter4);
                                      }
                             if((S.Presenter5.Presenter_EBC_Name__c!=Null && S.Presenter5.Presenter_EBC_Name__c!='')&&
                                 (String.valueof(S.Presenter5.Topic_Presenters__c)!=NULL && String.valueof(S.Presenter5.Topic_Presenters__c)!='') || 
                                 (S.Presenter5.Guest_Presenter_Last_Name__c!=NULL && S.Presenter5.Guest_Presenter_Last_Name__c!='') ||
                                 (S.Presenter5.Guest_Presenter_Email__c!=NULL && S.Presenter5.Guest_Presenter_Email__c!=''))
                                      {
                                      newSess_Presenters.add(S.Presenter5);
                                      }
                          }
                         } 
                      
                      //DB operations Start                    
                      
                      if(existingSessions!=Null && existingSessions.size()>0)
                      Update existingSessions;
                      
                      if(existingSess_UpdatePresenters!=Null && existingSess_UpdatePresenters.size()>0)
                      Update existingSess_UpdatePresenters;
                      
                      if(existingSess_InsertPresenters!=Null && existingSess_InsertPresenters.size()>0)
                      Insert existingSess_InsertPresenters; 
                      
                      if(delete_Presenters!=Null && delete_Presenters.size()>0)
                      Delete delete_Presenters; 
                      
                      //to clear the lists--for the delete error
                      delete_Presenters = new List<EBC_Session_Presenter__c>();
                      
                      
                      //DB operations for new session
                      if(newSession!=Null && newSession.size()>0)
                        {
                         Database.SaveResult[] sessionSaveResult = Database.insert(newSession,false);
                         temptosavesession = [Select id, Name from EBC_Session__c where id =:sessionSaveResult[0].getId() LIMIT 1];
                         if(newSess_Presenters!=Null && newSess_Presenters.size()>0)
                              {
                               for(EBC_Session_Presenter__c SP:newSess_Presenters)
                                 {
                                  SP.Session__c = temptosavesession.id;
                                  SP.Name = temptosavesession.Name;
                                 }        
                              }
                        }
                       upsert newSess_Presenters; 
                     }  
                   }

        public void cleanTopicMessage(){
                List<EBC_Session__c> sessions = new List<EBC_Session__c>();
                
                for(EBC_Session__c s:[SELECT Id, Status__c from EBC_Session__c WHERE Briefing_Event__c = :this.BEvent.Id]){
                        if(s.Status__c != null){
                                s.Status__c = '';
                                sessions.add(s);
                        }
                }
                
                if(sessions.size() > 0){
                        update sessions;
                }
                
                System.debug('SESSIONS: ' + sessions);
        }
}