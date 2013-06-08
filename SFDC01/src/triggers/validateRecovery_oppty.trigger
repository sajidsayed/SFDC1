trigger validateRecovery_oppty on Recovery_Opportunity__c (before insert, before update) {
    Transformation_recovery_oppty rObj = new Transformation_recovery_oppty();
    List<Recovery_Opportunity__c> lstRec = new List<Recovery_Opportunity__c>();
    if(trigger.isBefore ){
        if(trigger.isInsert){ 
                rObj.validateOpptyExistance(trigger.new);
        }
        if(trigger.isUpdate){ 
            for(Recovery_Opportunity__c rOpptyObj : Trigger.new){
            if((rOpptyObj.Opportunity_Name__c!=null && (rOpptyObj.Opportunity_Name__c != trigger.oldMap.get(rOpptyObj.id).Opportunity_Name__c))){
                 lstRec.add(rOpptyObj);
                 }
            }
            if(lstRec.size() > 0){
                rObj.validateOpptyExistance(lstRec);
            }
        }
          
      }
  
    
}