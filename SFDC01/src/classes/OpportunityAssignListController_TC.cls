/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  Unknown                     
 |  23-Jul-2011     Anand Sharma                Updated email field value of user record creation
 +===========================================================================*/
@isTest
private class OpportunityAssignListController_TC{
    public static testMethod void opportunityAssignment() 
    { 
        List<User_Assignment__c> userAssgnment=new List<User_Assignment__c>();
        /*List<User_Assignment__c> userAssgnment = [select Opportunity__r.Id, Opportunity__c,Id,
                            Account__r.Id, Account__c ,User__r.Forecast_Group__c, User__c,
                            Opportunity__r.House_Account_Name__c,Assignment_Group__c,Name
                            From User_Assignment__c where Assignment_Group__c='House Account' limit 10];*/
        
        User user01 = [Select u.Forecast_Group__c from User u  where u.Forecast_Group__c='Direct' and isActive=true limit 1];
        Opportunity Oppty01 = [Select o.AccountId, o.CloseDate, o.Id from Opportunity o  where o.CloseDate > :System.today() limit 1];
        User_Assignment__c userAssgnment01 = new User_Assignment__c();
        userAssgnment01.User__c = user01.id; 
        userAssgnment01.Opportunity__c = Oppty01.id;
        userAssgnment01.Account__c = Oppty01.AccountId;
        userAssgnment01.Assignment_Group__c='House Account';
        userAssgnment.add(userAssgnment01);
        
        User_Assignment__c userAssgnment02 = new User_Assignment__c();
        userAssgnment02.User__c = user01.id; 
        userAssgnment02.Opportunity__c = Oppty01.id;
        userAssgnment02.Account__c = Oppty01.AccountId;
        userAssgnment02.Assignment_Group__c='Direct';
        userAssgnment.add(userAssgnment02);
        
        User_Assignment__c userAssgnment03 = new User_Assignment__c();
        userAssgnment03.Account__c = Oppty01.AccountId;
        userAssgnment03.Opportunity__c = Oppty01.id;
        userAssgnment03.Assignment_Group__c = 'Inside Sales';
        userAssgnment.add(userAssgnment03);
        
        insert userAssgnment;
        
        List<AccountTeamMember> acctMember = [Select User.Forecast_Group__c,id, UserId,TeamMemberRole, Account.Name, AccountId,AccountAccessLevel From AccountTeamMember where UserId=:UserInfo.getUserId() and accountid=:userAssgnment[0].Account__r.Id];
                         
        
        String key = 'toInsert';
        //String value = userAssgnment[0].id+','+userAssgnment[1].id+','+userAssgnment[2].id+','+userAssgnment[3].id;
    String value = userAssgnment[0].id+','+userAssgnment[1].id+','+userAssgnment[2].id;                           
        ApexPages.currentpage().getParameters().put(key,value);
        System.debug('ListIds*************'+ApexPages.currentpage().getParameters().get('toInsert'));
        
        ApexPages.StandardController controller = new ApexPages.StandardController(new User_Assignment__c());               
        OpportunityAssignListController opptyAssgnlistController = new OpportunityAssignListController(controller);
        opptyAssgnlistController.addSelfAssignedUser();
        opptyAssgnlistController.Ok();         
                      
    }
    
    public static testMethod void opportunityAssignment02() 
    { 
        User user01 = [Select u.Forecast_Group__c from User u  where u.Forecast_Group__c='Direct' and isActive=true limit 1];
           
        List<User_Assignment__c> userAssgnmentList = new List<User_Assignment__c>();
        Opportunity Oppty01 = [Select o.AccountId, o.CloseDate, o.Id from Opportunity o  where o.CloseDate > :System.today() limit 1];
        User_Assignment__c userAssgnment01 = new User_Assignment__c();
        userAssgnment01.User__c = user01.id; 
        userAssgnment01.Opportunity__c = Oppty01.id;
        userAssgnment01.Account__c = Oppty01.AccountId;
        userAssgnment01.Assignment_Group__c='House Account';
        insert userAssgnment01;
        userAssgnmentList.add(userAssgnment01);
        
        User_Assignment__c userAssgnment02 = new User_Assignment__c();
        userAssgnment02.User__c = user01.id; 
        userAssgnment02.Opportunity__c = Oppty01.id;
        userAssgnment02.Account__c = Oppty01.AccountId;
        userAssgnment02.Assignment_Group__c='Direct';
        insert userAssgnment02;
        userAssgnmentList.add(userAssgnment02);
        
        User_Assignment__c userAssgnment03 = new User_Assignment__c();
        userAssgnment03.Account__c = Oppty01.AccountId;
        userAssgnment03.Opportunity__c = Oppty01.id;
        userAssgnment03.Assignment_Group__c = 'Inside Sales';
        insert userAssgnment03;
        userAssgnmentList.add(userAssgnment03);
        
       
        
        String key = 'toInsert';
        String value = userAssgnmentList[0].id+','+userAssgnmentList[1].id+','+userAssgnmentList[2].id;
                           
        ApexPages.currentpage().getParameters().put(key,value);
        System.debug('ListIds*************'+ApexPages.currentpage().getParameters().get('toInsert'));
        
        ApexPages.StandardController controller01 = new ApexPages.StandardController(new User_Assignment__c());               
        OpportunityAssignListController opptyAssgnlistController01 = new OpportunityAssignListController(controller01);
        opptyAssgnlistController01.addSelfAssignedUser();
        opptyAssgnlistController01.Ok(); 
        UserRole usrRole=createRole('test6666');
        //User getuser=createUser('AMER Channels User',usrRole); // Chnaged from EMC Channels User to AMER Channels User, for EMC Channels User profile Deletion 
        User getuser = [Select u.Email, u.ProfileId, u.Username from User u where u.ProfileId = '00eT0000000ir0k' and isActive=true limit 1];
        System.runAs(getuser){
            opptyAssgnlistController01.addSelfAssignedUser();
            opptyAssgnlistController01.Ok();
        }
        
      /*  User getuser01 = [Select u.Forecast_Group__c, u.Id from User u  where u.Forecast_Group__c= 'Channel' and isActive=true limit 1];
        System.runAs(getuser01){
            opptyAssgnlistController01.addSelfAssignedUser();
            opptyAssgnlistController01.Ok();
        }
        */
       
    }
    private static UserRole createRole(String roleName){
      UserRole NewusrRole1=new UserRole(Name=roleName+Math.Random());
      insert NewusrRole1;
      return NewusrRole1;
    } 
      private static User createUser(String Profilename,UserRole newRole){
            
      Profile amerUserProf = [select Id from Profile where Name=:Profilename];
    //UserRole role = [select Id from UserRole where Name='test'];
    User tempUsr = new User(
             Username='test1234'+Math.random()+'@acme.com.test',
             TimeZoneSidKey='America/New_York',
             ProfileId=amerUserProf.Id,
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             UserRoleId=newRole.Id,
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782000',
             IsActive=true 
        );
    insert tempUsr;
      return tempUsr;
    }
     public static testMethod void opportunityAssignment03() 
    {
         //
        User userFG = [Select u.Forecast_Group__c, u.Id, u.IsActive from User u  where u.Forecast_Group__c='Inside Sales' and u.IsActive=true limit 1];
        Account account = new Account();
        account.name = 'Test';
        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        insert account;
        AccountTeamMember acctTeamMember= new AccountTeamMember();
        acctTeamMember.AccountId=account.Id;
        acctTeamMember.TeamMemberRole='BURA-SALES REP';
        acctTeamMember.UserId=userFG.id;
        insert acctTeamMember;
        AccountTeamMember acctTeamMember2= new AccountTeamMember();
        acctTeamMember2.AccountId=account.Id;
        acctTeamMember2.TeamMemberRole='BURA-SALES REP';
        acctTeamMember2.UserId=Userinfo.getuserId();
        insert acctTeamMember2;
        
        Opportunity Oppty = new Opportunity();
        Date closeDate = date.today()+15;
        Date approvalDate = date.newinstance(2014, 11, 1);
        Date expirationDate = date.newinstance(2015, 11, 18);
        Oppty.Name = 'Test Oppty';
        Oppty.Sales_Channel__c = 'Direct';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.Quote_Type__c='New';
        Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate;
        Oppty.AccountId=account.Id;
        Oppty.Amount=75900;
        insert Oppty;
        
        List<User_Assignment__c> userAssgnmentList = new List<User_Assignment__c>();
        User_Assignment__c userAssgnment = new User_Assignment__c();
        userAssgnment.Account__c = account.id;
        userAssgnment.Opportunity__c = Oppty.id;
        userAssgnment.Assignment_Group__c = 'Inside Sales';
        insert userAssgnment;
        userAssgnmentList.add(userAssgnment);
        
        User_Assignment__c userAssgnment01 = new User_Assignment__c();
        userAssgnment01.Account__c = account.id;
        userAssgnment01.Opportunity__c = Oppty.id;
        userAssgnment01.Assignment_Group__c = 'House Account';
        insert userAssgnment01;
        userAssgnmentList.add(userAssgnment01);
        
        User_Assignment__c userAssgnment02 = new User_Assignment__c();
        userAssgnment02.Account__c = account.id;
        userAssgnment02.Opportunity__c = Oppty.id;
        userAssgnment02.Assignment_Group__c = 'Direct';
        insert userAssgnment02;
        userAssgnmentList.add(userAssgnment02);
        //
        System.debug('**********List sizze is---->'+userAssgnmentList.size());
        System.debug('**********List sizze is---->'+userAssgnmentList);
        
        String key = 'toInsert';
        String value = userAssgnmentList[0].id+','+userAssgnmentList[1].id+','+userAssgnmentList[2].id;
                           
        ApexPages.currentpage().getParameters().put(key,value);
        System.debug('ListIds*************'+ApexPages.currentpage().getParameters().get('toInsert'));
        
        ApexPages.StandardController controller02 = new ApexPages.StandardController(new User_Assignment__c());               
        OpportunityAssignListController opptyAssgnlistController02 = new OpportunityAssignListController(controller02);
        opptyAssgnlistController02.addSelfAssignedUser();
        opptyAssgnlistController02.Ok(); 
        
        System.runAs(userFG){
            opptyAssgnlistController02.addSelfAssignedUser();
            opptyAssgnlistController02.Ok();
        }
        
        /*User userFG01 = [Select u.Forecast_Group__c, u.Id, u.IsActive from User u  where u.Forecast_Group__c='N/A' and u.IsActive=true limit 1];
        
        System.runAs(userFG01){
            opptyAssgnlistController02.addSelfAssignedUser();
            opptyAssgnlistController02.Ok();
        }*/
    }
    
}