/***********************************************************************************************************************

 Name      Modified on       Description    
 Prasad K  7/8/2010          send notiifcation of onwer change
 Rajeev C  22/07/2010        make Lead Record visibility. 
 Ashwini   13/05/2011        Added for Deal Reg Functionality to populate
                             Field Reps.
 Anand     19/05/2011        Commented code Passed list to convertLeads method instead of set   
 Ashwini   14/07/2011        Added check to make sure reassignment doesnt happen untill Related Account is populated.
 Anil      21/09/2011        Lead Opportunity mapping      
 Anand     27/09/2011        Added dealUpdated field to check recursive call instead of extensionUpdated variable  
 Anand     29/09/2011        Updated Code to invoke updateApprovedDeal future call method to populate Approval Comments and to break 
                             the context of ApprovalProcess.    
 Anand      08/10/2011       Added method to create share record for Last EMC Owner : Req#2849      
 Arif       26/10/2011       Commented condition of DealReg_Create_New_Opportunity__c == false while calling 'updateApprovalDeal' method  
 Prasad     11/1/2011        Taken out the exp date,creatation date update on opp   
 Accenture  26/12/2011       Updated trigger to invoke ApprovedPartnerSEDealRegList() method of PRM_DealReg_Operations class 
                             whenever a Deal for Americas theater is Approved with a Partner SE on to it.
 22/01/2011      Accenture   Updated trigger to incorporate ByPass Logic 
 |                           NOTE: Please write all the code after BYPASS Logic
 24 April 2012  Arif                            Commented Codes for EMEA Decommision
 27 April 2012 Arif                      Deleted Codes for EMEA Decommission
 2 August 2012 Kaustav       Code added for eBusiness leads updated
 4 Oct    2012 Kaustav       Commented Code added for eBusiness leads updated
 10 Oct   2012 Sheriff       calculateNumberOfDealsforPartnerSE method call changed to a future call
 11 Dec 2012 Anirudh        196176      Uncommented eBusiness SFDC Integration related code. 
 ***********************************************************************************************************************/

trigger LeadAfterUpdate on Lead (after update) {
    //Trigger BYPASS Logic
 if(CustomSettingBypassLogic__c.getInstance()!=null){
 if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){ 
        return;
        }
 }    
  
   List<Lead> emeaSubmittedDealRegList = new List<Lead>(); 
   Set<Id> ApprovedPartnerSEDealRegSet = new Set<Id>(); 
   Set<Id> emeaSubmittedDealRegSet = new Set<Id>(); 
   List<Lead> emeaDealRegList = new List<Lead>();
   List<Lead> DealRegList = new List<Lead>();
   List<Lead> dealRegistrationForAutoApprovalList = new List<Lead>();
   Set<Id> leadIdsRejectedByFieldRepSet = new Set<Id>();
   PRM_DEALREG_ApprovalRouting dealRegApprovalProcess = new PRM_DEALREG_ApprovalRouting();
   PRM_DEALREG_SLACalculation SLAobj = new PRM_DEALREG_SLACalculation();
   List<Lead> DealRegSLAlist = new List<Lead>();
   List<Lead> ChangedOwnerDeals = New List<Lead>();
   Set<Id> emeaDealRegWithRelatedAccountSet = new Set<Id>(); 
   
   /*Code added for eBusiness SFDC Integration*/
     Map<Id,Lead> mapLeadTriggerNew=new Map<Id,Lead>();
     Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
     
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Source = (mapCustomSettingEBiz.get('Lead_Source'));           
        String str_eBiz_Lead_Source = eBus_Lead_Source.String_Values__c;
        
        for(Lead nextLead :trigger.new){
				System.debug('#### in after update lead trigger');
				System.debug('### nextLead.Lead_Originator__c=>'+nextLead.Lead_Originator__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Lead_Originator__c=>'+Trigger.oldMap.get(nextLead.id).Lead_Originator__c);
    	   		System.debug('### Util.iseBusinessLeadInsert=>'+Util.iseBusinessLeadInsert);
    	   		System.debug('### str_eBiz_Lead_Source=>'+str_eBiz_Lead_Source);
    	   		System.debug('### nextLead.eBus_RFQ_ID__c=>'+nextLead.eBus_RFQ_ID__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).eBus_RFQ_ID__c=>'+Trigger.oldMap.get(nextLead.id).eBus_RFQ_ID__c);
    	   		System.debug('### nextLead.Originator_Details__c=>'+nextLead.Originator_Details__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Originator_Details__c=>'+Trigger.oldMap.get(nextLead.id).Originator_Details__c);
    	   		System.debug('### nextLead.Date_Accepted__c=>'+nextLead.Date_Accepted__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Date_Accepted__c=>'+Trigger.oldMap.get(nextLead.id).Date_Accepted__c);
    	   		System.debug('### nextLead.Date_Rejected__c=>'+nextLead.Date_Rejected__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Date_Rejected__c=>'+Trigger.oldMap.get(nextLead.id).Date_Rejected__c);
			if(str_eBiz_Lead_Source!=null && 
        	nextLead.Lead_Originator__c!=null && 
    	    nextLead.Lead_Originator__c==Trigger.oldMap.get(nextLead.id).Lead_Originator__c &&
    	    nextLead.DealReg_Deal_Registration__c==false &&
    	    Util.iseBusinessLeadInsert==false &&
    	    nextLead.DealReg_Deal_Registration__c==Trigger.oldMap.get(nextLead.id).DealReg_Deal_Registration__c &&
    	    str_eBiz_Lead_Source.contains(nextLead.Lead_Originator__c.toLowerCase()) &&
    	    (nextLead.eBus_RFQ_ID__c!=Trigger.oldMap.get(nextLead.id).eBus_RFQ_ID__c ||
    	    nextLead.Originator_Details__c!=Trigger.oldMap.get(nextLead.id).Originator_Details__c ||
    	    nextLead.Date_Accepted__c!=Trigger.oldMap.get(nextLead.id).Date_Accepted__c ||
    	    nextLead.Date_Rejected__c!=Trigger.oldMap.get(nextLead.id).Date_Rejected__c ||
    	    nextLead.ownerid!=Trigger.oldMap.get(nextLead.id).ownerid ||
    	    nextLead.eBus_Lead_Owner_Email__c!=Trigger.oldMap.get(nextLead.id).eBus_Lead_Owner_Email__c ||
    	    nextLead.eBus_Lead_Owner_Phone__c!=Trigger.oldMap.get(nextLead.id).eBus_Lead_Owner_Phone__c ||
    	    nextLead.eBus_Lead_Status__c!=Trigger.oldMap.get(nextLead.id).eBus_Lead_Status__c ||
    	    nextLead.Lead_Number__c!=Trigger.oldMap.get(nextLead.id).Lead_Number__c 
    	    )
    	    )
    	    {
    	   		System.debug('### nextLead.Lead_Originator__c=>'+nextLead.Lead_Originator__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Lead_Originator__c=>'+Trigger.oldMap.get(nextLead.id).Lead_Originator__c);
    	   		System.debug('### str_eBiz_Lead_Source=>'+str_eBiz_Lead_Source);
    	   		System.debug('### nextLead.eBus_RFQ_ID__c=>'+nextLead.eBus_RFQ_ID__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).eBus_RFQ_ID__c=>'+Trigger.oldMap.get(nextLead.id).eBus_RFQ_ID__c);
    	   		System.debug('### nextLead.Originator_Details__c=>'+nextLead.Originator_Details__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Originator_Details__c=>'+Trigger.oldMap.get(nextLead.id).Originator_Details__c);
    	   		System.debug('### nextLead.Date_Accepted__c=>'+nextLead.Date_Accepted__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Date_Accepted__c=>'+Trigger.oldMap.get(nextLead.id).Date_Accepted__c);
    	   		System.debug('### nextLead.Date_Rejected__c=>'+nextLead.Date_Rejected__c);
    	   		System.debug('### Trigger.oldMap.get(nextLead.id).Date_Rejected__c=>'+Trigger.oldMap.get(nextLead.id).Date_Rejected__c);
    	   		mapLeadTriggerNew.put(nextLead.id,nextLead);    	   		
    	    } 
    	    
        }
         
    if(mapLeadTriggerNew!=null && mapLeadTriggerNew.size()>0)
    {
    	PRM_Lead_eBusiness_Integration leadEbizUpdate=new PRM_Lead_eBusiness_Integration();
    	leadEbizUpdate.updatedLeadEbusinessToLogTable(Trigger.newMap);
    }
  	
    /*End of Code added for eBusiness SFDC Integration*/
   
   emeaDealRegList = [Select Id, Name, DealReg_Deal_Registration_Status__c,OwnerId, Related_Account__c, Related_Account__r.Theater1__c,
                        Related_Account__r.Grouping__c,Original_Submission_Time__c, Related_Account__r.BillingCountry,DealReg_Approved_By_Field_Rep__c,
                        Tier_2_Partner__r.Grouping__c, Tier_2_Partner__r.BillingCountry,DealReg_Deal_Registration__c,
                        Partner__r.Grouping__c, Partner__r.BillingCountry,DealReg_Theater__c,Approval_Status__c,DealReg_PSC_Owner__c
                        From Lead
                        where id in: Trigger.newMap.keySet()];
   
   for(Lead emeaDealReg:emeaDealRegList){
        System.debug('emeaDealReg.DealReg_Deal_Registration_Status__c' + emeaDealReg.DealReg_Deal_Registration_Status__c);
        System.debug('emeaDealReg.DealReg_Theater__c' + emeaDealReg.DealReg_Theater__c);
        Lead oldDealReg = Trigger.oldMap.get(emeaDealReg.Id); 

        if(emeaDealReg.DealReg_Deal_Registration__c == true && emeaDealReg.Approval_Status__c=='Rejected By Field Rep' && 
            trigger.oldMap.get(emeaDealReg.Id).Approval_Status__c!='Rejected By Field Rep' && 
            emeaDealReg.DealReg_Deal_Registration_Status__c != 'PSC Declined' && emeaDealReg.DealReg_PSC_Owner__c!= Userinfo.getuserid()){
            leadIdsRejectedByFieldRepSet.add(emeaDealReg.id);
        }
        //Added for reassignment

        if(emeaDealReg.OwnerId !=oldDealReg.OwnerId && emeaDealReg.DealReg_Deal_Registration__c == true){
                ChangedOwnerDeals.add(emeaDealReg);  
        }
   }
   System.debug('emeaSubmittedDealRegList.size()---->'+emeaSubmittedDealRegList.size());
   System.debug('dealRegistrationForAutoApprovalList.size()---->'+dealRegistrationForAutoApprovalList.size());
   
   
   
   if(ChangedOwnerDeals.size()>0){
       dealRegApprovalProcess.createLeadShareForQueues(ChangedOwnerDeals);
   }

   //End of Deal Reg
    System.debug('#### PRM_CommonUtils.isOpportunityAfterUpdateExecuted---->'+PRM_CommonUtils.isOpportunityAfterUpdateExecuted);
    if(PRM_CommonUtils.isOpportunityAfterUpdateExecuted==true){
        return;
    }
    PRM_CommonUtils.isOpportunityAfterUpdateExecuted=true;
    
    Set<String> lead_To_Contact_Opp_Lst = new Set<String>();
    List<String> oppLst = new List<String>();
    List<String> filterLeadLst = new List<String>(); 
    
    // update the related Account records' lead counts
    AH_ChildObjectCounters.ProcessLeadUpdates(trigger.new, trigger.old);

    // make record level visibility
    PRM_PortalVisibility porVisObj = new PRM_PortalVisibility();
    porVisObj.setVisibility(trigger.oldMap,trigger.newMap);
    
    
    
    // if lead status =   and previous related_account ==null and current related account !=null
    for(Lead nextLead :trigger.new){
        if(nextLead.Related_opportunity__c==null && nextLead.DealReg_Deal_Registration__c ==false && nextLead.status =='Converted to Opportunity' && nextLead.Related_Account__c !=null &&  trigger.oldMap.get(nextLead.Id).Related_Account__c ==null)        
          {
                System.debug('*************point1' + nextLead.Id);
                lead_To_Contact_Opp_Lst.add(nextLead.Id);
                DealRegList.add(nextLead);
            }
        
    }
   
 
   for(String nextLeadId :lead_To_Contact_Opp_Lst)
       filterLeadLst.add(nextLeadId );
       
   System.debug('*************point2');
   
   // Change by anand on 23/05/2011
   if(filterLeadLst.size()>0)
       EMC_ConvertLead.convertLeads(DealRegList);
      // EMC_ConvertLead.convertLead1(filterLeadLst[0]);
        
    
  /*  // Added by prasad for Mail notification
    List<Lead>OnwerChanged = new list<Lead>();
    for(Lead newLead:trigger.newMap.values()){
        Lead oldLead= trigger.oldMap.get(newLead.id);
        //if(newLead.ownerId!=oldLead.ownerId){
            OnwerChanged.add(newLead);
        //}
    }
    if(OnwerChanged.size()>0){
      PRM_CommonUtils.sendEmailNotification(OnwerChanged);
    }
   */
    /*Added by Shalabh*/
    /*Checking opportunity field to true if linked to Deal Reg */
    PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations();
    Map<Id,Lead> mapNewLeads = new Map<Id,Lead>();
    Map<Id,Lead> mapLeads = new Map<Id,Lead>();
    List<Lead> rejectedLeadsList = new List<Lead>();
    Map<Id,Lead> mapLeadsForExpirationUpdate = new Map<Id,Lead>();
    
    for(Lead leads: trigger.newMap.values()){
        System.debug('Approval_Status__c-->'+leads.Approval_Status__c);
        if(leads.Related_Opportunity__c != trigger.oldMap.get(leads.Id).Related_Opportunity__c && leads.DealReg_Deal_Registration__c == true){
            mapNewLeads.put(leads.Id,leads);           
        }
        if((leads.Related_Opportunity__c != trigger.oldMap.get(leads.Id).Related_Opportunity__c || leads.DealReg_Partner_Expected_Close_Date__c != trigger.oldMap.get(leads.Id).DealReg_Partner_Expected_Close_Date__c|| 
            leads.DealReg_Partner_Notes__c != trigger.oldMap.get(leads.Id).DealReg_Partner_Notes__c || leads.DealReg_Partner_Probability__c != trigger.oldMap.get(leads.Id).DealReg_Partner_Probability__c ||
            leads.DealReg_Deal_Registration_Type__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Type__c || leads.DealReg_Deal_Registration_Status__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c ||
            leads.DealReg_Comments__c != trigger.oldMap.get(leads.Id).DealReg_Comments__c || leads.DealReg_Deal_Registration_Number__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Number__c ||
            leads.DealReg_Submission_Date__c != trigger.oldMap.get(leads.Id).DealReg_Submission_Date__c || leads.DealReg_PSC_Approval_Rejection_Date_Time__c != trigger.oldMap.get(leads.Id).DealReg_PSC_Approval_Rejection_Date_Time__c ||
            leads.DealReg_Expiration_Date__c != trigger.oldMap.get(leads.Id).DealReg_Expiration_Date__c || leads.DealReg_PSC_SLA_Expired__c != trigger.oldMap.get(leads.Id).DealReg_PSC_SLA_Expired__c ||
            leads.DealReg_PSC_SLA_Expire_On__c != trigger.oldMap.get(leads.Id).DealReg_PSC_SLA_Expire_On__c || leads.DealReg_Field_SLA_Expire_on__c != trigger.oldMap.get(leads.Id).DealReg_Field_SLA_Expire_on__c ||
            leads.DealReg_Field_SLA_Expired__c != trigger.oldMap.get(leads.Id).DealReg_Field_SLA_Expired__c || leads.DealReg_Deal_Description__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Description__c ||
            leads.DealReg_Expected_Deal_Value__c != trigger.oldMap.get(leads.Id).DealReg_Expected_Deal_Value__c || leads.DealReg_Expected_Close_Date__c != trigger.oldMap.get(leads.Id).DealReg_Expected_Close_Date__c ||
            leads.DealReg_Deal_Registration_Justification__c != trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Justification__c || leads.DealReg_Submission_Source__c != trigger.oldMap.get(leads.Id).DealReg_Submission_Source__c ||
            leads.Lead_Number__c != trigger.oldMap.get(leads.Id).Lead_Number__c || leads.DealReg_Partner_Deal_Value_Amount_Deal_L__c != trigger.oldMap.get(leads.Id).DealReg_Partner_Deal_Value_Amount_Deal_L__c) && (leads.DealReg_Deal_Registration__c == true)){
            mapLeads.put(leads.Id,leads);            
        }
       
        if(leads.DealReg_Deal_Registration_Status__c == 'PSC Declined' && 
        leads.DealReg_Deal_Registration_Status__c!=trigger.oldMap.get(leads.Id).DealReg_Deal_Registration_Status__c && 
        leads.Approval_Status__c!='Submitted By Field Rep'){
            rejectedLeadsList.add(leads);
        } 
        if(leads.Related_Opportunity__c != null && (leads.DealReg_Expiration_Date__c != trigger.oldMap.get(leads.Id).DealReg_Expiration_Date__c ) && leads.DealReg_Deal_Registration__c == true){
            mapLeadsForExpirationUpdate.put(leads.Id,leads);           
        }
    }
    
    System.debug('rejectedLeadsList-->'+rejectedLeadsList.size());
    if(mapNewLeads.values().size()>0){
        objDealReg.linktoDealReg(mapNewLeads,trigger.oldMap,true);
    }
    if(mapLeads.values()!=null){    
        objDealReg.populatePartnerJudgement(mapLeads,true);
    }
    
    if(rejectedLeadsList.size()>0){    
        objDealReg.ProcessRejectedLeads(rejectedLeadsList);
    } 
    /* Taking out as the fields are taken out
        if(mapLeadsForExpirationUpdate.size() >0){
      objDealReg.populateCreationAndExpirationDateofLeadONOpportunity(mapLeadsForExpirationUpdate);
    }*/
    
  /*  for(integer i=0;i<trigger.new.size();i++){
     if((trigger.new[i].DealReg_PSC_SLA_Expire_On__c != trigger.old[i].DealReg_PSC_SLA_Expire_On__c || trigger.new[i].DealReg_Field_SLA_Expire_on__c != trigger.old[i].DealReg_Field_SLA_Expire_on__c)&&
        (trigger.new[i].DealReg_PSC_SLA_Expire_On__c!=null ||trigger.new[i].DealReg_Field_SLA_Expire_on__c != null)){
          DealRegSLAlist.add(trigger.new[i]);
        }
    }
    if(DealRegSLAlist.size()>0){
       SLAobj.insertSLAExpirationRecord(DealRegSLAlist); 
    }  */
    Set<Id> setDeal = new Set<Id>();
    for(Lead dealReg: trigger.newMap.values()){     
        Lead oldLead = Trigger.oldMap.get(dealReg.Id); 
        if((dealReg.Related_Opportunity__c != null) 
            //&& dealReg.DealReg_Create_New_Opportunity__c == false 
            && dealReg.DealReg_Deal_Registration_Status__c == 'Approved' && oldLead.DealReg_Deal_Registration_Status__c =='Submitted'){
            setDeal.add(dealReg.id);
        }
        if(dealReg.DealReg_Deal_Registration_Status__c == 'Approved' && dealReg.DealReg_Deal_Registration_Status__c != oldLead.DealReg_Deal_Registration_Status__c 
           && dealReg.DealReg_Theater__c =='Americas' && dealReg.Partner_SE_Lookup__c !=null){
           ApprovedPartnerSEDealRegSet.add(dealReg.id);
        }
    }       
    
    if(setDeal.size() >0){        
        PRM_DEALREG_ApprovalRouting.updateApprovedDeal(setDeal);        
    }      
    if(ApprovedPartnerSEDealRegSet.size()>0){
        PRM_DealReg_Operations.calculateNumberOfDealsforPartnerSE(ApprovedPartnerSEDealRegSet);
    }
    //Added method to create share record for Last EMC Owner : Req#2849  
    PRM_PopulatePartnerOnLead.createLastEMCOwnerLeadShare(trigger.new);    
    
    objDealReg.UpdateScontrolConvert(trigger.new);
    
   }