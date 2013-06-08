/*======================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 30/9/2010      Karthik Shivprakash      1074          This trigger is invoked 
                                                        after insert on account
| 15/02/2011     Anirudh Singh            1829          Commented Grouping Logic 
                                                        as this method is called from
|                                                       PRM_AssociationScheduler Class 
 06/06/2011      Anirudh Singh                          Updated trigger to call setRelatedAccountOnDealReg
|                                                       when a new account is getting created.
 22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic
|06/02/2013		krishna pydavula		223453			To handle the exceptions from Informatica for Booking object										
+======================================================================================*/


trigger AccountAfterInsert on Account (after Insert) {
  //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
       System.Debug('1111--->');
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    } 
	List<Account> acc=new List<Account>();
    //Linking account to deal reg having same track_party_number
    PRM_DealReg_Operations dealRegObj = new PRM_DealReg_Operations();
    dealRegObj.setRelatedAccountOnDealReg(Trigger.New);  
 	//Added by Krishna WR 223453
    for(Account a:Trigger.new)
    {
    	acc.add(a);
    }
	BookingOperations bookopts=new BookingOperations();
	bookopts.PopulateRelatedAccount(acc);	
    //End of the code for WR 223453
    
    //Anirudh
    /*
    PRM_AccountGrouping groupObj = new PRM_AccountGrouping();
    groupObj.setAssociation(Trigger.new);*/
    
     /*
    //shipra
    Set<Id> accIdSet= new Set<Id>();
    for(Account accnt:trigger.new)
    {
        if(accnt.Install_Base_Account__c==true)
        {
            accIdSet.add(accnt.id);
        }       
    }
    System.debug('accIdSet--->'+accIdSet);
    if(accIdSet.size()>0)
    {
        Acc_updateInstallBaseAccount.updateInstallBaseAccount(accIdSet);
    }
    */
    //end
 }