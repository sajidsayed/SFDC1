/*===========================================================================+
 |  HISTORY                                                                  
 |
 |  DATE       DEVELOPER             WR               DESCRIPTION                               
 |  ====       =========             ==               ===========
 |  20-JUL-09  S Douglas                              Initial Creation - for prevention of duplicate contacts
 |                                                    A contact may not be created if a user already has access to a contact
 |                                                    with the same email address (so we must enforce user security via "with sharing")
 |  
 |  09-JUN-10  Devi Prasad Bal       EBC Phase II     Code modified to prevent duplication of contacts belonging to a particular Record Type
 |                                                    as against preventing contact duplication across all contacts.
 |
 |  07-July-11 Srinivas Nallapati    169801            Prevention of Duplication during update  
 |
 |                          
 +===========================================================================*/
public with sharing class CTCT_PreventDuplicates 
{

    public static void ProcessContactInserts(List <Contact> inboundContacts) 
    {

        //Build a list of all non-null emails in the incoming contact list
        List<String> contactEmails = new List<String>();
        for (Contact cont : inboundContacts) {
            if (cont.email != null) {
                contactEmails.add(cont.email);
            }
        }
        
        //[Devi] check whether duplicate contact record from among the new contacts being created.
        //If so, flag as error

        for (Integer i=0; i < inboundContacts.size(); i++)
        {
            for (Integer j=i+1; j < inboundContacts.size(); j++)
            {
                if(inboundContacts[i].email!=null && inboundContacts[j].email!=null && inboundContacts[i].email.toUpperCase() == inboundContacts[j].email.toUpperCase() && inboundContacts[i].RecordTypeId == inboundContacts[j].RecordTypeId) 
                {
                        inboundContacts[i].addError(System.Label.CTCT_DupContactExists);
                        break;
                }           
            }
        }
        

        //[Devi: code modified to put the record type check while finding out duplicate contacts.]
        //Now query for any contacts which already exist with the emails in the list
        //Note that there could be duplicates in the returned list
        List<Contact> dupContacts;
        if(contactEmails.size() > 0 ){
        	dupContacts = [SELECT ID, email, RecordTypeId FROM contact WHERE email IN :contactEmails and active__c = true ORDER BY email];
        }
                
        
        //Now check whether the contacts in the incoming contact list have duplicates.
        //If so, flag as error
        for (Contact cont : inboundContacts) 
        {
            if (cont.email != null) {
            	if(dupContacts != null && dupContacts.size() > 0){
            		for(Contact dupCon : dupContacts)
	                {
	                    if(cont.email.toUpperCase() == dupCon.email.toUpperCase() && cont.RecordTypeId == dupCon.RecordTypeId)
	                    {
	                        //This email is a duplicate
	                        cont.addError(System.Label.CTCT_DupContactExists);
	                        break;  
	                    }
                	}
            	} 
                
            }
        }
        
    }//End of method
    
    
    //WR-169801 Srinivas Nallapati Created this method to prevent duplication of contacts during the Update
    public static void ProcessContactUpdates(List <Contact> inboundContacts) 
    {

        //Build a list of all non-null emails in the incoming contact list
        List<String> contactEmails = new List<String>();
        for (Contact cont : inboundContacts) {
            if (cont.email != null) {
                contactEmails.add(cont.email);
            }
        }
        
        //[Devi] check whether duplicate contact record from among the new contacts being created.
        //If so, flag as error
        for (Integer i=0; i < inboundContacts.size(); i++)
        {
            for (Integer j=i+1; j < inboundContacts.size(); j++)
            {
                if(inboundContacts[i].email!=null && inboundContacts[j].email!=null && inboundContacts[i].email.toUpperCase() == inboundContacts[j].email.toUpperCase() && inboundContacts[i].RecordTypeId == inboundContacts[j].RecordTypeId) 
                {
                        inboundContacts[i].addError(System.Label.CTCT_DupContactExists);
                        break;
                }           
            }
        }
        

        //[Devi: code modified to put the record type check while finding out duplicate contacts.]
        //Now query for any contacts which already exist with the emails in the list
        //Note that there could be duplicates in the returned list
        List<Contact> dupContacts = [SELECT ID, email, RecordTypeId FROM contact WHERE email IN :contactEmails and active__c = true ORDER BY email];
        
        
        //Now check whether the contacts in the incoming contact list have duplicates.
        //If so, flag as error
        for (Contact cont : inboundContacts) 
        {
            if (cont.email != null) {
                for(Contact dupCon : dupContacts)
                {
                    if(cont.email.toUpperCase() == dupCon.email.toUpperCase() && cont.RecordTypeId == dupCon.RecordTypeId && cont.id != dupCon.id)
                    {
                        //This email is a duplicate
                        cont.addError(System.Label.CTCT_DupContactExists);
                        break;  
                    }
                }
            }
        }
    }//End of method
        
}//End of Class