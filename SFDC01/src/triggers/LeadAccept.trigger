/**********************************************************************************************************************************

 Name               Modified on    WR#      Description
 ====                =======       ===      ========     
 Ashwini Gowda      28/4/2011               Modified to create New Opportunity when deal reg is approved and if no Opportunity in the 
                                            Related Opportunity field and "Create New Opportunity" is checked.    
 Ashwini Gowda      29/4/2011               Create share to grant edit access to respective PSC User Queue based on Theater when
                                            a lead is submitted for approval.
 Anand Sharma       19/05/2011              req# 2278.DR is accepted with no related opportunity, and “Create New Opportunity” not checked,
                                            Display error: “Create New Opportunity checkbox should be checked to create a new Opportunity”.  
Ashwini Gowda       14/07/2011              Updated for ReAssignment and fix for recurrsive call.     
Anirudh Singh       22/09/2011              Updated trigger to invoke updateRelatedAccountFieldsOnDR method to populate
                                            Account Category field on Deal Reg based upon Related Account  
Suman B             28/12/2011    WR-181921 Updated the condition for setting the CAM on DR - userIdForCAMsMap
                                            Added conditon to check if the Owner of the DR is changed,so to reflect the corresponding CAM.   
Accenture           29/12/2011    WR#183080 Updated logic to invoke createLeadShareForQueues() for Deal Registration if Deal Reg Owner is changed.
22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                        NOTE: Please write all the code after BYPASS Logic

Arif             16 April 2012    WR 185023 Added code for change in status of lead to 'Converted to Opportunity' when any oppty manualy associated to DR 
Arif             28 June 2012     IM8046862(197027) Added call of 'populateDateTimeFieldsOnUpdate' method     
Vivek	         17 Dec 2012      WR# 206404 and WR# 207171 Lead Pull Back and Deal Reg Pull   
Vivek	         17 Dec 2012      WR# 252201 and WR# 225313 Workflow move to the trigger and lead passtopartner set to false     
                                                                                                                                                                                                                                                                 
***********************************************************************************************************************************/
trigger LeadAccept on Lead (before update,before insert) {
    //Trigger BYPASS Logic      
  if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
        return;
  }
  system.debug('LeadAccept ----------->' +trigger.new[0].OwnerId);
     system.debug('LeadAccept ----------->' +trigger.new[0].Accept_Lead__c);   
    List<lead> DealsToPopulateRelatedAccountField = new List<lead>();
    List<lead> lstLeadSLA = new List<lead>();
    PRM_DealReg_Operations objDealReg1 = new PRM_DealReg_Operations(); 
    if(trigger.isInsert){
        MAP_LeadAccept.setAcceptFlag(trigger.new);
        for(lead leadobj :trigger.new){
            if(leadobj.Related_Account__c !=null){
               DealsToPopulateRelatedAccountField.add(leadobj);
            }   
        }
        if(DealsToPopulateRelatedAccountField.size()>0){
            objDealReg1.updateRelatedAccountFieldsOnDR(DealsToPopulateRelatedAccountField);
        }
    }
    else{         
        MAP_LeadAccept.UpdateAcceptFlag(trigger.old, trigger.new); 
        //Added for PRM Deal Reg
        List<String> dealRegIdsList = new List<String>();
        List<Lead> dealRegsList = new List<Lead>();
        List<Lead> submittedDealRegList = new List<Lead>();
        List<Lead> approvedDealRegistrationList = new List<Lead>();
        List<Id> submittedDealRegIdsList = new List<Id>();
        //Distributor/Direct Reseller and Distribution VAR fields are synced between the Deal Reg and the Opportunity
        List<Lead> lstLeadWithProduct = new List<Lead>();
        List<Lead> lstLeadWithoutOpportunity = new List<Lead>();
        List<Lead> lstLead = new List<Lead>();
        Map<Id,Lead> userIdForCAMsMap = new Map<Id,Lead>();
        PRM_DEALREG_ApprovalRouting approvalRouting = new PRM_DEALREG_ApprovalRouting();
        //List<Lead> leadsRejectedByFieldRepList = new List<Lead>();
        
        /*Checking the Deal Reg checkbox*/
        PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations(); 
        objDealReg.markDealReg(trigger.new,false);
        
        String AdminConversionIds;
        Map<String,CustomSettingDataValueMap__c>  dataValueMap =  CustomSettingDataValueMap__c.getall();
        if(dataValueMap.containsKey('AdminConversionId')){
            AdminConversionIds = dataValueMap.get('AdminConversionId').DataValue__c;
        }
        String userProfile = UserInfo.getProfileId();
        
        if(userProfile != null && userProfile.length() >15){
            userProfile = userProfile.substring(0, 15);
        }        
              
        for(Lead dealReg: trigger.new){
            Lead newLead = Trigger.newMap.get(dealReg.Id);
            Lead oldLead = Trigger.oldMap.get(dealReg.Id); 
            System.debug('dealReg-->'+dealReg.DealReg_Deal_Registration_Status__c);
            System.debug('dealReg Related_Opportunity__c-->'+dealReg.Related_Opportunity__c);
            
            if((dealReg.Related_Opportunity__c == null) && 
                dealReg.DealReg_Create_New_Opportunity__c == true 
                && dealReg.DealReg_Deal_Registration_Status__c == 'Approved' && oldLead.DealReg_Deal_Registration_Status__c!='Approved'){
                dealRegIdsList.add(dealReg.id);
                dealRegsList.add(dealReg);
            }
            
            /*  Added  By Arif WR 185023  */
            if(dealReg.Related_Opportunity__c != null &&
               dealReg.DealReg_Create_New_Opportunity__c == false && 
               dealReg.DealReg_Deal_Registration_Status__c == 'Approved' && 
               oldLead.DealReg_Deal_Registration_Status__c!='Approved' &&
               dealReg.DealReg_Deal_Registration__c == true){
                   dealReg.Status = 'Converted to Opportunity';
                   
            }       
                      
            if((dealReg.DealReg_Deal_Registration_Status__c == 'Submitted' && oldLead.DealReg_Deal_Registration_Status__c!='Submitted')||
               (dealReg.OwnerId !=oldLead.OwnerId) && dealReg.DealReg_Deal_Registration__c == true){
                submittedDealRegList.add(dealReg);  
            }
            /** Added for WR-181921 **/
            if( (dealReg.DealReg_Deal_Registration_Status__c == 'Submitted' && oldLead.DealReg_Deal_Registration_Status__c!='Submitted') ||
                ( (dealReg.OwnerId != oldLead.ownerId) && ((String)dealReg.OwnerId).startswith('005') ) && 
                  (dealReg.DealReg_Deal_Registration_Status__c == 'Submitted') ||(dealReg.DealReg_Deal_Registration_Status__c == 'Approved') ){ 
                  userIdForCAMsMap.put(dealReg.OwnerId,dealReg);
            }
                                    
            if(dealReg.DealReg_Deal_Registration_Status__c == 'Approved' && oldLead.DealReg_Deal_Registration_Status__c!='Approved'){
                approvedDealRegistrationList.add(dealReg);                    
            }             
            //add by Anand Sharma 0n 19/05/2011
            //Display Error: Create New Opportunity checkbox should be checked to create a new Opportunity
            if((dealReg.Related_Opportunity__c == null) && dealReg.DealReg_Deal_Registration_Status__c == 'Approved' && 
            dealReg.DealReg_Create_New_Opportunity__c == false && dealReg.DealReg_Deal_Registration__c == true && ( ! AdminConversionIds.contains(userProfile))){
                dealReg.addError(System.Label.Deal_Conversion_Error);
            }
            if(dealReg.DealReg_Deal_Registration__c==true && (dealReg.Related_Account__c != oldLead.Related_Account__c)){
               DealsToPopulateRelatedAccountField.add(dealReg);
            }
                                   
        } 
        System.debug('approvedDealRegistrationList-->'+approvedDealRegistrationList.size());
        System.debug('dealRegIdsList-->'+dealRegIdsList.size());
        System.debug('submittedDealRegList-->'+submittedDealRegList.size());                       
        
        //System.debug('leadsRejectedByFieldRepList-->'+leadsRejectedByFieldRepList.size());
        
        // Anand Sharma 18/05/2011 
        if(!PRM_DEALREG_RegistrationConversion.LeadAccept){
            PRM_DEALREG_RegistrationConversion.LeadAccept = true;
            for(Lead dealReg: trigger.new){
                Lead newLead = Trigger.newMap.get(dealReg.Id);
                Lead oldLead = Trigger.oldMap.get(dealReg.Id);
                if((newLead.Related_Opportunity__c != oldLead.Related_Opportunity__c) 
                        && dealReg.Related_Opportunity__c != null && dealReg.DealReg_Deal_Registration__c == true){
                    lstLeadWithProduct.add(dealReg);
                }
            }
            System.debug('lstLeadWithProduct-->'+lstLeadWithProduct.size()); 
            //one Deal Registrations from getting linked to one Opportunity
            PRM_DEALREG_RegistrationConversion.validateRelatedOpportunity(lstLeadWithProduct);
            //Distributor/Direct Reseller and Distribution VAR fields are synced between the Deal Reg and the Opportunity
            PRM_DEALREG_RegistrationConversion.syncDealRelatedOpportunity(lstLeadWithProduct);
        }
        
        //End 
                
        if(dealRegIdsList.size()>0){
            EMC_ConvertLead.convertLeads(dealRegsList);
        }
        if(submittedDealRegList.size()>0){
            approvalRouting.createLeadShareForQueues(submittedDealRegList);
        }            
        if(approvedDealRegistrationList.size()>0){
            approvalRouting.autoPopulateExpirationDate(trigger.NewMap,trigger.oldMap);
        }        
        for(Id newLeadId: Trigger.newMap.keySet()){        
            Lead newLead = Trigger.newMap.get(newLeadId);
            Lead oldLead = Trigger.oldMap.get(newLeadId);
            if((newLead.DealReg_Deal_Registration_Status__c != oldLead.DealReg_Deal_Registration_Status__c )){            
                if(oldLead.DealReg_Deal_Registration_Status__c =='Submitted' && newLead.DealReg_Deal_Registration_Status__c =='PSC Declined'){
                    if(newLead.DealReg_Rejection_Reason__c ==null || newLead.DealReg_Rejection_Reason__c ==''){
                        newLead.addError(System.Label.Rejection_reason_before_Rejecting);
                    }
                }
            }              
        }            
        //End of Added for PRM Deal Reg 
        for(Lead dealReg: Trigger.new){ 
            if(dealReg.DealReg_Deal_Registration_Status__c=='Approved' && dealReg.DealReg_Deal_Registration__c == true && 
                dealReg.Related_Opportunity__c!=null && dealReg.Related_Opportunity__c != trigger.oldMap.get(dealReg.Id).Related_Opportunity__c){
                    lstLead.add(dealReg);
            }
            if(dealReg.DealReg_Deal_Registration__c == false){
                lstLeadSLA.add(dealReg);
            }
            
        }
         
        if(lstLead.size()>0){
            objDealReg1.populateOpptyOwnerOnLead(lstLead); 
        } 
        if(userIdForCAMsMap.size()>0){
            objDealReg1.populateChannelManagerOnLead(userIdForCAMsMap);
        }
        if(DealsToPopulateRelatedAccountField.size()>0){
            objDealReg1.updateRelatedAccountFieldsOnDR(DealsToPopulateRelatedAccountField);
        }
        
        PRM_DEALREG_PopulateDateTimeFields PopDtFieldsObj = new PRM_DEALREG_PopulateDateTimeFields();
        PopDtFieldsObj.populateDateTimeFieldsOnUpdate(trigger.oldMap,trigger.newMap);
    }
    
      Set<id> checkids = new Set<id>();
      for(Lead setownerid:trigger.new){
        checkids.add(setownerid.OwnerId);
      }
      public static Map <id,User> objPartneruser = new Map<id,User>([Select u.id,u.name, u.UserType From User u where u.IsActive=true and u.id in:checkids and u.usertype like '%partner%']);
     	
     	
      if(!Test.isRunningTest()){
        if(lstLeadSLA.size() >0){
	        PRM_DEALREG_PopulateDateTimeFields PopDtFieldsObjnew = new PRM_DEALREG_PopulateDateTimeFields();
	        PRM_PopulatePartnerOnLead objpopulateData = new PRM_PopulatePartnerOnLead();
	        //WR# 206404
	        PopDtFieldsObjnew.populateSLAforPassToPartner(trigger.new,objPartneruser);       
	        //WR# 207171
	        PopDtFieldsObjnew.populateSLAforAcceptedLead(trigger.new,objPartneruser);
	        objpopulateData.UpdateOwnerforLeadPullback(trigger.new);
		    objpopulateData.UpdateOwnerforDealReg(trigger.new);		    
		    
		    PopDtFieldsObjnew.UpdateLeadStatus(trigger.new);
		    
         }
         PRM_PopulatePartnerOnLead.setPassToPartnerFlagOnLeadwithpartner(trigger.new);
    	}    	
    	
    	
    
         
  }