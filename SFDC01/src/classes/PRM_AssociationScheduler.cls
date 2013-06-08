/*======================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
  03/03/2011     Anirudh Singh            1828          This class is a Schedulable class
|                                          1829          and is used to process the Accounts
                                          				and either create or delete the
|                                          				Associations depending on the Active
                                          				Partner User Count.                                    
+======================================================================================*/
global class PRM_AssociationScheduler implements Schedulable{
    
/* @Method <execute(): for scheduling>
   @param <SchedulableContext SC>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    global void execute(SchedulableContext SC){
        
        
        PRM_GroupingAssociation scheduleAssociation = new PRM_GroupingAssociation();
        PRM_AccountGrouping groupObj = new PRM_AccountGrouping();
        //Creating List of Accounts for which Associations needs to be deleted.
        List<Account> ListAccountstoDelAsso = New List<Account>();
        //Creating List of Ids of Accounts for which Association needs to be made.
        List<Id> ListIdstoDelAsso = New List<Id>();
        //Creating List of Accounts for which Association needs to be made.
        List<Account> ListAccountsAssociate = New List<Account>();
        ListAccountsAssociate = [select id,Partner_Type__c,Lead_Oppty_Enabled__c,
                               PROFILED_ACCOUNT_FLAG__c,Grouping__c ,
                               Site_DUNS_Entity__c,Profiled_Account__c   
                               from account
                               where (PROFILED_ACCOUNT_FLAG__c=false and Child_Partner_Users_Count__c>0 and of_Associations__c=0 and Profiled_Account__c!=null)];
        ListAccountstoDelAsso = [select id,Partner_Type__c,Lead_Oppty_Enabled__c,
                               PROFILED_ACCOUNT_FLAG__c,Grouping__c ,
                               Site_DUNS_Entity__c,Profiled_Account__c   
                               from account
                               where (PROFILED_ACCOUNT_FLAG__c=false and Child_Partner_Users_Count__c=0 and of_Associations__c>0)];                       
        System.Debug('ListAccountsAssociate--->' +ListAccountsAssociate);
        System.Debug('ListAccountstoDelAsso--->' +ListAccountstoDelAsso);
        if(ListAccountsAssociate.size()> 0){
        groupObj.setAssociation(ListAccountsAssociate);
        scheduleAssociation.createAssociationsforUpdate(ListAccountsAssociate);
    	}
    	if(ListAccountstoDelAsso.size()>0){
    		for(Account deletacctassoid :ListAccountstoDelAsso){
    			ListIdstoDelAsso.add(deletacctassoid.Id);
    		}    		
           scheduleAssociation.deleteAssociation(ListIdstoDelAsso);
        }
         
    }
}