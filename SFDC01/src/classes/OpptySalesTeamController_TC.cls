/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  07.02.2013      Vivek                       Remove hard coded user id value and placed dynamic userid 
 |  
 +===========================================================================*/

@isTest
Private class OpptySalesTeamController_TC {
    
    static testMethod void opptySalesTeam() 
    { 
        //OpportunityTeamMember opptyTeamMember = [Select o.User.Name,o.UserId,o.TeamMemberRole,o.OpportunityId, o.OpportunityAccessLevel,o.User.Forecast_Group__c  From OpportunityTeamMember o where o.OpportunityId=: limit 1000];
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity Oppty = new Opportunity();
        Oppty.AccountId = testAccount.Id;
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
        Oppty.Expiration_Date__c=expirationDate ;
        insert Oppty;

        System.debug('Oppty.Id'+Oppty.Id);    
        //opptyAccess.checkOppAcces(Oppty.Id);
        OpportunityTeamMember opptyTeamMember= new OpportunityTeamMember();
        //opptyTeamMember.OpportunityAccessLevel='Read';
        List<User> getActiveuser =[Select u.id,u.name, u.UserType From User u where u.IsActive=true and profile.Name='System Administrator' limit 1];
        opptyTeamMember.OpportunityId=Oppty.Id;
        opptyTeamMember.TeamMemberRole='BURA-SALES REP';
        opptyTeamMember.UserId=getActiveuser[0].Id;
        insert opptyTeamMember;
        ApexPages.currentpage().getParameters().put('Id',Oppty.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(new Opportunity());               
        OpptySalesTeamController opptySalesTeamCtrl = new OpptySalesTeamController(controller);
        opptySalesTeamCtrl.getOpportunitySalesTeam();
        
       /* User u =[select id from user where id ='00570000001L7RS'];
        System.runAs(u){        
            List<OpportunityTeamMember> lst=  [Select o.User.Name,o.UserId,o.TeamMemberRole, o.OpportunityAccessLevel,o.User.Forecast_Group__c  From OpportunityTeamMember o where o.OpportunityId='006T0000004XTq4' order by o.User.Forecast_Group__c limit 1000];
            
            System.debug('lst '+lst.size());
        
        }
        
        User u2 =[select id from user where id='005T0000000gL8S'];
        System.runAs(u2){        
            List<OpportunityTeamMember> lst02=  [Select o.User.Name,o.UserId,o.TeamMemberRole, o.OpportunityAccessLevel,o.User.Forecast_Group__c  From OpportunityTeamMember o where o.OpportunityId='006T0000004XTq4' order by o.User.Forecast_Group__c limit 1000];
            
            System.debug('lst02 '+lst02.size());
        
        }*/
               
    }
}