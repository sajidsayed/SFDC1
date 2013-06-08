/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  11-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
 @isTest(SeeAllData = true) 
private class SearchHit_TC {
         public Static Partner_Location__c location= new Partner_Location__c();
         public Static GeoPoint point= new GeoPoint(-90,-180);
         public Static List<SearchHit> a1=new List<SearchHit>();
         public Static List<SearchHit> a2=new List<SearchHit>();
                     

static testMethod void SearchHit(){
    
    Test.StartTest(); 
    location.Latitude__c=90;
    location.Longitude__c=90;
    location.Country__c='BELARUS (BY)';
    insert location;
    SearchHit obj= new SearchHit(location);
    obj.setDistanceToPoint(point);
    a2= SearchHit.sortByDistance(a1);
    
       
    Test.StopTest();
}
}