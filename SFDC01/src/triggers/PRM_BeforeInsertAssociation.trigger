/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 23/11/2010      Karthik Shivprakash     846       This is used trigger is used to   
                                                     get the newly created association 
 |                                                   accounts list.
   01/Mar/2010     Anirudh Singh           1828      Updated trigger to incorporate the logic
 |                                                   to check if there is only one preferred group on a Account.                                                                        
 +===========================================================================*/

trigger PRM_BeforeInsertAssociation on APPR_MTV__RecordAssociation__c (before insert) {

//Here we are creating the instance of the class PRM_GroupingAssociation
PRM_GroupingAssociation associationObj = new PRM_GroupingAssociation();
    
    if(Trigger.isInsert){
        System.debug('Trigger Map values'+Trigger.new);
        //Calling the method fetchAssociatedAccount from the class PRM_GroupingAssociation
        associationObj.fetchAssociatedAccount(Trigger.new);
        //Calling the method PreferredDistributorCheck for the newly inserted associations.
        associationObj.PreferredDistributorCheck(Trigger.new);
    }
    if(Trigger.isUpdate){
       associationObj.PreferredDistributorCheck(Trigger.new); 
    }
}