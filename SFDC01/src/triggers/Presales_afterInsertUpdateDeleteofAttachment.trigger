/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  30/12/2011     Shalabh Sharma       Trigger to map the details of attachments on Opportunity to Opportunity Reporting                                             
 +==================================================================================================================**/
trigger Presales_afterInsertUpdateDeleteofAttachment on Attachment (before delete, after insert, after update) {
    Presales_OpportunityReporting objAttmt= new Presales_OpportunityReporting();
    if(trigger.isInsert){
        objAttmt.mapAttachmentDetailsOnInsert(trigger.newMap);  
    }
    
    if(trigger.isUpdate){
        Map<Id,Attachment> mapUpdatedAttachment = new Map<Id,Attachment>();
        for(Attachment attmt:trigger.newMap.values()){
            if(attmt.IsPrivate!=trigger.oldMap.get(attmt.Id).IsPrivate ||attmt.Description!=trigger.oldMap.get(attmt.Id).Description ||
               attmt.Name!=trigger.oldMap.get(attmt.Id).Name){
                mapUpdatedAttachment.put(attmt.Id,attmt);       
            }
        }
        objAttmt.mapAttachmentDetailsOnUpdate(mapUpdatedAttachment,false);  
    }
    
    if(trigger.isDelete){
        objAttmt.mapAttachmentDetailsOnUpdate(trigger.oldMap,true); 
    }   
}