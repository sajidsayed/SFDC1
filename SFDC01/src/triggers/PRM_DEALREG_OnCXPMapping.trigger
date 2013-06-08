/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  18 May 2011        Arif                    This trigger is used to insert record in Outbound Message Log Object
                                               on insertion,updation,deletion of CXP Mapping Record.
 +=========================================================================================================================*/
trigger PRM_DEALREG_OnCXPMapping on CxP_Mapping__c (after insert,before update,before delete) {
    PRM_DEALREG_CXPMappingOperation cxpMapping = new PRM_DEALREG_CXPMappingOperation();
    if(Trigger.isInsert || Trigger.isUpdate){
        cxpMapping.insertOutboundMessageLogRecord(Trigger.New,'Upsert CXP Mapping');
    }
    if(Trigger.isDelete){
        cxpMapping.insertOutboundMessageLogRecord(Trigger.old,'Delete CXP Mapping');
    }
}