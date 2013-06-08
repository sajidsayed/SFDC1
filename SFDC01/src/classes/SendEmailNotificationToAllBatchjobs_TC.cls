/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
| 11/01/2012    Vivekananda             197607          TestClass for SendEmailNotificationToAllBatchjobs
                                                                                                          
+=====================================================================================================*/


@isTest
private class SendEmailNotificationToAllBatchjobs_TC {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        SequencialBatchJobScheduler SeqBatch = new SequencialBatchJobScheduler();
        String batchid = Database.executeBatch(SeqBatch);
               
        System.Test.startTest();
        SendEmailNotificationToAllBatchjobs SendEmail = new SendEmailNotificationToAllBatchjobs();
        List<EMCException> errorexp  = new LIst<EMCException>();
         errorexp.add(new EMCException('Checkingtesting',batchid , new String [] {'00000044444aq','00000333333fd'}));
         errorexp.add(new EMCException('Checkingtesting',batchid , new String [] {'00000044444aq','00000333333fd'}));
        SendEmailNotificationToAllBatchjobs.EmailProcessor(batchid,errorexp);
        List<string> collection=new List<string>();
        collection.add('test');
        collection.add('test1');
        SendEmailNotificationToAllBatchjobs.ListAsString(collection,'test');
        System.Test.stopTest();
    }
}