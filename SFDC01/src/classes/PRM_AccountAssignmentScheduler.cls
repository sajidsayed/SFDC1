/*=====================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 16/9/2010      Karthik Shivprakash      1070          This class is used to create the 
                                                        account share between the associated accounts.
                                                        
| 29/9/2010      Karthik Shivprakash      Defect#129    The method createAccountShare is updated to 
                                                        create account share for the accounts based 
                                                        on the associations created between the 
                                                        respective accounts.
| 30/9/2010      Prasad Kothawade         Defect#135    Sharing is not getting created on porifield 
                                                        account to access to non profiled account. 
| 04/10/2010     Prasad Kothawade         Defect#       Moved the code class PRM_AccountAssociationBatch.  
                                                                                              
+=====================================================================================================*/



global class PRM_AccountAssignmentScheduler implements Schedulable{


/* @Method <This method execute is used to create sharing records between the 
            associated accounts.This is schedular class which is scheduled 
            automatically using custom setting>
@param <SchedulableContext to keep track of the scheduled job once it's scheduled>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    global void execute(SchedulableContext SC){
        try 
        {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null)
            {
                System.abortJob(ct.Id);
            }
        }
        catch(Exception e) 
        {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        PRM_AccountAssociationBatch AccosiciationBatch = new PRM_AccountAssociationBatch();
        database.executebatch(AccosiciationBatch);
    }
       
}