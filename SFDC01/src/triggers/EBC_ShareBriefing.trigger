/*
*  Created By       :- Sunil Arora
*  Created Date     :- 19/05/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used to create/delete Briefing Share records when the role changed to 'Acount Teeam Member'.
*  Note             :- This trigger will work only when user update/delete the Invitee records from Browser and all Invitees have same Briefing Event.
*/
trigger EBC_ShareBriefing on EBC_Invitees__c (after update,before delete)
{
    Set<Id> useridToDelete = new Set<Id>();
    Set<String> inviteeEmailToCreateShare=new Set<String>();
    Set<String> inviteeEmailToDeleteShare=new Set<String>();
    List<EBC_Briefing_Event__Share> beShareLst=new List<EBC_Briefing_Event__Share>();
    
    if(trigger.isUpdate)
    {
    	//for(Integer i=0;i<trigger.new.size();i++)
    	for(Id newInviteeId: Trigger.oldMap.keySet())
	    {
	        EBC_Invitees__c newInvitee = Trigger.newMap.get(newInviteeId);
        	EBC_Invitees__c oldInvitee = Trigger.oldMap.get(newInviteeId);
	        //To add Email to create Briefing Share records
	        if(newInvitee.Briefing_Team_Role__c=='Account Team Member' && oldInvitee.Briefing_Team_Role__c!='Account Team Member')
	        {
	            inviteeEmailToCreateShare.add(newInvitee.Attendee_Email__c);
	        }
	        //To add Email to delete Briefing Share records
	        else if(newInvitee.Briefing_Team_Role__c!='Account Team Member' && oldInvitee.Briefing_Team_Role__c=='Account Team Member')
	        {
	            inviteeEmailToDeleteShare.add(newInvitee.Attendee_Email__c);
	        }
	    }
    }
    else
    {
    	for(EBC_Invitees__c invitee:trigger.old)
    	{
    		if(invitee.Briefing_Team_Role__c=='Account Team Member')
    		{
    			inviteeEmailToDeleteShare.add(invitee.Attendee_Email__c);
    		}
    	}
    }
    //This call is used here to fetch related User records
    User[] usr=[Select Id,Email from User where Email IN:inviteeEmailToCreateShare or Email IN: inviteeEmailToDeleteShare];
    for(Integer i=0;i<usr.size();i++)
    {
        if(inviteeEmailToCreateShare.contains(usr[i].Email+''))
        {
            EBC_Briefing_Event__Share addBShare=new EBC_Briefing_Event__Share(UserOrGroupId=usr[i].Id,ParentId=trigger.new[0].Briefing_Event__c,AccessLevel='Edit');
            beShareLst.add(addBShare);
        }
        else if(inviteeEmailToDeleteShare.contains(usr[i].Email))
        {
            useridToDelete.add(usr[i].Id);
        }
    }
    insert beShareLst;
    
    //This call is use to fetch Briefinng Share record to delete them.
    EBC_Briefing_Event__Share[] bShare=[Select UserOrGroupId, RowCause, ParentId,
                                             IsDeleted, Id, AccessLevel From EBC_Briefing_Event__Share where UserOrGroupId IN: useridToDelete and parentId=:trigger.old[0].Briefing_Event__c];
    if(bShare.size()>0)
    {
        delete bShare;
    } 
}