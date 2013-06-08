/*====================================================================================================================+
 |  HISTORY |                                                                 
 |                                                                           
 |  DATE          DEVELOPER              WR               DESCRIPTION                               
 |  ====          =========              ==               =========== 
 |  26 March 12    Arif                                   This trigger is written for Competitive Summary Mapping Functionality
 |  20 November12  Hemavathi N M                          Dec Release - Removed the functionality of auto populating Competitive_Summary_URL__c field with the Document URL from the unique document name provided
                                                          in the Competitive_Summary__c field
  
 +====================================================================================================================*/
trigger CompetitiveSummaryMappingBeforeInsertUpdate on Competitive_Summary_Mapping__c (before insert,before update) {
    if(Trigger.isInsert){
        CompetitiveSummaryOperation obj = new CompetitiveSummaryOperation();
        obj.restrictDublicateRecord(Trigger.New);
        obj.insertUpdateCompetitiveMapping(Trigger.New);
    }
    else{
        map<Id,Competitive_Summary_Mapping__c> mapComSumMapping = new map<Id,Competitive_Summary_Mapping__c>(); 
        for(Competitive_Summary_Mapping__c comSumMap: Trigger.New){
            Competitive_Summary_Mapping__c oldRecord = Trigger.OldMap.get(comSumMap.Id);
            
            if((comSumMap.Primary_Competitor__c != oldRecord.Primary_Competitor__c && comSumMap.Primary_Competitor__c != ''
               && comSumMap.Primary_Competitor__c != null)
             || (comSumMap.Product__c != oldRecord.Product__c && comSumMap.Product__c != '' && comSumMap.Product__c != null)
             || ( comSumMap.Competitive_Summary__c != '')
             ){
                System.Debug('mapComSumMapping ----->' + mapComSumMapping);
                mapComSumMapping.put(comSumMap.Id,comSumMap);
                System.Debug('mapComSumMappingNew ----->' + mapComSumMapping);
            }
        }
        
  // Dec Release : Remove auto populate URL Field
         if(!mapComSumMapping.isempty()){
            CompetitiveSummaryOperation obj = new CompetitiveSummaryOperation();
            //obj.restrictDublicateRecord(mapComSumMapping.values());
            //obj.updateCompetitiveMapping(mapComSumMapping);  
            obj.insertUpdateCompetitiveMapping(mapComSumMapping.values());  
        }  
   }                    
            
}