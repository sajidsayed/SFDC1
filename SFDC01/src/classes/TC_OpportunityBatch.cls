@istest
class TC_OpportunityBatch{
    static testmethod void test() {
    DeleteUserAssignments__c deletionParameters = DeleteUserAssignments__c.getValues('UserAssignmentsDeletionParameters');
    deletionParameters.DeleteUnassigned__c = true;
    update deletionParameters;
    String query = 'Select o.AccountId ,o.CloseDate, o.Id, o.Partner__c,o.Tier_2_Partner__c, o.Name, o.Opportunity_Owner__c ,o.OwnerId from Opportunity o where o.IsClosed = false and o.AccountId<>'+ '\'0017000000YiRfS\''+' order by o.AccountId limit 200';
    Opportunity oppty = [Select o.AccountId ,o.CloseDate, o.Id, o.Partner__c,o.Tier_2_Partner__c, o.Name, o.Opportunity_Owner__c ,o.OwnerId from Opportunity o where o.IsClosed = false and o.AccountId<>'0017000000YiRfS' and o.CloseDate>today limit 1];
    
    
    Test.StartTest();
    OpportunityBatch opptyBatch = new OpportunityBatch(query);
    opptyBatch.Query = query;
    ID batchprocessid = Database.executeBatch(opptyBatch);
    
  /*
    Database.batchablecontext bc;
    List<sobject> st;
    opptyBatch.execute(bc,st); */ 
    Test.StopTest();  
    
    
 /* Test.StartTest();
    Database.BatchableContext bc;
    Database.QueryLocator st;
    OpportunityBatch obj = new OpportunityBatch(query) ;
    //st=obj.start(bc);
    //List <SObject> scope=new List<SObject>();
    sobject[] scope;
    Opportunity opt= new Opportunity();
    opt.CloseDate=System.today()-1;
    scope.add(opt);
    obj.execute(bc,scope);
    obj.finish(bc);
    Test.StopTest(); */
    
    
    
        
    
    }
    
    
   
}