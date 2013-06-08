/*

 Name               Modified on       Description 
 Rajeev C           22/07/2010        Modify to make Lead Record visibility. 
 Shipra Misra       06.12.2010        WR-151285 Add Install Base flag to Leads - Updated trigger to update/flag all Leads 
                                      where Related Account is marked as Install Base 
 Shipra Misra       17.01.2011        Added variable Tst data"isLeadInsertUpdateExecuted" to handle recurrsive call  
11/1/2011     PRasad                  taken out the exp date,creatation date update on opp
22/01/2011    Accenture               Updated trigger to incorporate ByPass Logic
|                                     NOTE: Please write all the code after BYPASS Logic
|15.05.2012   Anirudh                 Updated trigger to invoke cloneRegistrationProduct() method of
                                      PRM_Clone_Deal_Registration class for all the cloned Deals.    
****************************************************************************************************************/

trigger LeadAfterInsert on Lead (after insert) {
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
     }
    List<Lead> lstClonedDeal = new List<Lead>();  
    if(!Util.isLeadInsertUpdateExecuted){       
        Util.isLeadInsertUpdateExecuted = true;
        //Shipra on 06/12/2010 to update install base on lead.
        //Hold Set Of Lead Id's.
        Set<Id> leadIdSet= new Set<Id>();
        for(Lead leadUpdate:trigger.new)
        {
            if(leadUpdate.Related_Account__c!=null)
            {
                leadIdSet.add(leadUpdate.id);
            }       
        }
        if(leadIdSet.size()>0)
        {
                Acc_updateInstallBaseAccount.updateInstallBaseAccountFromLeadCallFuture(leadIdSet);
        }
        //End of Code Update By Shipra.
        
        // increment the related Account records' lead counts
        AH_ChildObjectCounters.ProcessLeadInserts(trigger.new);
         // make record level visibility
        PRM_PortalVisibility porVisObj = new PRM_PortalVisibility();
        porVisObj.setVisibility(trigger.oldMap,trigger.newMap);
        
        
    }
       /*Added by Shalabh*/
    /*Checking opportunity field to true if linked to Deal Reg*/
    PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations();
    Map<Id,Lead> mapNewLeads = new Map<Id,Lead>();
    for(Lead leads: trigger.new){
        if(leads.Related_Opportunity__c != null && leads.DealReg_Deal_Registration__c == true){
            mapNewLeads.put(leads.Id,leads);
        }
        if(leads.Parent_Deal_Registration__c!= null && leads.DealReg_Deal_Registration__c == true){
            lstClonedDeal.add(leads);
        }      
    }
    objDealReg.linktoDealReg(mapNewLeads,trigger.oldMap,true);
    if(lstClonedDeal.size()>0){
       PRM_Clone_Deal_Registration cloneDealObj = new PRM_Clone_Deal_Registration();
       cloneDealObj.cloneRegistrationProduct(lstClonedDeal);
    }
    // taking out as no fields has been removed from opportunity
    //objDealReg.populateCreationAndExpirationDateofLeadONOpportunity(mapNewLeads) ;     
 }