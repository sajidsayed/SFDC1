/*===============================================================================================================
| Developer        DATE       WR        Description    
| Prasad    -                           This trigger hnadles only lead before update event  
| Ashwini                               Added check to stop rejection of a DR if PSC Owner is blank. 
| Ashwini                               Updated Trigger for Auto Approval by Field Reps   
| Ashwini Gowda                         Added logic to send notifications when DR or ER is approved or
                                        Rejected by Field Rep/Direct Rep to rest of Reps.  
| Ashwini Gowda                         Added check to make sure reassignment doesnt happen untill Related Account is populated and
                                        SLA is not hit.  
| Ashwini Gowda                         Updated for ReAssignment.    
| Ashwini Gowda                         Added check to clear DealReg_Approved_By_Field_Rep__c once DR is Approved By Field Rep for resubmission.  
| Ashwini Gowda                         Added Check to stop Expiration Date change Notification when PSC Updates Expiration Date in UI.   
| Arif            18 Aug 211            Populate Related_Account_Populated_Date_Time__c,Approved_to_Closed_Expired_Date_Time__c etc fields 
| Anirudh Singh   12/09/2011            Updated trigger to invoke to clearDealRegDateTimeFields method to
                                        nullify date/time fields for Deal Reg Resubmission.  
| Ashwini Gowda                         Added Check to stop Expiration Date change Notification when Sys Admin Updates Expiration Date in UI.
| Suman B        14/10/2011             Added condition to avoid resubmission of DealReg if DealReg_Not_Valid_for_Resubmission__c
| Anirudh Singh  18/10/2011             Added condition to throw error if Pre-Sales Fields are blank while submitting Deal for Approval. 
 Arif            26/10/2011             Set 'IsPortalInsert' as false if its value is true(got set if DR is inserted on selection of account)
 Arif            3 Nov 2011             Calling of dealRegMarkHandOfftoTrack method for checking 'Handoff To Track' checkbox
 Arif            14 Nov 2011            178752      To Calculate the difference in first Approval/Rej and First Submission of DR in hours
 22/01/2011      Accenture              Updated trigger to incorporate ByPass Logic
 |                                      NOTE: Please write all the code after BYPASS Logic
 24 April 2012  Arif                            Commented Codes for EMEA Decommision
 27 April 2012 Arif                      Deleted Codes for EMEA Decommission
 5 June 2012   Arif                     Called a method 'convertLeadtoDealReg' to convert a lead to DR if 'EMC Convert to Deal Reg' checbox is checked. 
 22 June 2012  Kaustav                  WR 194177 Added code to check the lead owner is partner user for inside sales/SMB user to be able to submit
                                        a DR 
 28 June 2012  Arif         IM8046862(197027) Commented call of 'populateDateTimeFieldsOnUpdate' method as now it will be called from 'LeadAccept' trigger(to replace order issue)
 1 August 2012 Kaustav      198481      eBusiness SFDC Integration related code
 17 Sep   2012  Avinash K   201385      Added a query to get the Lead Owner's isActive field value and throw an error if the
                                        User tries to convert the Lead to Opportunity by changing the Related Opportunity
                                        value of the Lead when Lead Owner is Inactive
 9/20/2012   Krishna Pydavula 201503    Added Validation for phone field. 
 3 Oct 2012  Avinash K      201385      Moved the Inactive Lead Error Message to a custom label and used it in the code      
 4 Oct 2012 Kaustav         198481      Commented eBusiness SFDC Integration related code  
 11 Dec 2012 Anirudh        196176      Uncommented eBusiness SFDC Integration related code. 
 18 Jan 2013 Vivek			WR 220442   updated Lead Owner while partner Reject the Lead
 25 Feb 2013 Vivek			WR 220442   updated Lead Owner while partner Reject the Lead
 17 Apr 2013 Krishna        WR 243649   Calling the method "populatedTheaterOnLead" to update the theater.
============================================================================================================================*/
trigger LeadBeforeUpdate on Lead(before update) {   
    //Trigger BYPASS Logic
 if(CustomSettingBypassLogic__c.getInstance()!=null){
 if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
        return;
 }
 }
 system.debug('LeadBeforeUpdate ----------->' +trigger.new[0].OwnerId);
     system.debug('LeadBeforeUpdate ----------->' +trigger.new[0].Accept_Lead__c); 
 System.Debug('Testing Trigger.new Size--->' +Trigger.new.size());
 System.Debug('Testing Trigger.oldSize--->' +Trigger.old.size());

     /*Code added for WR# 201503*/
        for(lead objlead: Trigger.new)
        {
            system.debug('objlead.Phone == '+objlead.Phone);
            if((objlead.DealReg_Theater__c=='EMEA'||objlead.DealReg_Theater__c=='Americas') && (objlead.DealReg_Deal_Registration_Status__c=='Submitted' && objlead.Phone==null))
            {
                objlead.Phone.adderror('Customer Phone number is mandatory for EMEA and Americas partners.');
            }   
       }
   /*End of Code added for WR# 201503*/
   
     Lead[] lds = Trigger.new;
     Lead[] oldTrg = Trigger.old;
     List<Lead> ResubmittedDeals= new List<Lead>();   
      LeadBeforeUpdateTrigger leadTrigger = new LeadBeforeUpdateTrigger (); 
      leadTrigger.beforeUpdate(Trigger.oldMap,Trigger.newMap );
      List<Lead> DealstoUpdateProductsList = new List<Lead>();
      List<Lead> lstClosedLostDeals = new  List<Lead>();
      List<Lead> lstDealstoUpdateDROwnerEmail = new  List<Lead>();
      list<Lead> lstLead = new list<Lead>();
      list<Lead> lstLeadForConvertingToDR = new list<Lead>();
      String Errormessage; 
      PRM_LeadRejection leadRejection = new PRM_LeadRejection();       
      if(trigger.isUpdate){
          //Included for Lead Rejection Functionality:         
         Map<Id,String> errorMap = leadRejection.ownerAssignment(lds);         
         Set<Id> RejectedLeadIds = errorMap.KeySet();         
         if(RejectedLeadIds.size()>0){
             for(Id RejectedLeadId: RejectedLeadIds){
                 Errormessage = errorMap.get(RejectedLeadId);
                 Lead lead = Trigger.newMap.get(RejectedLeadId);
                 lead.addError(Errormessage);
             }
         }     
      } 
    /*Added by Shalabh*/
    /*Auto populating deal submitter section fields */
    PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations();
    objDealReg.populatedTheaterOnLead(trigger.new);  //Added by Krishna for WR 243649 
    objDealReg.dealRegMarkHandOfftoTrack(trigger.new,false);
    objDealReg.populateDealSubmitterDetails(trigger.newMap,trigger.oldMap,false);
        
    PRM_DEALREG_ApprovalRouting approvalRouting = new PRM_DEALREG_ApprovalRouting();
    approvalRouting.createLeadShareOnReAssignmentForQueues(trigger.newMap,trigger.oldMap);
    
    Map<Id,Lead> dealsApprovedByFieldRepMap = new Map<Id,Lead>();
    Map<Id,Lead> dealsRejectedByFieldRepMap = new Map<Id,Lead>();
    
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    String AdminUsers = DataValueMap.get('Admin Users').DataValue__c;
    
    String userProfile = Userinfo.getProfileId();
    if(userProfile != null && userProfile.length() >15){
        userProfile = userProfile.substring(0, 15);
    }
    /* WR 194177 code added to check if lead owner is partner user*/
     PRM_CommonUtils utils = new PRM_CommonUtils();
     Map<Id,User> isPartner = new Map<Id,User>();
     list<Id> isPartnerId = new list<Id>();
     for(lead l: Trigger.new ){    
            if(((string)l.OwnerId).startswith('005')){
                isPartnerId.add(l.ownerId);
            }
     }
     isPartner = utils.userDetails(isPartnerId);
     /*end of WR 194177 code added to check if lead owner is partner user*/
    /*Added validation if Related Account or PSC Owner is blank*/
    
//Code added by Avinash begins below for WR# 201385..

    Set<Id> setLeadOwner = new Set<Id>();
    Map<Id,User> mapIdUser;

    for(Lead l : Trigger.New)
    {
        if (Trigger.OldMap.get(l.id).Related_Opportunity__c == null && l.Related_Opportunity__c != null) 
        {
            setLeadOwner.add(l.OwnerId);  
        }
      
    }

    if(setLeadOwner.size() > 0)
        mapIdUser = new Map<Id,User>([Select id, isActive 
                                                From User
                                                Where isActive = false AND Id in :setLeadOwner
                                                Limit 50000]);

// Code added by Avinash ends above.


    for(Lead leads: trigger.new){
        system.debug('DealReg submission ##########');
        
//Code added by Avinash begins below for WR# 201385..

        if (mapIdUser != null && mapIdUser.keyset().size() > 0 && mapIdUser.containsKey(leads.OwnerId) &&
            Trigger.OldMap.get(leads.id).Related_Opportunity__c == null &&
            Trigger.NewMap.get(leads.id).Related_Opportunity__c != null) 
        {
            leads.addError(System.Label.Inactive_Lead_Owner_Error_Message);
        }

//Code by Avinash ends above.


        //added by Arif(26 Oct 2011)
        if(leads.IsPortalInsert__c && !PRM_DEALREG_CustomSearch.flag){
            leads.IsPortalInsert__c = false;
        }
        //Added by Suman oct-14
        if(leads.DealReg_Deal_Registration__c == true &&leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c 
            && (leads.DealReg_Not_Valid_for_Resubmission__c == true && leads.DealReg_Deal_Registration_Status__c == 'Submitted')){
            leads.addError(System.label.DealReg_Not_Valid_for_Resubmission);
            system.debug(System.label.DealReg_Not_Valid_for_Resubmission +'---' + leads.DealReg_Deal_Registration_Status__c);
        }
        
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Approved' && 
            leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c &&
             leads.Related_Account__c == null && UserInfo.getUserType()!= 'PowerPartner'){
            leads.addError(System.label.Related_Account_blank);
        }
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Approved' && 
            leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c && 
            leads.DealReg_PSC_Owner__c == null && UserInfo.getUserType()!= 'PowerPartner'){
            leads.addError(System.label.PSC_owner_is_blank);
        }
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'PSC Declined' && 
            leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c && 
            leads.DealReg_PSC_Owner__c == null && UserInfo.getUserType()!= 'PowerPartner' && leads.DealReg_Theater__c!='EMEA'){
            leads.addError(System.label.PSC_owner_is_blank);
        }
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Approved' && 
            leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c 
            && leads.DealReg_PSC_Owner__c == null){
            leads.addError(System.Label.Accept_Deal_Reg_Button_before_Approving_or_Rejecting);
        }
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'PSC Declined' && 
            leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c && 
            leads.DealReg_PSC_Owner__c == null && leads.DealReg_Theater__c!='EMEA'){
            leads.addError(System.Label.Accept_Deal_Reg_Button_before_Approving_or_Rejecting);
        }            
        if ( leads.DealReg_Deal_Registration__c == true && (
            ( leads.DealReg_Deal_Registration_Status__c != Trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c  &&    
              leads.DealReg_Deal_Registration_Status__c == 'Submitted' 
            ) || 
             leads.DealReg_Of_Registration_Products__c != Trigger.oldMap.get(leads.Id).DealReg_Of_Registration_Products__c) ){
                DealstoUpdateProductsList.add(leads);        
        }
        if (leads.DealReg_Deal_Registration__c == true && (leads.Approval_Status__c != Trigger.oldMap.get(leads.Id).Approval_Status__c ) && 
          leads.DealReg_Deal_Registration_Status__c == 'Submitted' && leads.Approval_Status__c == 'Approved By Field Rep' && 
          leads.DealReg_Theater__c=='EMEA') {
                dealsApprovedByFieldRepMap.put(leads.id,leads);        
        }
        if (leads.DealReg_Deal_Registration__c == true && (leads.Approval_Status__c != Trigger.oldMap.get(leads.Id).Approval_Status__c ) && 
          leads.DealReg_Deal_Registration_Status__c == 'Submitted' && leads.Approval_Status__c == 'Rejected By Field Rep' && 
          leads.DealReg_Theater__c=='EMEA') {
                dealsRejectedByFieldRepMap.put(leads.id,leads);        
        }
        //Added for reassignment

        if (leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Submitted' && 
          leads.Related_Account__c!= null && trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c!= 'Submitted' &&
          leads.DealReg_Theater__c=='EMEA' && leads.Approval_Status__c != 'Submitted By Field Rep') {
            leads.Approval_Status__c = 'Submitted By Field Rep';        
        }
        //Added check to clear DealReg_Approved_By_Field_Rep__c
        /* WR 194177 Added to check whether the deal reg owner is a power partner user or not*/
        if(isPartner.containsKey(leads.OwnerId))
        {
            if (leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Submitted' && 
              //leads.Related_Account__c!= null && 
              trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c!= 'Submitted' &&
              leads.Approval_Status__c == 'Submitted By Field Rep' && isPartner.get(leads.ownerid).UserType != 'PowerPartner'
              && leads.DealReg_Submission_Source__c != 'Powerlink') {
                leads.addError(System.Label.Owner_Not_a_Partner_User);        
            }
        }
        /*end of WR 194177 code Added to check whether the deal reg owner is a power partner user or not*/
        //Added Check to stop Expiration Date change Notification
        if(leads.DealReg_Deal_Registration__c == true && (DataValueMap.ContainsKey(leads.DealReg_Theater__c) && 
            (DataValueMap.get(leads.DealReg_Theater__c) != null) && (DataValueMap.get(leads.DealReg_Theater__c).DataValue__c != null)
            && DataValueMap.get(leads.DealReg_Theater__c).DataValue__c.contains(userProfile) || AdminUsers.contains(userProfile)) && 
            leads.DealReg_Expiration_Date__c != trigger.oldMap.get(leads.Id).DealReg_Expiration_Date__c
            && !PRM_DEALREG_ApprovalRouting.isexecuted){
            leads.DealReg_Expiration_Date_changed_By_PSC__c = false; 
        }
        /*if(leads.DealReg_Deal_Registration__c == true && (DataValueMap.ContainsKey(leads.DealReg_Theater__c) && 
            (DataValueMap.get(leads.DealReg_Theater__c) != null) && (DataValueMap.get(leads.DealReg_Theater__c).DataValue__c != null)
            && !(DataValueMap.get(leads.DealReg_Theater__c).DataValue__c.contains(userProfile)) || !AdminUsers.contains(userProfile)) && 
            leads.DealReg_Expiration_Date__c != trigger.oldMap.get(leads.Id).DealReg_Expiration_Date__c){
            leads.DealReg_Expiration_Date_changed_By_PSC__c = false;
        }*/
        if(leads.DealReg_Deal_Registration__c == true && 
           leads.DealReg_Partner_Probability__c !=trigger.oldMap.get(leads.Id).DealReg_Partner_Probability__c &&
           leads.DealReg_Partner_Probability__c =='Deal Lost'){
           lstClosedLostDeals.add(leads);
        }
        if(leads.DealReg_Deal_Registration__c == true && 
           (((leads.Partner__c !=null && leads.Partner__c != trigger.oldMap.get(leads.Id).Partner__c) ||
           (leads.Tier_2_Partner__c !=null && leads.Tier_2_Partner__c!= trigger.oldMap.get(leads.Id).Tier_2_Partner__c)))){
           lstDealstoUpdateDROwnerEmail.add(leads);
        }
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Submitted' && trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c!='Submitted'){
           ResubmittedDeals.add(leads);                                 
        }
        /*
        if(leads.DealReg_Deal_Registration__c == true && leads.DealReg_Deal_Registration_Status__c == 'Submitted' && 
            leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c 
            && leads.DealReg_Theater__c=='Americas'
            && (leads.DealReg_Pre_Sales_Engineer_Email__c == null || leads.DealReg_Pre_Sales_Engineer_Name__c == null ||
            leads.DealReg_Pre_Sales_Engineer_Phone__c == null || leads.DealReg_EMCTA_Certified_Email__c == null)){
            leads.addError(System.Label.Pre_Sales_Information_Is_Required);
        }*/ 
        //Added By Arif WR 178752
        if(leads.DealReg_Deal_Registration__c == true && 
            leads.DealReg_Theater__c == 'Americas' && leads.DealReg_PSC_Approval_Rejection_Date_Time__c != null && 
            leads.DealReg_PSC_Approval_Rejection_Date_Time__c != trigger.oldMap.get(leads.Id).DealReg_PSC_Approval_Rejection_Date_Time__c){
            lstLead.add(leads); 
        }
        
        if(leads.EMC_Convert_To_Deal_Reg__c && !trigger.oldMap.get(leads.Id).EMC_Convert_To_Deal_Reg__c){
            lstLeadForConvertingToDR.add(leads);
        }          
    }
    /*Code added for eBusiness SFDC Integration*/
     Map<Id,Lead> mapLeadTriggerNew=new Map<Id,Lead>();
     Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
     
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Source = (mapCustomSettingEBiz.get('Lead_Source'));           
        String str_eBiz_Lead_Source = eBus_Lead_Source.String_Values__c;
    
    for(Integer i=0;i<Trigger.new.size();i++)
    {
        if(str_eBiz_Lead_Source!=null && 
           Trigger.new[i].Lead_Originator__c!=null && 
           Trigger.new[i].eBus_RFQ_ID__c != null &&
           Trigger.new[i].Lead_Originator__c==Trigger.old[i].Lead_Originator__c &&
           Trigger.new[i].DealReg_Deal_Registration__c==false &&
           Trigger.new[i].DealReg_Deal_Registration__c==Trigger.old[i].DealReg_Deal_Registration__c &&
           str_eBiz_Lead_Source.contains(Trigger.new[i].Lead_Originator__c.toLowerCase()) &&
           Trigger.new[i].eBus_RFQ_ID__c==Trigger.old[i].eBus_RFQ_ID__c &&         
             (Trigger.new[i].ownerid!=Trigger.old[i].ownerid ||
              Trigger.new[i].eBus_Lead_Status__c != Trigger.old[i].eBus_Lead_Status__c||
              Trigger.new[i].Accept_Lead__c != Trigger.old[i].Accept_Lead__c ||
              Trigger.new[i].EMC_Lead_Rejected__c != Trigger.old[i].EMC_Lead_Rejected__c
             )
           )
        {
            System.debug('### in eBiz code');
            mapLeadTriggerNew.put(Trigger.new[i].id,Trigger.new[i]);
            
        }
    }
    if(mapLeadTriggerNew!=null && mapLeadTriggerNew.size()>0)
    {
        PRM_Lead_eBusiness_Integration leadEBizObj=new PRM_Lead_eBusiness_Integration();
        leadEBizObj.updateLeadEBusinessFields(mapLeadTriggerNew,'Update');
    }    
    /*End of Code added for eBusiness SFDC Integration*/
    if(lstLeadForConvertingToDR.size()>0){
        PRM_InsertDeleteGroupMembers obj = new PRM_InsertDeleteGroupMembers();
        obj.convertLeadtoDealReg(lstLeadForConvertingToDR,false);
    }    
    if(lstLead.size()>0){
        approvalRouting.populateDiffOfOriginalAppRejAndSub(lstLead);
    }
    if(DealstoUpdateProductsList.size()>0){
        new PRM_DealReg_Operations().populateRegProducts(DealstoUpdateProductsList );
    } 
    if(lstDealstoUpdateDROwnerEmail.size()>0){
        new PRM_DealReg_Operations().populatePartnerOwnerEmailforDealReg(lstDealstoUpdateDROwnerEmail);
    }
    if(!PRM_DealReg_Operations.recordProcessed){
        PRM_DealReg_Operations.recordProcessed = true;
    }
     
    //DR Resubmission
    if(ResubmittedDeals.size()>0){
       PRM_DEALREG_PopulateDateTimeFields PopDtFieldsObj = new PRM_DEALREG_PopulateDateTimeFields();
       PopDtFieldsObj.clearDealRegDateTimeFields(ResubmittedDeals); 
    } 
    // Track handoff           
    new PRM_DealReg_Operations().setRelatedAccount(Trigger.oldMap, Trigger.newMap);    
        
    PRM_DEALREG_SLACalculation  obj = new PRM_DEALREG_SLACalculation ();  
    obj.slaCalculation(Trigger.NewMap,Trigger.OldMap);
    
    /* Added By Arif   */
    PRM_DEALREG_PopulateDateTimeFields PopDtFieldsObj = new PRM_DEALREG_PopulateDateTimeFields();
   // PopDtFieldsObj.populateDateTimeFieldsOnUpdate(trigger.oldMap,trigger.newMap);
    if(lstClosedLostDeals.size()>0){
    PopDtFieldsObj.updateClosedlostDR(lstClosedLostDeals);
    }
    //WR 220442
      boolean rejectedByPartner = false;
      if(trigger.isUpdate){ 
			for(Integer i=0;i<Trigger.new.size();i++) {
				Lead updatedLead = Trigger.new[i];
				Lead existingLead = Trigger.old[i];
				//(updatedLead.OwnerId == existingLead.OwnerId)  &&
				System.debug('updatedLead'+updatedLead+'existingLead'+existingLead);
				if  ( (isPartner.containsKey(updatedLead .OwnerId)) &&
				      (updatedLead.Accept_Lead__c != updatedLead.EMC_Lead_Rejected__c) &&
				      (updatedLead.EMC_Lead_Rejected__c != existingLead.EMC_Lead_Rejected__c) &&
				      (updatedLead.EMC_Lead_Rejected__c == true) ) {
					//rejectedByPartner  = true;
					 leadRejection.partnerRejection(Trigger.new, Trigger.old);
				}
				//if (rejectedByPartner == true) {
				  
				//}
			}
     }
    //End
  }