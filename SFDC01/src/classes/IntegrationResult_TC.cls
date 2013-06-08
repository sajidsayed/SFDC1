@isTest
Private Class IntegrationResult_TC{
    Private static testMethod void startTest(){
        Boolean issucs=true;
        String ErrMess='Error';
        String SfdcOppid='006S0000002nga0IAA';
        String SynoppId='1234567';
        IntegrationResult Int1=new IntegrationResult();
        IntegrationResult Intresult=new IntegrationResult(issucs,ErrMess,sfdcoppid,SynoppId);
        Intresult.getErrorMessage();
        Intresult.getSFDCOpportunityId();
        Intresult.getSynergyOpportunityId();
        Intresult.getIsSuccess();
        Intresult.setIsSuccess(True);
        Intresult.setErrorMessage('Error');
        Intresult.setSFDCOpportunityId('006S0000002nga0IAA');
        Intresult.setSynergyOpportunityId('1234567');
    }
}