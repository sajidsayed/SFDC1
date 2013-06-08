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
private class AssignChannelRep_TC { 
static testMethod void testAssignChannelRep(){
    testclassUtils.getCustomSettingrec_opptyIntg('Admin Conversion', '00570000001L8zrAAC'); 
    OpportunityIntegration__c lcs= OpportunityIntegration__c.getvalues('Admin Conversion');
    User user01 = [Select Id,u.Forecast_Group__c from User u  where Id=:lcs.Admin_Conversion__c limit 1];
    System.runas(user01){   
       
       Account acc = testclassUtils.getAccount(); 
        insert acc ;
       Opportunity oppty01 =  testclassUtils.getOppty();
        oppty01.AccountId = acc.id ;
        insert oppty01 ;
       // Opportunity Oppty01 = [Select o.AccountId, o.CloseDate, o.Id from Opportunity o  where o.CloseDate > :System.today() limit 1];
        User_Assignment__c userAssgnment01 = new User_Assignment__c();
        userAssgnment01.User__c = user01.id; 
        userAssgnment01.Opportunity__c = Oppty01.id;
        userAssgnment01.Account__c = Oppty01.AccountId;
        userAssgnment01.Assignment_Group__c='House Account';
        insert userAssgnment01;
        userAssgnment01.Assignment_Status__c='100_Channel_Assigned by Tool';
        update userAssgnment01;
    }
}
}