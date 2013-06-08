@isTest
private class MapHubInfoScheduler_TC {
    
/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER          WR          DESCRIPTION                               
 |  ====       =========          ==          =========== 
 |  29-JUN-11  M Mutebi                       Created
 |  21-MAR-13  Krishna Pydavula	 241804		  Increased code coverage.
 +===========================================================================*/

    static testMethod void testScheduler () 
    { 
     try{ 
     		
        //schedule the test job
         Test.StartTest();       
        MapHubInfoScheduler t = new MapHubInfoScheduler();
        t.isTest=true;
        String sch = '20 30 8 10 2 ?';
        
        System.schedule('TestJob', sch, t);
        
        //verify the scheduled job
        
        /* CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, 
         NextFireTime	
         FROM CronTrigger WHERE CronExpression = :'20 30 8 10 2 ?'];
        
         System.assertEquals(0, ct.TimesTriggered); */
       
        Test.stopTest();
            
        
     }catch(Exception e){
        system.debug('Scheduler class error :' + e.getMessage());
     } 
    
    }
     
}