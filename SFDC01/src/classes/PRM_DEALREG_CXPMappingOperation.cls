/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  18 May 2011        Arif                    This class is used to insert the record in Outbound Message Log Object
                                               when any record of CXP Mapping is inserted,updated,deleted.
 +=========================================================================================================================*/
public class PRM_DEALREG_CXPMappingOperation {
    
/*@Method <This method is used to insert the record in Outbound Message Log Object on insertion,updation,deletion of CXP Mapping record.>
@param <This method takes list<CxP_Mapping__c> and operation as a parameter.>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/
    public void insertOutboundMessageLogRecord(List<CxP_Mapping__c> lstCXPMappingRecord,String Operation){
        List<Outbound_Message_Log__c> lstOutboundMessageLogRecord = new List<Outbound_Message_Log__c>();
        Outbound_Message_Log__c OutboundMessageLogRecord = new Outbound_Message_Log__c();
        if(lstCXPMappingRecord != null){
            for(CxP_Mapping__c cxpRecord: lstCXPMappingRecord){
                OutboundMessageLogRecord.RecordId__c = cxpRecord.Id;
                OutboundMessageLogRecord.Integration_Operation__c = Operation;
                lstOutboundMessageLogRecord.add(OutboundMessageLogRecord);
            }
            if(lstOutboundMessageLogRecord != null){
                insert lstOutboundMessageLogRecord;
            }
        } 
    }
}