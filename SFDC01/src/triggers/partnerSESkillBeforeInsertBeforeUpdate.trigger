/*============================================================================+
|  HISTORY |                                                                 
 |                                                                           
 |  DATE       DEVELOPER              WR               DESCRIPTION                               
 |  ====       =========              ==               =========== 
 |  14-Nov-11  Kaustav Debnath      178714            Initial Creation - this trigger is to populate the rating average fields
 |  13-Dec-11  Kaustav Debnath      178714            Updated code to populate ratings entered by PTC and rating date
                                                      fields for clones and original records |  
 |  06-Jan-12 Anand Sharma                            Added Latest_Modified_Skill_Rating__c field value as true                                                
 |  12-Jan-12 Kaustav Debnath                         Uncommented the updateRatingsEnteredAndDateFields method call at line 68
 |  23rd Jan 12  Kaustav Debnath   184063             as part of WR  added code for partner se skill validation rule to check 
                                                      creation of duplicate unvalidated records
 +===========================================================================*/
trigger partnerSESkillBeforeInsertBeforeUpdate on Partner_SE_Skill_Sales_Acumen_Rating__c (Before Insert,Before Update) {
  
    list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstToUpdateValidateFields = new list<Partner_SE_Skill_Sales_Acumen_Rating__c>(); 
    list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSalesAcumenToInsert = new list<Partner_SE_Skill_Sales_Acumen_Rating__c>();
    list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSalesAcumenToUpdate = new list<Partner_SE_Skill_Sales_Acumen_Rating__c>();
    Set<Id> contactIds= new Set<Id>();
    PRM_Partner_Leverage.calculateAverageRatings(Trigger.New);
    
    //for(Partner_SE_Skill_Sales_Acumen_Rating__c obj:trigger.new)
    
    if(trigger.isInsert){
        for(Integer i=0;i<Trigger.New.size();i++)
        {
            Trigger.New[i].Latest_Modified_Skill_Rating__c = true;
            if(Trigger.New[i].Ratings_Validated_by_Core_TC__c==true )
            {
                System.debug('### inside before trigger'+Trigger.New[i]);
                lstToUpdateValidateFields.add(Trigger.New[i]);
            }
            if(Trigger.New[i].Ratings_Validated_by_Core_TC__c==false 
               && Trigger.New[i].Parent_Partner_SE_Skill_Sales_Acumen__c==null)
            {
                lstSalesAcumenToInsert.add(Trigger.New[i]);
            }
            if(Trigger.New[i].Partner_SE__c != null && Trigger.New[i].Latest_Modified_Skill_Rating__c == true){
               contactIds.add(Trigger.New[i].Partner_SE__c);
            }  
        }
    }
    if(trigger.isUpdate){
        for(Integer i=0;i<Trigger.New.size();i++)
        {   if(Trigger.New[i].Latest_Modified_Skill_Rating__c == Trigger.Old[i].Latest_Modified_Skill_Rating__c){
                Trigger.New[i].Latest_Modified_Skill_Rating__c = true;
            }
            if(Trigger.New[i].Ratings_Validated_by_Core_TC__c==true && 
               Trigger.New[i].Ratings_Validated_by_Core_TC__c != Trigger.Old[i].Ratings_Validated_by_Core_TC__c)
            {
                System.debug('### inside before trigger'+Trigger.New[i]);
                lstToUpdateValidateFields.add(Trigger.New[i]);
            }
            if(Trigger.New[i].Ratings_Validated_by_Core_TC__c==false)
            {
                lstSalesAcumenToUpdate.add(Trigger.New[i]);
            }
            if(Trigger.New[i].Partner_SE__c != null && Trigger.New[i].Latest_Modified_Skill_Rating__c == true){
               contactIds.add(Trigger.New[i].Partner_SE__c);
            }  
        }
        if(contactIds.size() >0 && Trigger.NewMap.KeySet().size()>0){
        PRM_PartnerSESearchController.populateLastedModifiedSESkill(contactIds, Trigger.NewMap.KeySet());
        }
    }
     
        
     if(contactIds.size() >0 && Trigger.NewMap ==null){
        PRM_PartnerSESearchController.populateLastedModifiedSESkill(contactIds, null);
        }   
    if(lstSalesAcumenToInsert.size()>0 ){
         PRM_Partner_Leverage.updateRatingsEnteredAndDateFields(lstSalesAcumenToInsert,true);
    } 
    if(lstSalesAcumenToUpdate.size()>0 ){
         PRM_Partner_Leverage.updateRatingsEnteredAndDateFields(lstSalesAcumenToUpdate,false);
    } 
    if(lstToUpdateValidateFields!=null && lstToUpdateValidateFields.size()>0)
    {
        PRM_Partner_Leverage.updateValidationFields(lstToUpdateValidateFields);
    }
    
}