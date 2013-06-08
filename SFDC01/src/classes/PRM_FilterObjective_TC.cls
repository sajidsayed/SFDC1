/*===========================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 12/01/2011     Karthik Shivprakash      1173     This is the test class used
                                                   to test filter objectives on
|                                                  the channel account plan.
| 28/02/2011     Saravanan C              2430     udpated the code for EMC channel User profile name used
| 14/12/2011     Anil Sure                         Removed All  Queries.
+===========================================================================*/

@istest
private class PRM_FilterObjective_TC {
    
    static testmethod void testFilterObjective(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Account account1 = createAccount('TestAccount');
        
        Account_Groupings__c TestGroup1 = createGrouping(account1.Id);
        
        User user1 = createUser('AMER Channels User');
        
        Test.startTest();
        
        RecordType recordType1 = createRecordType('Americas Distributor CAP');
        
        RecordType recordType2 = createRecordType('EMEA Reseller CAP');
        
        RecordType recordType3 = createRecordType('APJ Distributor CAP Locked');
        
        SFDC_Channel_Account_Plan__c channelAccount1 = createChannelAccountPlan(recordType1.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount2 = createChannelAccountPlan(recordType2.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount3 = createChannelAccountPlan(recordType3.Id,account1.Id,user1.Id);
        
        ApexPages.StandardController channelPlan1 = new ApexPages.Standardcontroller(channelAccount1);
        ApexPages.StandardController channelPlan2 = new ApexPages.Standardcontroller(channelAccount2);
        ApexPages.StandardController channelPlan3 = new ApexPages.Standardcontroller(channelAccount3);
        PRM_FilterObjective Obj1 = new PRM_FilterObjective(channelPlan1);
        Obj1.getParentObjectiveTypeList();
        Obj1.getObjectiveTypeList();
        Obj1.getSolutionFocusList();
        Obj1.getIndustryFocusList();
        Obj1.getSolutionList();
        Obj1.getVerticalList();
        Obj1.getSegmentList();
        Obj1.goOnDetailPage();
        Obj1.OpenObjective();
        Obj1.EditRecord();
        // mycode
        Obj1.getGeographyList();
        Obj1.goonpdfpage();
        //Obj1.DeleteRecord();
        //Obj1.setObjectiveList();
        Obj1.getObjectiveList();
        
        // Mycode
        
        
        PRM_FilterObjective Obj2 = new PRM_FilterObjective(channelPlan2);
        
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.ObjectiveType='--None--';
        Obj2.Segment ='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = 'abc';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = 'abc';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';      
        Obj2.Vertical = 'abc';      
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--abc--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--ace--'; 
        Obj2.Segment = '--abe--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--dse--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--dsdas--';        
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--Ndsdone--';
        Obj2.Vertical = '--dasdsa--';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--fdfds--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--fdfds--';   
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--fdsfds--';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--fsdfdsf--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--Ndsadsadone--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--dsads--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--sdsad--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--fdssds--';
        Obj2.Vertical = '--dsadsa--';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--dsfdsf--';
        Obj2.Solutions = '--dsdfdsfd--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--Nonfvdsfdse--';      
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--fdsfd--';
        Obj2.Vertical = '--sdfdsfds--';     
        Obj2.goOnDetailPage();      
       
        Test.stopTest();
    }
    
    static testmethod void testFilterObjective1(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Account account1 = createAccount('TestAccount');
        
        Account_Groupings__c TestGroup1 = createGrouping(account1.Id);
        
        User user1 = createUser('AMER Channels User');
        
        Test.startTest();
        
        RecordType recordType1 = createRecordType('Americas Distributor CAP');
        
        RecordType recordType2 = createRecordType('EMEA Reseller CAP');
        
        RecordType recordType3 = createRecordType('APJ Distributor CAP Locked');
        
        SFDC_Channel_Account_Plan__c channelAccount1 = createChannelAccountPlan(recordType1.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount2 = createChannelAccountPlan(recordType2.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount3 = createChannelAccountPlan(recordType3.Id,account1.Id,user1.Id);
        
        ApexPages.StandardController channelPlan1 = new ApexPages.Standardcontroller(channelAccount1);
        ApexPages.StandardController channelPlan2 = new ApexPages.Standardcontroller(channelAccount2);
        ApexPages.StandardController channelPlan3 = new ApexPages.Standardcontroller(channelAccount3);
        PRM_FilterObjective Obj1 = new PRM_FilterObjective(channelPlan1);
        Obj1.getParentObjectiveTypeList();
        Obj1.getObjectiveTypeList();
        Obj1.getSolutionFocusList();
        Obj1.getIndustryFocusList();
        Obj1.getSolutionList();
        Obj1.getVerticalList();
        Obj1.getSegmentList();
        Obj1.goOnDetailPage();
        Obj1.OpenObjective();
        Obj1.EditRecord();
         // mycode
        Obj1.getGeographyList();
        Obj1.goonpdfpage();
        //Obj1.DeleteRecord();
        //Obj1.setObjectiveList();
        Obj1.getObjectiveList();
        
        // Mycode
        
        PRM_FilterObjective Obj2 = new PRM_FilterObjective(channelPlan2);
        
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.ObjectiveType='--None--';
        Obj2.Segment ='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = 'abc';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = 'abc';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';      
        Obj2.Vertical = 'abc';      
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--abc--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--ace--'; 
        Obj2.Segment = '--abe--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--dse--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--dsdas--';        
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--Ndsdone--';
        Obj2.Vertical = '--dasdsa--';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--fdfds--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--fdfds--';   
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--fdsfds--';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--esdfdsfds--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--fdsfsd--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ParentObjectiveType = 'abc';
        Obj2.ObjectiveType = 'abc';
        Obj2.SolutionFocus = 'abc';
        Obj2.Solutions = 'abc';
        Obj2.IndustryFocus = 'abc';
        Obj2.Segment = 'abc';
        Obj2.Vertical = 'abc';
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.getParentObjectiveTypeList();
        Obj2.getObjectiveTypeList();
        Obj2.getSolutionFocusList();
        Obj2.getIndustryFocusList();
        Obj2.getSolutionList();
        Obj2.getVerticalList();
        Obj2.getSegmentList();
        Obj2.goOnDetailPage();
        Obj2.OpenObjective();
        Obj2.EditRecord();      
        
        PRM_FilterObjective Obj3 = new PRM_FilterObjective(channelPlan3);
        
        Obj3.EMEAFilters = false;
        Obj3.APJFilters = false;
        Obj3.AmerciaFilters = false;
        Obj3.getParentObjectiveTypeList();
        Obj3.getObjectiveTypeList();
        Obj3.getSolutionFocusList();
        Obj3.getIndustryFocusList();
        Obj3.getSolutionList();
        Obj3.getVerticalList();
        Obj3.getSegmentList();
        Obj3.goOnDetailPage();
        Obj3.OpenObjective();
        Obj3.EditRecord();
         // mycode
        Obj3.getGeographyList();
        Obj3.goonpdfpage();
        // Obj3.DeleteRecord();
        //Obj3.setObjectiveList();
        Obj3.getObjectiveList();
        
        // Mycode
       Test.stopTest();
    }
    
    static testmethod void testFilterObjective2(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Account account1 = createAccount('TestAccount');
        
        Account_Groupings__c TestGroup1 = createGrouping(account1.Id);
        
        User user1 = createUser('AMER Channels User');
        
        Test.startTest();
        
        RecordType recordType1 = createRecordType('Americas Distributor CAP');
        
        RecordType recordType2 = createRecordType('EMEA Reseller CAP');
        
        RecordType recordType3 = createRecordType('APJ Distributor CAP Locked');
        
        SFDC_Channel_Account_Plan__c channelAccount1 = createChannelAccountPlan(recordType1.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount2 = createChannelAccountPlan(recordType2.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount3 = createChannelAccountPlan(recordType3.Id,account1.Id,user1.Id);
        
        ApexPages.StandardController channelPlan1 = new ApexPages.Standardcontroller(channelAccount1);
        ApexPages.StandardController channelPlan2 = new ApexPages.Standardcontroller(channelAccount2);
        ApexPages.StandardController channelPlan3 = new ApexPages.Standardcontroller(channelAccount3);
        PRM_FilterObjective Obj1 = new PRM_FilterObjective(channelPlan1);
        Obj1.getParentObjectiveTypeList();
        Obj1.getObjectiveTypeList();
        Obj1.getSolutionFocusList();
        Obj1.getIndustryFocusList();
        Obj1.getSolutionList();
        Obj1.getVerticalList();
        Obj1.getSegmentList();
        Obj1.goOnDetailPage();
        Obj1.OpenObjective();
        Obj1.EditRecord();
         // mycode
        Obj1.getGeographyList();
        Obj1.goonpdfpage();
        //Obj1.DeleteRecord();
        //Obj1.setObjectiveList();
        Obj1.getObjectiveList();
        
        // Mycode
        
        PRM_FilterObjective Obj2 = new PRM_FilterObjective(channelPlan2);
        
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.ObjectiveType='--None--';
        Obj2.Segment ='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = 'abc';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = 'abc';       
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';      
        Obj2.Vertical = 'abc';      
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--abc--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--Ndsadsadone--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--dsads--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        Obj2.ObjectiveType='--sdsad--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--fdssds--';
        Obj2.Vertical = '--dsadsa--';       
        Obj2.goOnDetailPage();      
       
        Obj2.ObjectiveType='--dsfdsf--';
        Obj2.Solutions = '--dsdfdsfd--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--Nonfvdsfdse--';      
        Obj2.goOnDetailPage();      
        //Obj2.goOnVisualForcePage();
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--fdsfd--';
        Obj2.Vertical = '--sdfdsfds--';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--esdfdsfds--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--fdsfsd--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        
        Obj2.ParentObjectiveType = 'abc';
        Obj2.ObjectiveType = 'abc';
        Obj2.SolutionFocus = 'abc';
        Obj2.Solutions = 'abc';
        Obj2.IndustryFocus = 'abc';
        Obj2.Segment = 'abc';
        Obj2.Vertical = 'abc';
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.getParentObjectiveTypeList();
        Obj2.getObjectiveTypeList();
        Obj2.getSolutionFocusList();
        Obj2.getIndustryFocusList();
        Obj2.getSolutionList();
        Obj2.getVerticalList();
        Obj2.getSegmentList();
        Obj2.goOnDetailPage();
        Obj2.OpenObjective();
        Obj2.EditRecord();      
        
        
        
        
        PRM_FilterObjective Obj3 = new PRM_FilterObjective(channelPlan3);
        
        Obj3.EMEAFilters = false;
        Obj3.APJFilters = false;
        Obj3.AmerciaFilters = false;
        Obj3.getParentObjectiveTypeList();
        Obj3.getObjectiveTypeList();
        Obj3.getSolutionFocusList();
        Obj3.getIndustryFocusList();
        Obj3.getSolutionList();
        Obj3.getVerticalList();
        Obj3.getSegmentList();
        Obj3.goOnDetailPage();
       
        Obj3.OpenObjective();
        Obj3.EditRecord();
        
        Test.stopTest();
    }
    
    static testmethod void testFilterObjective3(){
        
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Account account1 = createAccount('TestAccount');
        
        Account_Groupings__c TestGroup1 = createGrouping(account1.Id);
        
        User user1 = createUser('AMER Channels User');
        
        Test.startTest();
        
        RecordType recordType1 = createRecordType('Americas Distributor CAP');
        
        RecordType recordType2 = createRecordType('EMEA Reseller CAP');
        
        RecordType recordType3 = createRecordType('APJ Distributor CAP Locked');
        
        SFDC_Channel_Account_Plan__c channelAccount1 = createChannelAccountPlan(recordType1.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount2 = createChannelAccountPlan(recordType2.Id,account1.Id,user1.Id);
        
        SFDC_Channel_Account_Plan__c channelAccount3 = createChannelAccountPlan(recordType3.Id,account1.Id,user1.Id);
        
        ApexPages.StandardController channelPlan1 = new ApexPages.Standardcontroller(channelAccount1);
        ApexPages.StandardController channelPlan2 = new ApexPages.Standardcontroller(channelAccount2);
        ApexPages.StandardController channelPlan3 = new ApexPages.Standardcontroller(channelAccount3);
        PRM_FilterObjective Obj1 = new PRM_FilterObjective(channelPlan1);
        Obj1.getParentObjectiveTypeList();
        Obj1.getObjectiveTypeList();
        Obj1.getSolutionFocusList();
        Obj1.getIndustryFocusList();
        Obj1.getSolutionList();
        Obj1.getVerticalList();
        Obj1.getSegmentList();
        Obj1.goOnDetailPage();
        
        Obj1.OpenObjective();
        Obj1.EditRecord();
       
        PRM_FilterObjective Obj2 = new PRM_FilterObjective(channelPlan2);
        
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.ObjectiveType='--None--';
        Obj2.Segment ='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = 'abc';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Vertical ='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = 'abc';       
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';      
        Obj2.Vertical = 'abc';      
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--abc--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--ace--'; 
        Obj2.Segment = '--abe--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--dse--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--dsdas--';        
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--Ndsdone--';
        Obj2.Vertical = '--dasdsa--';       
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--fdfds--';
        Obj2.Solutions = '--fdsfds--';  
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--fdfds--';   
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--fdsfds--';       
        Obj2.goOnDetailPage();      
        
        
        Obj2.ObjectiveType='--None--';
        Obj2.Solutions = '--None--';    
        Obj2.Segment = '--None--';
        Obj2.Vertical = '--None--';     
        Obj2.goOnDetailPage();      
        
        
        
        Obj2.ParentObjectiveType = 'abc';
        Obj2.ObjectiveType = 'abc';
        Obj2.SolutionFocus = 'abc';
        Obj2.Solutions = 'abc';
        Obj2.IndustryFocus = 'abc';
        Obj2.Segment = 'abc';
        Obj2.Vertical = 'abc';
        Obj2.EMEAFilters = true;
        Obj2.APJFilters = true;
        Obj2.AmerciaFilters = true;
        
        Obj2.getParentObjectiveTypeList();
        Obj2.getObjectiveTypeList();
        Obj2.getSolutionFocusList();
        Obj2.getIndustryFocusList();
        Obj2.getSolutionList();
        Obj2.getVerticalList();
        Obj2.getSegmentList();
        Obj2.goOnDetailPage();
        Obj2.OpenObjective();
        Obj2.EditRecord();      
        
        
        PRM_FilterObjective Obj3 = new PRM_FilterObjective(channelPlan3);
        
        Obj3.EMEAFilters = false;
        Obj3.APJFilters = false;
        Obj3.AmerciaFilters = false;
        Obj3.getParentObjectiveTypeList();
        Obj3.getObjectiveTypeList();
        Obj3.getSolutionFocusList();
        Obj3.getIndustryFocusList();
        Obj3.getSolutionList();
        Obj3.getVerticalList();
        Obj3.getSegmentList();
        Obj3.goOnDetailPage();
       
        Obj3.OpenObjective();
        Obj3.EditRecord();  
        Test.stopTest();
    }

    
    /* @Method <This method is used to create Distribution VAR account 
             for the test class >
       @param <Taking string as paramter which contains account name>
       @return <void> - <Account record>
       @throws exception - <No Exception>
    */

        public static Account createAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            Partner_Type__c='Distribution Var',
            Lead_oppty_enabled__c =True,
            APPR_MTV__Association_Account__c=True,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '223652'
        );
        insert account;
        return account;
        }
        
        
    /* @Method <This method is used create user for the test class>.   
        @param <Taking Id and String as paramters which contains newly created             
        contactId and profileName>   
        @return <void> - <User record>   
        @throws exception - <No Exception>
    */
    private static User createUser(String Profilename){
        Profile emcUser = [select Id from Profile where Name=:Profilename];        
        UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='EMC Reference Manager'];        
        User tempUsr = new User(
             Username='testing123'+Math.random()+'@acme4.com.test34',
             TimeZoneSidKey='America/New_York',
             ProfileId=emcUser.Id,
             FirstName='TestingCAP',
             LastName='LastCAP',
             email='john12456@acme.com',
             Alias='test1',             
             LocaleSidKey='en_US',             
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Role__c='N/A',
             UserRoleId=userRoles.Id,
             Forecast_Group__c='Direct',
             BU__c='NA',
             CAP_Approver__c=true,
             IsActive=true);
        //insert tempUsr;    
        return tempUsr;
    }
    
    /* @Method <This method is used to create grouping Data 
            for the test class >
        @param <Taking Id as paramter which contains account Id>
        @return <void> - <Grouping record>
        @throws exception - <No Exception>
    */
        public static Account_Groupings__c createGrouping(Id accountId){
            Account_Groupings__c grouping = new Account_Groupings__c();
            grouping.Name = 'TestGrouping1';
            grouping.Active__c = true;
            grouping.Profiled_Account__c = accountId;
            grouping.No_Master_Required__c = False;

        insert grouping;
        return grouping;
    }
    
    public static RecordType createRecordType(String RecordName){
        RecordType recordTypes = [Select r.Id, r.Name, r.SobjectType 
                                    from RecordType r 
                                    where r.name=:RecordName];
        return recordTypes;
    }
    
    public static SFDC_Channel_Account_Plan__c createChannelAccountPlan(Id recordType,Id accountID,Id userID){
        SFDC_Channel_Account_Plan__c channelAccount = new SFDC_Channel_Account_Plan__c(
        Name='Testing',
        Partner_Account__c=accountID,
        Status__c='New',
        Plan_Period__c='Q1',
        EMC_CAM__c=userID,
        RecordTypeId=recordType);
    insert channelAccount;
    return channelAccount;
    }
}