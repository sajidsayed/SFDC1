/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  Unknown                     
 |  23-Jul-2011     Anand Sharma                Removed query on account and created account
 |  14/12/2011      Anil                        Used Custom setting Data Halper
 +===========================================================================*/
@isTest
Private class PRM_IncludeAccountGrouping_TC {
    
    /*Private static testMethod void IncludeAccountGrouping(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        PRM_IncludeAccountGrouping includeObj = new PRM_IncludeAccountGrouping();
        List<Account> accounts = new List<Account>();
        
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account ( name ='Test-AccountGrp1',Site_Duns_Entity__c='00102134', 
                            Grouping__c=null,selected__c=false,PROFILED_ACCOUNT_FLAG__c=false );
        accountList.add(acc1);
        Account acc2 = new Account ( name ='Test-AccountGrp2',Site_Duns_Entity__c='0011354', 
                            Grouping__c=null,selected__c=false,PROFILED_ACCOUNT_FLAG__c=false );
        accountList.add(acc2);
        insert accountList;
          
        //}
        for(Account acc:accountList){
            acc.Selected__c=true;
            accounts.add(acc);
        }
        update accounts;
        
        System.debug('Selected Accounts----->'+accounts);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(accounts);       
        includeObj.stdController = controller;

            
        //Account accout = [Select Id from Account  where (Site_Duns_Entity__c='001021455') and (Grouping__c=null) and selected__c=false limit 1];
        
        Account accout1 = new Account ( name ='Test-AccountGrouping',Site_Duns_Entity__c='001021455678',Grouping__C = Null, selected__c=false );        
        insert accout1 ;
        
        for(Account acc :[select Id,IsPartner,Lead_Oppty_Enabled__c 
                            from account 
                            where Id=:accout1.Id]){
            acc.ispartner=true;
            update acc;
       }
        
        Account_Groupings__c grouping = new Account_Groupings__c(
        Name = 'TestClass3',
        Active__c = true,
        Profiled_Account__c = accout1.id,
        No_Master_Required__c = false);
        insert grouping;
             
        Account_Groupings__c grouping01 = [Select id,id__c from Account_Groupings__c where id =:grouping.id ];

        System.debug('grouping---->'+grouping);
        System.debug('grouping01---->'+grouping01);
        system.debug('profiledaccount--->' +grouping.profiled_account__c);
        System.debug('grouping01.id__c---->'+grouping01.id__c);
        System.currentPageReference().getParameters().put('groupingId',grouping01.id__c);
        includeObj.grouping = grouping01;
        includeObj.GroupingID = grouping01.id__c;
        
        PRM_IncludeAccountGrouping.accountWrapper acctWrper = new PRM_IncludeAccountGrouping.accountWrapper(accounts[0],true);
        List<PRM_IncludeAccountGrouping.accountWrapper> acctList = new List<PRM_IncludeAccountGrouping.accountWrapper>();
        acctList.add(acctWrper);
        Test.StartTest();
        includeObj.include();
      
        includeObj.previousPage();
        includeObj.getRenderList();
        includeObj.editView();
        includeObj.createView();
        includeObj.getAccount();
        includeObj.nextPage();
        includeObj.goToPage();
        includeObj.getSortedAccounts();
        includeObj.getCountOfInclude();
        includeObj.getTotalCount();
        includeObj.getGrouping();
        includeObj.getResult();
        includeObj.back();
        includeObj.cancel();
        includeObj.getResultNotProcessed();
        includeObj.getAccountsNotProcessed();
        includeObj.selectAll();
        
        String Errormsg = 'Error';
        includeObj.setResult(Errormsg);
        boolean checked = true;
        
        includeObj.setAccountsNotProcessed(accounts);
        includeObj.deSelectAll();
        includeObj.getSelectRender();
        includeObj.getResult();
        includeObj.setResult(Errormsg);
        includeObj.getAccountWrapList();  
      
        acctWrper.getResult();
        acctWrper.setResult('Success');      
        acctWrper.setChecked(true);
        acctWrper.getChecked();
        acctWrper.getAcc();
        acctWrper.setAcc(accountList[0]);
         Test.StopTest();
    }*/
    
    public static testMethod void IncludeAccountGrouping02(){
        
        
        
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account ( name ='Test-AccountGrp1',Site_Duns_Entity__c='00102134', 
                            Grouping__c=null,selected__c=false,PROFILED_ACCOUNT_FLAG__c=false );
        accountList.add(acc1);
        Account acc2 = new Account ( name ='Test-AccountGrp2',Site_Duns_Entity__c='0011354', 
                            Grouping__c=null,selected__c=false,PROFILED_ACCOUNT_FLAG__c=false );
        accountList.add(acc2);
        insert accountList;
        
        List<Account> accounts = new List<Account>();
        for(Account acc:accountList){
            acc.Selected__c=true;
            accounts.add(acc);
        }
        update accounts;
                
        Account accout = new Account ( name ='Test-AccountGrouping',Site_Duns_Entity__c='001021455678',Grouping__C = Null, selected__c=false );        
        insert accout ;
        System.Debug('Account----->' +accout.Id);
        
        Account_Groupings__c grouping = new Account_Groupings__c();
        grouping.Name = 'TestClass11';
        grouping.Active__c = true;
        grouping.Profiled_Account__c = accout.id;
        grouping.No_Master_Required__c = false;
        insert grouping;
        
        Account_Groupings__c grouping01 = [Select id, id__c from Account_Groupings__c where id =:grouping.id ];
        
        System.currentPageReference().getParameters().put('groupingId',grouping01.id__c);
        
                
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(accounts);   
        
        PRM_IncludeAccountGrouping includeObj = new PRM_IncludeAccountGrouping();
       // PRM_IncludeAccountGrouping includeObj1 = new PRM_IncludeAccountGrouping(controller);
        
        controller.setSelected(accounts);    
        includeObj.stdController = controller;
        
                        
        includeObj.grouping = grouping01;
        includeObj.GroupingID = grouping01.id__c;
        Test.StartTest();
        includeObj.include(); 
        includeObj.previousPage();
        includeObj.getRenderList();
        includeObj.editView();
        includeObj.createView();
        includeObj.getAccount();
        includeObj.nextPage();
        includeObj.goToPage();
        includeObj.getSortedAccounts();
        includeObj.getCountOfInclude();
        includeObj.getTotalCount();
        includeObj.getGrouping();
        includeObj.getResult();
        includeObj.back();
        includeObj.cancel();
        includeObj.getResultNotProcessed();
        includeObj.getAccountsNotProcessed();
        includeObj.selectAll();
        
        String Errormsg = 'Error';
        includeObj.setResult(Errormsg);
        boolean checked = true;
        
        includeObj.setAccountsNotProcessed(accounts);
        includeObj.deSelectAll();
        includeObj.getSelectRender();
        includeObj.getResult();
        includeObj.setResult(Errormsg);
        includeObj.getAccountWrapList();  
        
        PRM_IncludeAccountGrouping.accountWrapper acctWrper = new PRM_IncludeAccountGrouping.accountWrapper(accounts[0],true);
        List<PRM_IncludeAccountGrouping.accountWrapper> acctList = new List<PRM_IncludeAccountGrouping.accountWrapper>();
        acctList.add(acctWrper);
        
      
        acctWrper.getResult();
        acctWrper.setResult('Success');      
        acctWrper.setChecked(true);
        acctWrper.getChecked();
        acctWrper.getAcc();
        acctWrper.setAcc(accountList[0]);
         
        Test.StopTest();
    }        
}