/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     =========== 
 |                                             Initial draft             
 |  17.01.2011      Shipra Misra     151285             Updated code as it was failing in deployement.Removed query to EMC Channel User Profile.
 +=========================================================================================================================*/
 

@isTest

private class OpportunityAssignController_TC{
    
    Static User user01=null; 
    Static User user02=null;
    Static User user03=null;
    Static User user04=null;
    Static User user05=null;
    //Updated code on 20 SEP 10 By Shipra Misra *declared a static user...user06... *//
    Static User user06=null;
    Static Opportunity Oppty01 =null;
    static{
        //extended limit to 1000 17.01.2011
        List<User>users = [Select u.id,u.Email, u.ProfileId, u.Username,u.Forecast_Group__c from User u  where ( u.Forecast_Group__c='Direct') and IsActive = true limit 1000];
        //Selected user with House account//
        List<User>HouseAccountuser = [Select u.id,u.Email, u.ProfileId, u.Username,u.Forecast_Group__c from User u  where (Name='House Account' ) and IsActive = true limit 1];
        
        for(User u :users){
            if(u.Forecast_Group__c=='Channel'){
                user02=u;
            }else if(u.Forecast_Group__c=='Direct'){
                user04=u;        
                user01=u;        
            }else if(u.Forecast_Group__c=='N/A'){
                user05 =u;
            }
            
        }
       //20.09.10 Shipra//
        for(User u :HouseAccountuser){
            user06=u;
        }

        //* end of update 20.09.10 Shipra//
        if(users.size()>0 )
        {
            user05 = users[0];
            user04 = users[0];
            user03 = users[0];
            user02 = users[0];
            user01 = users[0];
        }

        Oppty01 = [Select o.AccountId, o.CloseDate, o.Id from Opportunity o  where o.CloseDate > today  and owner.Isactive=true limit 1];

    }
    
    public static testMethod void opportunityAssignment() 

    { 
      

        Account account = new Account();

        account.name = 'Test';

        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));

        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));

        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));

        insert account;

        AccountTeamMember acctTeamMember01 = new AccountTeamMember();

        acctTeamMember01.AccountId = account.Id;

        acctTeamMember01.TeamMemberRole = 'BURA-SALES REP';

        acctTeamMember01.UserId = user05.id;                       
 
        insert acctTeamMember01;

        

        User_Assignment__c userAssgnment01 = new User_Assignment__c();

        userAssgnment01.User__c = user05.id; 

        userAssgnment01.Opportunity__c = Oppty01.id;

        userAssgnment01.Account__c = account.id;

        userAssgnment01.Assignment_Group__c='House Account';
        
                
        insert userAssgnment01;
              

        OpportunityTeamMember OpptyTmMem= new OpportunityTeamMember();
        
        OpptyTmMem.OpportunityId = Oppty01.id;
        
        OpptyTmMem.UserId = user06.id; 
        
        insert OpptyTmMem;                               

        //AccountTeamMember[] acctTeamMember = [Select User.Forecast_Group__c,id, UserId,TeamMemberRole, Account.Name, AccountId,AccountAccessLevel From AccountTeamMember where accountid=:Oppty01.AccountId and User.Forecast_Group__c='Direct'];

                

        ApexPages.StandardController controller01 = new ApexPages.StandardController(userAssgnment01);               

        OpportunityAssignController opptyAssgnController01 = new OpportunityAssignController(controller01);

                
        opptyAssgnController01.UserAssignmentPage();

        opptyAssgnController01.getUser_Assignment();

        opptyAssgnController01.AssignSalesTeamMember();

        opptyAssgnController01.UserAssignmentId();

        opptyAssgnController01.AssignUtils.restrictPermission();

        opptyAssgnController01.addSelfAssignedUser();        

        opptyAssgnController01.Ok();
        //Shipra
        opptyAssgnController01.assignSelfOk();
                

        opptyAssgnController01.BackToUAPage();

        String BackToUAPage = opptyAssgnController01.BackToUAPage().getURL();

        System.debug('BackToUAPage page url'+BackToUAPage);

        System.assertEquals('/'+userAssgnment01.Account__r.id,BackToUAPage);

        
        opptyAssgnController01.NextAccountPage();

        String NextAccountPage = opptyAssgnController01.NextAccountPage().getURL();

        System.debug('NextAccountPage page url'+NextAccountPage);

                              

        List<OpportunityAssignController.SalesTeamWrapper> uaList = opptyAssgnController01.getUser_Assignment();
        if(uaList==null ||uaList.size()<0)return;
        System.debug('SalesTeamWrapper size'+uaList.size());

        opptyAssgnController01.addTeamMember(uaList[0],100);

        System.runAs(user02){

            opptyAssgnController01.AssignUtils.restrictPermission();

        }

        

        AccountTeamMember acctTeamMember02 = new AccountTeamMember();

        acctTeamMember02.AccountId = account.Id;

        acctTeamMember02.TeamMemberRole = 'BURA-SALES REP';

        acctTeamMember02.UserId = user05.id;                       

                

        System.runAs(user05){        

            //insert acctTeamMember02;

            opptyAssgnController01.AssignUtils.addSelfAssignedUser();

            opptyAssgnController01.AssignUtils.restrictPermission();

        }
    }
  
    public static testMethod void opportunityAssignment01() 

    {
        //Commented both queries as no longer required. 17.01.2011
        //Profile amerUserProf = [select Id from Profile where Name = 'EMC Channels User'];
         
        //user03 = [select id from user where isactive = true and profileId =: amerUserProf.id and Forecast_Group__c='Direct' limit 1];
        user03 = [select id from user where isactive = true and Forecast_Group__c='Direct' limit 1];
        Account account = new Account();

        account.name = 'Test';

        account.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));

        account.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));

        account.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));

        insert account;



        AccountTeamMember acctTeamMember01 = new AccountTeamMember();

        acctTeamMember01.AccountId = account.Id;

        acctTeamMember01.TeamMemberRole = 'BURA-SALES REP';

        acctTeamMember01.UserId = user04.id;

        insert acctTeamMember01;

        Opportunity Oppty02=Oppty01;

        List<User_Assignment__c> lstuserAssgnment = new List<User_Assignment__c>();
        User_Assignment__c userAssgnment02 = new User_Assignment__c();

        userAssgnment02.User__c = user03.id; 

        userAssgnment02.Opportunity__c = Oppty02.id;

        userAssgnment02.Account__c = account.id;

        userAssgnment02.Assignment_Group__c='Direct';
        lstuserAssgnment.add(userAssgnment02);
        
        //20.09.10 Shipra//
        User_Assignment__c userAssgnment06 = new User_Assignment__c();

        userAssgnment06.User__c = user06.id; 

        userAssgnment06.Opportunity__c = Oppty01.id;

        userAssgnment06.Account__c = account.id;

        userAssgnment06.Assignment_Group__c='House Account';
        lstuserAssgnment.add(userAssgnment06);
                
        insert lstuserAssgnment;  
        
        ApexPages.StandardController controller02 = new ApexPages.StandardController(userAssgnment02);               
        ApexPages.StandardController controller06 = new ApexPages.StandardController(userAssgnment06); 
        OpportunityAssignController opptyAssgnController02 = new OpportunityAssignController(controller02);
        OpportunityAssignController opptyAssgnController06 = new OpportunityAssignController(controller06);
        List<OpportunityAssignController.SalesTeamWrapper> uaList1 = opptyAssgnController06.getUser_Assignment();
        //* end of update 20.09.10 Shipra//   
        
        System.runAs(user03){

            opptyAssgnController02.AssignUtils.restrictPermission();
            // DD System.debug('SalesTeamWrapper size'+uaList1.size()+'the value uaList1 is '+uaList1);
            //  System.assertEquals(true,opptyAssgnController02.AssignUtils.restrictPermission());
            opptyAssgnController02.AssignSalesTeamMember();

        }

        

        System.runAs(user04){

            opptyAssgnController02.addSelfAssignedUser();

            opptyAssgnController02.AssignUtils.restrictPermission();

            // DD System.assertEquals(false,opptyAssgnController02.AssignUtils.restrictPermission());

            opptyAssgnController02.AssignSalesTeamMember();

        }
        //20.09.10 Shipra//
        /*
        System.runAs(user06){

            opptyAssgnController06.addSelfAssignedUser();
            
            uaList1[0].IsChecked=true;
            
            opptyAssgnController06.AssignUtils.restrictPermission();

            System.assertEquals(false,opptyAssgnController06.AssignUtils.restrictPermission());

            //opptyAssgnController06.AssignSalesTeamMember();

        }
        */
        //* end of update 20.09.10 Shipra//

    }

}