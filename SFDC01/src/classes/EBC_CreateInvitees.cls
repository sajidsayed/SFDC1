/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This class will be called by EBC_CreateInvitees trigger to create invitees, if user selects Guest Presenter.
*/
public  class EBC_CreateInvitees
{
	public void createInvitees(EBC_Session_Presenter__c spNew,Boolean gPresenter,Boolean presenter)
	{
		EBC_Session__c[] bEventLst=[Select Id,Briefing_Event__c from EBC_Session__c where Id =: spNew.Session__c Limit 1];
		List<EBC_Invitees__c> new_inviteesLst=new List<EBC_Invitees__c> ();
		if(bEventLst.size()>0)
		{    
	     
	     //This query is used here to check, whether Invitees are getting added for the first time or we are adding duplicate ones.
	     EBC_Invitees__c[] chkInvitees=[Select id,Attendee_Email__c,Contact__c from EBC_Invitees__c 
	                                        where Briefing_Event__c=:bEventLst[0].Briefing_Event__c and 
	                                        ((Contact__c=:spNew.Presenter__c and 
	                                            (Briefing_Team_Role__c='Presenter (Non EMC Employee)' or Briefing_Team_Role__c= 'Presenter (EMC Employee)')
	                                            ) or (Attendee_Email__c=: spNew.Guest_Presenter_Email__c and Briefing_Team_Role__c='Presenter (Non EMC Employee)'))];
	     
	     //spNew.addError(gPresenter+'chk'+chkInvitees);
	     for(Integer i=0;i<chkInvitees.size();i++)
	     {
	     	if(chkInvitees[i].Attendee_Email__c==spNew.Guest_Presenter_Email__c)
	     	{
	     		gPresenter=false;
	     	}
	     	if(chkInvitees[i].Contact__c==spNew.Presenter__c)
	     	{
	     		presenter=false;
	     	}
	     }
	     EBC_Topic_Presenters__c tPresenter;
	      if(spNew.Topic_Presenters__c!=null)
	      {
	      	//This call is used here to fetch EBC Title and Name.
	        tPresenter=[Select Id,EBC_Name__c,EBC_Title__c from EBC_Topic_Presenters__c where Id=:spNew.Topic_Presenters__c];
	      }
	      
	      
	      if(spNew.Guest_Presenter_Email__c !=null && spNew.Guest_Presenter_Last_Name__c != null && gPresenter==true)
	      {
	       EBC_Invitees__c invitee = new EBC_Invitees__c (
                                                       Briefing_Team_Role__c='Presenter (Non EMC Employee)',
                                                       Last_Name__c=spNew.Guest_Presenter_Last_Name__c,
                                                       First_Name__c=spNew.Guest_Presenter_First_Name__c,
                                                       Attendee_Email__c=spNew.Guest_Presenter_Email__c,
                                                       EBC_Title__c=spNew.Guest_Presenter_EBC_Title__c,
                                                       EBC_Name__c=spNew.Presenter_Name__c,
                                                       Company__c=spNew.Guest_Company__c,
                                                       From_Object__c='Session Presenter',
                                                       Briefing_Event__c=bEventLst[0].Briefing_Event__c
                                                       );
            new_inviteesLst.add(invitee);	      	
	      }
	      if(spNew.Presenter__c!=null && presenter==true && spNew.Topic_Presenters__c!=null)
	      {
	      	Contact con = [Select Id,FirstName,LastName,Email,RecordTypeId,Account.Name from Contact where id=:spNew.Presenter__c];
	        
	        //This code is used to get record type id
	        Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
			Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
		    Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
			Id rTypeId= record_Type_name_RT.getRecordTypeId();

	       	EBC_Invitees__c invitee = new EBC_Invitees__c (
                                          Last_Name__c=con.LastName,
                                          First_Name__c=con.FirstName,
                                          Attendee_Email__c=con.Email,
                                          Contact__c=con.Id,
                                          EBC_Title__c=tPresenter.EBC_Title__c,
                                          EBC_Name__c=tPresenter.EBC_Name__c,
                                          From_Object__c='Session Presenter',
                                          Briefing_Event__c=bEventLst[0].Briefing_Event__c);
	       
	       if(rTypeId==con.RecordTypeId)
	       {
               invitee.Briefing_Team_Role__c='Presenter (EMC Employee)';
               invitee.Send_FBP__c=true;
               invitee.Feedback_Output__c=true;
	       }
	       else
	       {                                         
            	invitee.Briefing_Team_Role__c='Presenter (Non EMC Employee)';
            	invitee.Feedback_Output__c=false;     	
	       }
	       
	       if(con.recordTypeId==rTypeId)
            {
              invitee.Company__c='EMC Corporation';
            }
            else
	        {
              invitee.Company__c=con.Account.Name;
	        }
	       new_inviteesLst.add(invitee);
	      }
	      insert new_inviteesLst;
		}
	}
	
	//This method will be called on Update and Delete session Presenter record.
	public void deleteInvitees(EBC_Session_Presenter__c spOld,Boolean gPresenterChange,Boolean presenterChange)
	{
		List<EBC_Invitees__c> delInvitees=new List<EBC_Invitees__c> ();
		EBC_Session__c[] bEventLst=[Select Id,Briefing_Event__c from EBC_Session__c where Id =: spOld.Session__c Limit 1];
		
		if(bEventLst.size()>0)
		{
			    EBC_Invitees__c[] chkInvitees=[Select id,Attendee_Email__c,Contact__c,Briefing_Team_Role__c 
		                                      from EBC_Invitees__c 
		                                      where Briefing_Event__c=:bEventLst[0].Briefing_Event__c and (Contact__c=:spOld.Presenter__c or Attendee_Email__c=: spOld.Guest_Presenter_Email__c)];
		
				EBC_Session_Presenter__c[] sp=[Select Id,Presenter__c,Guest_Presenter_Email__c from EBC_Session_Presenter__c where Id !=: spOld.Id and Session__c=:spOld.Session__c];
				for(Integer i=0;i<sp.size();i++)
				{
					if(sp[i].Presenter__c==spOld.Presenter__c)
					{
						presenterChange=false;
					}
					if(sp[i].Guest_Presenter_Email__c==spOld.Guest_Presenter_Email__c)
					{
						gPresenterChange=false;
					}
				}
				                                      
				for(Integer i=0;i<chkInvitees.size();i++)
				{
					if(chkInvitees[i].Contact__c==spOld.Presenter__c && presenterChange==true && spOld.Presenter__c!=null && (chkInvitees [i].Briefing_Team_Role__c=='Presenter (EMC Employee)' || chkInvitees[i].Briefing_Team_Role__c=='Presenter (Non EMC Employee)'))
					{
						delInvitees.add(chkInvitees[i]);
					}
					if(chkInvitees[i].Attendee_Email__c==spOld.Guest_Presenter_Email__c && gPresenterChange==true && chkInvitees[i].Briefing_Team_Role__c=='Presenter (Non EMC Employee)' && spOld.Guest_Presenter_Email__c!=null)
					{
						delInvitees.add(chkInvitees[i]);
					}
				}
				if(delInvitees.size()>0)
				{
					delete delInvitees;
				}
		}
		

	}
}