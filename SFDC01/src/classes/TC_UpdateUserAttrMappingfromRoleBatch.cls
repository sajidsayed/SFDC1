/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    06-Sep-2010     Pratibh Prakash         136350          Test Class for UpdateUserAttrMappingfromRoleBatch Batch class.
==============================================================================*/
@isTest
private class TC_UpdateUserAttrMappingfromRoleBatch {
    private static testMethod void testUpdateUserAttrMappingfromRoleBatch(){
        
        String query = 'Select Id, Name, Role_Id__c from User_Attribute_Mapping__c limit 10';
        System.debug('Query is---->'+Query);
        
        UpdateUserAttrMappingfromRoleBatch userAttrBatch = new UpdateUserAttrMappingfromRoleBatch(query);     
        userAttrBatch.Query = query; 
        Test.startTest();
        ID batchprocessid = database.executebatch(userAttrBatch);
                
        Test.stopTest();
    } 
}