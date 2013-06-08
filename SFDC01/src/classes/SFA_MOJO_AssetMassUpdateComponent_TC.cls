/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  02.11.2012      Avinash K       MOJO        Initial Creation.Creating this test class to unit test 
                                                SFA_MOJO_AssetMassUpdateComponent class.
+========================================================================================================================*/

@isTest(seeAllData = true) 
 private class SFA_MOJO_AssetMassUpdateComponent_TC 
{
    static testMethod void myUnitTest() 
    {
        List<Account> lstAccount = [Select id, Account_Flag__c 
        From Account
        Where Account_Flag__c = 'Primary'
        Limit 1];

        Account acc;
        Asset__c asset1;

        if (lstAccount != null && lstAccount.size() > 0) 
        {
            acc = lstAccount.get(0);
            asset1 = new Asset__c(name = 'Test 1', Customer_Name__c = acc.id);
        insert asset1;
        }
        
                      

        SFA_MOJO_AssetMassUpdateComponent con = new SFA_MOJO_AssetMassUpdateComponent();

        String str = con.getStep();
        String str1 = con.getsType();
        Integer i = con.getRecordSize();
        Boolean str2 = con.getFlag();
        con.setFlag(true);
        String str3 = con.getNow(true);
        String str4 = con.getNow(false);
                
        List<SObject> lstObject = con.objsToUpdate;
        String str25 = con.getFieldInfoToDisplay();

        Pagereference p1 = con.Cancel();
        Pagereference p2 = con.step1();
        Pagereference p3 = con.step2();
        Pagereference p4 = con.step3();
        Pagereference p5 = con.step4();
     // Pagereference p6 = con.step5();

     // DescribeSObjectResult d = con.discoverSObjectType(asset1);

        //List<SelectOption> lstSelOpt = con.getFieldTypeOptions();
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

        SFA_MOJO_AssetMassUpdateComponent.aAsset aAss = new SFA_MOJO_AssetMassUpdateComponent.aAsset(asset1);

    }
}