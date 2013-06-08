@isTest
Private Class OpptyCreditsTbl_TC{
    Private static testMethod void startTest(){
        OpptyCreditsTbl OppCredit=new OpptyCreditsTbl();
        Opportunity Opp=[Select id from Opportunity limit 1];
        OppCredit.getCreditSplit(Opp.id);
        OppCredit.getSfdcUserId();
        OppCredit.getCreditPercent();
        OppCredit.setSfdcUserId(Opp.id);
        OppCredit.setCreditPercent(12);
    }
}