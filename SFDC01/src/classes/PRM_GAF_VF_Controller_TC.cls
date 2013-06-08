/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 

 |  06.04.2012      Anirudh Singh   188157      This will used for unit testing of 
 |                                              PRM_GAF_VF_Controller Class.
 | 28.02.2013       Krishna Pydavula 209736     Custom settings covered.
 +=========================================================================================================================*/
@isTest
public class PRM_GAF_VF_Controller_TC {
     //Method for Creation of Account Grouping  
    public static Account_Groupings__c createAccountGrouping(Account ProfiledAccount){
        Account_Groupings__c accountGrouping = new Account_Groupings__c();
        accountGrouping.Name = 'Test Account Grouping';
        accountGrouping.Profiled_Account__c = ProfiledAccount.Id;
        accountGrouping.Active__c = true;
        accountGrouping.No_Master_Required__c = true;
        insert accountGrouping;        
        return accountGrouping;
    }

    //Method for Creation of Profiled Account   
    public static Account createProfiledAccount(){
        list<Account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        lstPartnerAccount[0].name = 'ACCOUNT FOR GAF TEST';
        insert lstPartnerAccount;
        lstPartnerAccount[0].PROFILED_ACCOUNT_FLAG__c = true;
        lstPartnerAccount[0].Ispartner=true;
        update lstPartnerAccount;
        return lstPartnerAccount[0];
    }
    
    //Method for creation of GAF Record
    public static List<GAF__c> createGAF(Account ProfiledAccount){
    	RecordType rectype=[SELECT IsActive, BusinessProcessId, CreatedById, CreatedDate, Description, LastModifiedById, LastModifiedDate, Name, NamespacePrefix, Id, DeveloperName, SobjectType, SystemModstamp FROM RecordType where IsActive=true and Name like'%AMER Direct%' and SobjectType='GAF__c' limit 1];
        List<GAF__c> lstGAF = new List<GAF__c>();
        GAF__c GAF = new GAF__C();
        for(integer i=0;i<2;i++){
            GAF = new GAF__C();
            GAF.Partner_Name__c = ProfiledAccount.Id;
            GAF.RecordTypeId = rectype.Id;
            if(i==0)
                GAF.Year__c=String.valueOf(System.Now().yearGmt());
            else
                GAF.Year__c=String.valueOf(System.Now().yearGmt()+1);
            GAF.GAF_Status__c='Draft';
            lstGAF.add(GAF);
        }
        insert lstGAF;
        return lstGAF;
    }
    
    
    static testMethod void GAFUnitTest() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1]; 
    	 System.runAs(insertUser)
   		 {
  		 	 PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
   		 }
        Account profiledAccount = createProfiledAccount();
        Account_Groupings__c accountGrouping = createAccountGrouping(profiledAccount);
        List<GAF__c> lstGAFafterinsert = createGAF(profiledAccount);
        Test.StartTest();       
        ApexPages.StandardController controller01 = new ApexPages.StandardController(lstGAFafterinsert[0]); 
        ApexPages.currentPage().getParameters().put('id',lstGAFafterinsert[0].Id);
        PRM_GAF_VF_Controller  objGAFController = new PRM_GAF_VF_Controller(controller01);    
        Test.StopTest();
    }

}