/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  06.04.2012      Anil Sure                   This will used for unit testing of PRM_CalculateChampionsBatch Class.
 ========================================================================================================================*/
@isTest
private class PRM_CalculateChampionsBatch_TC {
    //Method for Creation of Profiled Account
    public static Account createProfiledAccount(){
        /*Account_Groupings__c gr=new Account_Groupings__c();
        gr.Profiled_Account__c=acctLst[0].id;
        gr.name='testing Grouping';
        gr.Account__c='test';
        insert gr;*/
        Account acctObj = new Account();
         acctObj.Name = 'testingtesting Partner Account';
        acctObj.Partner_Type__c='Direct Reseller';
        acctObj.rating_eligible__c = true;
        acctObj.BillingCountry='Colombia';
        //acctObj.theater1__c='Americas';
        acctObj.Lead_Oppty_Enabled__c=true;
        acctObj.type='Partner';
        acctObj.Site_DUNS_Entity__c='test999999999';
         insert acctObj;
         //objAccount.grouping__c=gr.id;
         acctObj.PROFILED_ACCOUNT_FLAG__c = true;
         acctObj.Ispartner=true;
         update acctObj;
         
         return acctObj;
        
    }
    public static List<Contact> CreateContact(Account accountObj){
        List<Contact> lstContactToInsert=new List<Contact>();
        List<Contact> lstContactToUpdate=new List<Contact>();
        Contact contact1 = UserProfileTestClassDataHelper.createContact();
        lstContactToInsert.add(contact1);
        //insert contact1;
        
        Contact cont = new Contact();
        cont.LastName = 'testContact1';
        cont.Active__c = true ;
        cont.Email = 'hanumann7863@emc.com' ;
        lstContactToInsert.add(cont);
        //insert cont;
        insert lstContactToInsert;
        for(Integer iCount=0;iCount<lstContactToInsert.size();iCount++)
        {
            lstContactToInsert[iCount].AccountId=createProfiledAccount().Id;
            lstContactToInsert[iCount].Partner_Contact2__c=true;
            if(Math.mod(iCount,lstContactToInsert.size())==0)
            {
                lstContactToInsert[iCount].Advanced_Consolidate_Champion__c=true;
                lstContactToInsert[iCount].Consolidate_Champion__c=true;
                lstContactToInsert[iCount].Backup_Champion__c=true;
                lstContactToInsert[iCount].Governance_Archive_Champion__c=true;
            }
            else
            {
                lstContactToInsert[iCount].Advanced_Consolidate_Champion__c=false;
                lstContactToInsert[iCount].Consolidate_Champion__c=false;
                lstContactToInsert[iCount].Backup_Champion__c=false;
                lstContactToInsert[iCount].Governance_Archive_Champion__c=false;
            }
            lstContactToUpdate.add(lstContactToInsert[iCount]);
            
        }
        update lstContactToUpdate;
        return lstContactToUpdate;
    }
    
    public static testMethod void testRevenueGAFVRCalculation() {
        PRM_CalculateChampionsBatch_TC testObj=new PRM_CalculateChampionsBatch_TC();
        User userObj = [SELECT  u.Id, u.Contact.Account.Owner.Email, u.Contact.Account.Name 
                        FROM    User u 
                        WHERE   u.profile.name='System Administrator - API Only' and u.isActive=true limit 1];
        Account accProfiledAccount=createProfiledAccount();
        List<Contact> lstContact=new List<Contact>();
        System.runAs(userObj)
        {
            lstContact=CreateContact(accProfiledAccount);
        }
        PRM_CalculateChampionsBatch championBatch=new PRM_CalculateChampionsBatch();
        championBatch.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c,'
                                    +' Advanced_Consolidate_Champion_Resources__c,Consolidate_Champion_Resources__c,'
                                    +' Backup_Champion_Resources__c,Governance_Archive_Champion_Resources__c  ' 
                                    +' from account where name=\'testingtesting Partner Account\'';
        Test.startTest();
             ID batchprocessid = Database.executeBatch(championBatch);
             
        Test.stopTest();
    }
    
    
    public static testMethod void testSchedularRevenueGAFVRCalculation() {
        PRM_CalculateChampionsBatch_TC testObj=new PRM_CalculateChampionsBatch_TC();
        User userObj = [SELECT  u.Id, u.Contact.Account.Owner.Email, u.Contact.Account.Name 
                        FROM    User u 
                        WHERE   u.profile.name='System Administrator - API Only' and u.isActive=true limit 1];
        Account accProfiledAccount=createProfiledAccount();
        List<Contact> lstContact=new List<Contact>();
        System.runAs(userObj)
        {
            lstContact=CreateContact(accProfiledAccount);
        }
        PRM_CalculateChampionsBatch championBatch=new PRM_CalculateChampionsBatch();
        championBatch.batchQuery = 'select Id,PROFILED_ACCOUNT_FLAG__c,'
                                    +' Advanced_Consolidate_Champion_Resources__c,Consolidate_Champion_Resources__c,'
                                    +' Backup_Champion_Resources__c,Governance_Archive_Champion_Resources__c  ' 
                                    +' from account where name=\'testingtesting Partner Account\'';
       
        
        Test.StartTest();      
	    // run batch 
	    String strScheduleTime ='0 0 0 3 9 ? ';
	    strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
	    String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_CalculateChampion_Scheduler());
	      
	    Test.StopTest();
    }

}