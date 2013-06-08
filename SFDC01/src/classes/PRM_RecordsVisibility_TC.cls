/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | Unknown          Unknown                         initial Draft
 
 | 09/09/2010     Anand Sharma                      Test class to do unit testing of PRM_RecordVisibility class.
  
 | 09/03/2011     Anirudh Singh                     Updated Test Data Creation not to set Preferred Flag
                                                    on Association.
 | 19/12/2011		Anil						   Removed Query for fetching Lead and used Custom setting Data Halper    
 +===========================================================================*/

@isTest
Private Class PRM_RecordsVisibility_TC{

     static PRM_RecordsVisibility objCls = new PRM_RecordsVisibility(); 
     static list<id> accid =new list<id>();
     static map<id,list<id>> maplead = new map<id,list<id>>();
      
    Private static testMethod void startTest(){
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        List<Account> objAccount = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();       
	       insert objAccount;
	       for(Account acc1 : objAccount)
	       {
	       	acc1.Type='Partner';
	       	acc1.IsPartner=true;
	       	acc1.Lead_Oppty_Enabled__c=true;
	       	acc1.PROFILED_ACCOUNT_FLAG__c = true;
	       	acc1.Partner_Type__c='Distributor';
	       }
	       update objAccount; 
          
         /*Creating Lead record*/
        Lead l = new Lead(LastName='test', firstname='testfm2', company='test2',DealReg_Deal_Registration__c = true, 
                                  email='test2@test.com', Partner__c = objAccount[0].Id, Status='New', Sales_Force__c='EMC', city='India', Street ='bangalore',
                                  Lead_Originator__c='Field', LeadSource ='Manual', Originator_Details__c ='Core Referral', Channel__c='Direct');
                                  
        insert l;
        
           accid.add(l.partner__c);
           
           maplead.put(l.id,accid);
           
           objCls.removeLeadAssociation(maplead);
           
           objCls.createLeadAssociation(maplead);
            
           objCls.deleteAccountAssociation(maplead); 
    }
    
    
     Private static testMethod void startRecordAssociationTest(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        } //hold value of account role for Distributor
        String strAccountRoleDistributor = System.Label.Account_Role_Distributor;
        //hold value of account role for T2 VAR
        String strAccountRoleT2VAR = System.Label.Account_Role_T2_VAR;
        //hold list of Record Association to create 
        List<APPR_MTV__RecordAssociation__c> associationAccountList = new List<APPR_MTV__RecordAssociation__c>();
        
        List<RecordType> lstRecordType = [Select r.Id, r.Name, r.SobjectType from RecordType r where SobjectType='Account' and Name ='Partner Account Record Type'];
        //Create Account data
        List<Account> accountList = new List<Account>();
        Account objAcc1 = New Account(RecordTypeId =lstRecordType.get(0).Id, name= 'TestAccount1', APPR_MTV__Association_Account__c= true, Lead_Oppty_Enabled__c=true);
        accountList.add(objAcc1);
        Account objAcc2 = New Account(RecordTypeId =lstRecordType.get(0).Id, name= 'TestAccount2', APPR_MTV__Association_Account__c= true, Lead_Oppty_Enabled__c=true);
        accountList.add(objAcc2);
        insert accountList;
        
        //create RecordAssociation data
        APPR_MTV__RecordAssociation__c objRecordAssociation1 =    
                new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=accountList.get(0).Id,              
                APPR_MTV__Associated_Account__c=accountList.get(1).Id , APPR_MTV__Account_Role__c = strAccountRoleDistributor);
        associationAccountList.add(objRecordAssociation1);
        
        APPR_MTV__RecordAssociation__c objRecordAssociation2 =    
                new APPR_MTV__RecordAssociation__c(APPR_MTV__Account__c=accountList.get(0).Id,              
                APPR_MTV__Associated_Account__c=accountList.get(1).Id , APPR_MTV__Account_Role__c = strAccountRoleT2VAR );
        associationAccountList.add(objRecordAssociation2);
        // insert RecordAssociation record
        insert associationAccountList; 
        // call method to create record   
        objCls.createAssociationDistributorT2VAR(associationAccountList);
        // call method to delete record   
        objCls.deleteAssociationDistributorT2VAR(associationAccountList);

    }
 }