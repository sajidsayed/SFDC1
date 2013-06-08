/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
|11 Sep 2012    Vivekananda             204934          SFA - Bug Fix for Batch Job that Removes Inactive Account Team Members.
                                                              Test Class for Schedule_ToDeleteInactiveAccountTeamMemb                                                
+=====================================================================================================*/
@isTest
private class Schedule_ToDeleteInactiveAccount_TC {

    static testMethod void ScheduleToDelete() {
            
            RunInactiveATbatch__c RIA = new RunInactiveATbatch__c(Name='FlagStatus',StatusFlag__c=true); 
            Database.insert(RIA,false);
            ATMLimit__c atlmt = new ATMLimit__c(LimitNumber__c ='100');
            Database.insert(atlmt,false);
            Schedule_ToDeleteInactiveAccountTeamMemb sh1 = new Schedule_ToDeleteInactiveAccountTeamMemb();        
            String sch = '0 0 23 * * ?';
            System.Test.startTest();
            system.schedule('Test Territory Check', sch, sh1);
            System.Test.stopTest();
            RIA.StatusFlag__c = true;
            Database.update(RIA,false);
    }
}