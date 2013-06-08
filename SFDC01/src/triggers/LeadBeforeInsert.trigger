/*================================================================================
    Name                Date                WR          Description
    Prasad    -                                         This trigger hnadles only lead before insert event  
|   Anand Sharma        24/05/2011        req# .        Populate Theater on lead      
    Arif                18 Aug 2011                     Populate Related_Account_Populated_Date_Time__c,Approved_to_Closed_Expired_Date_Time__c etc fields
    22/01/2011      Accenture                           Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic
    Arif                26 June 2012      194177         Calling of method 'convertLeadtoDealReg'
|   Kaustav             1 August 2012     198481         eBusiness SFDC Integration related code                                                                                             
===================================================================================*/
trigger LeadBeforeInsert on Lead (before Insert) {
    //Trigger BYPASS Logic
  if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return; 
         }
  } 
    list<Lead> lstLeadForConvertingToDR = new list<Lead>();
    LeadBeforeUpdateTrigger leadTrigger = new LeadBeforeUpdateTrigger ();
    list<Lead> lstTosetPartnerOwnerEmail = new list<Lead>();
    leadTrigger.beforeInsert(trigger.new);
    /*Added by Shalabh*/
    /*Checking the Deal Reg checkbox*/
    PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations(); 
    
     //Anand Sharma: on 24/05/2011
    //Populate Theater value on lead
    objDealReg.populatedTheaterOnLead(trigger.new); 
    
    objDealReg.markDealReg(trigger.new,false); 
    objDealReg.populatePartnerOwnerEmailforDealReg(trigger.new);
    // mark track handoff
    objDealReg.dealRegMarkHandOfftoTrack(trigger.new,false);
    //PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations();
    /*if(trigger.newMap != null){
        objDealReg.populateDealSubmitterDetails(trigger.newMap,false);
    }*/
    
    /* Added By Arif   */
    PRM_DEALREG_PopulateDateTimeFields obj = new PRM_DEALREG_PopulateDateTimeFields();         
    obj.populateDateTimeFieldsOnInsert(trigger.new);
    
    /*Code added for eBusiness SFDC Integration*/
     Map<Id,Lead> mapLeadTriggerNew=new Map<Id,Lead>();
     Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
     
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Source = (mapCustomSettingEBiz.get('Lead_Source'));           
        String str_eBiz_Lead_Source = eBus_Lead_Source.String_Values__c;
    /*End of Code added for eBusiness SFDC Integration*/
    for(lead leadobj :trigger.new){
        if(leadobj.DealReg_Deal_Registration__c==true && 
            (leadobj.Partner__c!=null || leadObj.Tier_2_Partner__c!=null)){
             lstTosetPartnerOwnerEmail.add(leadobj);
        }
        if(leadobj.EMC_Convert_To_Deal_Reg__c){
            lstLeadForConvertingToDR.add(leadobj);
        }    
        /*Code added for eBusiness SFDC Integration*/
    	System.debug('#### inside create trigger');
    	if(str_eBiz_Lead_Source!=null && 
    	   leadobj.Lead_Originator__c!=null && 
    	   leadobj.DealReg_Deal_Registration__c==false &&
    	   str_eBiz_Lead_Source.contains(leadobj.Lead_Originator__c.toLowerCase()))
    	{
    		mapLeadTriggerNew.put(leadobj.id,leadobj);
    		
    	}
    	/*End of Code added for eBusiness SFDC Integration*/
        
    }
    /*Code added for eBusiness SFDC Integration*/
    if(mapLeadTriggerNew!=null && mapLeadTriggerNew.size()>0)
    {
    	PRM_Lead_eBusiness_Integration leadEBizObj=new PRM_Lead_eBusiness_Integration();
    	leadEBizObj.updateLeadEBusinessFields(mapLeadTriggerNew,'Insert');
    }
    /*End of Code added for eBusiness SFDC Integration*/
    if(lstLeadForConvertingToDR.size()>0){
        PRM_InsertDeleteGroupMembers insertDelGrpMem = new PRM_InsertDeleteGroupMembers();
        insertDelGrpMem.convertLeadtoDealReg(lstLeadForConvertingToDR,true);
    }
    if(lstTosetPartnerOwnerEmail.size()>0){
        objDealReg.populatePartnerOwnerEmailforDealReg(lstTosetPartnerOwnerEmail);
    }
    
  }