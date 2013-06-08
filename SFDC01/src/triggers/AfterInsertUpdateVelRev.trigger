/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 18/05/2011     Anil Sure      2829    This trigger used to invoke methods of PRM_VelocityRevenueOperations class                                          
 +==================================================================================================================**/

trigger AfterInsertUpdateVelRev on Velocity_Revenue__c (after insert, after update) {
    PRM_VelocityRevenueOperations obj1=new PRM_VelocityRevenueOperations();
    List<Velocity_Revenue__c> VelocityRevIds = new List<Velocity_Revenue__c>();
    //Insert
    if(trigger.isInsert)
    {
    obj1.updatevelocityRevenueProfiledAccount(trigger.new);
    }
    //Update
    if(trigger.isUpdate)
    { 
    for(Velocity_Revenue__c newRev :Trigger.new){
        Velocity_Revenue__c oldRev= Trigger.oldMap.get(newRev.Id);
        if(oldRev.Total_Product_Curr_Per_Rev_HW_SW__c!=newRev.Total_Product_Curr_Per_Rev_HW_SW__c || 
            oldRev.Total_Product_Prev_Per_Rev_HW_SW__c!=newRev.Total_Product_Prev_Per_Rev_HW_SW__c ||
            oldRev.Total_Services_Curr_Per_Rev_SVS__c!=newRev.Total_Services_Curr_Per_Rev_SVS__c ||
            oldRev.Total_Services_Prev_Per_Rev_SVS__c!=newRev.Total_Services_Prev_Per_Rev_SVS__c 
          ){
              VelocityRevIds.add(newRev);              
          }            
    }
    }
    if(VelocityRevIds.size()>0)
    {
        obj1.updatevelocityRevenueProfiledAccount(VelocityRevIds);
    }
    
}