/*====================================================================================================================+
 |  HISTORY |                                                                 
 |                                                                           
 |  DATE       DEVELOPER              WR               DESCRIPTION                               
 |  ====       =========              ==               =========== 
 |  26 March 12 Arif                                   This class is written for Competitive Summary Mapping Functionality 
 |  28 Nov   12 Medhavi                                Changed in  populateCompetitiveMappingOnOppty m/d, to set the  
  
 +====================================================================================================================*/
public class CompetitiveSummaryOperation{
    public void populateCompetitiveMappingOnOppty(List<Opportunity> lstOpportunity){
        map<Id,string> mapOpptyIdString = new map<Id,string>();
        Set<String> setOpptyIdString = new Set<String>();
        map<string,Competitive_Summary_Mapping__c> mapStringCompId = new map<string,Competitive_Summary_Mapping__c>();
        list<Competitive_Summary_Mapping__c> lstCompetitiveSummary = new list<Competitive_Summary_Mapping__c>();
        //string tempString = 'Primary Competitor';
        string tempString = System.Label.Primary_Competitor;
        for(Opportunity oppty: lstOpportunity){
            system.debug('c-->'+oppty.Competitor__c +'<-->'+ oppty.Product_Model__c +'<-->'+ tempString);
            if(oppty.Competitor__c != null && oppty.Competitor__c != ''){
            	setOpptyIdString.add(oppty.Competitor__c + ' ' + oppty.Product_Model__c + ' ' +tempString); 
            }            
        }
        if (setOpptyIdString.size() > 0){
        	lstCompetitiveSummary = [Select Id,Name,Competitive_Summary_URL__c from Competitive_Summary_Mapping__c where Name in :setOpptyIdString];
        }
        system.debug('setOpptyIdString-->'+setOpptyIdString +'<--size-->'+ lstCompetitiveSummary.size());
        
        if(lstCompetitiveSummary.size()>0){
            for(Competitive_Summary_Mapping__c comp: lstCompetitiveSummary){
                if(!mapStringCompId.containskey(comp.Name)){
                    mapStringCompId.put(comp.Name,comp);
                }    
            }
        }
        for(Opportunity oppty: lstOpportunity){
            if(oppty.Competitor__c==null || oppty.Competitor__c=='' || oppty.Product_Model__c==null || oppty.Product_Model__c=='' )
            {
                oppty.Competitive_Summary_Mapping__c=null;
            }
            else if(!mapStringCompId.isEmpty()){
                if(mapStringCompId.containsKey(oppty.Competitor__c + ' ' + oppty.Product_Model__c + ' ' +tempString))
                {
                    system.debug('value--->'+mapStringCompId.get(oppty.Competitor__c + ' ' + oppty.Product_Model__c + ' ' +tempString).Competitive_Summary_URL__c);
                    oppty.Competitive_Summary_Mapping__c =mapStringCompId.get(oppty.Competitor__c + ' ' + oppty.Product_Model__c + ' ' +tempString).id;
                    oppty.Competitive_Summary__c = mapStringCompId.get(oppty.Competitor__c + ' ' + oppty.Product_Model__c + ' ' +tempString).Competitive_Summary_URL__c;
                }
                else{
                  oppty.Competitive_Summary_Mapping__c=null;
                }    
            }
            else if (mapStringCompId.isEmpty())
                oppty.Competitive_Summary_Mapping__c = null;    
        }
    }
    
        
       public void insertUpdateCompetitiveMapping(list<Competitive_Summary_Mapping__c> lstNewCompSumMapping)
       {
        map<string,string> mapCompSumMappingNameAndCompSummField = new map<string,string>();
        list<Document> lstDocument = new list<Document>();
        map<string,Id> mapUniqueNameAndDocId = new  map<string,Id>();
            for(Competitive_Summary_Mapping__c compSumMap: lstNewCompSumMapping){
                if(compSumMap != null){
                     if(compSumMap.Primary_Competitor__c != null && compSumMap.Primary_Competitor__c != '' && compSumMap.Product__c != null && compSumMap.Product__c != '')
                     {
                          compSumMap.Name = compSumMap.Primary_Competitor__c + ' ' + compSumMap.Product__c + ' ' + Label.Primary_Competitor;
                          compSumMap.Name = compSumMap.Name.trim();
                     }     
                    // compSumMap.Competitive_Summary_URL__c = ''; 
                      if(compSumMap.Competitive_Summary_URL__c != null && compSumMap.Competitive_Summary_URL__c != '')
                      {
                          if(!mapCompSumMappingNameAndCompSummField.containsKey(compSumMap.Name))
                          {
                              mapCompSumMappingNameAndCompSummField.put(compSumMap.Name,compSumMap.Competitive_Summary_URL__c);
                          }    
                      }
                }      
            }
           /* if(!mapCompSumMappingNameAndCompSummField.isEmpty())
            {
                lstDocument = [Select Id,DeveloperName from Document where DeveloperName in: mapCompSumMappingNameAndCompSummField.values()];
            }
            if(lstDocument.size()>0)
            {
                for(Document doc: lstDocument)
                {
                    mapUniqueNameAndDocId.put(doc.DeveloperName.tolowercase(),doc.Id);
                }
            }
            if(!mapUniqueNameAndDocId.isEmpty())
            {
                String baseURL = URL.getSalesforceBaseUrl().getHost();
                //Competitive_Summary_Mapping__c toUpdate = new Competitive_Summary_Mapping__c();
                for(Competitive_Summary_Mapping__c compSumMap: lstNewCompSumMapping){
                    if(mapCompSumMappingNameAndCompSummField.containsKey(compSumMap.Name)){ 
                        if(mapUniqueNameAndDocId.containsKey(mapCompSumMappingNameAndCompSummField.get(compSumMap.Name).toLowercase())){                   
                           compSumMap.Competitive_Summary_URL__c =  'https://'+baseURL+'/servlet/servlet.FileDownload?file='+mapUniqueNameAndDocId.get(mapCompSumMappingNameAndCompSummField.get(compSumMap.Name).toLowercase());
                        }
                    }
                }
            }  */
      }     
      
      public void restrictDublicateRecord(list<Competitive_Summary_Mapping__c> lstCompSumMapping){
          map<string,Competitive_Summary_Mapping__c> mapNameCumpSumMap = new map<string,Competitive_Summary_Mapping__c>();
          list<Competitive_Summary_Mapping__c> lstExistingCumpSumMap = new list<Competitive_Summary_Mapping__c>();
          map<string,Competitive_Summary_Mapping__c> mapExistingNameCumpSumMap = new map<string,Competitive_Summary_Mapping__c>();
          
          if(lstCompSumMapping.size()>0){
              for(Competitive_Summary_Mapping__c compSum: lstCompSumMapping){
                  if(compSum.Primary_Competitor__c != null && compSum.Primary_Competitor__c != '' && compSum.Product__c != null && compSum.Product__c != ''){
                      compSum.Name = compSum.Primary_Competitor__c + ' ' + compSum.Product__c + ' ' + Label.Primary_Competitor;
                      compSum.Name = compSum.Name.trim();
                  }
                  if(!mapNameCumpSumMap.containskey(compSum.Name)){    
                      mapNameCumpSumMap.put(compSum.Name,compSum);
                  }
               }
           }
           if(!mapNameCumpSumMap.isEmpty()){
               lstExistingCumpSumMap = [Select Id,Name from Competitive_Summary_Mapping__c where Name in: mapNameCumpSumMap.keyset()];
           }
           if(lstExistingCumpSumMap.size()>0){
               for(Competitive_Summary_Mapping__c compSum: lstExistingCumpSumMap){
                   if(!mapExistingNameCumpSumMap.containsKey(compSum.Name)){
                       mapExistingNameCumpSumMap.put(compSum.Name,compSum); 
                   }
               }
           }
           if(!mapExistingNameCumpSumMap.isEmpty() && !mapNameCumpSumMap.isEmpty()){
               for(Competitive_Summary_Mapping__c compSum: mapNameCumpSumMap.values()){
                   if(mapExistingNameCumpSumMap.containskey(compSum.Name)){
                        compSum.addError(Label.Comp_Summary_Error_Message);
                   }    
               }
           }
      }                     
}