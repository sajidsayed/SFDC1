/*=============================================================================+ 

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 23/7/2010       Rajeev Choudhary               This class will be called by LeadAfterUpdate and LeadAfterInsert  Triggers on Lead.
 
 | 07/09/2010      Anand Sharma                   Create association record only when lead owner is partner type or Queue.
 
 | 30/06/2011      Anirudh Singh                  Updated setVisibility Method to Create Lead Sharing for only those Records where Owner is 
                                                  Partner Queue and delete the sharing if The Ownership is changed to Non-Partner User Or Queue. 
 | 30/08/2011      Anirudh Singh                  Updated Code to Create Sharing for Deal Reg Records if they are being created from
                                                  PowerLink as well.                                                                                                                                      
 +=============================================================================*/
 
 public  class PRM_PortalVisibility{
 
 PRM_RecordsVisibility recVisObj = new PRM_RecordsVisibility();
 
 
 /**
        * Method <setVisibility(Map<Id,Lead> oldLeadMap ,Map<Id,Lead> newLeadMap)
            is set Leads visibility between tier1/tier2 partner accounts >
        *   @param <This method is taking Map<Id,Lead> old map from trigger as a argument.> 
        *   @param <This method is taking Map<Id,Lead> new map from trigger as a argument.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
  */
    public  void setVisibility(Map<Id,Lead> oldLeadMap ,Map<Id,Lead> newLeadMap){
     
        Map<ID,List<Id>> leadsUpdateTrack = new Map<ID,List<Id>>();
        Map<ID,List<Id>> leadsDeleteTrack = new Map<ID,List<Id>>();
        List<Id> oldAccIds = new List<Id>();
        List<Id> newAccIds = new List<Id>();

        Map<Id,Lead> oldValidLeadMap = new Map<Id,Lead>();
        //hold list of Lead owner id's 
        List<String> leadOwneridsList = new List<String>();
        //hold set of partner user id 
        Set<String> partnerUseridsSet = new Set<String>();
        //hold Lead owner id 
        String strLeadOwnerId ='';
        //hold Lead Owner Queue Ids
        Map<Id,Id> MapLeadOwnerQueueIds = New Map<Id,Id>();
        //hold Lead Owner Partner Queue Ids
        Set<Id> SetPartnerQueueIds = New Set<Id>();
        //hold value of Site User from Custom Setting
        Map<String, CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        Id SiteUserId = DataValueMap.get('SiteUserId').DataValue__c;
        
        if(newLeadMap != null){
            //fetch all lead owner into set
            for(Lead leadObj: newLeadMap.values()){
                if(leadObj.OwnerId != null){ 
                    strLeadOwnerId = leadObj.OwnerId;
                    if(strLeadOwnerId.substring(0,3) !='00G'){
                        leadOwneridsList.add(leadObj.OwnerId);   
                    } 
                    if(strLeadOwnerId.substring(0,3) =='00G'){
                        MapLeadOwnerQueueIds.put(leadObj.OwnerId,leadObj.Id);    
                    }
                }       
            }       
        }
        System.Debug('MapPartnerQueueIDsByAnirudh--->' +MapLeadOwnerQueueIds);
        Map<Id,QueueSobject> MapPartnerQueue = New Map<Id,QueueSobject>([Select Id, SobjectType, QueueId, Queue.Name from QueueSobject where Queue.Name like'Partner%' and QueueId in :MapLeadOwnerQueueIds.keyset()]);
        for(QueueSobject queueObj :MapPartnerQueue.values()){
            SetPartnerQueueIds.add(queueObj.QueueId);
        }
        System.Debug('MapPartnerQueueByAnirudh--->' +MapPartnerQueue);
        if(oldLeadMap != null){
            //fetch all lead owner into set
            for(Lead leadObj: oldLeadMap.values()){
                if(leadObj.OwnerId != null){ 
                    strLeadOwnerId = leadObj.OwnerId;
                    if(strLeadOwnerId.substring(0,3) !='00G'){
                        leadOwneridsList.add(leadObj.OwnerId);   
                    } 
                }       
            }       
        }
         
         //get all user ids set using lead owner set
        PRM_CommonUtils prmCommUtilObj = new PRM_CommonUtils();    
        partnerUseridsSet = prmCommUtilObj.userType(leadOwneridsList); 
        //Adding Site User also to PartnerUserIdsSet
        partnerUseridsSet.add(SiteUserId);
        
        //create a map of lead to setVisibility which contains lead owner is Queue  OR partner Type user
        /*  */
        for(Lead nextLead: newLeadMap.Values()){    
            newAccIds = new List<Id>();
            oldAccIds = new List<Id>();
            
            // lead update case   
            if(oldLeadMap !=null){ 
                //check if lead owner is changed or Tier 1 Partner values changed       
                if((nextLead.Partner__c != oldLeadMap.get(nextLead.Id).Partner__c) || (nextLead.OwnerId != oldLeadMap.get(nextLead.Id).OwnerId))
                {   
                    //check for Tier 1 Partner is not null and Lead Owner is Partner Type or Queue
                    // add Tier 1 Partner into set of account for create
                    strLeadOwnerId = nextLead.OwnerId;
                    if((nextLead.Partner__c !=null) && ((partnerUseridsSet.contains(nextLead.OwnerId)) || SetPartnerQueueIds.contains(strLeadOwnerId))){
                        newAccIds.add(nextLead.Partner__c);
                    }
                    //check for Tier 1 Partner is not null 
                    // add Tier 1 Partner into set of account for delete
                    if(oldLeadMap.get(nextLead.Id).Partner__c !=null){
                        oldAccIds.add(oldLeadMap.get(nextLead.Id).Partner__c);
                    }
                }
                //check if lead owner is changed or Tier 2 Partner values changed 
                if ((nextLead.Tier_2_Partner__c != oldLeadMap.get(nextLead.Id).Tier_2_Partner__c ) || (nextLead.OwnerId != oldLeadMap.get(nextLead.Id).OwnerId))
                {
                    //check for Tier 2 Partner is not null and Lead Owner is Partner Type or Queue
                    // add Tier 1 Partner into set of account for create
                    strLeadOwnerId = nextLead.OwnerId;
                    System.Debug('strLeadOwnerIdByAnirudh--->' +strLeadOwnerId);
                    System.Debug('MapConditionCheckByAnirudh--->' +MapPartnerQueue.containskey(strLeadOwnerId));                
                    if((nextLead.Tier_2_Partner__c !=null) && ((partnerUseridsSet.contains(nextLead.OwnerId)) || SetPartnerQueueIds.contains(strLeadOwnerId)))
                        newAccIds.add(nextLead.Tier_2_Partner__c);
                        
                    //check for Tier 2 Partner is not null 
                    // add Tier 2 Partner into set of account for delete
                    if(oldLeadMap.get(nextLead.Id).Tier_2_Partner__c !=null)
                        oldAccIds.add(oldLeadMap.get(nextLead.Id).Tier_2_Partner__c);
                    
                }               
            }
            //lead insert case 
            else{
                //check for Tier 1 Partner is not null and Lead Owner is Partner Type or Queue
                // add Tier 1 Partner into set of account for create
                if((nextLead.Partner__c !=null) && ((partnerUseridsSet.contains(nextLead.OwnerId)) || SetPartnerQueueIds.contains(strLeadOwnerId)))
                    newAccIds.add(nextLead.Partner__c);
                
                //check for Tier 2 Partner is not null and Lead Owner is Partner Type or Queue
                // add Tier 1 Partner into set of account for create   
                if((nextLead.Tier_2_Partner__c !=null) && ((partnerUseridsSet.contains(nextLead.OwnerId)) || SetPartnerQueueIds.contains(strLeadOwnerId)))
                    newAccIds.add(nextLead.Tier_2_Partner__c);
             
            }
            strLeadOwnerId = nextLead.OwnerId;         
            if(oldAccIds.size()>0 && (!SetPartnerQueueIds.contains(strLeadOwnerId) || !partnerUseridsSet.contains(nextLead.OwnerId)) ){
                if(leadsDeleteTrack.get(nextLead.Id) !=null){
                    for(Id nextId :oldAccIds)
                        leadsDeleteTrack.get(nextLead.Id).add(nextId);
                }          
                else{
                   leadsDeleteTrack.put(nextLead.Id ,oldAccIds);
                }           
            }
              
            if(newAccIds.size()>0){
                if(leadsUpdateTrack.get(nextLead.Id) !=null){
                    for(Id nextId :newAccIds)
                        leadsUpdateTrack.get(nextLead.Id).add(nextId);
                }
                else{
                    leadsUpdateTrack.put(nextLead.Id ,newAccIds);
                }
            }     
        }
      
         
        // delete the visibility of lead from previous partner accounts
        if(leadsDeleteTrack.size()>0)
            this.recVisObj.removeLeadAssociation(leadsDeleteTrack);
             
        // set the visibility of lead to new tier1/tier2 partner accounts
        if(leadsUpdateTrack.size()>0)
            this.recVisObj.createLeadAssociation(leadsUpdateTrack);
     
    }    
}