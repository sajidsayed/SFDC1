/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              Initial Creation.
 |  Aug-2011        Saravanan C         		Test Class cleanup
 |  
 +===========================================================================*/
@isTest
Private Class OpportunityDetails_TC{
    Private static testMethod void startTest(){
        Opportunity Opp= testclassUtils.getOppty ();
        insert Opp;
        OpportunityDetails Oppdetail=new OpportunityDetails(Opp.id);
        Oppdetail.getPOpptyHeaderBo();
        Oppdetail.getPOpptyProductBoTblItem();
        Oppdetail.getPOpptyCreaditsBoTblItem();
    }
}