/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 
 | 21/02/2011     Anirudh                  1828      This trigger is used to   
 |                                         1829      call the method of PRM_GroupingAssociation
 |                                         1598      class to process Profiled Account level Associations.    
 +===========================================================================*/

trigger PRM_AfterInsert on APPR_MTV__RecordAssociation__c (after insert) {    
   static integer i=0;
   PRM_GroupingAssociation association = New PRM_GroupingAssociation();   
   if(!PRM_RecordsVisibility.isInsertEventExecuted){ 
    if(i==0){
       i++;       
       association.createAccountMap(Trigger.New);
       PRM_RecordsVisibility objPRMVisibility = new PRM_RecordsVisibility();            
      }  
    }
    if(!PRM_RecordsVisibility.isInsertEventExecuted){
        PRM_RecordsVisibility objPRMVisibility = new PRM_RecordsVisibility();
        PRM_RecordsVisibility.isInsertEventExecuted = true;            
        objPRMVisibility.createAssociationDistributorT2VAR(Trigger.new);
    }       
}