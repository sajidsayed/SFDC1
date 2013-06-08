/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  22.09.2012      Avinash K       MOJO        Initial Creation.Creating this test class to unit test 
                                                SFA_MOJO_MassUpdateAssetController class.
    
+========================================================================================================================*/


@isTest (SeeAllData = true)
private class SFA_MOJO_MassUpdateAssetController_TC 
{

     static testMethod void MassUpdateControllerTest() 
    {
        try
        {
            List<Account> lstAccount = [Select id, Account_Flag__c 
            From Account
            Where Account_Flag__c = 'Primary'
            Limit 1];

            Account acc;

            if (lstAccount != null && lstAccount.size() > 0) 
            {
                acc = lstAccount.get(0);
            }

            
            List<Asset__c> lstAsset = new List<Asset__c>();

            Asset__c asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
            lstAsset.add(asset1);

            Asset__c asset2 = new Asset__c(name = 'Test 2', Customer_Name__c = acc.id, Disposition_Status__c = 'Installed');
            lstAsset.add(asset2);

            insert lstAsset;

            
            
            ApexPages.currentpage().getParameters().put('Id',acc.Id);
            ApexPages.StandardController stdcon = new ApexPages.StandardController(acc);
            SFA_MOJO_MassUpdateAssetController con = new SFA_MOJO_MassUpdateAssetController(stdcon);
            
            
            ApexPages.StandardSetController stdsetcon = new ApexPages.StandardSetController(lstAsset);
            SFA_MOJO_MassUpdateAssetController setcon = new SFA_MOJO_MassUpdateAssetController(stdsetcon);

            List<SFA_MOJO_MassUpdateAssetController.aAsset> lstAssets1 = con.getAssetsDetails();
            List<Asset__c> lstAssets2 = con.getselectedAssets();
            Pagereference p = con.processSelected();
            String str = con.getStep();
            String str1 = con.getsType();
            Integer i = con.getRecordSize();
            Boolean str2 = con.getFlag();
            con.setFlag(true);
            String str3 = con.getNow(true);

            SFA_MOJO_MassUpdateAssetController.aAsset aAss = new SFA_MOJO_MassUpdateAssetController.aAsset(asset1);

            //con.setFieldName('Name');
            String str4 = con.getFieldInfoToDisplay();

            Pagereference p1 = con.Cancel();
            Pagereference p2 = con.step1();
            Pagereference p3 = con.step2();
            Pagereference p4 = con.step3();
            Pagereference p5 = con.step4();
            Pagereference p6 = setcon.step5();

            DescribeSObjectResult d = con.discoverSObjectType(asset1);

            List<SelectOption> lstSelOpt = con.getFieldTypeOptions();
            List<SelectOption> lstSelOpt2 = con.getPicklistValues();

            String str5 = con.title();
            String str6 = con.gettitle();

            con.settitle('Name');
            Pagereference p7 = con.showOk();
            Boolean bln = con.getpreviousFlag();
            Boolean bln2 = con.getFlag1();
            Boolean bln3 = con.getcancelFlag();
            Boolean bln4 = con.getokFlag();
            con.setFlag1(false);
        }
        catch(Exception e)
        {
            
        }

    }
}