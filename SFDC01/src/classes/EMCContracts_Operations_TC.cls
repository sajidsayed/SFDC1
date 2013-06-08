@isTest
Private Class EMCContracts_Operations_TC{
    Private static testMethod void startTest(){
        EMC_Contracts__c[] installBase;
        List<EMC_Contracts__c> emcContract=[Select Keycol__c from EMC_Contracts__c limit 5];
        EMC_Contracts__c newRecord=new EMC_Contracts__c(
                                                    Keycol__c='XXX'
                                                    );
        //insert newRecord;                                            
        emcContract.add(newRecord);
        Delete_Record_Status[] status=EMCContracts_Operations.deleteEMCContractsRecord(emcContract);
        for(integer i=0;i<status.size();i++){
            System.debug(status[i]);
        }
    }
}