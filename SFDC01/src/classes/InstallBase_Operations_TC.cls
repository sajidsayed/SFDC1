@isTest
private class InstallBase_Operations_TC {  

    static testMethod void installBaseOperation()
    {
        Install_Base__c[] installBase;
        List<Install_Base__c> emcContract=[Select Keycol__c from Install_Base__c limit 5];
        Install_Base__c newRecord=new Install_Base__c(
                                                    Keycol__c='XXX'
                                                    );
        insert newRecord;                                            
        emcContract.add(newRecord);
        Delete_Record_Status[] status=InstallBase_Operations.deleteInstallBaseRecord(emcContract);
        for(integer i=0;i<status.size();i++){
            System.debug(status[i]);
        }

    }

}