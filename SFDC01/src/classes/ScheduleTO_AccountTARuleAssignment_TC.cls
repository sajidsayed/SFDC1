/*    
    Created By:     Karthik    
    Created Date:   09 June 2010
    Description :   Test class for schedule the batch TO_AccountTARuleAssignment for the public and private groups
    05-Jan-2011     Srinivas Nallapati						Removed year (2010) from the cron expression paremeter of the System.Schedule method call
*/

@istest
class ScheduleTO_AccountTARuleAssignment_TC
{
    static testmethod void Test() {
        Test.startTest();
        String jobId = System.schedule('Test','0 0 20 * * ?',new ScheduleTO_AccountTARuleAssignment());
        Test.stopTest();
    }
}