/**
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       	WR          DESCRIPTION                               
 |  ====            =========       	==          =========== 
 |  06 Apr 2012		Avinash Kaltari		188318      Initial Creation of Test Class. 
 													Inserting and Updating Competitive_Summary_Mapping__c record.  
 |  																
 +========================================================================================================================*/

 
@isTest(SeeAllData=true)
private class CompetitiveSummaryMappingInsertUpdate_TC {

    static testMethod void myUnitTest() {
        Competitive_Summary_Mapping__c obj = new Competitive_Summary_Mapping__c();
        insert obj;
        update obj;
    }
    
    static testMethod void competitiveSummaryWithSummaryTest(){
    	List<Opportunity> lstOpportunity = [Select id, name, Competitor__c, Product_Model__c from Opportunity where Competitor__c != null and Product_Model__c != null limit 100];
    	CompetitiveSummaryOperation compSummaryOp = new CompetitiveSummaryOperation();
    	compSummaryOp.populateCompetitiveMappingOnOppty(lstOpportunity) ;
    	
    }

    static testMethod void competitiveSummaryWithoutSummaryTest(){
        List<Opportunity> lstOpportunity = [Select id, name, Competitor__c, Product_Model__c from Opportunity where Competitor__c = null and Product_Model__c = null limit 100];
        CompetitiveSummaryOperation compSummaryOp = new CompetitiveSummaryOperation();
        compSummaryOp.populateCompetitiveMappingOnOppty(lstOpportunity) ;
        
    }

    static testMethod void competitiveSummaryTest(){
        List<Competitive_Summary_Mapping__c> lstCompSumMapping = [Select id, name, Primary_Competitor__c, Product__c from Competitive_Summary_Mapping__c where Primary_Competitor__c != null and Product__c != null limit 100];
        CompetitiveSummaryOperation compSummaryOp = new CompetitiveSummaryOperation();
        compSummaryOp.insertUpdateCompetitiveMapping(lstCompSumMapping) ;
        compSummaryOp.restrictDublicateRecord(lstCompSumMapping) ;
    }
}