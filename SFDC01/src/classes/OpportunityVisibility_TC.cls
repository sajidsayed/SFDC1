/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C         		Test Class cleanup
 |  
 +===========================================================================*/
@isTest
Private class OpportunityVisibility_TC{
    static testMethod void opportunityVisibilityTests() {
        
        OpportunityIntegration__c newrec = OpportunityIntegration__c.getInstance('HouseAccount');
        if(newrec== null)
        {
            newrec = new OpportunityIntegration__c(Name = 'HouseAccount', House_Account_User__c = '00570000001dlVA');
            insert newrec;
        }
       
      //  Map<String, Opportunity> OpenOpportunityMap = new Map<String, Opportunity>();
    
        List<Opportunity> opportunities = [Select o.Id,o.AccountId, o.IsClosed,o.Partner__c, o.Tier_2_Partner__c,o.OwnerId from Opportunity o where o.IsClosed = false limit 5];
      //  Opportunity Oppty = [Select o.Id,o.AccountId, o.IsClosed,o.Partner__c, o.Tier_2_Partner__c,o.OwnerId from Opportunity o where o.IsClosed = false limit 1];
        List<User_Assignment__c> userAssignment = [Select u.Account__c, u.Assignment_Group__c, u.Assignment_Status__c, u.Opportunity__c,u.Unique_Key__c from User_Assignment__c u limit 10];
      //  OpenOpportunityMap.put(Oppty.Id,Oppty);
    
        OpportunityVisibility opptyVisibility = new OpportunityVisibility(opportunities);
        //opptyVisibility.getOpportunityTeamMemberJudgementGroup();
        //opptyVisibility.getAccountTeamMemberJudgementGroup();
        //opptyVisibility.getOpportunityProductJudgementGroup();
        opptyVisibility.getOpportunityWithNoForecastGroupMember();
        opptyVisibility.getPartnerOpportunityWithNoChannelMember();
        opptyVisibility.getHouseAccountOpportunity();
        opptyVisibility.createUserAssigments('Channel',opportunities );
        opptyVisibility.insertUserAssigments(userAssignment );
     }
}