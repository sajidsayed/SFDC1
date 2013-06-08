/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Devi Bal
*  Modified Reason  :- Issue# 197: when a BE is rescheduled need same logic to apply to daily food options dates, need to re-schedule Briefing food options 
*  Description      :- This trigger will be called on update of Briefing Event(If it get updated from Event) and will update the dates of Sessions.
*  Note             :- Trigger will work on single record only.
*/

trigger EBC_UpdateSessionDates on EBC_Briefing_Event__c (after update)
{
    Date startDate;
    try
    {
        //If user update the start date or end date of Briefing Event.
        if(trigger.new[0].Start_Date__c!=trigger.old[0].Start_Date__c || trigger.new[0].End_Date__c!=trigger.old[0].End_Date__c)
        {
            EBC_Session__c[] sess=[Select Id,Session_Start_Time__c,Session_End_Time__c,
            							  Session_Start_Date__c, Session_End_Date__c, Can_this_session_be_changed__c,
                                      	  (Select Id,Is_the_Presenter_Confirmed__c from Session_Presenter__r)
                                   from EBC_Session__c 
                                   where Briefing_Event__c=:trigger.new[0].Id];
            List<EBC_Session_Presenter__c>  sp=new List<EBC_Session_Presenter__c>();
            
            Briefing_Food_Options__c[] bfo= [Select Id, Date__c 
            								 From Briefing_Food_Options__c
            								 where Briefing_Event__c=:trigger.new[0].Id];
            								 
            for(Integer i=0;i<bfo.size();i++)
            {
            	bfo[i].Date__c = trigger.new[0].Start_Date__c;	
            }
                                                   
            for(Integer i=-0;i<sess.size();i++)
            {
                if(sess[i].Session_Start_Time__c!=null)
                {
                    startDate = date.valueOf(sess[i].Session_Start_Time__c+''); 
                }   
                /*
                * It will update the session date only when if Session dates doesn't lie between Briefing Event Start and End Dates
                * (Assuming session will be of 1 day only).
                */
                if(startDate<trigger.new[0].Start_Date__c || startDate>trigger.new[0].End_Date__c || sess[i].Session_Start_Time__c==null)
                {
                    sess[i].Session_Start_Time__c=datetime.valueOf(trigger.new[0].Start_Date__c + '');                    
                    sess[i].Session_End_Time__c=datetime.valueOf(trigger.new[0].Start_Date__c + '');
                    sess[i].Session_Start_Date__c=trigger.new[0].Start_Date__c ;                    
                    sess[i].Session_End_Date__c=trigger.new[0].Start_Date__c ;
                    sess[i].Are_the_Presenters_Secured__c='No';
                    sess[i].Can_this_session_be_changed__c='Yes';
                    for(Integer j=0;j<sess[i].Session_Presenter__r.size();j++)
                    {
                        sp.add(new EBC_Session_Presenter__c(Id=sess[i].Session_Presenter__r[j].Id,Is_the_Presenter_Confirmed__c='No'));
                    }
                }
            }
            try
            {
                update sess;
                update sp;
            }
            catch (DMLException e)
            {
                trigger.new[0].addError('The session dates could not be changed on change of date in briefing event. Please contact your System Administrator for more details.' + e.getMessage());
            }
            try
            {
            	update bfo;
            }
			catch (DMLException e)
            {
                trigger.new[0].addError('The briefing food option date could not be changed on change of date in briefing event. Please contact your System Administrator for more details.' + e.getMessage());
            }
        }       
    }
    catch(QueryException e)
    {
    	trigger.new[0].addError('There has been a database query error. Please contact your System Administrator for more details.' + e.getMessage());	
    }
    catch (Exception e)
    {
        trigger.new[0].addError('There has been an error. Please contact your System Administrator for more details.' + e.getMessage());
    }
}