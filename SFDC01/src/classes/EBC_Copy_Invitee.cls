/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER         WR                DESCRIPTION                               
 |  ====       =========         ==                =========== 
 |  27-APR-10  Devi Prasad Bal  Initial Creation.  Procedures for creating a copy of an existing invitee(EMC Internal Contact)
 |												   with a different role(EMC Employee).
 |              
 +===========================================================================*/

public class EBC_Copy_Invitee {
    
    public Id inviteesId= System.currentPageReference().getParameters().get('Id');
	public String bEventId= ApexPages.currentPage().getParameters().get('retURL');
	public EBC_Briefing_Event__c objBEvent {get;set;} // to hold the briefing event object record
	public List<EBC_Invitees__c> inviteeList = new List<EBC_Invitees__c>(); // to hold invitee records list for diplay
	public String selectedInvitee;
	
	//Constructor
	public EBC_Copy_Invitee(ApexPages.StandardController stdController)
	{
		if(bEventId!=null)
		{
			bEventId=bEventId.replace('/','');
		}
		
    	// retrieve the Feedback fields from the Briefing Event and store it in objBEvent
        objBEvent=[Select   Id, Name, Start_Date__c, End_Date__c        
                    From EBC_Briefing_Event__c where Id=:bEventId];
                    
		retrieveInvitees();  // invoke method for retrieving Invitees records for the Briefing Event
		
	}
	
	public void setSelectedInvitee(String s){
        this.selectedInvitee=s;
    }
    public String getSelectedInvitee(){
        return this.selectedInvitee;
    }
    public List<EBC_Invitees__c> getInternalInvList() {
        return inviteeList;
    }
	
	// method for retrieving Invitees records for the Briefing Event
    public void retrieveInvitees()
    {
    	setSelectedInvitee('');
    	// code to retrieve the contact record type id where the record type name is 'EMC Internal Contact'       
        Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
        Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
        Id internalContact= record_Type_name_RT.getRecordTypeId();
    	
        try{
            // invitees' list to be displayed on the page
            inviteeList = [Select Id, Invitee__c , Briefing_Team_Role__c, Contact__r.RecordTypeId , Attendee_Email__c, EBC_Title__c
            				 from EBC_Invitees__c 
            				 where Briefing_Event__c =:bEventId and Contact__r.RecordTypeId =:internalContact and Briefing_Team_Role__c != 'Presenter (EMC Employee)'  
            				 ORDER BY Invitee__c ];           
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'No EMC Employee could be found as an employee.'));
        }
    }
    
    
    public PageReference addInvitee(){
    	
    	// Display an error message if the radio button is not selected.
        if(selectedInvitee == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, ' You must select one of the invitees in the list below to perform the requested action.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        else{
        	
        	try{
        		//Id selectedInviteeId = getSelectedInvitee();
		        // retrieve the selected invitee											
				EBC_Invitees__c ebcInv = [Select Contact__c, Company__c, Send_Impact__c, Send_Feedback__c, Send_FBP__c, Send_CBP__c,
				                                 Position_they_represent_in_their_Company__c, Id, Feedback_Output__c,
				                                 EBC_Title__c, EBC_Name__c, Customer_Notes__c, Briefing_Team_Role__c,                                                  
				                                 Briefing_Event__c, Attitude_towards_EMC__c, Attending__c, Attendee_Email__c,                                                  
				                                 Last_Name__c, First_Name__c                                                  
				                                 from EBC_Invitees__c where Id =:selectedInvitee];
				                                 
				// create a new invitee with the same name as that of the retrieved invitee                                                              
				EBC_Invitees__c newInv = new EBC_Invitees__c(Contact__c = ebcInv.Contact__c, Briefing_Event__c=bEventId, Attending__c=true, EBC_Name__c=ebcInv.EBC_Name__c,                                                             
																		Company__c = ebcInv.Company__c, EBC_Title__c=ebcInv.EBC_Title__c, Briefing_Team_Role__c='EMC Employee',                                                            
																		Attendee_Email__c=ebcInv.Attendee_Email__c, Attitude_towards_EMC__c='',                                                             
																		Position_they_represent_in_their_Company__c='', Customer_Notes__c='',                                                             
																		Send_Impact__c=false, Send_Feedback__c=false, Send_FBP__c=false,                                                             
																		Send_CBP__c=false, Feedback_Output__c=false,                                                             
																		Last_Name__c=ebcInv.Last_Name__c, First_Name__c=ebcInv.First_Name__c);				                                 		        											
		        											
		        											
				insert newInv;	// create a new invitee
								
				// code to redirect to the Briefing Team Attributes page of the Briefing Event
				PageReference pageRef = new PageReference('/apex/EBC_Briefing_Team_Attributes?id=' + bEventId);
        		pageRef.setRedirect(true);
        		return pageRef;
				
        	
        	}
        	catch(Exception ex){
        		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'A new invitee with the selected invitee could not be created. Please contact your system administrator.');
            	ApexPages.addMessage(myMsg);
            	return null;	
        	}	        
	        
        }
    }    
    

	// method to go back to the briefing event detail page
    public PageReference backToBE()
    { 
        PageReference pageRef = new PageReference('/' + bEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
}