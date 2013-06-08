/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C                 Test Class cleanup
 |  
 +===========================================================================*/
@isTest
Private Class CheckOpportunityAccess_TC{
    Private static testMethod void startTest(){
        User getuser01 = [Select u.Email, u.ProfileId, u.Username from User u where Forecast_Group__c = 'Direct' and IsActive = true and Profile.Name like '%Administrator%' Limit 1];
        CheckOpportunityAccess opptyAccess = new CheckOpportunityAccess();
        Account testAccount = new Account(Name='Test Account');
        testAccount.OwnerId = getuser01.Id;
        insert testAccount;
        Opportunity Oppty = new Opportunity();
        Date closeDate = date.today()+15;
        Date approvalDate = date.newinstance(2014, 11, 1);
        Date expirationDate = date.newinstance(2015, 11, 18);
        Oppty.AccountId = testAccount.Id;
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
        
        
        System.runAs(getuser01){
            insert Oppty;
            opptyAccess.checkOppAcces(Oppty.Id);
        }

        //insert Oppty;

        System.debug('Oppty.Id'+Oppty.Id); 
        System.debug('Oppty.Owner'+Oppty.Opportunity_Owner__r.Forecast_Group__c);   
        opptyAccess.checkOppAcces(Oppty.Id);
        OpportunityTeamMember opptyTeamMember= new OpportunityTeamMember();
        //opptyTeamMember.OpportunityAccessLevel='Read';
        opptyTeamMember.OpportunityId=Oppty.Id;
         opptyTeamMember.TeamMemberRole='BURA-SALES REP';
        User getuser = [Select u.Id,u.Email, u.ProfileId, u.Username from User u where IsActive=true Limit 1];
        opptyTeamMember.UserId=getuser.Id;
        insert opptyTeamMember;
        System.runAs(getuser){
            opptyAccess.checkOppAcces(Oppty.Id);
        }
    }
}