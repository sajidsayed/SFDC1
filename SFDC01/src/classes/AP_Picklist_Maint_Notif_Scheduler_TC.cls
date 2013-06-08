/* =====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  31.12.2012      Avinash K       213868      Initial Creation.  Test class for AP_Picklist_Maint_Notif_Scheduler class.
 +=====================================================================================================================*/

@isTest(SeeAllData=true)
private class AP_Picklist_Maint_Notif_Scheduler_TC { 

 private static testmethod void TestAP_Picklist_Maint_Notif_Scheduler() {
    Test.StartTest();
    String sch = '0 0 0 4 10 ?' ;
    
    try{
    system.schedule('Test AP_Picklist_Maint_Notif_Scheduler_TC', sch, new AP_Picklist_Maint_Notif_Scheduler());
    
    } catch(Exception e) {
      system.debug('Exception Inside AP_Picklist_Maint_Notif_Scheduler_TC()' + e );   
     }
    Test.StopTest();
  }
}