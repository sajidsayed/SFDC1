/*=============================================================================================================================+
|  HISTORY |                                                                 
 |                                                                           
 |  DATE       DEVELOPER              WR               DESCRIPTION                               
 |  ====       =========              ==               =========== 
 |  14-Nov-11  Kaustav Debnath      178714            Initial Creation - this trigger is to populate the rating average fields
|  13-Dec-11  Kaustav Debnath      178714            Updated the code as per code review comments to remove Trigger.Old to 
                                                      Trigger.New comparison condition
  
 |  06-Jan-12 Anand Sharma                            Added method populateLastedModifiedSESkill to Latest_Modified_Skill_Rating__c field value as false  
 |  13-Jan-12 Kaustav Debnath                         Commented the method populateLastedModifiedSESkill and the if loop  
 +=============================================================================================================================*/
trigger partnerSESkillAfterInsertAfterUpdate on Partner_SE_Skill_Sales_Acumen_Rating__c (after insert, after update) {
    
    
    list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstToMakeCopy = new list<Partner_SE_Skill_Sales_Acumen_Rating__c>();
    
    //list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstToUpdateValidateFields = new list<Partner_SE_Skill_Sales_Acumen_Rating__c>();
    
    Set<Id> contactIds= new Set<Id>();
        for(Integer i=0;i<Trigger.New.size();i++)
        {
            if(Trigger.IsUpdate && Trigger.New[i]!=Trigger.Old[i])
            {
                if(Trigger.New[i].Validated_By__c!=null && Trigger.New[i].Validated_By__c != Trigger.Old[i].Validated_By__c 
                    && Trigger.New[i].Validation_Date__c!=null  && Trigger.New[i].Validation_Date__c != Trigger.Old[i].Validation_Date__c)
                {
                    System.debug('### inside after trigger=>'+Trigger.New[i]);
                    lstToMakeCopy.add(Trigger.New[i]); 
                }
            }
            if(Trigger.IsInsert)
            {
                if(Trigger.New[i].Validated_By__c!=null && Trigger.New[i].Validation_Date__c!=null)
                {
                    System.debug('### inside after trigger=>'+Trigger.New[i]);
                    lstToMakeCopy.add(Trigger.New[i]); 
                }
            }
            
            if(Trigger.New[i].Partner_SE__c != null && Trigger.New[i].Latest_Modified_Skill_Rating__c == true){
                contactIds.add(Trigger.New[i].Partner_SE__c);
            }
            
        }
        
        //if(contactIds.size() >0){
            //PRM_PartnerSESearchController.populateLastedModifiedSESkill(contactIds, Trigger.NewMap.KeySet());
        //}
        
        if(lstToMakeCopy!=null && lstToMakeCopy.size()>0)
        {
            PRM_Partner_Leverage.partnerSEAcumenCopy(lstToMakeCopy);
        } 
      
    
    
}