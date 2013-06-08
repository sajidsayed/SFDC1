/*============================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                                  

 |  ====          =========         ==       =========== 

 |  03/05/2011    Ashwini Gowda     2338     Trigger to calulate "# of Extension Requests" and calculate and
                                             set the Expiration date upon extension of a Deal Reg.     
    1/7/2011      Ashwini Gowda             Added logic to send notifications when DR or ER is approved or
                                            Rejected by Field Rep/Direct Rep to rest of Reps.  
    7 Feb 2012    Arif             185856   Calling setSubmissionORApprRejDate method of PRM_DealReg_Operations class 
    24 April 2012  Arif                            Commented Codes for EMEA Decommision
    27 April 2012 Arif                      Deleted Codes for EMEA Decommission                      
 +==============================================================================================================*/
trigger beforeUpdateOfExtensionRequest on Extension_Request__c (before update) {
    PRM_DEALREG_ApprovalRouting extensionRequest = new PRM_DEALREG_ApprovalRouting();
    extensionRequest.createExtensionShareForQueues(trigger.NewMap,trigger.oldMap);
    PRM_DEALREG_SLACalculation slaCalculationForExtension = new PRM_DEALREG_SLACalculation();
    slaCalculationForExtension.slaCalculationForExtensionRequest(trigger.newMap,trigger.oldMap);     
    list<Extension_Request__c> lstER = new list<Extension_Request__c>();
    Map<Id,Extension_Request__c> extensionApprovedByFieldRepMap = new Map<Id,Extension_Request__c>();
    Map<Id,Extension_Request__c> extensionRejectedByFieldRepMap = new Map<Id,Extension_Request__c>();
    Map<Id,Extension_Request__c> extensionRequestSubmittedMap = new Map<Id,Extension_Request__c>([Select e.Deal_Registration__c, e.Deal_Registration__r.Id, e.Extension_Request_Status__c, e.Id, e.Approval_Status__c, e.Deal_Registration__r.DealReg_Deal_Registration_Status__c                                
                                                                                                  from Extension_Request__c e where id in: Trigger.newMap.keySet()]);  
     for(Extension_Request__c extensionReq: trigger.New){
        System.debug('Deal_Registration__c-->'+extensionReq.Deal_Registration__c);
        System.debug('Approval_Status__c-->'+extensionReq.Approval_Status__c);
        System.debug('Extension_Request_Status__c-->'+extensionReq.Extension_Request_Status__c);
        System.debug('DealReg_Country__c-->'+extensionReq.DealReg_Country__c);
      
    //185856
    if(extensionReq.Extension_Request_Status__c != Trigger.oldMap.get(extensionReq.Id).Extension_Request_Status__c &&
       extensionReq.Deal_Registration__c != null &&
       (extensionReq.Extension_Request_Status__c == 'Submitted' || extensionReq.Extension_Request_Status__c == 'Approved' ||
        extensionReq.Extension_Request_Status__c == 'PSC Declined')){
        lstER.add(extensionReq);
        } 
    if((extensionRequestSubmittedMap.get(extensionReq.id).Deal_Registration__r.DealReg_Deal_Registration_Status__c == 'New' || extensionRequestSubmittedMap.get(extensionReq.id).Deal_Registration__r.DealReg_Deal_Registration_Status__c == 'Closed-Won') && extensionReq.Extension_Request_Status__c == 'Submitted'){
         extensionReq.addError(System.Label.Extension_Request_Cannot_be_Submitted);
         }
  
     }
    System.debug('extensionApprovedByFieldRepMap-->'+extensionApprovedByFieldRepMap.size());
    System.debug('extensionRejectedByFieldRepMap-->'+extensionRejectedByFieldRepMap.size());
    
    //185856
    if(lstER.size()>0){
        PRM_DealReg_Operations obj = new PRM_DealReg_Operations();
    obj.setSubmissionORApprRejDate(lstER);
    }


            
     
              
}