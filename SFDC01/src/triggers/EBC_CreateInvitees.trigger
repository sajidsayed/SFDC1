/*
*  Created By       :- Sunil Arora
*  Created Date     :- 26/02/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This trigger is used here to create Invitee records.

Modification History
Last modified by : Vijo Joy
Modified On: 20th March 2013
Reason: The trigger was excuting only for single record. added loop constructs to cycle thru all trigger records
WR/eRFC: WR240944
*/
trigger EBC_CreateInvitees on EBC_Session_Presenter__c (after insert,after update,after delete)
{
    //variables used in previous version of this class
    /*
    Set<Id> sessionIdSet=new Set<Id>();
    Id presenterId;
    Id presenterIdToDelete;
    String presenterEmail;
    String presenterEmailToDelete;
    Boolean gPresenter=false;
    Boolean gPresenterDelete=false;
    Boolean presenter=false;
    Boolean presenterDelete=false;
    */
    // new variables to bulkify the trigger
    List<EBC_Session_Presenter__c>lstInsertGuestPresentersInvitees = new List<EBC_Session_Presenter__c>();
    List<EBC_Session_Presenter__c>lstInsertTopicPresentersInvitees = new List<EBC_Session_Presenter__c>();
    List<EBC_Session_Presenter__c>lstDeleteGuestPresentersInvitees = new List<EBC_Session_Presenter__c>();
    List<EBC_Session_Presenter__c>lstDeleteTopicPresentersInvitees = new List<EBC_Session_Presenter__c>();
    //end of variables declaration
    
    //EBC_CreateInvitees CI=new EBC_CreateInvitees();
    //Vijo--declaring the class to support this trigger
    EBC_createBriefingInvitees createOrDelInvitees = new EBC_createBriefingInvitees();
    
    //If user is inserting the record.
    if(trigger.isInsert)
    {
        //vijo:WR240944:added loop for insert
        for(EBC_Session_Presenter__c sessPres : trigger.new)
        {
        if(sessPres.Guest_Presenter_Email__c !=null && sessPres.Guest_Presenter_Last_Name__c != null)
        {
            //gPresenter=true;
            lstInsertGuestPresentersInvitees.add(sessPres);
        }
        if(sessPres.Presenter__c!=null)
        {
            //presenter=true;
            lstInsertTopicPresentersInvitees.add(sessPres);
        }
        //CI.createInvitees(trigger.new[eSP],gPresenter,presenter);
        }
    }
    
    //If user is updating the record.
    else if(trigger.isUpdate)
    {
        //vijo:WR240944:added loop for update
        for(Integer eSP = 0; eSP<trigger.new.size();eSP++)
        {
        if(trigger.new[eSP].Guest_Presenter_Email__c !=null && trigger.new[eSP].Guest_Presenter_Last_Name__c != null && trigger.new[eSP].Guest_Presenter_Email__c!=trigger.old[eSP].Guest_Presenter_Email__c )
        {
            //gPresenter=true;
            lstInsertGuestPresentersInvitees.add(trigger.new[eSP]);
        }
        //If Guest_Presenter_Email__c was null before updating, then there is no use to delete any record.
        if(trigger.old[eSP].Guest_Presenter_Email__c!=null && trigger.new[eSP].Guest_Presenter_Email__c!=trigger.old[eSP].Guest_Presenter_Email__c)
        {
            //gPresenterDelete=true;
            lstDeleteGuestPresentersInvitees.add(trigger.old[eSP]);
        }
        //If Presenter__c was null before updating, then there is no use to delete any record.
        if(trigger.old[eSP].Presenter__c!=null && trigger.new[eSP].Presenter__c!=trigger.old[eSP].Presenter__c)
        {
            //presenterDelete=true;
            lstDeleteTopicPresentersInvitees.add(trigger.old[eSP]);
        }   
        if(trigger.new[eSP].Presenter__c!=null && trigger.new[eSP].Presenter__c!=trigger.old[eSP].Presenter__c)
        {
            //presenter=true;
            lstInsertTopicPresentersInvitees.add(trigger.new[eSP]);         
        }
          
            //CI.createInvitees(trigger.new[eSP],gPresenter,presenter);
          
          //CI.deleteInvitees(trigger.old[eSP],gPresenterDelete,presenterDelete);
        }   
    }
    // if the user is deleting presenter records, guest or otherwise
    else
    {
        //vijo:WR240944:added loop for delete
        for(Integer eSP = 0; eSP<trigger.old.size();eSP++)
        {
        //CI.deleteInvitees(trigger.old[eSP],true,true);
        if(trigger.old[eSP].Presenter__c!=null)
        {
        //presenterDelete=true;
        lstDeleteTopicPresentersInvitees.add(trigger.old[eSP]);
        }
        else
        {
        lstDeleteGuestPresentersInvitees.add(trigger.old[eSP]);
        }       
        }
    }
    
    // to delete invitees
    if((lstDeleteTopicPresentersInvitees.size()>0)||(lstDeleteGuestPresentersInvitees.size()>0))
    createOrDelInvitees.deleteInvitees(lstDeleteGuestPresentersInvitees, lstDeleteTopicPresentersInvitees); 
    // to create invitees
    if((lstInsertTopicPresentersInvitees.size()>0)||(lstInsertGuestPresentersInvitees.size()>0))
    createOrDelInvitees.createInvitees(lstInsertGuestPresentersInvitees, lstInsertTopicPresentersInvitees);
}