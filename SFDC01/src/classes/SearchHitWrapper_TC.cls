@isTest(SeeAllData = true) 
private class SearchHitWrapper_TC {
/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  11-Apr-2013  Prachi                 Created 

+===========================================================================*/ 
           public Static Partner_Location__c location= new Partner_Location__c();
           public Static List<SearchHitWrapper> hits= new List<SearchHitWrapper>();
           public Static string abc=null;
static testMethod void SearchHitWrapper (){
    
    Test.StartTest(); 
    location.Latitude__c=90;
    location.Longitude__c=90;
    location.Country__c='BELARUS (BY)';
    insert location;
    SearchHit obj= new SearchHit(location);
    Configuration config= Configuration.getInstance();
    SearchHitWrapper objMain= new SearchHitWrapper(obj,config);
    hits.add(objMain);
    abc=SearchHitWrapper.toJson(hits);
    Test.StopTest();
}

static testMethod void SearchHitWrapper1 (){
    
    Test.StartTest(); 
    SearchHit obj= new SearchHit(location);
    Configuration config= Configuration.getInstance();
    SearchHitWrapper objMain= new SearchHitWrapper(obj,config);
    hits.add(objMain);
    abc=SearchHitWrapper.toJson(hits);
    Test.StopTest();
}
}