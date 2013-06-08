/*=====================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
| 05/07/2010     Suman B                                Updated for Test Clsss for 
                                                        PRM_GroupingAssociationScheduler.
                                                          
| 01-12-2011     Anil                                   Fixed MIXED_DML Exception.
| 11-JAN-2012	 Anil									Removed role Id
+=====================================================================================================*/

@isTest
private class PRM_GroupingAssociationOperation_TC{
    static testMethod void myUnitTest(){
    User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
    System.runAs(insertUser)
    {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
    }
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert acc;
        for(Account accounts : acc)
      {
        accounts.IsPartner=true;
        accounts.PROFILED_ACCOUNT_FLAG__c =true;
        accounts.Cluster__c='APJ 2&3';
      }
      update acc;
        Contact cont = UserProfileTestClassDataHelper.createContact();
        cont.Email='test23@emc.com';       
        insert cont;       
        cont.AccountId=acc[0].id;
               
        update cont; 
        
      
        User partner;
        System.runAs(insertUser)
        {       
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();       
        String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
        Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];       
        partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
        insert partner;
        }
       
        List<Account> acclist = [Select id,name,Child_Partner_Users_Count__c,Site_DUNS_Entity__c
                                    FROM Account  where Site_DUNS_Entity__c != Null 
                                    and Child_Partner_Users_Count__c >0 and id=:partner.contact.account.id limit 1] ;
        
        if(acclist!= Null && acclist.size()>1){   
        Map<String,Account> mapAccount = new Map<String,Account>();
        mapAccount.put(acclist[0].Site_DUNS_Entity__c,acclist[0]);
        
        APPR_MTV__RecordAssociation__c association = new APPR_MTV__RecordAssociation__c();
        association.APPR_MTV__Associated_Account__c = acclist[0].Id;
        association.APPR_MTV__Account__c = acclist[0].Id;
        insert association;
        Test.startTest();
        PRM_GroupingAssociationOperation obj1 =  new PRM_GroupingAssociationOperation();
        obj1.fetchingOfBulkAccounts();
        obj1.creatingAssociationOnBulk(mapAccount);
        Test.stopTest();
      } 
    }
}