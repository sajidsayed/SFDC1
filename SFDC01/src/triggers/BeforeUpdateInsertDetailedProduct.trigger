/*===================================================================================================================================
|
|History 
|Date             Developer Name    WR        Details 
|----             --------------    --        -------
|14 January 2012  Anirudh Singh     219167    This trigger is used to invoke calculateTotalCompetency() of EMC_Consulting_Operations 
|                                             class
====================================================================================================================================*/
trigger BeforeUpdateInsertDetailedProduct on Detailed_Product__c (before update,before insert) {
    
    list<Detailed_Product__c> lstDetailedProductToProcess = new list<Detailed_Product__c>();

    for (Detailed_Product__c newDP : Trigger.new) {
        if(Trigger.IsUpdate && Trigger.Old != Trigger.New){
                if(newDP.Total_Competency__c != null ){
                    newDP.Is_Total_Competency_Updated__c = True; 
                }               
                Detailed_Product__c oldDP=Trigger.oldMap.get(newDP.ID);
                if(oldDP.Sub_Practice_1_Dollar__c != newDP.Sub_Practice_1_Dollar__c ||
                oldDP.Sub_Practice_2_Dollar__c != newDP.Sub_Practice_2_Dollar__c ||
                oldDP.Sub_Practice_3_Dollar__c != newDP.Sub_Practice_3_Dollar__c ||
                oldDP.Sub_Practice_4_Dollar__c != newDP.Sub_Practice_4_Dollar__c ||
                oldDP.Sub_Practice_5_Dollar__c != newDP.Sub_Practice_5_Dollar__c)
                {
                  lstDetailedProductToProcess.add(newDP);
                } 
        }
        else{
          newDP.Is_Total_Competency_Updated__c = False;  
        }   
      if(Trigger.IsInsert){
           if(newDP.Sub_Practice_1_Dollar__c != null || newDP.Sub_Practice_2_Dollar__c !=null ||
              newDP.Sub_Practice_3_Dollar__c != null || newDP.Sub_Practice_4_Dollar__c !=null ||
              newDP.Sub_Practice_5_Dollar__c !=null )
            {   
              lstDetailedProductToProcess.add(newDP);   
            }
      }
    }
    if(lstDetailedProductToProcess.size()>0){
        new EMC_Consulting_Operations().calculateTotalCompetency(lstDetailedProductToProcess);
    }
}