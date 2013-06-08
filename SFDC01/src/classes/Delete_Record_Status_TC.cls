@isTest
private class Delete_Record_Status_TC {  

    static testMethod void deleteRecords()
    {
        Delete_Record_Status deleteRecord = new Delete_Record_Status();
        String id ='1234';
        boolean isSucess = true;
        String keyCol = 'Test';
        String ErrorDescription = 'Description';
        deleteRecord.getId();
        deleteRecord.getIssucess();
        deleteRecord.getKeycol();
        deleteRecord.getErrorDescription();
        deleteRecord.setId(id);
        deleteRecord.setIssucess(isSucess);
        deleteRecord.setKeycol(keyCol);
        deleteRecord.setErrorDescription(ErrorDescription);
    }
}