/*===========================================================================+
 |  HISTORY      
 |                                                                           
 |  DATE       DEVELOPER             DESCRIPTION                               
 |  ====       =========             =========== 
 |            Saravanan C            Initial creation
    8/10/2010 Ashwini Gowda          Created Method beforeInsert() to be invoked in case
                                     of Lead Insert by LeadBeforeInsert Trigger.
   25/10/2010 Ashwini Gowda Req#1144 Updated beforeUpdate() Method.Create a validation
                                     that won't allow a user to reject a lead and close
                                     the lead at the same time
   30/05/2011 Anand Sharma           Added NOT into check flag processLeadUpdatesHasRun in beforeInsert method.
   15/10/2102 Suresh Dornadula       Added logic to handle dataloader batch                               
 +===========================================================================*/
public class LeadBeforeUpdateTrigger {
  
  static Boolean processLeadUpdatesHasRun = false;
  static Boolean processLeadUpdatesHasRunBatch = false;
    string Errormessage;
    
    /* @Method <This method is called from LeadBeforeInsert Trigger>.
   @param <newLeadList:List of Leads newly created>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void beforeInsert(List<Lead> newLeadList) {
    
      if(newLeadList.size()>0 && !processLeadUpdatesHasRun){
        System.debug('Entering before Insert processLeadUpdatesHasRun  '+processLeadUpdatesHasRun);
          System.debug('newLeadList --- '+newLeadList);
          processLeadUpdatesHasRun = true;
          if(newLeadList.size()>0){
            for(lead l: newLeadList){
                if(l.LastName == null || l.LastName == '' || l.Company == null || l.Company == ''){
                    processLeadUpdatesHasRun = false;
                    processLeadUpdatesHasRunBatch = true; 
                    break;
                }
            }
          }
          PRM_PopulatePartnerOnLead updatePartner = new PRM_PopulatePartnerOnLead();   
          updatePartner.populatePartneronLead(newLeadList);
          updatePartner.setPassToPartnerFlagOnLead(newLeadList);
      }
    }
    
    /* @Method <This method is called from LeadBeforeUpdate Trigger>.
   @param <Map<Id,Lead> oldLeadMap,Map<Id,Lead> newLeadMap>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void beforeUpdate(Map<Id,Lead> oldLeadMap,Map<Id,Lead> newLeadMap) {
        
     //Add error message if Lead status is getting closed reject lead is checked at same time.
      for(Lead lead: newLeadMap.values()){
        if(lead.Reject_Lead__c==true && lead.Status=='Closed'){
            lead.addError(System.Label.Reject_And_Close_Lead_Same_Time); 
        }
      }      
     System.debug('Entering processLeadUpdatesHasRun  '+processLeadUpdatesHasRun);
     
     
     if (!processLeadUpdatesHasRun && !processLeadUpdatesHasRunBatch){
            System.debug('Executing processLeadUpdatesHasRun  '+processLeadUpdatesHasRun);
            processLeadUpdatesHasRun = true;
     /*****  Start Execute *****/
      // PRM Default Patnerng
      List<Lead>SetPartneronLeads=new List<Lead>();
      if(oldLeadMap!=null){
          for(Lead lead:newLeadMap.Values()){
              if(lead.ownerId != (oldLeadMap.get(lead.Id)).ownerId){
                  SetPartneronLeads.add(lead);
              }
          }
      }
      System.debug('SetPartneronLeads size is  '+SetPartneronLeads.size());
      if(SetPartneronLeads.size()>0){
          System.debug('SetPartneronLeads list is  '+SetPartneronLeads);
          PRM_PopulatePartnerOnLead updatePartner = new PRM_PopulatePartnerOnLead();   
          updatePartner.populatePartneronLead(SetPartneronLeads);
          updatePartner.setPassToPartnerFlagOnLead(SetPartneronLeads);
     }    
         
     }//If Closing
     
    }//Method Closing
    
     
       
}//Class Closing