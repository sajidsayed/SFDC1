@isTest
private class Opp_CreateQuote_TC { 
 
 public static testmethod void deployOpp_CreateQuote(){
    
    //Updated code on 20 SEP 10 By Shipra Misra * Inserted account which is required field on Opportunity*//
    Account acc=new Account(Name='AccntTest1' );
    insert acc;
    Opportunity opp= new Opportunity(Name = 'Force Monkey 4x4',StageName = 'Pipeline',AccountId=acc.Id, Edit_Access__c ='test Access',Opportunity_Number__c='1123123123',Quote_Cart_Number__c='123', CloseDate = System.today()); 
    //End of update on 20 SEP 10//
    insert opp;
    ApexPages.StandardController oppController=new ApexPages.StandardController(opp);
    Opp_CreateQuote OPP_CREATE=new Opp_CreateQuote(oppController);   
    OPP_CREATE.checkUserProfile();
    OPP_CREATE.CurrentUserProfile = 'Marketing Standard User';
    OPP_CREATE.checkUserProfile();

    Profile p = [select id from profile where name='Marketing Standard User' limit 1];
    User u = [select id from user where ProfileId =: p.id and IsActive = True limit 1];
   
    System.runAs(u) {
      OPP_CREATE.checkOpportunityAccess();
    }

   OPP_CREATE.checkErrorMessagePresent();
   OPP_CREATE.objOppy.Opportunity_Number__c = null;
   OPP_CREATE.checkSynergyNumberPresent();
   OPP_CREATE.objOppy.Sell_Relationship__c = 'test method';
   OPP_CREATE.checkRequestRaised();
   OPP_CREATE.objOppy.Integration_Error_Message__c= 'Test';
   OPP_CREATE.objOppy.Sell_Relationship__c = null;
   OPP_CREATE.checkErrorMessagePresent();
   OPP_CREATE.Ok();
   OPP_CREATE.createQuotesave();
   
   System.runAs(u) {
     OPP_CREATE.createQuotesave();
   }
    
   OPP_CREATE.objOppy.Integration_Error_Message__c= 'Test';
   OPP_CREATE.checkRequestRaised();
   OPP_CREATE.objOppy.Opportunity_Number__c = '12312312' ;
   OPP_CREATE.checkSynergyNumberPresent();
   OPP_CREATE.objOppy.StageName= 'Closed';
   OPP_CREATE.objOppy.Sell_Relationship__c = 'Test';
   OPP_CREATE.checkRequestRaised();
   OPP_CREATE.validate();
   }  

}