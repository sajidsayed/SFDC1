/*
    Created By:     Karthik
    Created Date:   18 May 2010
    Description :   To schedule the batch TO_AccountTARuleAssignment for the public and private groups
*/

global class ScheduleTO_AccountTARuleAssignment implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        TO_AccountTARuleAssignment Tobj = new TO_AccountTARuleAssignment();
        database.executebatch(Tobj); 
    }
}