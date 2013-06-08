/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  02-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
  @isTest(SeeAllData = true)
private class PartnerSearchController_TC {
    
static testMethod void PartnerSearchController(){
Partner_Location__c ptnrLoc= new Partner_Location__c(CurrencyIsoCode='USD',Postal_Code__c='83854',Is_Primary__c=true,Country__c='UNITED STATES (US)',eBus_Location_Enabled__c=false,
Name='EDNETICS NORTH AMERICA',City__c='POST FALLS',Street__c='721 LOCHSA ST STE 15' );
insert ptnrLoc;
    Test.StartTest();
 PartnerSearchController  cons=new PartnerSearchController();
     cons.paramString='Test';
     cons.doOnLoad();
     cons.searchClicked();
     cons.refresh();
     cons.getMessages();
     cons.skipToLocation();
     cons.toggleFilter();
     cons.getSortColumnList();
     //cons.sortData();
 Test.StopTest();
}
static testMethod void PartnerSearchController1(){
    Partner_Location__c ptnrLoc= new Partner_Location__c(CurrencyIsoCode='USD',Postal_Code__c='83854',Is_Primary__c=true,Country__c='UNITED STATES (US)',eBus_Location_Enabled__c=true,
Name='EDNETICS NORTH AMERICA',City__c='POST FALLS',Street__c='721 LOCHSA ST STE 15');
    insert ptnrLoc;
    Test.StartTest();
 PartnerSearchController  cons=new PartnerSearchController();
     cons.paramString='Test';
     cons.displayAdvancedSearchFlag=null;    
     cons.refresh();
     cons.getMessages();
     cons.skipToLocation();
     cons.toggleFilter();
     cons.getSortColumnList();
    cons.sortData();
 Test.StopTest();
}
}