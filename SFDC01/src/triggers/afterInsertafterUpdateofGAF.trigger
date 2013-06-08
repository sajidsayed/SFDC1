/*===========================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER           WR      DESCRIPTION                               

 |  ====          =========           ==      =========== 

 |  15/03/2012    Anirudh Singh      188157   This trigger is used to perform all the Operations for GAF Object in case of
                                              before insert and before update of GAF Records. 
 |  27 April 2012 Arif                        Defect 804 Change of record type on change of 'Partner Type' or 'Theater'  
 |  29 June 2012  Anirudh Singh               Updated Invokation of setrecordTypeOnGAf() method for Status Change for Defect Fix.              
  +=========================================================================================================================*/
trigger afterInsertafterUpdateofGAF on GAF__c (after Insert,after Update) {
      PRM_GAF_Operations GAFOperationObj = new PRM_GAF_Operations();      
      List<GAF__c> lstDraftGaf= new List<GAF__c>();
      List<GAF__c> lstSubmittedGaf = new List<GAF__c>();
      List<GAF__c> lstApprovedGAf = new List<GAF__c>();
      if(trigger.isInsert){
         GAFOperationObj.setrecordTypeOnGAf(Trigger.New);
         for(GAF__c gafObj :Trigger.New){
            if(gafObj.GAF_Status__c=='EMC Submitted'){
               lstSubmittedGaf.add(gafObj); 
            }
            if(gafObj.GAF_Status__c=='Partner Approved'){
               lstApprovedGAf.add(gafObj); 
            }
         }       
      }
      if(trigger.isUpdate){
        for(GAF__c gafObj :Trigger.New){
             if((trigger.NewMap.get(GafObj.Id).GAF_Status__c !='Expired' && trigger.NewMap.get(GafObj.Id).GAF_Status__c !=Trigger.oldMap.get(GafObj.Id).GAF_Status__c)
                 ||(trigger.newmap.get(GafObj.Id).Partner_Theater__c != '' && trigger.newmap.get(GafObj.Id).Partner_Theater__c != null && trigger.newmap.get(GafObj.Id).Partner_Theater__c != Trigger.oldMap.get(GafObj.Id).Partner_Theater__c)
                 ||(trigger.newmap.get(GafObj.Id).Partner_Type__c != '' && trigger.newmap.get(GafObj.Id).Partner_Type__c != null && trigger.newmap.get(GafObj.Id).Partner_Type__c != Trigger.oldMap.get(GafObj.Id).Partner_Type__c)){
                lstDraftGaf.add(gafObj); 
             } 
             if((trigger.newmap.get(GafObj.Id).GAF_Status__c=='EMC Submitted') && trigger.NewMap.get(GafObj.Id).GAF_Status__c !=Trigger.oldMap.get(GafObj.Id).GAF_Status__c){
                lstSubmittedGaf.add(gafObj); 
             }
             if((trigger.newmap.get(GafObj.Id).GAF_Status__c!='Draft') && trigger.NewMap.get(GafObj.Id).Partner_GAF_Approver__c !=Trigger.oldMap.get(GafObj.Id).Partner_GAF_Approver__c && GafObj.Partner_GAF_Approver__c !=null){
                lstSubmittedGaf.add(gafObj); 
             }
             if(trigger.newmap.get(GafObj.Id).GAF_Status__c=='Partner Approved'  && trigger.NewMap.get(GafObj.Id).GAF_Status__c !=Trigger.oldMap.get(GafObj.Id).GAF_Status__c && GafObj.Partner_GAF_Approver__c !=null){
                lstApprovedGAf.add(gafObj); 
             } 
        }       
                  
      }
      if(lstDraftGaf.size()>0){
            GAFOperationObj.setrecordTypeOnGAf(lstDraftGaf);  
      }
      if(lstSubmittedGaf.size()>0){
            GAFOperationObj.createSharingForPartnerApprover(lstSubmittedGaf);  
      }
      if(lstApprovedGAf.size()>0){
            GAFOperationObj.updateApprovedGAFInternally(lstApprovedGAf);            
      }      
}