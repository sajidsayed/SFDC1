/*============================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                                 

 |  ====          =========         ==       =========== 

 |  17/05/2011    Ashwini Gowda              Trigger to populate Field Reps for Extension request for EMEA.  
    12/07/2011    Ashwini Gowda              Added check to make sure reassignment doesnt happen untill 
 |                                           Related Account is populated.  
    28/07/2011    Ashwini Gowda    2329      This will prevent auto-approval of any extension requests when 
 |                                           Do Not allow extension request is checked.  
    14/10/2011    Arif             177289    Called method 'updateDealRegExpirationFlag' which is written in PRM_DealReg_Operations class    
    28 Dec 2011   Arif             WR 184320 Calling method 'populateFieldsOnERWhileCreation' which is written in PRM_DealReg_Operations class 
    20 Jan 2012   Arif        WR 184320      Calling method setCommentsOnRejectedER for populating comment field on ER on rejection.
    24 April 2012  Arif                            Commented Codes for EMEA Decommision
    27 April 2012 Arif                      Deleted Codes for EMEA Decommission   
    10 Nov 2012   Suresh D		  WR205624	 Modified the code to handle Deal Regs Approved before and after 1 Jan 2013.
     
    ## Test Classes: PRM_DEALREG_ApprovalRouting_TC     
 +==============================================================================================================*/

trigger afterUpdateOfExtensionRequest on Extension_Request__c (after update,before insert) {
    if(Trigger.isUpdate){
        List<Extension_Request__c> submittedExtensionRequestList = new List<Extension_Request__c>();
        List<Extension_Request__c> extensionRequestForApprovalList = new List<Extension_Request__c>();   
        List<Extension_Request__c> emeaExtensionRequestList = new List<Extension_Request__c>();
        List<Extension_Request__c> approvedExtensionRequestList = new List<Extension_Request__c>();
        List<Extension_Request__c> submittedRequestList = new List<Extension_Request__c>();
        List<Extension_Request__c> rejectedExtensionRequestList = new List<Extension_Request__c>();
        List<Extension_Request__c> extensionRequestList = new List<Extension_Request__c>();
        Set<Id> emeaSubmittedERSet = new Set<Id>(); 
        Set<Id> extensionIdsRejectedByFieldRepSet = new Set<Id>();
    	Set<Id> setRejectedERId = new Set<Id>();
        //Set<Id> emeaExtensionsWithRelatedAccountSet = new Set<Id>();
               
        emeaExtensionRequestList = [Select e.Approved_By_EMEA_Field_Rep__c, e.Deal_Registration__c, e.Deal_Registration__r.Id, 
                                   e.Deal_Registration__r.Related_Account__c, e.Extension_Request_Status__c, e.Id,e.Deal_Registration__r.DealReg_Theater__c, 
                                   e.Deal_Registration__r.Related_Account__r.Theater1__c,e.Deal_Registration__r.Related_Account__r.Grouping__c,
                                   e.Deal_Registration__r.Related_Account__r.BillingCountry,e.Deal_Registration__r.Tier_2_Partner__r.Grouping__c,    
                                   e.Deal_Registration__r.Tier_2_Partner__r.BillingCountry,e.Deal_Registration__r.Partner__r.Grouping__c, Approval_Status__c,
                                   e.Deal_Registration__r.Partner__r.BillingCountry,e.Deal_Registration__r.DealReg_of_Extension_Requests__c,
                                   e.Deal_Registration__r.DealReg_Do_Not_Allow_Extension_Request__c,
                                   e.Deal_Registration__r.DealReg_PSC_Approval_Rejection_Date_Time__c
                                   from Extension_Request__c e
                                   where id in: Trigger.newMap.keySet()];
        
        for(Extension_Request__c emeaExtensionReqst:emeaExtensionRequestList){
            System.debug('emeaExtensionReqst.Extension_Request_Status__c' + emeaExtensionReqst.Extension_Request_Status__c);
            System.debug('Theater1__c' + emeaExtensionReqst.Deal_Registration__r.DealReg_Theater__c);
            System.debug('DealReg_of_Extension_Requests__c' + emeaExtensionReqst.Deal_Registration__r.DealReg_of_Extension_Requests__c);
            System.debug('DealReg_Do_Not_Allow_Extension_Request__c' + emeaExtensionReqst.Deal_Registration__r.DealReg_Do_Not_Allow_Extension_Request__c);
            Extension_Request__c oldExtension = Trigger.oldMap.get(emeaExtensionReqst.Id); 

            if(emeaExtensionReqst.Extension_Request_Status__c=='Submitted' && oldExtension.Extension_Request_Status__c!='Submitted'
            && emeaExtensionReqst.Deal_Registration__c!=null && 
            emeaExtensionReqst.Deal_Registration__r.DealReg_Theater__c!=null && 
            (emeaExtensionReqst.Deal_Registration__r.DealReg_Theater__c == 'EMEA' || 
            emeaExtensionReqst.Deal_Registration__r.DealReg_Theater__c == 'APJ')&&  
            emeaExtensionReqst.Deal_Registration__r.DealReg_of_Extension_Requests__c<1 && 
            emeaExtensionReqst.Deal_Registration__r.DealReg_Do_Not_Allow_Extension_Request__c==false){
                extensionRequestForApprovalList.add(emeaExtensionReqst);
            }
            if(emeaExtensionReqst.Extension_Request_Status__c=='Approved' && oldExtension.Extension_Request_Status__c!='Approved' && 
            emeaExtensionReqst.Deal_Registration__c!=null){
                approvedExtensionRequestList.add(emeaExtensionReqst);
            }
            if(emeaExtensionReqst.Extension_Request_Status__c=='Submitted' &&  oldExtension.Extension_Request_Status__c != 'Submitted' && 
            emeaExtensionReqst.Deal_Registration__c!=null){
                submittedRequestList.add(emeaExtensionReqst);
            }

        }
        System.debug('submittedRequestList.size()---->' +submittedRequestList.size());
        System.debug('submittedExtensionRequestList.size()---->'+submittedExtensionRequestList.size());
        System.debug('approvedExtensionRequestList.size()---->'+approvedExtensionRequestList.size());
        System.debug('extensionRequestForApprovalList.size()---->'+extensionRequestForApprovalList.size());
        System.debug('extensionRequestList.size()---->'+extensionRequestList.size());
        System.debug('extensionIdsRejectedByFieldRepSet.size()---->'+extensionIdsRejectedByFieldRepSet.size());
        //System.debug('emeaExtensionsWithRelatedAccountSet.size()---->'+emeaExtensionsWithRelatedAccountSet.size());
                
        if(!PRM_DEALREG_ApprovalRouting.extensionUpdated){
            PRM_DEALREG_ApprovalRouting.extensionUpdated = true; 
            Map<String,Deal_Reg_Approval_Date_Check__c> approvalDates = Deal_Reg_Approval_Date_Check__c.getall();
       		Date approvalDate = approvalDates.get('Deal Reg Approval Date').Approval_Date__c;    
            System.debug('Approval date is ---->'+approvalDate);
	        	if(extensionRequestForApprovalList.size()>0){
  					Set<Id> setExtnIds = new Set<Id>();
  					for(Extension_Request__c objEtxn: extensionRequestForApprovalList){
  						if(objEtxn.Deal_Registration__r.DealReg_PSC_Approval_Rejection_Date_Time__c < approvalDate && System.Today() < approvalDate){
  							System.debug('DealReg_Deal_Approved_Date__c date is ---->'+objEtxn.Deal_Registration__r.DealReg_PSC_Approval_Rejection_Date_Time__c);
  							setExtnIds.add(objEtxn.Id);
  						}
      				}
      				if(setExtnIds.size() > 0){
      					System.debug('setExtnIds.size() is ---->'+setExtnIds.size());
      					PRM_DEALREG_ApprovalRouting.autoApproveExtensionForAPjEMEA(setExtnIds);
      				}
		    	}
      
          if(submittedRequestList.size()>0){
              PRM_DEALREG_ApprovalRouting.calculateNOOfExtensions(submittedRequestList);
          }
 
        }
        
        if(approvedExtensionRequestList.size()>0){
            PRM_DEALREG_ApprovalRouting.extendExpirationDate(approvedExtensionRequestList);
            PRM_DEALREG_ApprovalRouting.isexecuted=true;
        } 
        
        //added by Arif(14/10/2011)(177289)        
        PRM_DealReg_Operations obj = new PRM_DealReg_Operations();
        obj.updateDealRegExpirationFlag(Trigger.newMap,Trigger.oldMap); 
    
        for(Extension_Request__c er: Trigger.New){
            if(er.Extension_Request_Status__c == 'PSC Declined' && er.Extension_Request_Status__c != Trigger.OldMap.get(er.Id).Extension_Request_Status__c){
                  setRejectedERId.add(er.Id);
            }
        }
        if(setRejectedERId.size()>0){
            PRM_DealReg_Operations.setCommentsOnRejectedER(setRejectedERId);
        }
     }    
     //WR 184320
     if(Trigger.isInsert){
        PRM_DealReg_Operations obj = new PRM_DealReg_Operations();
        obj.populateFieldsOnERWhileCreation(Trigger.new);
     }
         
}