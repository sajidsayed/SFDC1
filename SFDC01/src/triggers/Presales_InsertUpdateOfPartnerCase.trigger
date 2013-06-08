/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 26/04/2012    Leonard Victor            This trigger is used for populating Partner Related Fields on Case
 | 30/05/2012    Leonard Victor            Updated trigger to include partner case creation through SFDC system
 +==================================================================================================================**/



trigger Presales_InsertUpdateOfPartnerCase on Case (before insert, before update) {
      public static List<Case> lstNewCases = new List<Case>();
  
      public static Boolean updateGrp = false;
      public List<Id> partnerCase = new List<Id>();
      Presales_PartnerCaseOperation prtObj = new Presales_PartnerCaseOperation();
       Presales_CheckRecordType objCheckRecordType = new Presales_CheckRecordType();
       lstNewCases = objCheckRecordType.checkRecordType(trigger.new);
       if(lstNewCases!=null && lstNewCases.size()>0){
        
        
        if(trigger.isInsert){

              for(Case csLoop : lstNewCases){

                if(csLoop.Partner_Grouping_Name__c!=null){
                  partnerCase.add(csLoop.Partner_Grouping_Name__c);
              }     
              }
            
            if(lstNewCases.size()>0){
            prtObj.insertPartner(lstNewCases ,updateGrp, partnerCase);
            }
            
        }
        
        
      if(trigger.isUpdate){
        
        for(Case caseLoop : lstNewCases){
        
        if(caseLoop.Partner_Grouping_Name__c!=trigger.oldMap.get(caseLoop.id).Partner_Grouping_Name__c){
            updateGrp = true;
            partnerCase.add(caseLoop.Partner_Grouping_Name__c);
        System.debug('Inside Grouping Update Case');    

            
        }
        
        else if(caseLoop.Contact_Email1__c!=trigger.oldMap.get(caseLoop.id).Contact_Email1__c || caseLoop.ContactId!=trigger.oldMap.get(caseLoop.id).ContactId){
             updateGrp = false;
            partnerCase.add(caseLoop.Partner_Grouping_Name__c);
        }
            
                
        }
        
            if(partnerCase.size()>0){
            prtObj.insertPartner(lstNewCases ,updateGrp, partnerCase);
            }

      }
      

       }

}