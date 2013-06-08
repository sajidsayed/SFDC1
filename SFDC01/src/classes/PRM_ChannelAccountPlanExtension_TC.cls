/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  23.11.2010      Anand Sharma    #1187       This will used for unit testing of PRM_ChannelAccountPlanExtension Class.
 |  02.02.2011      Himanshu Kar    #1187       Handle the exception for Field Validation of EMC_Sales_Mgt_Approver__c.
 |  01.03.2011      Anil Sure       #2430       Udpated the code for EMC channel User profile name used
 |  23-Jul-2011     Anand Sharma                Updated email field value of user record creation
 |  27-Sep-2011		Anand Sharma	#3544		Update Test class for Amricas new PDF Views changes
 |  11-JAN-2012	 	 Anil						Fixed Test class for Jan'12 Release			
 +=========================================================================================================================*/

@isTest
private class PRM_ChannelAccountPlanExtension_TC {

    static testMethod void myUnitTest() {
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
        
       User PartnerUser;
       List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();       
       insert acc;
       Contact cont = UserProfileTestClassDataHelper.createContact();
       cont.AccountId=acc[0].Id;
       insert cont;
       System.runAs(insertUser)
        {       
       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
       PartnerUser = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
       insert PartnerUser;
        } 
        
        User EMCUser1;
        
        Account account = new Account();
        account.name = 'Testing AccountforCAP';
        insert account;
        account.IsPartner = true;
        update account;
        Contact contact1 = createContact(account.id,'testCAP');
        List<Account> partnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert partnerAccount;
        for(Account accounts : partnerAccount)
        {
        	accounts.IsPartner=true;
        	accounts.PROFILED_ACCOUNT_FLAG__c = true;
        }
        update partnerAccount;

       /* Account partnerAccount = [Select id,a.IsPartner from Account a  where IsPartner=true 
                                    and PROFILED_ACCOUNT_FLAG__c = true limit 1];*/
                                    
        User insertUser1 = [Select id from User where isActive=true and 
                            profile.Name='System Administrator' limit 1];       
                            
        System.runAs(insertUser1){
            EMCUser1 = createUser('AMER Channels User');//Changed from EMC Channel User by Anil    
        }
        
        SFDC_Channel_Account_Plan__c channelPlan1 = createChannelPlan(EMCUser1.id,'ChannelPlan1',
                                        PartnerUser.id,partnerAccount[0].id,AmericasDistributorCAP);
		
		Strategy__c objStrategy =  createStrategy(channelPlan1);
		                                        
		SFDC_Objective__c objObjective = createObjective(channelPlan1, objStrategy);                                        

        ApexPages.StandardController stdCon = new ApexPages.StandardController(channelPlan1);
        // test constructors
        PRM_ChannelAccountPlanExtension dealExtn = new PRM_ChannelAccountPlanExtension(stdCon);
        dealExtn.getResults();
        
        PRM_ChannelAccountPlanExtension.wrapObjectivesDataContainer  objwrapODC = new PRM_ChannelAccountPlanExtension.wrapObjectivesDataContainer(1, objObjective);
        List<PRM_ChannelAccountPlanExtension.wrapObjectivesDataContainer> lstwrapODC = new List<PRM_ChannelAccountPlanExtension.wrapObjectivesDataContainer>();
        lstwrapODC.add(objwrapODC);
        
        PRM_ChannelAccountPlanExtension.wrapStrategyDataContainer objwrapSDC = new PRM_ChannelAccountPlanExtension.wrapStrategyDataContainer(1, objStrategy, lstwrapODC);
    }
    
    /* @Method <This method is used create user for the test class>.   
    @param <Taking Id and String as paramters which contains newly created             
    contactId and profileName>   
    @return <void> - <User record>   
    @throws exception - <No Exception>
*/
    private static User createUser(String Profilename){
        Profile emcUser = [select Id from Profile where Name=:Profilename];
        System.debug('Profile---->'+emcUser);  
        UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='EMC Reference Manager'];        
        User tempUsr = new User(
             Username='testing123'+Math.random()+'@acme4.com.test34',
             TimeZoneSidKey='America/New_York',
             ProfileId=emcUser.Id,
             FirstName='TestingCAP',
             LastName='LastCAP',
             email='john12456@emc.com',
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
        insert tempUsr;       
        System.debug('insert tempUsr--->'+tempUsr);
        return tempUsr;
    }
    
/* @Method <This method is used create contact for the test class>.   
    @param <Taking Id as paramter which contains accountId and Contact Name>   
    @return <Contact> - <Contact record>   
    @throws exception - <No Exception>
*/    
    public static Contact createContact(Id accountId,String Name){ 
    //Creating the dummy contact on the previously created account for test class.        
        Contact contact = new Contact(            
        FirstName=Name,            
        LastName='User11213',            
        AccountId=accountId        
        );        
        insert contact;        
        return contact;    
    }
    
    /* @Method <This method is used create CAP for the test class>.   
    @param <Taking Name and RecordType Id has  parameters>   
    @return <CAP> - <CAP record>   
    @throws exception - <No Exception>
*/    
    public static SFDC_Channel_Account_Plan__c createChannelPlan(Id emcApprover,String CAPName,
                                    Id PartnerApprover,Id PartnerAccount,String RecordTypeId){  
        SFDC_Channel_Account_Plan__c channelPlan = new SFDC_Channel_Account_Plan__c( 
        Active__c = true,
        EMC_Sales_Mgt_Approver__c = emcApprover,
        Partner_Approver__c = PartnerApprover,
        Name = CAPName,
        Partner_Account__c = PartnerAccount,
        Plan_Period__c = 'Q1',
        Status__c = 'New', 
        RecordTypeId = RecordTypeId,
        EMC_CAM__c = emcApprover); 
        insert channelPlan;        
        return channelPlan;    
    }    
    
    public static SFDC_Objective__c createObjective(SFDC_Channel_Account_Plan__c objChannelPlan , Strategy__c objStrategy){
    	SFDC_Objective__c objObjective = new SFDC_Objective__c();
    	objObjective.Channel_Account_Plan__c = objChannelPlan.Id;
    	objObjective.Strategy__c = objStrategy.Id;
    	objObjective.Name ='testObjective';
    	insert objObjective;
    	return objObjective;
    }
    
    public static Strategy__c createStrategy(SFDC_Channel_Account_Plan__c objChannelPlan){
    	Strategy__c objStrategy = new Strategy__c();
    	objStrategy.Channel_Plan__c = objChannelPlan.Id;
    	objStrategy.Name ='testStrategy';
    	insert objStrategy;
    	return objStrategy;
    }  
}