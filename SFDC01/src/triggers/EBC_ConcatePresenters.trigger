/*
*  Created By       :- Devi Prasad Bal
*  Created Date     :- 06/04/2010
*  Description      :- This trigger is used to concatenate and update the 'concatenated preseneter information' field 
*                      on the Session object. This field will have the concatanated values of the presenter names and titles.
*  Last Modified Date :- 07/07/2010
*  Last Modified By :- Devi Bal
*  Last Modified Reason :- The code is being modified to work on multiple records and not a single record as earlier.
*/

trigger EBC_ConcatePresenters on EBC_Session_Presenter__c (after insert, after update, after delete) 
{
    List<EBC_Session_Presenter__c> lst = Trigger.isDelete?Trigger.Old:Trigger.New;
    
    // A set of Session Presenters
    Set<Id> sess_ids = new Set<Id>();
    for(EBC_Session_Presenter__c sessPres: lst)
    {
        sess_ids.add(sessPres.Session__c);
    }
    
    // Create a list of session presenters
    List<EBC_Session_Presenter__c> sessPresentersList = [Select Presenter_EBC_Name__c, Presenter_EBC_Title__c, Session__c  
                                                         From EBC_Session_Presenter__c 
                                                         Where Session__c IN: sess_ids ORDER BY Session__c];
	
	//This block of code works when there is only one session presenter for the a session and the session presenter is deleted.
    if(sessPresentersList.size() == 0)
    {
    	List<EBC_Session__c> sessList = [Select Concatenated_Presenter_Information__c From EBC_Session__c Where Id IN: sess_ids];
    	
    	for(Integer i=0; i< sessList.size(); i++)
    	{
    		sessList[i].Concatenated_Presenter_Information__c = '';	
    	}
    	update sessList; 	
    }
    else
    {
	    List<EBC_Session__c> sessList = new List<EBC_Session__c>();
	    
	    String sameSess= sessPresentersList[0].Session__c; // Initializing sameSess with the session id of the first session presenter in the list of session presenters
	    EBC_Session__c sess = new EBC_Session__c(Id=sessPresentersList[0].Session__c); // Initializing sess with the session record related to the first session presenter in the list of session presenters
	    
	    String pres=''; // to store the concatenated value
	    String name=''; // to store the presenter's name
	    String title=''; // to store the presenter's title
	            
	    for(Integer i=0; i< sessPresentersList.size(); i++)
	    {
	        // This block of code has the logic of the concatanation of name and title of the session presenters
	        if(sameSess == sessPresentersList[i].Session__c)
	        { 
	        	if(sessPresentersList[i].Presenter_EBC_Name__c == null)
	                name='';
	            else
	                name=sessPresentersList[i].Presenter_EBC_Name__c ;
	            if(sessPresentersList[i].Presenter_EBC_Title__c == null)
	                title='';
	            else
	                title= ', ' + sessPresentersList[i].Presenter_EBC_Title__c;
	                
	            pres = pres + name + title + '\n' ; // presenters' name and title being concatenated here.
	            
	        }
	        else if(sameSess != sessPresentersList[i].Session__c)
	        {
	            sess.Concatenated_Presenter_Information__c = pres;
	            sessList.add(sess);
	            
	            sameSess = sessPresentersList[i].Session__c;
	            pres='';
	
	            if(sessPresentersList[i].Presenter_EBC_Name__c == null)
	                name='';
	            else
	                name=sessPresentersList[i].Presenter_EBC_Name__c ;
	            if(sessPresentersList[i].Presenter_EBC_Title__c == null)
	                title='';
	            else
	                title= ', ' + sessPresentersList[i].Presenter_EBC_Title__c;
	                
	            pres = pres + name + title + '\n' ; // presenters' name and title being concatenated here.
	
	            sess = new EBC_Session__c(Id=sessPresentersList[i].Session__c);
	            
	        }  
	    }
	    sess.Concatenated_Presenter_Information__c = pres;
	    sessList.add(sess);
	    update sessList; // Update the concatenated presenter information of the list of sessions.
	}    
}