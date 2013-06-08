/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 
 
 | 09/09/2010     Anand Sharma                      Trigger to use create and delete association between distributor and Tier2 account
   17/02/2011     Anirudh Singh            1828     Commented Code as this Code has been Moved to PRM_AfterInsert
 |                                                  Trigger on Associations.  
 +===========================================================================*/

trigger PRM_AccountAssociations on APPR_MTV__RecordAssociation__c ( before insert, after update) {
    
    System.debug('in PRM_AccountAssociation trigger');
    PRM_RecordsVisibility objPRMVisibility = new PRM_RecordsVisibility();
    /*
    if(Trigger.isInsert) {
        System.debug('in is insert section...');  
        if(!PRM_RecordsVisibility.isInsertEventExecuted){
            PRM_RecordsVisibility.isInsertEventExecuted = true;
            System.debug('in is insert section. second time..'); 
            objPRMVisibility.createAssociationDistributorT2VAR(Trigger.new);
        }       
    }
    if(Trigger.isUpdate){
        System.debug('in is update section...');
        Commented by Anirudh
        objPRMVisibility.deleteAssociationDistributorT2VAR(Trigger.old);
        objPRMVisibility.createAssociationDistributorT2VAR(Trigger.new);
    }  
   */  
}