/*
    This trigger will set the transfer field on the case object
    to true if the case origin is EMC.
*/

trigger VCECaseSetTransferTrigger on Case (before insert,before update) {
    String recType = VCEStatic__c.getInstance('VCECaseRecordType').Value__c;
    for(Case c: Trigger.New)
    {
        if(c.RecordTypeId == recType &&
                    c.Origin == 'EMC' && c.VCE_Transfer__c != true)
        {
            c.VCE_Transfer__c = true;
        }
    }
 }