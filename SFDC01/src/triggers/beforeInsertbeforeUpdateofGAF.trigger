/*=========================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER           WR      DESCRIPTION                               

 |  ====          =========           ==      =========== 

 |  27/02/2012    Anirudh Singh               This trigger is used to perform all the Operations for GAF Object in case of
                                              before insert and before update of GAF Records. 
 |  06/07/2012    Anirudh Singh               Bypassed the Expired Gaf exception throw logic for Change Owner Functionality.                                                    
  +=========================================================================================================================*/
trigger beforeInsertbeforeUpdateofGAF on GAF__c (before Insert,before Update) {
    PRM_GAF_Operations GAFOperationObj = new PRM_GAF_Operations();
    List<GAF__c> GaftoValidate = new List<GAF__c>();
    List<GAF__c> lstSubmittedGAF= new List<GAF__c>();
    List<GAF__c> lstDraftGaf= new List<GAF__c>();
    List<GAF__c> lstApprovedGAF= new List<GAF__c>();
    List<GAF__c> lstGAFToShare= new List<GAF__c>();
    if(trigger.isInsert){
       GAFOperationObj.validateGAF(Trigger.New);       
       for(Gaf__c gafObj :Trigger.New){
           if(GafObj.GAF_Status__c=='EMC Submitted'){
              lstSubmittedGAF.add(GafObj);  
           }
       }
    }
    if(trigger.isUpdate){
       for(GAF__c gafObj :Trigger.New){
           if(GafObj.Year__c != Trigger.oldMap.get(GafObj.Id).Year__c){
              GaftoValidate.add(GafObj);               
           }
           if(trigger.OldMap.get(GafObj.Id).GAF_Status__c=='Expired' && trigger.New !=Trigger.Old && trigger.NewMap.get(GafObj.Id).OwnerId== trigger.OldMap.get(GafObj.Id).OwnerId){
              GafObj.adderror(System.Label.You_are_not_authorized_to_update_a_Expired_GAF); 
           }
           if(trigger.newmap.get(GafObj.Id).GAF_Status__c=='Draft' && trigger.NewMap.get(GafObj.Id).GAF_Status__c !=Trigger.oldMap.get(GafObj.Id).GAF_Status__c){
              lstDraftGaf.add(gafObj); 
           }
           if(GafObj.GAF_Status__c=='EMC Submitted' && GafObj.GAF_Status__c!=trigger.OldMap.get(GafObj.Id).GAF_Status__c && GafObj.Partner_GAF_Approver__c !=null){
              lstSubmittedGAF.add(GafObj); 
           }
           if(GafObj.GAF_Status__c != 'Draft' && GafObj.Partner_GAF_Approver__c!=trigger.OldMap.get(GafObj.Id).Partner_GAF_Approver__c && GafObj.Partner_GAF_Approver__c !=null){
              lstGAFToShare.add(GafObj); 
           }
           if(GafObj.GAF_Status__c=='Partner Approved' && GafObj.GAF_Status__c!=trigger.OldMap.get(GafObj.Id).GAF_Status__c){
              lstApprovedGAF.add(GafObj); 
           }
       }    
    }
    if(GaftoValidate.size()>0){
       GAFOperationObj.validateGAF(GaftoValidate); 
    }
    if(lstSubmittedGAF.size()>0){
       GAFOperationObj.setSubmittedByInfoOnGAF(lstSubmittedGAF); 
    }
    if(lstDraftGaf.size()>0){
       GAFOperationObj.updateGAFforResubmission(lstDraftGaf); 
    }
    if(lstGAFToShare.size()>0){
       GAFOperationObj.deleteSharingforPartnerUsers(lstGAFToShare); 
    }     
    if(lstGAFToShare.size()>0){
       GAFOperationObj.createSharingForPartnerApprover(lstGAFToShare); 
    }
}